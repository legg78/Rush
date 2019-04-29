create or replace package body cst_ibbl_report_pkg as

NUM_FORMAT constant varchar2(50) := 'FM999G999G999G999G999G990D0099';

procedure run_report (
    o_xml                  out  clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_invoice_id        in      com_api_type_pkg.t_medium_id
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
    l_charges_amount            com_api_type_pkg.t_money;
    l_payment_amount            com_api_type_pkg.t_money;
    l_dpp_amount                com_api_type_pkg.t_money;
    l_customer_id               com_api_type_pkg.t_medium_id;

    l_region                    com_api_type_pkg.t_name;
    l_city                      com_api_type_pkg.t_name;
    l_street                    com_api_type_pkg.t_name;
    l_house                     com_api_type_pkg.t_name;
    l_district_name             com_api_type_pkg.t_name;
    l_division_name             com_api_type_pkg.t_name;
    l_country_name              com_api_type_pkg.t_name;
    l_postal_code               com_api_type_pkg.t_name;
    l_account_rec               acc_api_type_pkg.t_account_rec;
    l_invoice_rec               crd_api_type_pkg.t_invoice_rec;
begin
    trc_log_pkg.debug (
        i_text          => 'Run statement report [#1] [#2]'
        , i_env_param1  => i_lang
        , i_env_param2  => i_invoice_id
    );

    l_lang := nvl(i_lang, get_user_lang);
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
    l_customer_id   := l_account_rec.customer_id;

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
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and object_id         = l_account_id
               and s.id              = o.service_id
               and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                  , i_env_param1    => l_account_id
                  , i_env_param2    => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                );
        end;
    else
        l_start_date := l_lag_invoice.invoice_date;
    end if;

    l_currency_name :=
        com_api_currency_pkg.get_currency_name(
            i_curr_code     => l_currency
        );

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
     where l.account_id  = b.column_value
       and l.expire_date between l_start_date and l_invoice_date
       and l.status      = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
       and l.split_hash  = l_split_hash;

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
                where a.account_id   = b.column_value
                  and a.split_hash   = l_split_hash
                  and a.posting_date between l_start_date and l_invoice_date
           );

    select sum(d.amount) as charges_amount
      into l_charges_amount
      from (select distinct debt_id
              from crd_invoice_debt_vw
             where invoice_id = i_invoice_id
               and is_new     = com_api_const_pkg.TRUE
           ) e
         , crd_debt d
     where d.id         = e.debt_id
       and not exists (select 1 from dpp_payment_plan p
                        where p.reg_oper_id = d.oper_id);

    select sum(m.amount) as payment_amount
      into l_payment_amount
      from crd_invoice_payment p
         , crd_payment m
     where p.invoice_id = i_invoice_id
       and p.is_new     = com_api_const_pkg.TRUE
       and m.id         = p.pay_id
       and not exists (select 1 from dpp_payment_plan d
                        where d.oper_id = m.original_oper_id);

    select sum(p.dpp_amount)
      into l_dpp_amount
      from (select distinct debt_id
              from crd_invoice_debt_vw
             where invoice_id = i_invoice_id
               and is_new     = com_api_const_pkg.TRUE
           ) e
         , crd_debt d
         , dpp_payment_plan p
     where d.id                    = e.debt_id
       and d.oper_id               = p.reg_oper_id;

    -- Select address for IBBL statement
    begin
        select a.region
             , a.city
             , a.street
             , a.house
             , ds.place_name as district_name
             , dv.place_name as division_name
             , com_api_country_pkg.get_country_full_name(
                   i_code            => a.country
                 , i_lang            => a.lang
                 , i_raise_error     => com_api_const_pkg.FALSE
               ) as country_name
             , a.postal_code
          into l_region
             , l_city
             , l_street
             , l_house
             , l_district_name
             , l_division_name
             , l_country_name
             , l_postal_code
          from (select o.object_id
                     , a.house
                     , a.street
                     , a.apartment
                     , a.postal_code
                     , a.city
                     , a.region
                     , a.country
                     , a.lang
                     , o.address_type
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
                  from com_address a
                     , com_address_object o
                 where a.id          = o.address_id 
                   and o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER -- 'ENTTCUST'
               ) a
             , adr_place ds
             , adr_place dv
         where a.object_id   = l_customer_id
           and a.apartment   = ds.place_code
           and ds.comp_id   in (select id from adr_component where country_id = 50)
           and a.postal_code = dv.place_code
           and dv.comp_id   in (select id from adr_component where country_id = 50)
           and a.rn          = 1;
    exception
        when no_data_found then
            l_region        := null;
            l_city          := null;
            l_street        := null;
            l_house         := null;
            l_district_name := null;
            l_division_name := null;
            l_country_name  := null;
            l_postal_code   := null;
    end;
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
             , xmlelement("loyalty_incoming" , com_api_currency_pkg.get_amount_str(nvl(l_loyalty_incoming, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_earned", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_earned, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_spent", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_spent, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_expired", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_expired, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("loyalty_outgoing", com_api_currency_pkg.get_amount_str(nvl(l_loyalty_outgoing, 0), l_loyalty_currency, com_api_const_pkg.TRUE))
             , xmlelement("charges_amount", com_api_currency_pkg.get_amount_str(nvl(l_charges_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("credit_amount", com_api_currency_pkg.get_amount_str(nvl(l_payment_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("avail_balance_dpp", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0) - nvl(l_dpp_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("total_amount_due_dpp", com_api_currency_pkg.get_amount_str(nvl(total_amount_due, 0) + nvl(l_dpp_amount, 0), l_currency, com_api_const_pkg.TRUE))
             , xmlelement("IBBL_delivery_address"
                 , xmlelement("region", l_region)
                 , xmlelement("city", l_city)
                 , xmlelement("street", l_street)
                 , xmlelement("house", l_house)
                 , xmlelement("postal_code", l_postal_code)
                 , xmlelement("country", l_country_name)
                 , xmlelement("district_name", l_district_name)
                 , xmlelement("division_name", l_division_name)
               )
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
                   and d.oper_type            != opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                   and o.merchant_country      = r.code(+)
                   and d.currency              = cr.code(+)
                   and o.oper_currency         = cr2.code(+)
                   and o.mcc                   = cm.mcc(+)
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
                   and d.oper_type             = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE--'OPTP0119'
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

procedure prepaid_card_statement(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number
  , i_start_date        in     date                              default null
  , i_end_date          in     date                              default null
  , i_lang              in     com_api_type_pkg.t_dict_value     default null
) is
    l_start_date              date := i_start_date;
    l_end_date                date := i_end_date;
    l_lang                    com_api_type_pkg.t_dict_value;

    l_header                  xmltype;
    l_detail                  xmltype;
    l_result                  xmltype;
    
    l_card_mask               com_api_type_pkg.t_card_number;
    l_cardholder_name         com_api_type_pkg.t_name;
    l_card_address            com_api_type_pkg.t_name;
    l_card_open_date          date;
    l_customer_number         com_api_type_pkg.t_name;
    l_debit_total             com_api_type_pkg.t_money;
    l_credit_total            com_api_type_pkg.t_money;
    l_last_balance_ledger     com_api_type_pkg.t_money;
begin
    l_lang       := nvl(i_lang, get_user_lang);
    l_end_date   := trunc(nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) - com_api_const_pkg.ONE_SECOND;
    l_start_date := trunc(nvl(i_start_date, add_months(trunc(l_end_date), -1)));
   
    trc_log_pkg.debug (
        i_text        => 'cst_ibb_report_pkg.prepaid_card_statement [#1][#2][#3][#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => i_inst_id
      , i_env_param3  => i_account_number
      , i_env_param4  => to_char(l_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param5  => to_char(l_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
    );
    
    begin
        select c.card_mask
             , ch.cardholder_name
             , c.reg_date
             , cu.customer_number
             , (select upper(rtrim(ltrim(a.postal_code   || ', ' ||
                                         a.region        || ', ' ||
                                         a.city          || ', ' ||
                                         a.street        || ', ' ||
                                         a.house         || ', ' ||
                                         a.apartment
                                      , ', ')
                                , ', ')
                            )
                 from (select o.object_id
                            , a.house
                            , a.street
                            , a.apartment
                            , a.postal_code
                            , a.city
                            , a.region
                            , a.country
                            , a.lang
                            , o.address_type
                            , row_number() over (partition by o.object_id
                                                     order by decode(o.address_type
                                                                   , 'ADTPLGLA', 1
                                                                   , 'ADTPHOME', 2
                                                                   , 'ADTPBSNA', 3
                                                                   , 4
                                                              )
                                                            , decode(a.lang
                                                                   , l_lang, -1
                                                                   , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                   , o.address_id
                                                              )
                                                ) rn
                         from com_address a
                            , com_address_object o
                        where a.id          = o.address_id 
                          and o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      ) a
                where a.object_id   = cu.id
                  and a.rn          = 1
               ) as adr
          into l_card_mask
             , l_cardholder_name
             , l_card_open_date
             , l_customer_number
             , l_card_address
          from iss_card c
             , prd_customer cu
             , iss_cardholder ch
             , acc_account a
             , acc_account_object o
         where c.customer_id    = cu.id
           and ch.id            = c.cardholder_id
           and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.object_id      = c.id
           and o.account_id     = a.id
           and a.account_number = i_account_number
           and a.inst_id        = i_inst_id
           and a.customer_id    = cu.id;
    exception
        when too_many_rows then
            select min(c.card_mask) keep (dense_rank first order by c.reg_date)
                 , min(ch.cardholder_name) keep (dense_rank first order by c.reg_date)
                 , min(c.reg_date) keep (dense_rank first order by c.reg_date)
                 , min(cu.customer_number) keep (dense_rank first order by c.reg_date)
                 , min((select upper(rtrim(ltrim(a.postal_code   || ', ' ||
                                                 a.region        || ', ' ||
                                                 a.city          || ', ' ||
                                                 a.street        || ', ' ||
                                                 a.house         || ', ' ||
                                                 a.apartment
                                              , ', ')
                                        , ', ')
                                    )
                         from com_address a
                            , com_address_object o
                        where a.id          = o.address_id 
                          and o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          and o.object_id   = cu.id)
                          ) as adr
              into l_card_mask
                 , l_cardholder_name
                 , l_card_open_date
                 , l_customer_number
                 , l_card_address
              from iss_card c
                 , prd_customer cu
                 , iss_cardholder ch
                 , acc_account a
                 , acc_account_object o
             where c.customer_id    = cu.id
               and cu.id            = a.customer_id
               and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.object_id      = c.id
               and o.account_id     = a.id
               and a.inst_id        = i_inst_id
               and a.account_number = i_account_number
               and ch.id            = c.cardholder_id
               and c.category       = iss_api_const_pkg.CARD_CATEGORY_PRIMARY;
        when no_data_found then
            l_card_mask       := null;
            l_cardholder_name := null;
            l_card_open_date  := null;
            l_customer_number := null;
            l_card_address    := null;
    end;

    begin
        select max(l.balance_orig) keep (dense_rank last order by l.rn) as last_balance_ladger
          into l_last_balance_ledger
          from (select row_number() over(order by e.id) rn
                     , round(e.balance / power(10, ec.exponent), 2) as balance_orig
                  from opr_operation o
                     , acc_macros m
                     , acc_entry e
                     , acc_balance b
                     , acc_balance_type t
                     , acc_account a
                     , com_currency ec
                 where a.account_number = i_account_number
                   and a.inst_id        = i_inst_id
                   and b.account_id     = a.id
                   and b.balance_type  != acc_api_const_pkg.BALANCE_TYPE_HOLD
                   and t.account_type   = a.account_type
                   and t.balance_type   = b.balance_type
                   and t.inst_id        = a.inst_id
                   and m.object_id      = o.id
                   and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and m.id             = e.macros_id
                   and e.account_id     = a.id
                   and e.balance_type   = b.balance_type
                   and e.status        != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                   and m.account_id     = a.id
                   and e.currency       = ec.code
                   and o.oper_date     >= trunc(l_start_date)
                   and o.oper_date     <  trunc(l_end_date)
               ) l;
    exception
        when no_data_found then
            l_last_balance_ledger := 0;
    end;

    -- detail
    select xmlelement(
              "details"
             , xmlagg(
                   xmlelement(
                      "detail"
                     , xmlelement("rn"            , rn)
                     , xmlelement("oper_date"     , to_char(oper_date, 'DD-MON-YY'))
                     , xmlelement("particulars"   , particulars)
                     , xmlelement("oper_amount"   , to_char(oper_amount, NUM_FORMAT, 'NLS_NUMERIC_CHARACTERS = ''.,'''))
                     , xmlelement("oper_curr"     , oper_curr)
                     , xmlelement("amount_orig"   , to_char(abs(amount_orig), NUM_FORMAT, 'NLS_NUMERIC_CHARACTERS = ''.,'''))
                     , xmlelement("currency_orig" , currency_orig)
                     , xmlelement("balance"       , to_char(current_balance, NUM_FORMAT, 'NLS_NUMERIC_CHARACTERS = ''.,'''))
                     , xmlelement("amount_sign"   , amount_sign)
                     , xmlelement("balance_type"  , balance_type) 
                   )
               order by rn ) 
           ) 
         , sum(case when amount_sign = -1
                    then abs(amount_orig)
                    else 0 
               end) as total_debit
         , sum(case when amount_sign = 1
                    then amount_orig 
                    else 0 
               end) as total_credit
    into l_detail
         , l_debit_total
         , l_credit_total
    from(
        select row_number() over(order by e_id) rn
             , o.oper_date
             , round(o.oper_amount / power(10, oc.exponent), 2) as oper_amount
             , com_api_currency_pkg.get_currency_name(i_curr_code =>  o.oper_currency) as oper_curr
             , case
                   when amount_purpose like 'FETP%' then ''||get_article_text(amount_purpose)||'. '
                   else null
               end
               || com_api_dictionary_pkg.get_article_text(o.oper_type, l_lang)
               || ' ' 
               || o.merchant_name   as particulars
             , e.balance_type
             , case when amount_signed > 0 then 1 else -1 end as amount_sign
             , com_api_currency_pkg.get_currency_name(i_curr_code => e.currency) as currency_orig
             , round((e.amount_signed) / power(10, ec.exponent), 2) as amount_orig
             , round(balance / power(10, ec.exponent), 2) as current_balance
             , e_rn
        from(
            select currency
                 , entry_id
                 , amount_signed
                 , oper_id
                 , balance
                 , balance_type
                 , account_id
                 , e_id
                 , amount_purpose
                 , e_rn
            from(
                select row_number() over(partition by m.object_id, e.currency, case when amount_purpose like 'FETP%' then null else 0 end order by e.id asc) as e_rn
                     , e.id as e_id
                     , e.currency
                     , e.balance_type
                     , e.account_id
                     , e.balance
                     , m.object_id as oper_id
                     , m.amount_purpose
                     , max(e.id) over(partition by m.object_id, e.currency, case when amount_purpose not like 'FETP%' then 0 else null end order by e.id desc) as entry_id
                     , sum(e.balance_impact * e.amount) over(partition by m.object_id, e.currency, case when amount_purpose not like 'FETP%' then 0 else null end order by e.id desc) as amount_signed
                from acc_entry e
                   , acc_macros m
                   , (
                      select a.id as account_id
                           , a.inst_id
                           , a.account_type
                           , a.account_number
                           , b.balance_type
                        from acc_account a
                           , acc_balance b
                       where 1 = 1
                         and a.account_number   = i_account_number
                         and a.inst_id          = i_inst_id
                         and a.id               = b.account_id 
                         and b.balance_type    != acc_api_const_pkg.BALANCE_TYPE_HOLD
                       ) a
                where 1 = 1
                  and e.status        != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                  and e.macros_id      = m.id 
                  and e.account_id     = m.account_id
                  and e.balance_type   = a.balance_type
                  and e.account_id     = a.account_id
                  and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
            ) e 
        ) e
         , (
            select o.oper_date
                 , o.oper_currency
                 , o.merchant_name
                 , o.oper_type
                 , o.oper_amount
                 , o.id              as operation_id
              from opr_operation o
             where 1 = 1
               and o.oper_date  >= trunc(l_start_date)
               and o.oper_date  <  trunc(l_end_date)
           ) o
         , com_currency oc
         , com_currency ec
     where 1 = 1
       and e.oper_id      = o.operation_id
       and o.oper_currency  = oc.code
       and e.currency       = ec.code
    )
    where e_rn = 1
    ;

    if l_detail.getclobval() = '<details></details>' then
        com_api_error_pkg.raise_error(
            i_error      => 'REPORT_RETURNS_EMPTY_RESULT'
        );
        select xmlelement(
              "details"
             , xmlagg(
                  xmlelement(
                      "detail"
                     , xmlelement("rn"            , null)
                     , xmlelement("oper_date"     , null)
                     , xmlelement("particulars"   , null)
                     , xmlelement("oper_amount"   , null)
                     , xmlelement("oper_curr"     , null)
                     , xmlelement("amount_orig"   , null)
                     , xmlelement("currency_orig" , null)
                     , xmlelement("balance"       , null)
                     , xmlelement("amount_sign"   , null)
                     , xmlelement("balance_type"  , null)
                  )
              ) 
          )
          into l_detail
          from dual;
    end if;

    -- header
    select xmlelement(
               "header"
             , xmlelement("p_start_date"      , to_char(l_start_date, 'dd-mm-yyyy'))
             , xmlelement("p_end_date"        , to_char(l_end_date, 'dd-mm-yyyy'))
             , xmlelement("p_card_mask"       , l_card_mask)
             , xmlelement("p_customer_number" , l_customer_number)
             , xmlelement("p_cardholder_name" , l_cardholder_name)
             , xmlelement("p_card_address"    , l_card_address)
             , xmlelement("p_card_open_date"  , to_char(l_card_open_date, 'DD-MON-YY'))
             , xmlelement("p_account_number"  , i_account_number)
             , xmlelement("p_debit_total"     , to_char(nvl(l_debit_total,  0), NUM_FORMAT))
             , xmlelement("p_credit_total"    , to_char(nvl(l_credit_total, 0), NUM_FORMAT))
             , xmlelement("p_last_balance"    , to_char(nvl(l_last_balance_ledger, 0), NUM_FORMAT))
           )
      into l_header
      from dual;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_ibb_report_pkg.prepaid_card_statement - ok'
    );

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end prepaid_card_statement;

procedure prepaid_card_statement_wrapped(
    o_xml               out clob
  , i_lang              in com_api_type_pkg.t_dict_value
  , i_eff_date          in date
  , i_inst_id           in com_api_type_pkg.t_inst_id
  , i_object_id         in com_api_type_pkg.t_long_id
  , i_entity_type       in com_api_type_pkg.t_dict_value  DEFAULT acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
) is
    l_start_date        date;
    l_end_date          date;
    l_account_number    com_api_type_pkg.t_account_number;
begin
    l_end_date   := trunc(nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate) + 1) - com_api_const_pkg.ONE_SECOND;
    l_start_date := trunc(add_months(l_end_date, -1));

    select account_number
      into l_account_number
      from acc_account
     where id = i_object_id;

    trc_log_pkg.debug (
        i_text              => 'cst_ibb_report_pkg.prepaid_card_statement [#1][#2][#3][#4][#5]'
      , i_env_param1        => i_lang
      , i_env_param2        => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3        => i_inst_id
      , i_env_param4        => i_object_id
      , i_env_param5        => i_entity_type
    );

    prepaid_card_statement(
        o_xml               => o_xml
      , i_inst_id           => i_inst_id
      , i_account_number    => l_account_number
      , i_start_date        => l_start_date
      , i_end_date          => l_end_date
      , i_lang              => i_lang
    );

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end prepaid_card_statement_wrapped;

procedure prepaid_statement_event(
    o_xml               out    clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
    l_attach            xmltype;
    l_subject           com_api_type_pkg.t_full_desc;
    l_inst_contact      xmltype;
    l_agent_contact     xmltype;
    l_card_data         xmltype;
    l_object_id         com_api_type_pkg.t_long_id;
    l_start_date        date;
    l_end_date          date;
begin
    l_end_date   := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
    l_start_date := add_months(trunc(l_end_date), -1);

     trc_log_pkg.debug (
        i_text       => 'Prepaid statment event notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_object_id := i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;
    --account and institution, agent contact data
    select (select xmlelement(
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
                                     , i_start_date    => i_eff_date
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
                                     , i_start_date    => i_eff_date
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
             where ao.account_id  = i.id
               and ao.object_id   = ic.id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           ) as card_data
      into l_inst_contact
         , l_agent_contact
         , l_card_data
      from acc_account i
     where id = l_object_id;

    --user exit
    select 'Prepaid statement of ' || account_number as res
      into l_subject
      from acc_account 
     where id = i_object_id;

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
             , row_number() over(partition by d.object_id order by d.id desc) rnum
          from rpt_document d
             , rpt_document_content c
         where d.object_id     = l_object_id
           and d.document_date between l_start_date and l_end_date
           and d.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and d.document_type = rpt_api_const_pkg.DOCUMENT_TYPE_CREDIT
           and c.document_id   = d.id
        ) t
        where rnum = 1;

    exception
        when no_data_found then
            null;
    end;

    select xmlconcat(
            xmlelement("subject", l_subject)
            , xmlelement("attachments"     , l_attach)
            , xmlelement("first_name"      , t.first_name)
            , xmlelement("second_name"     , t.second_name)
            , xmlelement("surname"         , t.surname)
            , xmlelement("account_number"  , t.account_number)
            , xmlelement("currency"        , t.currency_name)
            , xmlelement("start_date"      , to_char(t.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
            , xmlelement("end_date"        , to_char(t.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
            , l_inst_contact
            , l_agent_contact
            , l_card_data
         )
    into l_result
    from (
        select a.id
             , com_ui_person_pkg.get_first_name(i_person_id => s.object_id, i_lang => i_lang) first_name
             , com_ui_person_pkg.get_second_name(i_person_id => s.object_id, i_lang => i_lang) second_name
             , com_ui_person_pkg.get_surname(i_person_id => s.object_id, i_lang => i_lang) surname
             , a.account_number
             , a.currency
             , l_start_date start_date
             , l_end_date end_date
             , c.name currency_name
          from acc_account a
             , prd_customer s 
             , com_currency c
         where a.id           = l_object_id
           and a.customer_id  = s.id
           and c.code         = a.currency
    ) t;

    o_xml := l_result.getclobval();  

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end prepaid_statement_event;

procedure run_report_wrapped(
    o_xml                  out clob
  , i_account_id        in     com_api_type_pkg.t_account_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    l_invoice_id               com_api_type_pkg.t_medium_id;
    l_split_hash               com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := 
        com_api_hash_pkg.get_split_hash(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    l_invoice_id  := 
        crd_invoice_pkg.get_last_invoice_id(
            i_account_id => i_account_id
          , i_split_hash => l_split_hash
          , i_mask_error => com_api_const_pkg.FALSE
        );
    run_report(
        o_xml           => o_xml
      , i_lang          => i_lang
      , i_invoice_id    => l_invoice_id
    );
end run_report_wrapped;

procedure credit_payment(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_date              in     date
  , i_card_number       in     com_api_type_pkg.t_card_number   default null
  , i_tran_status       in     com_api_type_pkg.t_tiny_id       default null
  , i_src_system        in     com_api_type_pkg.t_tiny_id       default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
)
is
    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;
    l_account_id        com_api_type_pkg.t_medium_id    default null;
    l_status_processed  com_api_type_pkg.t_dict_value   default null;
    l_status_unheld     com_api_type_pkg.t_dict_value   default null;
    l_status_error      com_api_type_pkg.t_dict_value   default null;
    l_status_unsuccess  com_api_type_pkg.t_dict_value   default null;
    l_status_reversal   com_api_type_pkg.t_boolean      default null;
    l_payment_CBS       com_api_type_pkg.t_dict_value   default null;
    l_payment_ATM       com_api_type_pkg.t_dict_value   default null;
    l_payment_ibank     com_api_type_pkg.t_dict_value   default null;
begin

    if i_date is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
          , i_env_param1    => 'I_DATE'
          , i_env_param2    => 'credit_payment'
        );
    end if;
    
    case when i_tran_status = 1 then
            l_status_processed  := opr_api_const_pkg.OPERATION_STATUS_PROCESSED;    --'OPST0400'
            l_status_unheld     := opr_api_const_pkg.OPERATION_STATUS_UNHOLDED;     --'OPST0402'             
         when i_tran_status = 2 then
            l_status_error      := opr_api_const_pkg.OPERATION_STATUS_EXCEPTION;    --'OPST0500'
            l_status_unsuccess  := opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL; --'OPST0501'
         when i_tran_status = 3 then
            l_status_reversal   := com_api_type_pkg.TRUE; 
         when i_tran_status is null then
            null;                               
    end case;
    
    case when i_src_system = 1 then
            l_payment_CBS   := cst_ibbl_api_const_pkg.OPERATION_PAYMENT_CBS; --'OPTP7030'             
         when i_src_system = 2 then
            l_payment_ATM   := opr_api_const_pkg.OPERATION_TYPE_PAYMENT; --'OPTP0028'
         when i_src_system = 3 then
            l_payment_ibank := '';
         when i_src_system is null then
            null;                           
    end case;
    
    if i_card_number is not null then
        begin
            select o.account_id
              into l_account_id
              from acc_account_object o
                 , acc_account a
                 , iss_card_number n
             where o.object_id = n.card_id
               and o.account_id = a.id    
               and a.split_hash = o.split_hash        
               and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT    
               and a.inst_id = coalesce(i_inst_id, a.inst_id)
               and reverse(n.card_number) = reverse(i_card_number)
               and rownum = 1
               ;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'UNKNOWN_ACCOUNT'
                  , i_env_param1    => 'card_number='
                  , i_env_param2    => i_card_number
                );
        end;
    end if;
    
    -- header
    select xmlelement(
               "header"
             , xmlelement("p_date", to_char(i_date, 'dd/mm/yyyy'))
           )
      into l_header
      from dual;

    begin
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("row_num"     , r.row_num)
                     , xmlelement("card_number" , r.card_number)
                     , xmlelement("account_num" , r.account_num)
                     , xmlelement("src_system"  , r.src_system)
                     , xmlelement("tran_date"   , r.tran_date)
                     , xmlelement("amount"      , r.amount)
                     , xmlelement("tran_status" , r.tran_status)
                     , xmlelement("reason"      , r.reason)
                   )
               )
            )
      into l_detail
      from (select rownum as row_num
                 , t.card_number
                 , t.account_num
                 , t.src_system
                 , t.tran_date
                 , t.amount
                 , t.tran_status
                 , t.reason
              from (select nvl(iss_api_card_pkg.get_card_number(p.card_id)
                             , (select iss_api_token_pkg.decode_card_number(i_card_number => n.card_number)
                                  from acc_account_object o
                                     , acc_account a
                                     , iss_card_number n
                                 where o.object_id = n.card_id
                                   and o.account_id = a.id    
                                   and a.split_hash = o.split_hash        
                                   and a.id = p.account_id
                                   and rownum = 1)
                              ) as card_number
                         , (select account_number
                              from acc_account 
                             where id = p.account_id
                           ) as account_num
                         , case
                                when o.oper_type = cst_ibbl_api_const_pkg.OPERATION_PAYMENT_CBS                                        
                                then 'CBS'
                                when o.oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                then 'ATM'            
                           end as src_system
                         , o.host_date as tran_date
                         , p.amount
                         , case
                                when o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                                , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED)
                                 and p.is_reversal = 0                                              
                                then 'Success'
                                when o.status in (opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                                                , opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL)
                                 and p.is_reversal = 0
                                then 'Failure'                                                               
                                when p.is_reversal = 1 
                                then 'Reversed'
                           end as tran_status
                         , case
                                when o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                                , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED)    
                                 and p.is_reversal = 0                          
                                then 'OK'
                                when o.status in (opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                                                , opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL)
                                 and p.is_reversal = 0                              
                                then o.status_reason || '-' || com_api_dictionary_pkg.get_article_text(o.status_reason)
                                when p.is_reversal = 1 
                                then o.status_reason || '-' || com_api_dictionary_pkg.get_article_text(o.status_reason)
                           end as reason
                      from crd_payment p
                         , opr_operation o
                     where o.id = p.oper_id                                              
                       and (i_tran_status is null
                            or
                            o.status in (l_status_processed
                                       , l_status_unheld
                                       , l_status_error
                                       , l_status_unsuccess)
                           )
                       and (i_src_system is null
                            or
                            o.oper_type in (l_payment_CBS
                                          , l_payment_ATM
                                          , l_payment_ibank)
                           )
                       and (l_status_reversal is null or o.is_reversal = l_status_reversal)
                       and (nvl(i_card_number, 1) = decode(i_card_number, null, 1, iss_api_card_pkg.get_card_number(p.card_id))
                            or
                            p.account_id = coalesce(l_account_id, p.account_id)
                           )
                       and p.inst_id = coalesce(i_inst_id, p.inst_id)
                       and trunc(o.host_date) = trunc(i_date)
                       and o.id between com_api_id_pkg.get_from_id(i_date) and com_api_id_pkg.get_till_id(i_date)
                    )t
            )r;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'No data found for report cst_ibbl_report_pkg.credit_payment'
            );
    end;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_ibbl_report_pkg.credit_payment -> Finish'
    );
end credit_payment;

procedure rit_report(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_month             in      com_api_type_pkg.t_tiny_id
  , i_year              in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
)
is
    l_lang                      com_api_type_pkg.t_dict_value;
    l_month                     com_api_type_pkg.t_tiny_id;
    l_year                      com_api_type_pkg.t_tiny_id;  
    l_header                    xmltype;
    l_detail                    xmltype;
    l_result                    xmltype;
begin
    
    trc_log_pkg.debug(
        i_text => 'cst_ibbl_report_pkg.rit_report -> Begin'
    );  
    
    if i_month is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
          , i_env_param1    => 'I_MONTH'
          , i_env_param2    => 'rit_report'
        );
    end if;
    
    if i_year is null then
        com_api_error_pkg.raise_error (
            i_error         => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
          , i_env_param1    => 'I_YEAR'
          , i_env_param2    => 'rit_report'
        );
    end if;
    
    if i_year not between 2000 and 2100 then
        com_api_error_pkg.raise_error (
            i_error         => 'INVALID_REQUEST'
        );
    end if;    
    
    l_month := i_month;
    l_year  := i_year;
    l_lang  := nvl(i_lang, get_user_lang);

    --Header info
    select xmlelement(
               "header"
             , xmlelement("report_date", to_char(i_month, '09') || '-' || to_char(i_year))
           )
      into l_header
      from dual;
        
    --Details info
    select xmlelement(
           "details"
            , xmlelement("no_of_atm"                , 'N/A')
            , xmlelement("no_of_pos"                , 'N/A')
            , xmlelement("do_you_issue_etc"         , 'Not yet')
            , xmlelement("do_you_acq_etc"           , 'Not yet')
            , xmlelement("issued_local_credit"      , r.issued_local_credit)
            , xmlelement("issued_dual_credit"       , r.issued_dual_credit)
            , xmlelement("issued_intna_credit"      , r.issued_intna_credit)
            , xmlelement("issued_local_debit"       , r.issued_local_debit)
            , xmlelement("issued_intna_debit"       , r.issued_intna_debit)
            , xmlelement("issued_local_prepaid"     , r.issued_local_prepaid)
            , xmlelement("issued_intna_prepaid"     , r.issued_intna_prepaid)
            , xmlelement("debit_atm_bd_no_tran"     , r.debit_atm_bd_no_tran)
            , xmlelement("debit_atm_bd_value"       , r.debit_atm_bd_value)
            , xmlelement("debit_pos_bd_no_tran"     , r.debit_pos_bd_no_tran)
            , xmlelement("debit_pos_bd_value"       , r.debit_pos_bd_value)
            , xmlelement("debit_ecom_bd_no_tran"    , r.debit_ecom_bd_no_tran)
            , xmlelement("debit_ecom_bd_value"      , r.debit_ecom_bd_value)
            , xmlelement("debit_atm_ab_no_tran"     , r.debit_atm_ab_no_tran)
            , xmlelement("debit_atm_ab_value"       , r.debit_atm_ab_value)
            , xmlelement("debit_pos_ab_no_tran"     , r.debit_pos_ab_no_tran)
            , xmlelement("debit_pos_ab_value"       , r.debit_pos_ab_value)
            , xmlelement("debit_ecom_ab_no_tran"    , r.debit_ecom_ab_no_tran)
            , xmlelement("debit_ecom_ab_value"      , r.debit_ecom_ab_value)
            , xmlelement("credit_atm_bd_no_tran"    , r.credit_atm_bd_no_tran)
            , xmlelement("credit_atm_bd_value"      , r.credit_atm_bd_value)
            , xmlelement("credit_pos_bd_no_tran"    , r.credit_pos_bd_no_tran)
            , xmlelement("credit_pos_bd_value"      , r.credit_pos_bd_value)
            , xmlelement("credit_ecom_bd_no_tran"   , r.credit_ecom_bd_no_tran)
            , xmlelement("credit_ecom_bd_value"     , r.credit_ecom_bd_value)
            , xmlelement("credit_atm_ab_no_tran"    , r.credit_atm_ab_no_tran)
            , xmlelement("credit_atm_ab_value"      , r.credit_atm_ab_value)
            , xmlelement("credit_pos_ab_no_tran"    , r.credit_pos_ab_no_tran)
            , xmlelement("credit_pos_ab_value"      , r.credit_pos_ab_value)
            , xmlelement("credit_ecom_ab_no_tran"   , r.credit_ecom_ab_no_tran)
            , xmlelement("credit_ecom_ab_value"     , r.credit_ecom_ab_value)
            , xmlelement("credit_outstanding_amt"   , r.credit_outstanding_amt)
            , xmlelement("credit_year_intr_rate"    , r.credit_year_intr_rate)
            , xmlelement("prepaid_bd_no_tran"       , r.prepaid_bd_no_tran)
            , xmlelement("prepaid_bd_value"         , r.prepaid_bd_value)
            , xmlelement("prepaid_ab_no_tran"       , r.prepaid_ab_no_tran)
            , xmlelement("prepaid_ab_value"         , r.prepaid_ab_value)
            , xmlelement("fraud_atm_no"             , r.fraud_atm_no)
            , xmlelement("fraud_atm_value"          , r.fraud_atm_value)
            , xmlelement("acq_bd_debit_atm_no_tran" , r.acq_bd_debit_atm_no_tran)
            , xmlelement("acq_bd_debit_atm_value"   , r.acq_bd_debit_atm_value)
            , xmlelement("acq_bd_debit_pos_no_tran" , r.acq_bd_debit_pos_no_tran)
            , xmlelement("acq_bd_debit_pos_value"   , r.acq_bd_debit_pos_value)
            , xmlelement("acq_bd_credit_atm_no_tran", r.acq_bd_credit_atm_no_tran)
            , xmlelement("acq_bd_credit_atm_value"  , r.acq_bd_credit_atm_value)
            , xmlelement("acq_bd_credit_pos_no_tran", r.acq_bd_credit_pos_no_tran)
            , xmlelement("acq_bd_credit_pos_value"  , r.acq_bd_credit_pos_value)
            , xmlelement("acq_ab_atm_no_tran"       , r.acq_ab_atm_no_tran)
            , xmlelement("acq_ab_atm_value"         , r.acq_ab_atm_value)
            , xmlelement("acq_ab_pos_no_tran"       , r.acq_ab_pos_no_tran)
            , xmlelement("acq_ab_pos_value"         , r.acq_ab_pos_value)
            , xmlelement("acq_ab_ecom_no_tran"      , r.acq_ab_ecom_no_tran)
            , xmlelement("acq_ab_ecom_value"        , r.acq_ab_ecom_value)
            , xmlelement("acq_ab_prepaid_no_tran"   , r.acq_ab_prepaid_no_tran)
            , xmlelement("acq_ab_prepaid_value"     , r.acq_ab_prepaid_value)                               
            )
      into l_detail
     from (select * 
             from (select issued_local_credit
                        , issued_dual_credit
                        , issued_intna_credit
                        , issued_local_debit
                        , issued_intna_debit
                        , issued_local_prepaid
                        , issued_intna_prepaid
                        , debit_atm_bd_no_tran
                        , debit_atm_bd_value
                        , debit_pos_bd_no_tran
                        , debit_pos_bd_value
                        , debit_ecom_bd_no_tran
                        , debit_ecom_bd_value
                        , debit_atm_ab_no_tran
                        , debit_atm_ab_value
                        , debit_pos_ab_no_tran
                        , debit_pos_ab_value
                        , debit_ecom_ab_no_tran
                        , debit_ecom_ab_value
                        , credit_atm_bd_no_tran
                        , credit_atm_bd_value
                        , credit_pos_bd_no_tran
                        , credit_pos_bd_value
                        , credit_ecom_bd_no_tran
                        , credit_ecom_bd_value
                        , credit_atm_ab_no_tran
                        , credit_atm_ab_value
                        , credit_pos_ab_no_tran
                        , credit_pos_ab_value
                        , credit_ecom_ab_no_tran
                        , credit_ecom_ab_value
                        , credit_outstanding_amt
                        , credit_year_intr_rate
                        , prepaid_bd_no_tran
                        , prepaid_bd_value
                        , prepaid_ab_no_tran
                        , prepaid_ab_value
                        , fraud_atm_no
                        , fraud_atm_value
                        , acq_bd_debit_atm_no_tran
                        , acq_bd_debit_atm_value
                        , acq_bd_debit_pos_no_tran
                        , acq_bd_debit_pos_value
                        , acq_bd_credit_atm_no_tran
                        , acq_bd_credit_atm_value
                        , acq_bd_credit_pos_no_tran
                        , acq_bd_credit_pos_value
                        , acq_ab_atm_no_tran
                        , acq_ab_atm_value
                        , acq_ab_pos_no_tran
                        , acq_ab_pos_value
                        , acq_ab_ecom_no_tran
                        , acq_ab_ecom_value
                        , acq_ab_prepaid_no_tran
                        , acq_ab_prepaid_value
                     from cst_ibbl_bank_rit 
                    where i_month = l_month
                      and i_year = l_year
                    order by run_date desc
                 )
             where rownum = 1
            )r        
      ;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_ibbl_report_pkg.rit_report -> Finish'
    );    
exception    
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error => 'NO DATA! Please run container ''Custom processes for IBBL reports'' to generate data for this report, with input parameters: Month='
                       || l_month
                       || ', Year='
                       || l_year
        );  
end rit_report;

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
    );
end run_prc_report;

end cst_ibbl_report_pkg;
/
