create or replace package body crd_api_report_pkg is
/************************************************************
* Reports for Credit module <br />
* Created by Mashonkin V.(mashonkin@bpcbt.com) at 06.03.2014  <br />
* Module: CRD_API_REPORT_PKG <br />
* @headcom
************************************************************/

procedure run_report(
    o_xml                  out  clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_mode              in      com_api_type_pkg.t_dict_value    default crd_api_const_pkg.CREDIT_STMT_MODE_DATA_ONLY
) is
    l_header                    xmltype;
    l_detail                    xmltype;
    l_result                    xmltype;

    l_account_id                com_api_type_pkg.t_account_id;
    l_invoice_date              date;
    l_start_date                date;
    l_lag_invoice               crd_api_type_pkg.t_invoice_rec;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_currency                  com_api_type_pkg.t_dict_value;
    l_currency_name             com_api_type_pkg.t_dict_value;

    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_lty_account_id_tab        num_tab_tpt := num_tab_tpt();
    l_lty_account               acc_api_type_pkg.t_account_rec;
    l_loyalty_currency          com_api_type_pkg.t_curr_code := com_api_const_pkg.UNDEFINED_CURRENCY;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_loyalty_incoming          com_api_type_pkg.t_money;
    l_loyalty_earned            com_api_type_pkg.t_money;
    l_loyalty_spent             com_api_type_pkg.t_money;
    l_loyalty_expired           com_api_type_pkg.t_money;
    l_loyalty_outgoing          com_api_type_pkg.t_money;
    l_card_mask                 com_api_type_pkg.t_card_number;
    l_network_id                com_api_type_pkg.t_network_id;
    l_total_instalment_amount   com_api_type_pkg.t_money;
    l_debt_id                   com_api_type_pkg.t_long_id;
    l_interest_amount           com_api_type_pkg.t_money;
    l_card_tab                  iss_api_type_pkg.t_card_tab;
    l_dpp_account_id_tab        num_tab_tpt                     := num_tab_tpt();
    l_dpp_account_tab           com_api_type_pkg.t_number_tab;
    l_dpp_account_id            com_api_type_pkg.t_account_id;
    l_total_dpp_amount          com_api_type_pkg.t_money;
    l_prev_invoice_rec          crd_api_type_pkg.t_invoice_rec;
    l_dpp_incoming_balance      com_api_type_pkg.t_money;
    l_dpp_outgoing_balance      com_api_type_pkg.t_money;
    l_account_rec               acc_api_type_pkg.t_account_rec;
    l_invoice_rec               crd_api_type_pkg.t_invoice_rec;

    procedure get_prev_invoice_data(
        i_account_id            in com_api_type_pkg.t_account_id
      , i_invoice_id            in com_api_type_pkg.t_medium_id
      , o_prev_invoice_rec      out crd_api_type_pkg.t_invoice_rec
      , o_start_date            out date
    ) is
    begin
        -- get previous invoice
        begin
            select i1.id
                 , i1.account_id
                 , i1.serial_number
                 , i1.invoice_type
                 , i1.exceed_limit
                 , i1.total_amount_due
                 , i1.own_funds
                 , i1.min_amount_due
                 , i1.invoice_date
                 , i1.grace_date
                 , i1.due_date
                 , i1.penalty_date
                 , i1.aging_period
                 , i1.is_tad_paid
                 , i1.is_mad_paid
                 , i1.inst_id
                 , i1.agent_id
                 , i1.split_hash
                 , i1.overdue_date
                 , i1.start_date
              into o_prev_invoice_rec
              from crd_invoice_vw i1
                 , (select a.id
                         , lag(a.id) over (order by a.invoice_date) lag_id
                      from crd_invoice_vw a
                     where a.account_id = l_account_id
                   ) i2
             where i1.id = i2.lag_id
               and i2.id = i_invoice_id;
        exception
            when no_data_found then
                trc_log_pkg.debug (
                    i_text  => 'Previous invoice not found'
                );
        end;

        -- calc start date
        if l_lag_invoice.id is null then
            begin
                select o.start_date
                  into o_start_date
                  from prd_service_object o
                     , prd_service s
                 where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and object_id         = i_account_id
                   and s.id              = o.service_id
                   and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error (
                        i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                      , i_env_param1    => i_account_id
                      , i_env_param2    => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                    );
            end;
        else
            o_start_date := l_lag_invoice.invoice_date;
        end if;
    end get_prev_invoice_data;
begin
    l_lang := nvl(i_lang, get_user_lang);

    trc_log_pkg.debug (
        i_text          => 'Run statement report: lang [#1], invoice [#2], mode [#3]'
        , i_env_param1  => i_lang
        , i_env_param2  => i_invoice_id
        , i_env_param3  => i_mode
    );

    l_lag_invoice := null;

    l_invoice_rec := 
        crd_invoice_pkg.get_invoice(
            i_invoice_id    => i_invoice_id
        );

    l_account_id        := l_invoice_rec.account_id;
    l_invoice_date      := l_invoice_rec.invoice_date;
    l_inst_id           := l_invoice_rec.inst_id;

    begin
        select c.card_mask
             , c.network_id
          into l_card_mask
             , l_network_id
          from (select c.card_mask
                     , b.network_id
                  from acc_account_object o
                     , iss_card c
                     , iss_card_instance i
                     , iss_bin b
                 where o.account_id  = l_account_id
                   and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and c.id          = o.object_id
                   and c.id          = i.card_id
                   and i.bin_id      = b.id
                   and i.id          = iss_api_card_instance_pkg.get_card_instance_id (i_card_id => c.id)
              order by decode(i.status, iss_api_const_pkg.CARD_STATUS_VALID_CARD, 1, 2)
                     , decode(c.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 1, 2)
                     , i.reg_date
               ) c
         where rownum = 1;
    exception
        when no_data_found then
            l_card_mask  := null;
            l_network_id := null;
    end;

    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_account_id          => l_account_id
          , i_mask_error          => com_api_const_pkg.FALSE
        );

    l_currency      := l_account_rec.currency;
    l_split_hash    := l_account_rec.split_hash;

    get_prev_invoice_data(
        i_account_id        => l_account_id
      , i_invoice_id        => i_invoice_id
      , o_prev_invoice_rec  => l_prev_invoice_rec
      , o_start_date        => l_start_date
    );

    l_currency_name :=
        com_api_currency_pkg.get_currency_name(
            i_curr_code     => l_currency
        );

    if i_mode in (
        crd_api_const_pkg.CREDIT_STMT_MODE_FULL
      , crd_api_const_pkg.CREDIT_STMT_MODE_DATA_N_DPP
    ) then
        begin
            select debt_id
                 , interest_amount
              into l_debt_id
                 , l_interest_amount
              from (
                select debt_id
                     , sum(nvl(interest_amount, 0)) as interest_amount
                     , nvl(sum(decode(nvl(i.is_waived, com_api_const_pkg.FALSE)
                                , com_api_const_pkg.TRUE, interest_amount
                               )
                       ), 0) as waive_interest_amount
                  from crd_debt_interest i
                 where invoice_id = i_invoice_id
                   and split_hash = l_split_hash
                   and is_charged = com_api_const_pkg.TRUE
                 group by debt_id
            ) i;
        exception
            when no_data_found then
                null;
        end;

        l_card_tab :=
            iss_api_card_pkg.get_card(
                i_account_id    => l_account_id
              , i_split_hash    => l_split_hash
              , i_state         => iss_api_const_pkg.CARD_STATE_ACTIVE
            );

        if l_card_tab.count > 0 then
            for i in 1 .. l_card_tab.count loop
                l_dpp_account_id_tab.extend;
                l_dpp_account_id_tab(l_dpp_account_id_tab.count) := l_card_tab(i).id;
            end loop;
        end if;

        select
            t.account_id
        bulk collect into
            l_dpp_account_tab
         from (
                select ao.account_id
                     , ao.split_hash
                 from acc_account_object ao
                where 1 = 1
                  and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                  and ao.object_id in (select column_value from table(cast(l_dpp_account_id_tab as num_tab_tpt)))
             group by ao.account_id
                    , ao.split_hash
              ) t
        where prd_api_service_pkg.get_active_service_id(
                  i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                , i_object_id           => t.account_id
                , i_attr_name           => null
                , i_service_type_id     => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
                , i_split_hash          => t.split_hash
                , i_eff_date            => com_api_sttl_day_pkg.get_sysdate
                , i_inst_id             => l_inst_id
                , i_mask_error          => com_api_const_pkg.TRUE
              ) is not null;

        if l_dpp_account_tab.count > 0 then
            l_dpp_account_id := l_dpp_account_tab(1);

            select sum(d.dpp_amount)
              into l_total_dpp_amount
              from dpp_payment_plan d
             where d.account_id = l_dpp_account_id;

            declare
                l_last_invoice_rec  crd_api_type_pkg.t_invoice_rec;
            begin
                l_last_invoice_rec :=
                    crd_invoice_pkg.get_last_invoice(
                        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => l_dpp_account_id
                      , i_split_hash        => l_split_hash
                      , i_mask_error        => com_api_const_pkg.TRUE
                    );

                get_prev_invoice_data(
                    i_account_id        => l_dpp_account_id
                  , i_invoice_id        => l_last_invoice_rec.id
                  , o_prev_invoice_rec  => l_prev_invoice_rec
                  , o_start_date        => l_start_date
                );

                select sum(instalment_amount)
                  into l_dpp_incoming_balance
                  from dpp_payment_plan p
                 where p.oper_date <= l_start_date
                   and p.account_id = l_dpp_account_id;

                select sum(instalment_amount)
                  into l_dpp_outgoing_balance
                  from dpp_payment_plan p
                 where p.oper_date <= l_start_date
                   and p.account_id = l_dpp_account_id;
            end;

            select sum(p.dpp_amount)
              into l_total_instalment_amount
              from (select distinct debt_id
                      from crd_invoice_debt_vw
                     where invoice_id = i_invoice_id
                       and is_new     = com_api_const_pkg.TRUE
                   ) e
                 , crd_debt d
                 , dpp_payment_plan p
             where d.id                    = e.debt_id
               and d.oper_id               = p.oper_id;
        end if;
    end if;

    if i_mode in (
        crd_api_const_pkg.CREDIT_STMT_MODE_FULL
      , crd_api_const_pkg.CREDIT_STMT_MODE_DATA_N_LTY
    ) then
        for r in (
            select ao.object_id
                 , ao.entity_type
              from acc_account_object ao
             where ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.account_id     = l_account_id
                union all
            select l_account_id as object_id
                 , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT as entity_type
              from dual
        )
        loop
            lty_api_bonus_pkg.get_lty_account(
                i_entity_type => r.entity_type
              , i_object_id   => r.object_id
              , i_inst_id     => l_inst_id
              , i_eff_date    => l_invoice_date
              , i_mask_error  => com_api_const_pkg.TRUE
              , o_account     => l_lty_account
            );
            if l_lty_account.account_id is not null then
                l_lty_account_id_tab.extend;
                l_lty_account_id_tab(l_lty_account_id_tab.count) := l_lty_account.account_id;
                l_loyalty_currency := l_lty_account.currency;
            end if;
        end loop;

        trc_log_pkg.debug(
            i_text  => 'count of lty accounts ' || l_lty_account_id_tab.count
        );

        select sum(l.amount - l.spent_amount)
          into l_loyalty_expired
          from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
             , lty_bonus l
         where l.account_id = b.column_value
           and l.expire_date between l_start_date and l_invoice_date
           and l.status     = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
           and l.split_hash = l_split_hash;

        select min(loyalty_incoming) as loyalty_incoming
             , min(loyalty_earned) as loyalty_earned
             , min(loyalty_spent) - l_loyalty_expired as loyalty_spent
             , min(loyalty_outgoing) as loyalty_outgoing
          into l_loyalty_incoming
             , l_loyalty_earned
             , l_loyalty_spent
             , l_loyalty_outgoing
          from (
                   select max(balance - amount) keep (dense_rank first order by posting_order) over () as loyalty_incoming
                        , sum(decode(a.balance_impact, 1, a.amount, null)) over () as loyalty_earned
                        , sum(decode(a.balance_impact, -1, a.amount, null)) over () as loyalty_spent
                        , min(balance) keep (dense_rank last order by posting_order) over () as loyalty_outgoing
                     from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                        , acc_entry a
                    where a.account_id = b.column_value
                      and a.split_hash = l_split_hash
                      and a.posting_date between l_start_date and l_invoice_date
               );
    end if;

    -- header
    select xmlconcat(
               xmlelement("customer_number", t.customer_number)
             , xmlelement("account_number", t.account_number)
             , xmlelement("account_currency", l_currency_name)
             , (select xmlagg(
                           xmlelement("customer_name"
                             , xmlelement("surname", p.surname)
                             , xmlelement("first_name", p.first_name)
                             , xmlelement("second_name", p.second_name)
                             , xmlelement("person_title", p.title)
                           )
                       )
                  from (select id
                             , min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, 'LANGENG', 2, 3)) lang
                          from com_person
                         group by id
                       ) p2
                     , com_person p
                 where p2.id  = t.object_id
                   and p.id   = p2.id
                   and p.lang = p2.lang
               )
             , xmlelement("card_number", l_card_mask)
             , xmlelement("network_id", l_network_id)
             , (select xmlelement("delivery_address"
                         , xmlelement("region", a.region)
                         , xmlelement("city", a.city)
                         , xmlelement("street", a.street)
                         , xmlelement("house", a.house)
                         , xmlelement("apartment", a.apartment)
                         , xmlelement("postal_code", a.postal_code)
                         , xmlelement("country", com_api_country_pkg.get_country_full_name(
                                                     i_code         => a.country
                                                   , i_lang         => l_lang
                                                   , i_raise_error  => com_api_const_pkg.FALSE
                                                 )
                           )
                       )
                  from (select a.region
                             , a.city
                             , a.street
                             , a.house
                             , a.apartment
                             , a.postal_code
                             , a.country
                             , o.object_id
                             , row_number() over (partition by o.object_id
                                                      order by decode(o.address_type
                                                                    , 'ADTPSTDL', 1
                                                                    , 'ADTPLGLA', 2
                                                                    , 'ADTPHOME', 3
                                                                    , 'ADTPBSNA', 4
                                                                    , 5
                                                               )
                                                             , decode(a.lang
                                                                    , l_lang, -1
                                                                    , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                    , o.address_id
                                                               )
                                                 ) rn
                          from com_address_object o
                             , com_address a
                         where o.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           and a.id          = o.address_id
                           and a.lang        = l_lang
                       ) a
                 where a.object_id   = t.customer_id
                   and rn            = 1
               )
             , xmlelement("start_date", to_char(start_date, 'dd/mm/yyyy'))
             , xmlelement("invoice_date", to_char(invoice_date, 'dd/mm/yyyy'))
             , xmlelement("min_amount_due", com_api_currency_pkg.get_amount_str(nvl(min_amount_due, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("due_date", to_char(due_date, 'dd/mm/yyyy'))
             , xmlelement("credit_limit", com_api_currency_pkg.get_amount_str(nvl(credit_limit, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("incoming_balance", com_api_currency_pkg.get_amount_str(nvl(incoming_balance, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("payment_amount", com_api_currency_pkg.get_amount_str(nvl(payment_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("expense_amount", com_api_currency_pkg.get_amount_str(nvl(expense_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("interest_amount", com_api_currency_pkg.get_amount_str(nvl(interest_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("fee_amount", com_api_currency_pkg.get_amount_str(nvl(fee_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("total_amount_due", com_api_currency_pkg.get_amount_str(nvl(total_amount_due, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("own_funds", com_api_currency_pkg.get_amount_str(nvl(own_funds, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("hold_balance", com_api_currency_pkg.get_amount_str(nvl(hold_balance, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("available_balance", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("outgoing_balance", com_api_currency_pkg.get_amount_str((nvl(total_amount_due, 0)- nvl(own_funds, 0)), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_incoming", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_incoming, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_earned", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_earned, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_spent", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_spent, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_expired", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_expired, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_outgoing", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_outgoing, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("total_dpp_amount", com_api_currency_pkg.get_amount_str(nvl(l_total_dpp_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("dpp_incoming_balance", com_api_currency_pkg.get_amount_str(nvl(l_dpp_incoming_balance, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("dpp_outgoing_balance", com_api_currency_pkg.get_amount_str(nvl(l_dpp_outgoing_balance, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("total_instalment_amount", com_api_currency_pkg.get_amount_str(nvl(l_total_instalment_amount, 0), l_currency, com_api_const_pkg.TRUE))
           )
      into l_header
      from (select c.customer_number
                 , a.account_number
                 , c.object_id
                 , c.id customer_id
                 , i.start_date
                 , i.invoice_date
                 , i.min_amount_due
                 , i.due_date
                 , i.exceed_limit credit_limit
                 , nvl(l_lag_invoice.total_amount_due, 0) incoming_balance
                 , i.payment_amount
                 , (i.expense_amount - i.fee_amount) expense_amount
                 , i.interest_amount
                 , i.fee_amount
                 , i.total_amount_due
                 , i.own_funds
                 , i.hold_balance
                 , i.available_balance
              from crd_invoice_vw i
                 , acc_account_vw a
                 , prd_customer_vw c
             where i.id             = i_invoice_id
               and a.id             = i.account_id
               and c.id(+)          = a.customer_id
               and c.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_PERSON
           ) t;

    begin
        -- details
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("card_mask", card_mask)
                         , xmlelement("oper_category", oper_category)
                         , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                         , xmlelement("posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                         , xmlelement("oper_amount", com_api_currency_pkg.get_amount_str(oper_amount, oper_currency, com_api_const_pkg.TRUE))
                         , xmlelement("oper_currency", oper_currency_name)
                         , xmlelement("posting_amount", com_api_currency_pkg.get_amount_str(account_amount, account_currency, com_api_const_pkg.TRUE))
                         , xmlelement("posting_currency", account_currency_name)
                         , xmlelement("oper_type", oper_type)
                         , xmlelement("oper_type_name", oper_type_name)
                         , xmlelement("merchant_name", merchant_name)
                         , xmlelement("merchant_street", merchant_street)
                         , xmlelement("merchant_city", merchant_city)
                         , xmlelement("merchant_country", merchant_country)
                         , xmlelement("oper_id", oper_id)
                         , xmlelement("fee_type", fee_type)
                         , xmlelement("fee_type_name", com_api_dictionary_pkg.get_article_text(fee_type, l_lang))
                         , xmlelement("mcc", mcc)
                         , xmlelement("merchant_category", merchant_category)
                         , xmlelement("macros_type_id", macros_type_id)
                         , xmlelement("macros_type", macros_type)
                         , xmlelement("instalment_total", instalment_total)
                         , xmlelement("instalment_number", instalment_number)
                         , xmlelement("loyalty_points"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(lty_points, 0)
                                        , i_curr_code      => l_loyalty_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("loyalty_points_pending"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(lty_points_pending, 0)
                                        , i_curr_code      => l_loyalty_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("interest_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(l_interest_amount, 0)
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                       )
                   order by oper_date, oper_id, debt_id, oper_category
                   )
               )
          into l_detail
          from (select (select card_mask from iss_card where id = d.card_id) card_mask
                     , 'EXPENSE' oper_category
                     , o.oper_date
                     , d.posting_date
                     , o.oper_amount
                     , o.oper_currency
                     , cr2.name oper_currency_name
                     , d.amount account_amount
                     , d.currency account_currency
                     , cr.name account_currency_name
                     , o.oper_type
                     , com_api_dictionary_pkg.get_article_text(o.oper_type, l_lang) oper_type_name
                     , o.merchant_name
                     , o.merchant_street
                     , o.merchant_city
                     , r.name merchant_country
                     , d.fee_type
                     , d.card_id
                     , o.id oper_id
                     , d.id debt_id
                     , o.mcc
                     , com_api_i18n_pkg.get_text('com_mcc', 'name', cm.id, l_lang) as merchant_category
                     , d.macros_type_id
                     , com_api_i18n_pkg.get_text('macros_type', 'name', d.macros_type_id, l_lang) as macros_type
                     , (select to_char(instalment_total) from dpp_payment_plan p where d.oper_id = p.reg_oper_id) as instalment_total
                     , (select to_char(max(di.instalment_number))
                          from dpp_payment_plan p
                             , dpp_instalment di
                             , crd_invoice_vw i
                         where d.oper_id = p.reg_oper_id
                           and p.id      = di.dpp_id
                           and i.id      = i_invoice_id
                           and di.instalment_date <= i.invoice_date) as instalment_number
                     , lty_points
                     , lty_points_pending
                  from (select distinct debt_id
                          from crd_invoice_debt_vw
                         where invoice_id = i_invoice_id
                           and is_new     = com_api_const_pkg.TRUE
                       ) e
                     , crd_debt d
                     , opr_operation o
                     , opr_participant p
                     , com_country r
                     , com_currency cr
                     , com_currency cr2
                     , com_mcc cm
                     , (
                           select sum(case when m.posting_date between l_start_date and l_invoice_date then m.amount end) as lty_points
                                , sum(case when m.posting_date not between l_start_date and l_invoice_date then m.amount end) as lty_points_pending
                                , m.object_id as oper_id
                             from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                                , acc_macros m
                                , acc_entry e
                            where m.account_id     = b.column_value
                              and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              and m.id             = e.macros_id
                              and e.balance_impact = 1
                            group by m.object_id
                       ) b
                 where d.id                    = e.debt_id
                   and d.oper_id               = o.id(+)
                   and p.oper_id(+)            = o.id
                   and p.participant_type(+)   = com_api_const_pkg.PARTICIPANT_ISSUER
                   and d.oper_type            != opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                   and o.merchant_country      = r.code(+)
                   and d.currency              = cr.code(+)
                   and o.oper_currency         = cr2.code(+)
                   and o.mcc                   = cm.mcc(+)
                   and d.oper_id               = b.oper_id(+)
                 union all
                select (select card_mask from iss_card where id = d.card_id) card_mask
                     , 'FEE' oper_category
                     , o.oper_date
                     , d.posting_date
                     , o.oper_amount
                     , o.oper_currency
                     , cr2.name oper_currency_name
                     , d.amount account_amount
                     , d.currency account_currency
                     , cr.name account_currency_name
                     , o.oper_type
                     , com_api_dictionary_pkg.get_article_text(o.oper_type, l_lang) oper_type_name
                     , o.merchant_name
                     , o.merchant_street
                     , o.merchant_city
                     , r.name merchant_country
                     , d.fee_type
                     , d.card_id
                     , o.id oper_id
                     , d.id
                     , o.mcc
                     , com_api_i18n_pkg.get_text('com_mcc', 'name', cm.id, l_lang) as merchant_category
                     , d.macros_type_id
                     , com_api_i18n_pkg.get_text('macros_type', 'name', d.macros_type_id, l_lang) as macros_type
                     , null as instalment_total
                     , null as instalment_number
                     , null as lty_points
                     , null as lty_points_pending
                  from (select distinct debt_id
                          from crd_invoice_debt_vw
                         where invoice_id = i_invoice_id
                           and is_new     = com_api_const_pkg.TRUE
                       ) e
                     , crd_debt d
                     , opr_operation o
                     , opr_participant p
                     , com_country r
                     , com_currency cr
                     , com_currency cr2
                     , com_mcc cm
                 where d.id                    = e.debt_id
                   and d.oper_id               = o.id(+)
                   and p.oper_id(+)            = o.id
                   and p.participant_type(+)   = com_api_const_pkg.PARTICIPANT_ISSUER
                   and d.oper_type             = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE -- 'OPTP0119'
                   and o.merchant_country      = r.code(+)
                   and d.currency              = cr.code(+)
                   and o.oper_currency         = cr2.code(+)
                   and o.mcc                   = cm.mcc(+)
                 union all
                select (select card_mask from iss_card where id = m.card_id) card_mask
                     , 'PAYMENT' oper_category
                     , o.oper_date
                     , m.posting_date
                     , o.oper_amount
                     , o.oper_currency
                     , cr2.name oper_currency_name
                     , m.amount account_amount
                     , m.currency account_currency
                     , cr.name account_currency_name
                     , o.oper_type
                     , com_api_dictionary_pkg.get_article_text(o.oper_type, l_lang) oper_type_name
                     , o.merchant_name
                     , o.merchant_street
                     , o.merchant_city
                     , r.name merchant_country
                     , null fee_type
                     , m.card_id
                     , o.id oper_id
                     , null debt_id
                     , o.mcc
                     , com_api_i18n_pkg.get_text('com_mcc', 'name', cm.id, l_lang) as merchant_category
                     , null as macros_type_id
                     , null as macros_type
                     , null as instalment_total
                     , null as instalment_number
                     , null as lty_points
                     , null as lty_points_pending
                  from crd_invoice_payment p
                     , crd_payment m
                     , opr_operation o
                     , opr_participant iss
                     , com_country r
                     , com_currency cr
                     , com_currency cr2
                     , com_mcc cm
                 where p.invoice_id            = i_invoice_id
                   and p.is_new                = com_api_type_pkg.TRUE
                   and m.id                    = p.pay_id
                   and m.oper_id               = o.id(+)
                   and iss.oper_id(+)          = o.id
                   and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                   and o.merchant_country      = r.code(+)
                   and m.currency              = cr.code(+)
                   and o.oper_currency         = cr2.code(+)
                   and o.mcc                   = cm.mcc(+)
               ) t;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
            );
    end;

    if l_detail.getclobval() = '<operations></operations>' then
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("card_mask", null)
                         , xmlelement("oper_category", null)
                         , xmlelement("oper_date", null)
                         , xmlelement("posting_date", null)
                         , xmlelement("oper_amount", null)
                         , xmlelement("oper_currency", null)
                         , xmlelement("posting_amount", null)
                         , xmlelement("posting_currency", null)
                         , xmlelement("oper_type", null)
                         , xmlelement("oper_type_name", null)
                         , xmlelement("merchant_name", null)
                         , xmlelement("merchant_street", null)
                         , xmlelement("merchant_city", null)
                         , xmlelement("merchant_country", null)
                         , xmlelement("oper_id", null)
                         , xmlelement("fee_type", null)
                         , xmlelement("fee_type_name", null)
                         , xmlelement("mcc", null)
                         , xmlelement("merchant_category", null)
                         , xmlelement("macros_type_id", null)
                         , xmlelement("macros_type", null)
                         , xmlelement("instalment_total", null)
                         , xmlelement("instalment_number", null)
                         , xmlelement("loyalty_points", null)
                         , xmlelement("loyalty_points_pending", null)
                         , xmlelement("interest_amount", null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement (
               "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

end run_report;

procedure instant_credit_statement(
    o_xml                   out clob
    , i_account_number      in com_api_type_pkg.t_account_number
    , i_settl_date          in date
    , i_lang                in com_api_type_pkg.t_dict_value
)is
    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_interest              xmltype;
    l_interest_detail       xmltype;
    l_oper_detail           xmltype;

    l_account_id            com_api_type_pkg.t_account_id;
    l_invoice_id            com_api_type_pkg.t_medium_id;
    l_invoice_date          date;
    l_start_date            date;
    l_aval_balance          com_api_type_pkg.t_amount_rec;
    l_overdue_balance       com_api_type_pkg.t_amount_rec;
    l_overdue_intr_balance  com_api_type_pkg.t_amount_rec;
    l_ledger_balance        com_api_type_pkg.t_amount_rec;
    l_entry_balance         com_api_type_pkg.t_money := 0;
    l_output_balance        com_api_type_pkg.t_money := 0;
    l_total_income          com_api_type_pkg.t_money := 0;
    l_total_expence         com_api_type_pkg.t_money := 0;
    l_total_interest        com_api_type_pkg.t_money := 0;
    l_interest_amount       com_api_type_pkg.t_money := 0;
    l_debt_interest_amount  com_api_type_pkg.t_money := 0;
    l_exceed_limit          com_api_type_pkg.t_amount_rec;

    l_currency_id           com_api_type_pkg.t_tiny_id;
    l_currency              com_api_type_pkg.t_dict_value;

    l_settl_date            date;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_debt_id               com_api_type_pkg.t_long_id;
    l_oper_description      com_api_type_pkg.t_name;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;

    l_calc_interest_end_attr   com_api_type_pkg.t_dict_value;

    l_calc_interest_date_end   date;

    l_calc_due_date            date;
    l_inst_id                  com_api_type_pkg.t_short_id;

    procedure add_element_to_detail is
    begin
        select
            xmlconcat(
                xmlelement( "operation"
                    , xmlelement( "oper_type", to_char(null) )
                    , xmlelement( "oper_description", l_oper_description)
                    , xmlelement( "card_mask", to_char(null) )
                    , xmlelement( "card_id", to_char(null) )
                    , xmlelement( "posting_date", to_char(l_settl_date, 'dd/mm/yyyy') )
                    , xmlelement( "oper_date", to_char(l_settl_date, 'dd/mm/yyyy') )
                    , xmlelement( "oper_currency", l_aval_balance.currency )
                    , xmlelement( "oper_amount", l_debt_interest_amount )
                    , xmlelement( "credit_oper_amount", 0 )
                    , xmlelement( "debit_oper_amount", 0 )
                    , xmlelement( "overdraft_amount", 0 )
                    , xmlelement( "repayment_amount", 0 )
                    , xmlelement( "interest_amount", nvl(l_debt_interest_amount, 0) )
                    , xmlelement( "oper_type_interest", 1 )
               )
            )
            into l_interest
        from dual;

        -- add node to detail
        select
            xmlconcat(l_interest_detail, l_interest) r
        into
            l_interest_detail
        from
            dual;
    end;

begin
    trc_log_pkg.debug (
        i_text          => 'Run instant_credit_statement [#1] [#2] [#3]'
        , i_env_param1  => i_lang
        , i_env_param2  => i_account_number
        , i_env_param3  => i_settl_date
    );
    l_lang        := nvl(i_lang, get_user_lang);
    --l_settl_date  := trunc(nvl(i_settl_date, com_api_sttl_day_pkg.get_sysdate));
    l_settl_date  := nvl(trunc(i_settl_date), com_api_sttl_day_pkg.get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;

    --get account id
    begin

        select id
             , split_hash
             , inst_id
          into l_account_id
             , l_split_hash
             , l_inst_id
          from acc_account
         where account_number = i_account_number;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'ACCOUNT_NOT_FOUND'
                , i_env_param1  => i_account_number
            );
    end;

    -- get last invoice
    select max(i.id)
      into l_invoice_id
      from crd_invoice_vw i
     where i.account_id = l_account_id
       and i.invoice_date <= l_settl_date;

    -- calc start date
    if l_invoice_id is null then
         begin
            select
                o.start_date
            into
                l_start_date
            from
                prd_service_object o
                , prd_service s
            where
                o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                and object_id = l_account_id
                and s.id = o.service_id
                and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;

            l_entry_balance := 0;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                    , i_env_param1  => l_account_id
                    , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                );
        end;
    else
        select invoice_date
             , total_amount_due
          into l_invoice_date
             , l_entry_balance
          from crd_invoice_vw i
         where i.id = l_invoice_id;

        l_start_date := l_invoice_date;
    end if;

    -- get aval balance
    l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount (
        i_account_id    => l_account_id
        , i_date        => l_settl_date
        , i_date_type   => com_api_const_pkg.DATE_PURPOSE_PROCESSING
    );
    -- get overdue balance
    l_overdue_balance := acc_api_balance_pkg.get_balance_amount (
        i_account_id      => l_account_id
        , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE
        , i_date          => l_settl_date
        , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
    );
    -- get overdue intr balance
    l_overdue_intr_balance := acc_api_balance_pkg.get_balance_amount (
        i_account_id      => l_account_id
        , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
        , i_date          => l_settl_date
        , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
    );

    --get credit limit
    l_exceed_limit := acc_api_balance_pkg.get_balance_amount (
        i_account_id     => l_account_id
      , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
      , i_date           => l_settl_date
      , i_date_type      => com_api_const_pkg.DATE_PURPOSE_BANK
      , i_mask_error     => com_api_const_pkg.TRUE
    );

    -- get currency
    select id
      into l_currency_id
      from com_currency
     where code = l_aval_balance.currency;

    -- get ladger balance
    l_ledger_balance :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id        => l_account_id
          , i_balance_type      => acc_api_const_pkg.BALANCE_TYPE_LEDGER
          , i_date              => l_settl_date
          , i_date_type         => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_from_id := com_api_id_pkg.get_from_id(l_start_date);
    l_till_id := com_api_id_pkg.get_till_id(l_settl_date);

    -- get output_balance and total_expence
    select sum (decode(b.balance_type, acc_api_const_pkg.BALANCE_TYPE_LEDGER, 0, nvl(b.amount, 0)))
         , sum (nvl(d.amount, 0))
      into l_output_balance
         , l_total_expence
      from (
            select d.id debt_id
                 , d.amount
              from crd_debt d
             where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
               and d.split_hash = l_split_hash
               and is_new = com_api_type_pkg.TRUE
               and d.id between l_from_id and l_till_id
            union
            select d.id debt_id
                 , d.amount
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = l_account_id
               and d.split_hash = l_split_hash
               and is_new = com_api_type_pkg.TRUE
               and d.id between l_from_id and l_till_id
         ) d
         , crd_debt_balance b
     where b.debt_id(+)    = d.debt_id
       and b.split_hash(+) = l_split_hash
       and b.id between l_from_id and l_till_id;

    -- get total_income
    select sum (amount)
      into l_total_income
      from crd_payment
     where account_id = l_account_id
       and split_hash = l_split_hash
       and id between l_from_id and l_till_id;

    -- Get calc interest end date ICED
    l_calc_interest_end_attr :=
        crd_interest_pkg.get_interest_calc_end_date(
            i_account_id  => l_account_id
          , i_eff_date    => l_settl_date
          , i_split_hash  => l_split_hash
          , i_inst_id     => l_inst_id
        );

    -- Get Due Date
    l_calc_due_date :=
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_account_id => l_account_id
          , i_split_hash => l_split_hash
          , i_inst_id    => l_inst_id
          , i_eff_date   => l_settl_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );

    -- get total_interest
    l_debt_id := null;
    for r in (
        select a.balance_type
             , a.fee_id
             , a.amount
             , a.balance_date start_date
             , lead(a.balance_date) over (partition by a.balance_type order by a.id) end_date
             , a.debt_id
             , a.id
             , d.inst_id
             , d.macros_type_id
             , get_article_text(d.oper_type, l_lang) oper_type
             , d.oper_date
             , i.due_date
          from crd_debt_interest a
             , crd_debt d
             , crd_invoice i
         where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
           and a.is_charged      = com_api_const_pkg.FALSE
           and d.is_grace_enable = com_api_const_pkg.FALSE
           and d.id              = a.debt_id
           and a.split_hash      = l_split_hash
           and a.id between l_from_id and l_till_id
           and a.invoice_id      = i.id(+)
         order by d.id
    ) loop
        l_calc_interest_date_end :=
            case l_calc_interest_end_attr
                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                    then r.end_date
                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                    then nvl(r.due_date, l_calc_due_date)
                else r.end_date
            end;
        l_interest_amount := round(
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id            => r.fee_id
              , i_base_amount       => r.amount
              , io_base_currency    => l_currency
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account_id
              , i_split_hash        => l_split_hash
              , i_eff_date          => r.start_date
              , i_start_date        => r.start_date
              , i_end_date          => l_calc_interest_date_end
            )
          , 4
        );
        trc_log_pkg.debug (
            i_text          => 'Calc interest [#1] [#2] [#3] [#4] [#5]'
            , i_env_param1  => r.fee_id
            , i_env_param2  => r.amount
            , i_env_param3  => r.debt_id
            , i_env_param4  => r.start_date
            , i_env_param5  => r.end_date
        );

        l_total_interest := l_total_interest + l_interest_amount;

        -- create detail
        if l_debt_id = r.debt_id then
            l_debt_interest_amount := l_debt_interest_amount + l_interest_amount;
        else
            if l_debt_id is not null then
                -- create new element for previous debt
                add_element_to_detail;
            end if;

            -- save new debt
            l_debt_id := r.debt_id;
            l_oper_description := nvl(r.oper_type, '') || ' ' || nvl(r.oper_date, '');
            l_debt_interest_amount := l_interest_amount;
        end if;

    end loop;

    -- create new element for last debt
    if l_debt_id is not null then
        add_element_to_detail;
    end if;
    -- header
    select
        xmlconcat(
            xmlelement( "account"
              , xmlelement( "account_number", t.customer_account )
              , xmlelement( "currency", t.account_currency)
              , xmlelement( "currency_name", com_api_i18n_pkg.get_text('com_currency', 'name', l_currency_id, l_lang))
              , xmlelement( "account_type", t.account_type )
              , xmlelement( "inst_id", t.inst_id )
              , xmlelement( "inst_name", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', t.inst_id, l_lang) )
              , xmlelement( "agent_id", t.agent_id )
              , xmlelement( "customer"
                  , xmlelement( "customer_number", t.customer_number )
                  , xmlelement( "customer_category", t.category )
                  , xmlelement( "resident", t.resident )
                  , xmlelement( "customer_relation", t.relation )
                  , xmlelement( "nationality", t.nationality )
                  , xmlelement( "is_person", t.is_person )
                  , xmlelement( "person"
                      , xmlelement( "person_name"
                          , xmlelement( "surname", t.surname )
                          , xmlelement( "first_name", t.first_name )
                          , xmlelement( "second_name", t.second_name )
                        )
                      , xmlelement( "identity_card"
                          , xmlelement( "id_type", to_char(null) )
                          , xmlelement( "id_series", to_char(null) )
                          , xmlelement( "id_number", to_char(null) )
                        )
                    )
                  , xmlelement( "company"
                      , xmlelement( "company_name", t.company_name)
                    )
                  , xmlelement( "contact"
                      , xmlelement( "contact_type", to_char(null) )
                      , xmlelement( "preferred_lang", to_char(null) )
                      , xmlelement( "contact_data"
                          , xmlelement( "commun_method", to_char(null) )
                          , xmlelement( "commun_address", to_char(null) )
                        )
                    )
                  , xmlelement( "address"
                      , xmlelement( "address_type", t.address_type )
                      , xmlelement( "country", t.country )
                      , xmlelement( "address_name"
                          , xmlelement( "region", nvl(t.region, '') )
                          , xmlelement( "city", nvl(t.city, '') )
                          , xmlelement( "street", nvl(t.street, '') )
                          , xmlelement( "house", nvl(t.house, '') )
                          , xmlelement( "apartment", nvl(t.apartment, '') )
                        )
                    )
                )
              , xmlelement( "contract"
                  , xmlelement( "contract_type", t.contract_type )
                  , xmlelement( "product_id", t.product_id )
                  , xmlelement( "contract_number", t.contract_number )
                  , xmlelement( "contract_date", to_char(t.contract_date, 'dd/mm/yyyy') )
                  , xmlelement( "opening_balance", nvl(entry_balance, 0) )
                  , xmlelement( "closing_balance", nvl(output_balance, 0) )
                  , xmlelement( "start_date", to_char(start_date, 'dd/mm/yyyy') )
                  , xmlelement( "invoice_date", to_char(invoice_date, 'dd/mm/yyyy') )
                  , xmlelement( "total_income", nvl(total_income, 0) )
                  , xmlelement( "total_expence", nvl(total_expence, 0) )
                  , xmlelement( "overdue", nvl(l_overdue_balance.amount, 0) )
                  , xmlelement( "overdue_interest", nvl(l_overdue_intr_balance.amount, 0) )
                  , xmlelement( "interest_sum", nvl(total_interest, 0) )
                  , xmlelement( "available_balance", nvl(l_aval_balance.amount, 0) )
                  , xmlelement( "serial_number", to_char(null) )
                  , xmlelement( "invoice_type", to_char(null) )
                  , xmlelement( "exceed_limit", nvl(credit_limit, 0) )
                  , xmlelement( "total_amount_due", nvl(output_balance, 0) )
                  , xmlelement( "own_funds", nvl(ledger_balance, 0) )
                  , xmlelement( "min_amount_due", to_char(null) )
                  , xmlelement( "grace_date", to_char(null) )
                  , xmlelement( "due_date", to_char(null) )
                  , xmlelement( "penalty_date", to_char(null) )
                  , xmlelement( "aging_period", to_char(null) )
                )
            )
        )
    into
        l_header
    from (
        select
            a.account_number customer_account
            , a.currency account_currency
            , a.account_type
            , a.inst_id
            , a.agent_id
            , c.customer_number
            , c.category
            , c.resident
            , com_api_dictionary_pkg.get_article_text(c.relation, l_lang) relation
            , c.nationality
            , r.contract_type
            , r.product_id
            , r.contract_number
            , r.start_date contract_date
            , p.surname
            , p.first_name
            , p.second_name
            , ob1.address_type
            , d.country
            , d.region
            , d.city
            , d.street
            , d.house
            , d.apartment
            , l_start_date start_date
            , l_settl_date invoice_date
            , l_exceed_limit.amount credit_limit
            , l_ledger_balance.amount ledger_balance
            , l_entry_balance entry_balance
            , l_output_balance output_balance
            , l_total_income total_income
            , l_total_expence total_expence
            , l_total_interest total_interest
            , case c.entity_type
                   when com_api_const_pkg.ENTITY_TYPE_COMPANY
                   then com_api_i18n_pkg.get_text('com_company', 'label', c.object_id, l_lang)
                   else null
               end as company_name
            , decode(c.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON, 1, 0) as is_person
         from acc_account_vw a
            , prd_customer_vw c
            , prd_contract r
            , com_person p
            , com_address_object_vw ob1
            , com_address d
        where a.id = l_account_id
          and c.id = a.customer_id
          and r.id = a.contract_id
          and p.id(+) = c.object_id
          and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
          and ob1.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          and ob1.object_id(+) = c.id
          and d.id(+) = ob1.address_id
          and rownum = 1
    ) t;

    begin
        -- details
        select
               xmlagg(
                   xmlelement( "operation"
                       , xmlelement( "oper_type", oper_type)
                       , xmlelement( "oper_description", oper_description)
                       , xmlelement( "card_mask", object_ref )
                       , xmlelement( "card_id", card_id )
                       , xmlelement( "posting_date", to_char(posting_date, 'dd/mm/yyyy') )
                       , xmlelement( "oper_date", to_char(oper_date, 'dd/mm/yyyy') )
                       , xmlelement( "oper_currency", oper_currency )
                       , xmlelement( "oper_amount", nvl(oper_amount, 0) )
                       , xmlelement( "credit_oper_amount", nvl(oper_amount_in, 0) )
                       , xmlelement( "debit_oper_amount", nvl(oper_amount_out, 0) )
                       , xmlelement( "overdraft_amount", nvl(oper_credit, 0) )
                       , xmlelement( "repayment_amount", nvl(oper_payment, 0) )
                       , xmlelement( "interest_amount", nvl(oper_interest, 0) )
                       , xmlelement( "oper_type_interest", 0 )
                   )
               )
        into
            l_oper_detail
        from (
            select
                oper_type
                , nvl2(oper_type, oper_type || ' ', null) || nvl2(oper_date, oper_date || ' ', null) || merchant_address oper_description
                , object_ref
                , card_id
                , posting_date
                , oper_date
                , nvl(oper_amount, 0) oper_amount
                , oper_currency
                , oper_amount_in
                , oper_amount_out
                , oper_credit
                , oper_payment
                , oper_interest
            from (
                -- debit
                select
                    get_article_text(o.oper_type, l_lang) oper_type
                    , nvl2(o.merchant_city, o.merchant_city || ', ', null) || o.merchant_street merchant_address
                    , (select card_mask from iss_card where id = d.card_id) object_ref
                    , d.card_id
                    , d.posting_date
                    , d.oper_date
                    , o.oper_amount
                    , o.oper_currency
                    , null oper_amount_in
                    , nvl(d.amount, 0) oper_amount_out
                    , nvl(d.debt_amount, 0) oper_credit
                    , null oper_payment
                    , null oper_interest
                from (
                    select d.id debt_id
                      from crd_debt d
                     where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
                       and d.split_hash = l_split_hash
                       and is_new = com_api_type_pkg.TRUE
                       and d.id between l_from_id and l_till_id
                    union
                    select d.id debt_id
                      from crd_debt d
                     where decode(d.is_new, 1, d.account_id, null) = l_account_id
                       and d.split_hash = l_split_hash
                       and is_new = com_api_type_pkg.TRUE
                       and d.id between l_from_id and l_till_id
                    ) e
                    , crd_debt_vw d
                    , opr_operation_vw o
                where
                    d.id = e.debt_id
                    and o.id(+) = d.oper_id
                union all
                -- credit
                select
                    get_article_text(o.oper_type, l_lang) oper_type
                    , nvl2(o.merchant_city, o.merchant_city || ', ', null) || o.merchant_street merchant_address
                    , to_char(null) object_ref
                    , o.card_id
                    , m.posting_date
                    , o.oper_date
                    , o.oper_amount
                    , o.oper_currency
                    , nvl(m.amount, 0) oper_amount_in
                    , null oper_amount_out
                    , null oper_credit
                    , (nvl(m.amount, 0) - nvl(m.pay_amount, 0)) oper_payment
                    , null oper_interest
                from (
                   select id pay_id
                     from crd_payment
                    where account_id = l_account_id --decode(status, 'PMTSACTV', account_id, null) = l_account_id
                       and split_hash = l_split_hash
                       --and is_new = com_api_type_pkg.TRUE
                       and id between l_from_id and l_till_id
                    union
                    select id pay_id
                      from crd_payment
                     where account_id = l_account_id --decode(is_new, 1, account_id, null) = l_account_id
                       and split_hash = l_split_hash
                       and id between l_from_id and l_till_id
                    ) p
                    , crd_payment_vw m
                    , opr_operation_participant_vw o
                where m.id = p.pay_id
                  and o.id(+) = m.oper_id
            )
        );
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
            );
    end;

    select
        xmlelement(
            "operations"
            , l_oper_detail
            , l_interest_detail
        ) r
    into
        l_detail
    from
        dual;

    select
        xmlelement (
            "account_credit_statement"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text          => 'End instant_credit_statement'
    );
end instant_credit_statement;

function calculate_interest(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_debt_id           in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date
  , i_period_date       in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money
is
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_interest_amount           com_api_type_pkg.t_money;
    l_eff_date                  date;
    l_interest_sum              com_api_type_pkg.t_money    := 0;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_account_number            com_api_type_pkg.t_account_number;
    l_from_id                   com_api_type_pkg.t_long_id;
    l_till_id                   com_api_type_pkg.t_long_id;
    l_interest_calc_start_date  com_api_type_pkg.t_dict_value;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_calc_interest_end_attr    com_api_type_pkg.t_dict_value;
    l_calc_interest_date_end    date;
    l_calc_due_date             date;
begin
    trc_log_pkg.debug(
        'charge_interest: i_account_id [' || i_account_id
        || '] i_eff_date [' || to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')
        || '] i_period_date [' || to_char(i_period_date, 'dd.mm.yyyy hh24:mi:ss')
        || ']'
    );

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, i_account_id);
    else
        l_split_hash := i_split_hash;
    end if;

    begin
        select inst_id
          into l_inst_id
          from acc_account
         where id = i_account_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'ACCOUNT_NOT_FOUND'
                , i_env_param1  => i_account_id
            );
    end;

    l_interest_calc_start_date :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_attr_name     => crd_api_const_pkg.INTEREST_CALC_START_DATE
          , i_split_hash    => l_split_hash
          , i_service_id    => i_service_id
          , i_params        => l_param_tab
          , i_inst_id       => l_inst_id
        );

    case l_interest_calc_start_date
        when crd_api_const_pkg.INTEREST_CALC_DATE_POSTING
        then l_eff_date := com_api_sttl_day_pkg.get_sysdate;

        when crd_api_const_pkg.INTEREST_CALC_DATE_TRANSACTION
        then l_eff_date := com_api_sttl_day_pkg.get_sysdate;

        when crd_api_const_pkg.INTEREST_CALC_DATE_SETTLEMENT
        then l_eff_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => l_inst_id);
        
        when crd_api_const_pkg.INTEREST_CALC_DATE_TRANS_NEXT
        then l_eff_date := trunc(com_api_sttl_day_pkg.get_sysdate) + 1;

        else
            l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    end case;

    l_eff_date := crd_interest_pkg.get_interest_start_date(
                      i_product_id   => i_product_id
                    , i_account_id   => i_account_id
                    , i_split_hash   => l_split_hash
                    , i_service_id   => i_service_id
                    , i_param_tab    => l_param_tab
                    , i_posting_date => null
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => l_inst_id
                  );

    -- Get calc interest end date ICED
    l_calc_interest_end_attr :=
        crd_interest_pkg.get_interest_calc_end_date(
            i_account_id  => i_account_id
          , i_eff_date    => l_eff_date
          , i_split_hash  => l_split_hash
          , i_inst_id     => l_inst_id
        );

    -- Get Due Date
    l_calc_due_date := 
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_account_id => i_account_id
          , i_split_hash => i_split_hash
          , i_inst_id    => l_inst_id
          , i_eff_date   => l_eff_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );

    for p in (
        select d.id debt_id
             , c.account_type
             , c.currency
             , c.account_number
             , c.inst_id
          from crd_debt d
             , acc_account c
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.id = coalesce(i_debt_id, d.id)
           and d.account_id = c.id
           and d.split_hash = i_split_hash
           and crd_cst_interest_pkg.charge_interest_needed(i_debt_id => d.id) = com_api_const_pkg.TRUE
    ) loop

        l_currency := p.currency;
        l_account_number := p.account_number;
        l_from_id      := com_api_id_pkg.get_from_id_num(p.debt_id);
        l_till_id      := com_api_id_pkg.get_till_id_num(p.debt_id);

        for r in (
            select x.balance_type
                 , x.fee_id
                 , x.add_fee_id
                 , x.amount
                 , x.start_date
                 , x.end_date
                 , b.bunch_type_id
                 , x.id
                 , x.macros_type_id
                 , x.interest_amount
                 , x.debt_intr_id
                 , x.due_date
              from (
                    select a.id debt_intr_id
                         , a.balance_type
                         , a.fee_id
                         , a.add_fee_id
                         , a.amount
                         , a.balance_date start_date
                         , nvl(lead(a.balance_date) over (partition by a.balance_type order by a.id), l_eff_date) end_date
                         , a.debt_id
                         , a.id
                         , d.inst_id
                         , d.macros_type_id
                         , a.interest_amount
                         , a.is_charged
                         , i.due_date
                      from crd_debt_interest a
                         , crd_debt d
                         , crd_invoice i
                     where a.debt_id         = p.debt_id
                       and d.is_grace_enable = com_api_const_pkg.FALSE
                       and d.id              = a.debt_id
                       and a.split_hash      = i_split_hash
                       and a.id between l_from_id and l_till_id
                       and a.invoice_id      = i.id(+)
                   ) x
                 , crd_event_bunch_type b
             where x.end_date        <= l_eff_date
               and b.event_type(+)    = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
               and x.is_charged       = com_api_const_pkg.FALSE
               and b.balance_type(+)  = x.balance_type
               and b.inst_id(+)       = x.inst_id
             order by bunch_type_id nulls first

        ) loop
                -- only for migration purposes - interest amount could be sent in migration data
                -- so we do not need to recalculate it
                l_calc_interest_date_end := 
                    case l_calc_interest_end_attr
                        when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                            then r.end_date
                        when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                            then nvl(r.due_date, l_calc_due_date)
                        else r.end_date
                    end;
                if nvl(r.interest_amount, 0) = 0 then

                    -- Calculate interest amount. Base algorithm
                    if i_alg_calc_intr in (
                           crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                         , crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                       )
                    then

                        l_interest_amount :=  round(
                            fcl_api_fee_pkg.get_fee_amount(
                                i_fee_id            => r.fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => i_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                            )
                          , case i_alg_calc_intr
                                when crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                                    then 4
                                when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                    then 0
                            end
                        );

                        if r.add_fee_id is not null then
                            -- Calculate additional interest amount
                            l_interest_amount := l_interest_amount + round(
                                fcl_api_fee_pkg.get_fee_amount(
                                    i_fee_id            => r.add_fee_id
                                  , i_base_amount       => r.amount
                                  , io_base_currency    => p.currency
                                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                  , i_object_id         => i_account_id
                                  , i_split_hash        => i_split_hash
                                  , i_eff_date          => r.start_date
                                  , i_start_date        => r.start_date
                                  , i_end_date          => l_calc_interest_date_end
                                )
                              , case i_alg_calc_intr
                                    when crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                                        then 4
                                    when crd_api_const_pkg.ALGORITHM_CALC_INTR_NOT_DECIM
                                        then 0
                                end
                            );
                        end if;
                        
                    -- Custom algorithm
                    else
                        l_interest_amount :=  round(
                            crd_cst_interest_pkg.get_fee_amount(
                                i_fee_id            => r.fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => i_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                              , i_alg_calc_intr     => i_alg_calc_intr
                              , i_debt_id           => p.debt_id
                              , i_balance_type      => r.balance_type
                              , i_debt_intr_id      => r.debt_intr_id
                              , i_service_id        => i_service_id
                              , i_product_id        => i_product_id
                            )
                          , 4
                        );

                        -- Calculate additional interest amount
                        l_interest_amount := l_interest_amount + round(
                            crd_cst_interest_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => i_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                              , i_alg_calc_intr     => i_alg_calc_intr
                              , i_debt_id           => p.debt_id
                              , i_balance_type      => r.balance_type
                              , i_debt_intr_id      => r.debt_intr_id
                              , i_service_id        => i_service_id
                              , i_product_id        => i_product_id
                            )
                          , 4
                        );

                    end if;
                else
                    l_interest_amount := r.interest_amount;
                end if;

                l_interest_sum := l_interest_sum + l_interest_amount;

                trc_log_pkg.debug('Calulating interest amount base amount ['||r.amount||'] Fee Id ['||r.fee_id||'] Additional fee Id ['||r.add_fee_id||'] Interest amount ['||l_interest_amount||']');
        end loop;

    end loop;

    return l_interest_sum;

end calculate_interest;

procedure credit_statement_event(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result                    xmltype;
    l_attach                    xmltype;
    l_account_id                com_api_type_pkg.t_account_id;
    l_subject                   com_api_type_pkg.t_full_desc;
    l_inst_contact              xmltype;
    l_agent_contact             xmltype;
    l_card_data                 xmltype;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_eff_date                  date;
begin
     trc_log_pkg.debug (
        i_text       => 'Credit statment event notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_eff_date := nvl(i_eff_date, get_sysdate);

    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => i_entity_type
                          , i_object_id   => i_object_id
                          , i_mask_error  => com_api_const_pkg.FALSE
                        );
        l_object_id  := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id => i_object_id
                          , i_split_hash => l_split_hash
                          , i_mask_error => com_api_const_pkg.FALSE
                        );
        trc_log_pkg.debug (
            i_text       => 'Credit statment event notification - get_last_invoice_id [#1] for: entity type [#2] object_id [#3] split hash [#4]'
          , i_env_param1 => l_object_id
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_object_id
          , i_env_param4 => l_split_hash
        );
    elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_object_id := i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;
    --account & institution, agent contact data
    select account_id
         , (select xmlelement(
                       "institution_contacts"
                     , xmlagg(
                           xmlelement(
                               "contact"
                             , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                             , xmlelement(
                                   "communication_address"
                                 , com_api_contact_pkg.get_contact_string(
                                       i_contact_id    => co.contact_id
                                     , i_commun_method => cd.commun_method
                                     , i_start_date    => l_eff_date
                                   )
                               )
                           ) order by co.contact_type, cd.commun_method, co.id desc
                       )
                   )
              from com_contact_object co
                 , com_contact_data cd
             where co.object_id = i.inst_id
               and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
               and co.contact_id  = cd.contact_id
           ) as institution_contacts
         , (select xmlelement(
                       "agent_contacts"
                     , xmlagg(
                           xmlelement(
                               "contact"
                             , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                             , xmlelement(
                                   "communication_address"
                                 , com_api_contact_pkg.get_contact_string(
                                       i_contact_id    => co.contact_id
                                     , i_commun_method => cd.commun_method
                                     , i_start_date    => l_eff_date
                                   )
                               )
                           ) order by co.contact_type, cd.commun_method, co.id desc
                       )
                   )
              from com_contact_object co
                 , com_contact_data cd
             where co.object_id = i.agent_id
               and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
               and co.contact_id  = cd.contact_id
           ) as agent_contacts
         , (select xmlelement(
                       "cards"
                     , xmlagg(
                           xmlelement(
                               "card"
                             , xmlattributes(ic.category as "card_category")
                             , xmlelement(
                                   "card_mask"
                                 , ic.card_mask
                               )
                             , xmlelement(
                                   "card_short_mask"
                                 , iss_api_card_pkg.get_short_card_mask(
                                       i_card_number => ic.card_mask
                                   )
                               )
                           ) order by decode(ic.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1), ic.id desc
                       )
                   )
              from acc_account_object ao
                 , iss_card ic
             where ao.account_id  = i.account_id
               and ao.object_id   = ic.id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           ) as card_data
      into l_account_id
         , l_inst_contact
         , l_agent_contact
         , l_card_data
      from crd_invoice i
     where id = l_object_id;

    --user exit
    l_subject := crd_cst_report_pkg.get_subject(
        i_account_id  => l_account_id
      , i_eff_date    => l_eff_date
    );

    --attachment
    begin
        select xmlagg(
                    xmlelement("attachment",
                        xmlelement("attachment_path", t.attach_path)
                      , xmlelement("attachment_name", t.file_name)
                    )
                )
        into l_attach
        from (
        select c.file_name
             , c.save_path attach_path
          from rpt_document d
             , rpt_document_content c
         where object_id     = l_object_id
           and entity_type   = crd_api_const_pkg.ENTITY_TYPE_INVOICE
           and document_type = rpt_api_const_pkg.DOCUMENT_TYPE_CREDIT
           and c.document_id = d.id
        ) t;

    exception
        when no_data_found then
            null; --error?
    end;

    --invoice
    select
        xmlelement("report"
          , xmlelement("subject",             l_subject)
          , xmlelement("attachments",         l_attach)
          , xmlelement("first_name",          t.first_name)
          , xmlelement("second_name",         t.second_name)
          , xmlelement("surname",             t.surname)
          , xmlelement("account_number",      t.account_number)
          , xmlelement("currency",            t.currency_name)
          , xmlelement("invoice_date",        to_char(t.invoice_date, com_api_const_pkg.XML_DATETIME_FORMAT))
          , xmlelement("invoice_date_short" , to_char(t.invoice_date, 'DD/MM/YYYY'))
          , xmlelement("total_amount_due",    com_api_currency_pkg.get_amount_str(nvl(t.total_amount_due, 0), t.currency, com_api_const_pkg.TRUE))
          , xmlelement("min_amount_due"  ,    com_api_currency_pkg.get_amount_str(nvl(t.min_amount_due, 0), t.currency, com_api_const_pkg.TRUE))
          , xmlelement("due_date"        ,    to_char(t.due_date, com_api_const_pkg.XML_DATETIME_FORMAT))
          , xmlelement("due_date_short",      to_char(t.due_date, 'DD/MM/YYYY'))
          , xmlelement("due_date_short_year", to_char(t.due_date, 'DD/MM/YY'))
          , xmlelement("due_date_month",      to_char(t.due_date, 'MM/YY'))
          , crd_cst_report_pkg.credit_statement_invoice_data(
                i_account_id  => t.id
              , i_eff_date    => l_eff_date
              , i_currency    => t.currency
              , i_invoice_id  => t.invoice_id
              , i_split_hash  => t.split_hash
            )
          , l_inst_contact
          , l_agent_contact
          , l_card_data
        )
    into l_result
    from (
        select a.id
             , com_ui_person_pkg.get_first_name(i_person_id => s.object_id, i_lang => l_lang) first_name
             , com_ui_person_pkg.get_second_name(i_person_id => s.object_id, i_lang => l_lang) second_name
             , com_ui_person_pkg.get_surname(i_person_id => s.object_id, i_lang => l_lang) surname
             , a.account_number
             , a.currency
             , a.split_hash
             , i.id as invoice_id
             , i.invoice_date
             , i.total_amount_due
             , i.min_amount_due
             , i.due_date
             , c.name as currency_name
          from crd_invoice i
             , acc_account a
             , prd_customer s 
             , com_currency c
         where i.id           = l_object_id
           and i.account_id   = a.id
           and a.customer_id  = s.id
           and c.code         = a.currency
    ) t;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text       => 'end'
    );
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

procedure credit_loyalty_statement(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_invoice_id        in     com_api_type_pkg.t_medium_id
) is
    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_account_id            com_api_type_pkg.t_account_id;
    l_invoice_date          date;
    l_start_date            date;
    l_lag_invoice           crd_api_type_pkg.t_invoice_rec;
    l_currency_id           com_api_type_pkg.t_tiny_id;
    l_currency              com_api_type_pkg.t_dict_value;
    l_currency_name         com_api_type_pkg.t_dict_value;
    l_lty_account_id_tab    num_tab_tpt := num_tab_tpt();
    l_lty_account           acc_api_type_pkg.t_account_rec;
    l_loyalty_currency      com_api_type_pkg.t_curr_code;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_loyalty_incoming      com_api_type_pkg.t_money;
    l_loyalty_earned        com_api_type_pkg.t_money;
    l_loyalty_spent         com_api_type_pkg.t_money;
    l_loyalty_expired       com_api_type_pkg.t_money;
    l_loyalty_outgoing      com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text        => 'Run statement report [#1] [#2]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_invoice_id
    );

    begin
        select account_id
             , invoice_date
             , inst_id
          into l_account_id
             , l_invoice_date
             , l_inst_id
          from crd_invoice_vw
         where id = i_invoice_id;
    exception when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'INVOICE_NOT_FOUND'
          , i_env_param1  => i_invoice_id
        );
    end;

    select currency
         , split_hash
      into l_currency
         , l_split_hash
      from acc_account
     where id = l_account_id;

    -- get previous invoice
    begin
        select i1.id
             , i1.account_id
             , i1.serial_number
             , i1.invoice_type
             , i1.exceed_limit
             , i1.total_amount_due
             , i1.own_funds
             , i1.min_amount_due
             , i1.invoice_date
             , i1.grace_date
             , i1.due_date
             , i1.penalty_date
             , i1.aging_period
             , i1.is_tad_paid
             , i1.is_mad_paid
             , i1.inst_id
             , i1.agent_id
             , i1.split_hash
             , i1.overdue_date
             , i1.start_date
          into l_lag_invoice
          from crd_invoice_vw i1
             , ( select
                     a.id
                     , lag(a.id) over (order by a.invoice_date) lag_id
                   from crd_invoice_vw a
                  where a.account_id = l_account_id
               ) i2
         where i1.id = i2.lag_id
           and i2.id = i_invoice_id;
    exception when no_data_found then
        trc_log_pkg.debug(
            i_text  => 'Previous invoice not found'
        );
    end;

    -- calc start date
    if l_lag_invoice.id is null then
        begin
            select o.start_date
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and object_id         = l_account_id
               and s.id              = o.service_id
               and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
        exception when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
              , i_env_param1  => l_account_id
              , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
            );
        end;
    else
        l_start_date := l_lag_invoice.invoice_date;
    end if;

    select id
         , name
      into l_currency_id
         , l_currency_name
      from com_currency
     where code = l_currency;

    for r in (
        select ao.object_id
             , ao.entity_type
          from acc_account_object ao
         where ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.account_id     = l_account_id
            union all
        select l_account_id as object_id
             , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT as entity_type
          from dual
    )
    loop
        lty_api_bonus_pkg.get_lty_account(
            i_entity_type => r.entity_type
          , i_object_id   => r.object_id
          , i_inst_id     => l_inst_id
          , i_eff_date    => l_invoice_date
          , i_mask_error  => com_api_const_pkg.TRUE
          , o_account     => l_lty_account
        );
        if l_lty_account.account_id is not null then
            l_lty_account_id_tab.extend;
            l_lty_account_id_tab(l_lty_account_id_tab.count) := l_lty_account.account_id;
            l_loyalty_currency := l_lty_account.currency;
        end if;
    end loop;
    trc_log_pkg.debug(
        i_text  => 'count of lty accounts ' || l_lty_account_id_tab.count
    );

    select sum(l.amount - l.spent_amount)
      into l_loyalty_expired
      from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
         , lty_bonus l
     where l.account_id = b.column_value
       and l.expire_date between l_start_date and l_invoice_date
       and l.status     = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
       and l.split_hash = l_split_hash;

    select min(loyalty_incoming) as loyalty_incoming
         , min(loyalty_earned) as loyalty_earned
         , min(loyalty_spent) - l_loyalty_expired as loyalty_spent
         , min(loyalty_outgoing) as loyalty_outgoing
      into l_loyalty_incoming
         , l_loyalty_earned
         , l_loyalty_spent
         , l_loyalty_outgoing
      from (
               select max(balance - amount) keep (dense_rank first order by posting_order) over () as loyalty_incoming
                    , sum(decode(a.balance_impact, 1, a.amount, null)) over () as loyalty_earned
                    , sum(decode(a.balance_impact, -1, a.amount, null)) over () as loyalty_spent
                    , min(balance) keep (dense_rank last order by posting_order) over () as loyalty_outgoing
                 from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                    , acc_entry a
                where a.account_id = b.column_value
                  and a.split_hash = l_split_hash
                  and a.posting_date between l_start_date and l_invoice_date
           );

    -- header
    select xmlconcat(
               xmlelement("customer_number", t.customer_number)
             , xmlelement("account_number", t.account_number)
             , xmlelement("account_currency", l_currency_name)
             , (
                   select xmlagg(
                              xmlelement("customer_name"
                                , xmlelement("surname", p.surname)
                                , xmlelement("first_name", p.first_name)
                                , xmlelement("second_name", p.second_name)
                                , xmlelement("person_title", p.title)
                              )
                          )
                     from (select id, min(lang) keep(dense_rank first order by decode(lang, i_lang, 1, 'LANGENG', 2, 3)) lang
                             from com_person
                            group by id
                          ) p2
                         , com_person p
                    where p2.id  = t.object_id
                      and p.id   = p2.id
                      and p.lang = p2.lang
               )
             , (
                   select xmlelement("delivery_address"
                            , xmlelement("region", a.region)
                            , xmlelement("city", a.city)
                            , xmlelement("street", a.street)
                            , xmlelement("house", a.house)
                            , xmlelement("apartment", a.apartment)
                            , xmlelement("postal_code", a.postal_code)
                          )
                         from com_address_object o
                            , com_address a
                        where o.entity_type = 'ENTTCUST'
                          and o.object_id   = t.customer_id
                          and a.id          = o.address_id
                          and a.lang        = i_lang
                          and rownum        = 1
               )
             , xmlelement("start_date", to_char(start_date, 'dd/mm/yyyy'))
             , xmlelement("invoice_date", to_char(invoice_date, 'dd/mm/yyyy'))
             , xmlelement("min_amount_due"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(min_amount_due, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("due_date", to_char(due_date, 'dd/mm/yyyy'))
             , xmlelement("credit_limit"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(credit_limit, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("incoming_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(incoming_balance, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("payment_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(payment_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("expense_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(expense_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("interest_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(interest_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("fee_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(fee_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )

             , xmlelement("total_amount_due"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(total_amount_due, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("own_funds"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(own_funds, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("hold_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(hold_balance, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("available_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(available_balance, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("outgoing_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => (nvl(total_amount_due, 0)- nvl(own_funds, 0))
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_incoming"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_incoming, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_earned"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_earned, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_spent"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_spent, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_expired"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_expired, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_outgoing"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_outgoing, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("waive_interest_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(waive_interest_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
           )
    into l_header
    from (
             select c.customer_number
                  , a.account_number
                  , c.object_id
                  , c.id customer_id
                  , i.start_date
                  , i.invoice_date
                  , i.min_amount_due
                  , i.due_date
                  , i.exceed_limit credit_limit
                  , nvl(l_lag_invoice.total_amount_due, 0) incoming_balance
                  , i.payment_amount
                  , (i.expense_amount - i.fee_amount) expense_amount
                  , i.interest_amount - i.waive_interest_amount as interest_amount
                  , i.fee_amount
                  , i.total_amount_due
                  , i.own_funds
                  , i.hold_balance
                  , i.available_balance
                  , i.waive_interest_amount
               from crd_invoice_vw i
                  , acc_account_vw a
                  , prd_customer_vw c
              where i.id             = i_invoice_id
                and a.id             = i.account_id
                and c.id(+)          = a.customer_id
                and c.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_PERSON
    ) t;

    begin
        -- details
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("card_mask", card_mask)
                         , xmlelement("oper_category", oper_category)
                         , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                         , xmlelement("posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                         , xmlelement("oper_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => oper_amount
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      )
                           )
                         , xmlelement("oper_currency", oper_currency)
                         , xmlelement("posting_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => account_amount
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      )
                           )
                         , xmlelement("posting_currency", account_currency)
                         , xmlelement("oper_type", oper_type)
                         , xmlelement("oper_type_name", oper_type_name)
                         , xmlelement("merchant_name", merchant_name)
                         , xmlelement("merchant_street", merchant_street)
                         , xmlelement("merchant_city", merchant_city)
                         , xmlelement("merchant_country", merchant_country)
                         , xmlelement("oper_id", oper_id)
                         , xmlelement("fee_type", fee_type)
                         , xmlelement("fee_type_name"
                                    , com_api_dictionary_pkg.get_article_text(
                                          i_article => fee_type
                                        , i_lang    => i_lang
                                      )
                           )
                         , xmlelement("loyalty_points"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(lty_points, 0)
                                        , i_curr_code      => l_loyalty_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("loyalty_points_pending"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(lty_points_pending, 0)
                                        , i_curr_code      => l_loyalty_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("interest_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(interest_amount, 0)
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("waive_interest_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(waive_interest_amount, 0)
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                      )
                      order by oper_category, oper_date
                   )
               )
         into l_detail
         from (
            select (select coalesce(
                               card_mask
                             , iss_api_card_pkg.get_card_mask(
                                   i_card_number => card_number
                               )
                           )
                       from iss_card_vw
                      where id = d.card_id) card_mask
                 , 'EXPENSE' oper_category
                 , o.oper_date
                 , d.posting_date
                 , o.oper_amount
                 , ocr.name oper_currency
                 , p.account_amount
                 , cr.name account_currency
                 , o.oper_type
                 , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                 , o.merchant_name
                 , o.merchant_street
                 , o.merchant_city
                 , r.name merchant_country
                 , d.fee_type
                 , d.card_id
                 , o.id oper_id
                 , d.id debt_id
                 , b.lty_points
                 , b.lty_points_pending
                 , i.interest_amount - i.waive_interest_amount as interest_amount
                 , i.waive_interest_amount
            from (
                     select distinct debt_id
                       from crd_invoice_debt_vw
                      where invoice_id = i_invoice_id
                        and is_new     = com_api_type_pkg.TRUE
                 ) e
               , crd_debt d
               , opr_operation o
               , opr_participant p
               , com_country r
               , com_currency cr
               , com_currency ocr
               , (
                     select sum(case when m.posting_date between l_start_date and l_invoice_date then m.amount end) as lty_points
                          , sum(case when m.posting_date not between l_start_date and l_invoice_date then m.amount end) as lty_points_pending
                          , m.object_id as oper_id
                       from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                          , acc_macros m
                          , acc_entry e
                      where m.account_id     = b.column_value
                        and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                        and m.id             = e.macros_id
                        and e.balance_impact = 1
                      group by m.object_id
                 ) b
               , (
                     select debt_id
                          , sum(nvl(interest_amount, 0)) as interest_amount
                          , nvl(sum(decode(nvl(i.is_waived, com_api_const_pkg.FALSE)
                                     , com_api_const_pkg.TRUE, interest_amount
                                    )
                            ), 0) as waive_interest_amount
                       from crd_debt_interest i
                      where invoice_id = i_invoice_id
                        and split_hash = l_split_hash
                        and is_charged = 1
                      group by debt_id
                 ) i
           where d.id                  = e.debt_id
             and d.oper_id             = o.id(+)
             and p.oper_id(+)          = o.id
             and p.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
             and d.oper_type           != opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
             and o.merchant_country    = r.code(+)
             and p.account_currency    = cr.code(+)
             and o.oper_currency       = ocr.code(+)
             and d.oper_id             = b.oper_id(+)
             and e.debt_id             = i.debt_id(+)
             union all
          select (select coalesce(
                               card_mask
                             , iss_api_card_pkg.get_card_mask(
                                   i_card_number => card_number
                               )
                           )
                       from iss_card_vw
                      where id = d.card_id) card_mask
               , 'FEE' oper_category
               , o.oper_date
               , d.posting_date
               , o.oper_amount
               , ocr.name oper_currency
               , p.account_amount
               , cr.name account_currency
               , o.oper_type
               , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
               , o.merchant_name
               , o.merchant_street
               , o.merchant_city
               , r.name merchant_country
               , d.fee_type
               , d.card_id
               , o.id oper_id
               , d.id
               , null as lty_points
               , null as lty_points_pending
               , null as interest_amount
               , null as waive_interest_amount
            from (
                     select distinct debt_id
                       from crd_invoice_debt_vw
                      where invoice_id = i_invoice_id
                        and is_new = com_api_type_pkg.TRUE
                 ) e
               , crd_debt d
               , opr_operation o
               , opr_participant p
               , com_country r
               , com_currency cr
               , com_currency ocr
           where d.id                  = e.debt_id
             and d.oper_id             = o.id(+)
             and p.oper_id(+)          = o.id
             and p.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
             and d.oper_type           = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
             and o.merchant_country    = r.code(+)
             and p.account_currency    = cr.code(+)
             and o.oper_currency       = ocr.code(+)
              union all
          select (select coalesce(
                               card_mask
                             , iss_api_card_pkg.get_card_mask(
                                   i_card_number => card_number
                               )
                           )
                       from iss_card_vw
                      where id = m.card_id) card_mask
               , 'PAYMENT' oper_category
               , o.oper_date
               , m.posting_date
               , o.oper_amount
               , ocr.name oper_currency
               , iss.account_amount
               , cr.name account_currency
               , o.oper_type
               , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
               , o.merchant_name
               , o.merchant_street
               , o.merchant_city
               , r.name merchant_country
               , null as fee_type
               , m.card_id
               , o.id oper_id
               , null as debt_id
               , null as lty_points
               , null as lty_points_pending
               , null as interest_amount
               , null as waived_interest_amount
            from crd_invoice_payment p
               , crd_payment m
               , opr_operation o
               , opr_participant iss
               , com_country r
               , com_currency cr
               , com_currency ocr
           where p.invoice_id            = i_invoice_id
             and p.is_new                = com_api_type_pkg.TRUE
             and m.id                    = p.pay_id
             and m.oper_id               = o.id(+)
             and iss.oper_id(+)          = o.id
             and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
             and o.merchant_country      = r.code(+)
             and iss.account_currency    = cr.code(+)
             and o.oper_currency         = ocr.code(+)
            ) t;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text  => 'Operations not found'
            );
    end;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();
end credit_loyalty_statement;

procedure mad_overdue(
    o_xml                  out clob
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
    l_attach            xmltype;
    l_account_id        com_api_type_pkg.t_account_id;
    l_subject           com_api_type_pkg.t_full_desc;
    l_inst_contact      xmltype;
    l_agent_contact     xmltype;
    l_card_data         xmltype;
    l_object_id         com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_lang              com_api_type_pkg.t_dict_value;
    l_eff_date          date;
begin
    trc_log_pkg.debug(
        i_text       => 'MAD overdue notification [#1] [#2] [#3] [#4] '
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_eff_date := nvl(i_eff_date, get_sysdate);

    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => i_entity_type
                          , i_object_id   => i_object_id
                          , i_mask_error  => com_api_const_pkg.FALSE
                        );
        l_object_id  := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id => i_object_id
                          , i_split_hash => l_split_hash
                          , i_mask_error => com_api_const_pkg.TRUE
                        );
        trc_log_pkg.debug (
           i_text       => 'MAD overdue notification - get_last_invoice_id [#1] for: entity type [#2] object_id [#3] split hash [#4]'
         , i_env_param1 => l_object_id
         , i_env_param2 => i_entity_type
         , i_env_param3 => i_object_id
         , i_env_param4 => l_split_hash
       );
    elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_object_id := i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;
    --account & institution, agent contact data
    select account_id
         , (select xmlelement(
                       "institution_contacts"
                     , xmlagg(
                           xmlelement(
                               "contact"
                             , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                             , xmlelement(
                                   "communication_address"
                                 , com_api_contact_pkg.get_contact_string(
                                       i_contact_id    => co.contact_id
                                     , i_commun_method => cd.commun_method
                                     , i_start_date    => l_eff_date
                                   )
                               )
                           ) order by co.contact_type, cd.commun_method, co.id desc
                       )
                   )
              from com_contact_object co
                 , com_contact_data cd
             where co.object_id = i.inst_id
               and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
               and co.contact_id  = cd.contact_id
           ) as institution_contacts
         , (select xmlelement(
                       "agent_contacts"
                     , xmlagg(
                           xmlelement(
                               "contact"
                             , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                             , xmlelement(
                                   "communication_address"
                                 , com_api_contact_pkg.get_contact_string(
                                       i_contact_id    => co.contact_id
                                     , i_commun_method => cd.commun_method
                                     , i_start_date    => l_eff_date
                                   )
                               )
                           ) order by co.contact_type, cd.commun_method, co.id desc
                       )
                   )
              from com_contact_object co
                 , com_contact_data cd
             where co.object_id = i.agent_id
               and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
               and co.contact_id  = cd.contact_id
           ) as agent_contacts
         , (select xmlelement(
                       "cards"
                     , xmlagg(
                           xmlelement(
                               "card"
                             , xmlattributes(ic.category as "card_category")
                             , xmlelement(
                                   "card_mask"
                                 , ic.card_mask
                               )
                             , xmlelement(
                                   "card_short_mask"
                                 , iss_api_card_pkg.get_short_card_mask(
                                       i_card_number => ic.card_mask
                                   )
                               )
                           ) order by decode(ic.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1), ic.id desc
                       )
                   )
              from acc_account_object ao
                 , iss_card ic
             where ao.account_id  = i.account_id
               and ao.object_id   = ic.id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           ) as card_data
      into l_account_id
         , l_inst_contact
         , l_agent_contact
         , l_card_data
      from crd_invoice i
     where id = l_object_id;

    --user exit
    l_subject := crd_cst_report_pkg.get_subject(
        i_account_id  => l_account_id
      , i_eff_date    => l_eff_date
    );

    --attachment
    begin
        select xmlagg(
                    xmlelement("attachment",
                          xmlelement("attachment_path", t.attach_path)
                        , xmlelement("attachment_name", t.file_name)
                    )
                )
        into l_attach
        from (
        select c.file_name
             , c.save_path attach_path
          from rpt_document d
             , rpt_document_content c
         where object_id     = l_object_id
           and entity_type   = crd_api_const_pkg.ENTITY_TYPE_INVOICE
           and document_type = rpt_api_const_pkg.DOCUMENT_TYPE_CREDIT
           and c.document_id = d.id
        ) t;

    exception
        when no_data_found then
            null;
    end;

    --invoice
    select xmlelement("report"
            , xmlelement("subject", l_subject)
            , xmlelement("attachments"     , l_attach)
            , xmlelement("first_name"      , t.first_name)
            , xmlelement("second_name"     , t.second_name)
            , xmlelement("surname"         , t.surname)
            , xmlelement("account_number"  , t.account_number)
            , xmlelement("currency"        , t.currency_name)
            , xmlelement("invoice_date"    , to_char(t.invoice_date, com_api_const_pkg.XML_DATETIME_FORMAT))
            , xmlelement("invoice_date_short"  , to_char(t.invoice_date, 'DD/MM/YYYY'))
            , xmlelement("total_amount_due", com_api_currency_pkg.get_amount_str(nvl(t.total_amount_due, 0), t.currency, com_api_const_pkg.TRUE))
            , xmlelement("min_amount_due"  , com_api_currency_pkg.get_amount_str(nvl(t.min_amount_due, 0), t.currency, com_api_const_pkg.TRUE))
            , xmlelement("due_date"        , to_char(t.due_date, com_api_const_pkg.XML_DATETIME_FORMAT))
            , xmlelement("due_date_short"      , to_char(t.due_date, 'DD/MM/YYYY'))
            , xmlelement("due_date_short_year" , to_char(t.due_date, 'DD/MM/YY'))
            , xmlelement("due_date_month"      , to_char(t.due_date, 'MM/YY'))
            , xmlelement("overdue_date" , to_char(t.overdue_date, 'DD/MM/YYYY'))
            , xmlelement("min_amount_due", t.min_amount_due)
            , l_inst_contact
            , l_agent_contact
            , l_card_data
         )
    into l_result
    from (
        select a.id
             , com_ui_person_pkg.get_first_name(i_person_id => s.object_id, i_lang => l_lang) first_name
             , com_ui_person_pkg.get_second_name(i_person_id => s.object_id, i_lang => l_lang) second_name
             , com_ui_person_pkg.get_surname(i_person_id => s.object_id, i_lang => l_lang) surname
             , a.account_number
             , a.currency
             , i.invoice_date
             , i.total_amount_due
             , i.min_amount_due
             , i.due_date
             , i.overdue_date
             , c.name currency_name
          from crd_invoice i
             , acc_account a
             , prd_customer s
             , com_currency c
         where i.id           = l_object_id
           and i.account_id   = a.id
           and a.customer_id  = s.id
           and c.code         = a.currency
    ) t;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text       => 'end'
    );
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end mad_overdue;

procedure run_prc_report(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) is
begin
    run_report(
        o_xml            => o_xml
        , i_lang         => i_lang
        , i_invoice_id   => i_object_id
        , i_mode         => crd_api_const_pkg.CREDIT_STMT_MODE_DATA_ONLY
    );
end run_prc_report;

procedure run_prc_credit_full(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) is
begin
    run_report(
        o_xml            => o_xml
        , i_lang         => i_lang
        , i_invoice_id   => i_object_id
        , i_mode         => crd_api_const_pkg.CREDIT_STMT_MODE_FULL
    );
end run_prc_credit_full;

procedure run_prc_credit_dpp(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) is
begin
    run_report(
        o_xml            => o_xml
        , i_lang         => i_lang
        , i_invoice_id   => i_object_id
        , i_mode         => crd_api_const_pkg.CREDIT_STMT_MODE_DATA_N_DPP
    );
end run_prc_credit_dpp;

procedure run_prc_credit_lty(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) is
begin
    run_report(
        o_xml            => o_xml
        , i_lang         => i_lang
        , i_invoice_id   => i_object_id
        , i_mode         => crd_api_const_pkg.CREDIT_STMT_MODE_DATA_N_LTY
    );
end run_prc_credit_lty;

end crd_api_report_pkg;
/
