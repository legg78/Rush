create or replace package body crd_cst_report_pkg as

function get_additional_amounts(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_invoice_id            in     com_api_type_pkg.t_medium_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_product_id            in     com_api_type_pkg.t_short_id  
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_eff_date              in     date
)return xmltype 
is
    l_result    xmltype;
begin
   
    return l_result;
end;

function get_subject(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
) return com_api_type_pkg.t_name 
is
    l_result            com_api_type_pkg.t_name;
    l_account_number    com_api_type_pkg.t_account_number;
    
begin
    select account_number 
      into l_account_number
      from acc_account 
     where id = i_account_id;
     
    l_result := 'Credit statement of ' || l_account_number;
    
    return l_result;
end;

function credit_statement_invoice_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
  , i_currency              in      com_api_type_pkg.t_curr_code
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml                           xmltype;
begin
    return l_xml;
end;

function card_statement(
    i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_agent_id             in     com_api_type_pkg.t_agent_id     default null
  , i_start_date           in     date                            default null
  , i_eff_date             in     date                            
  , i_product_id           in     com_api_type_pkg.t_short_id
  , i_contract_number      in     com_api_type_pkg.t_name         default null
  , i_customer_number      in     com_api_type_pkg.t_name         default null
  , i_currency             in     com_api_type_pkg.t_curr_code    default null
  , i_introduced_by        in     com_api_type_pkg.t_name         default null
  , i_lang                 in     com_api_type_pkg.t_dict_value   default null
) return clob
is
    l_header                xmltype;
    l_result                xmltype;
    l_interest              xmltype;
    l_interest_detail       xmltype;
    l_oper_detail           xmltype;
    l_instalment_detail     xmltype;
    l_loyalty_detail        xmltype;
    l_xml                   clob;

    l_account_id            com_api_type_pkg.t_account_id;
    l_invoice_id            com_api_type_pkg.t_medium_id;
    l_invoice_date          date;
    l_start_date            date;
    l_aval_balance          com_api_type_pkg.t_amount_rec;
    l_overdue_balance       com_api_type_pkg.t_amount_rec;
    l_overdue_intr_balance  com_api_type_pkg.t_amount_rec;
    l_ledger_balance        com_api_type_pkg.t_amount_rec;
    l_entry_balance         com_api_type_pkg.t_money            := 0;
    l_output_balance        com_api_type_pkg.t_money            := 0;
    l_total_income          com_api_type_pkg.t_money            := 0;
    l_total_expence         com_api_type_pkg.t_money            := 0;
    l_total_interest        com_api_type_pkg.t_money            := 0;
    l_interest_amount       com_api_type_pkg.t_money            := 0;
    l_debt_interest_amount  com_api_type_pkg.t_money            := 0;
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
    l_card_id               com_api_type_pkg.t_long_id;
    l_card_mask             com_api_type_pkg.t_card_number;
    l_cardholder_name       com_api_type_pkg.t_name;
    l_interest_period_date  date;
    
    l_calc_interest_end_attr   com_api_type_pkg.t_dict_value;
    
    procedure add_element_to_detail(
        i_header    in xmltype
    ) is
    begin
        select
            xmlconcat(
                xmlelement("operation"
                    , i_header
                    , xmlelement("oper_type", to_char(null))
                    , xmlelement("oper_description", l_oper_description)
                    , xmlelement("balance_type", to_char(null))
                    , xmlelement("card_mask", l_card_mask)
                    , xmlelement("cardholder_name", l_cardholder_name)
                    , xmlelement("card_id", l_card_id)
                    , xmlelement("posting_date", to_char(l_settl_date, 'dd/mm/yyyy'))
                    , xmlelement("oper_date", to_char(l_settl_date, 'dd/mm/yyyy'))
                    , xmlelement("oper_currency", l_aval_balance.currency)
                    , xmlelement("oper_amount", l_debt_interest_amount)
                    , xmlelement("credit_oper_amount", 0)
                    , xmlelement("debit_oper_amount", 0)
                    , xmlelement("overdraft_amount", 0)
                    , xmlelement("repayment_amount", 0)
                    , xmlelement("interest_amount", nvl(l_debt_interest_amount, 0))
                    , xmlelement("amount_points", 0 )
                    , xmlelement("oper_type_interest", 1)
                )
            )
          into l_interest
          from dual;

        -- add node to detail
        select xmlconcat(l_interest_detail, l_interest) r
          into l_interest_detail
          from dual;
    end;

begin
    trc_log_pkg.debug(
        i_text        => 'Run credit_card_statement [#1] [#2] [#3] [#4] [#5] [#6] ['||i_currency||'] ['||i_introduced_by||'] ['||i_lang||']'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_agent_id
      , i_env_param3  => i_eff_date
      , i_env_param4  => i_product_id
      , i_env_param5  => i_contract_number
      , i_env_param6  => i_customer_number
    );

    l_lang        := nvl(i_lang, get_user_lang);
    l_settl_date  := nvl(trunc(i_eff_date), com_api_sttl_day_pkg.get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;

    for cur_account in (select id
                             , split_hash
                             , card_id
                             , card_mask
                             , cardholder_name
                          from (
                                select a.id
                                     , a.split_hash
                                     , a.agent_id
                                     , i.id card_id
                                     , i.card_mask
                                     , h.cardholder_name
                                     , c.product_id
                                     , c.contract_number
                                     , a.currency
                                  from acc_account    a
                                     , prd_contract   c
                                     , prd_customer   u
                                     , iss_card       i
                                     , iss_cardholder h
                                     , crd_debt       d
                                 where a.inst_id = i_inst_id
                                   and c.product_id = i_product_id
                                   and c.split_hash = a.split_hash
                                   and a.contract_id = c.id
                                   and a.customer_id = u.id
                                   and u.split_hash = a.split_hash
                                   and i.customer_id = a.customer_id
                                   and i.contract_id = a.contract_id
                                   and i.split_hash = a.split_hash
                                   and i.cardholder_id = h.id
                                   and (i_agent_id is null or a.agent_id = i_agent_id)
                                   and (i_contract_number is null or c.contract_number = i_contract_number)
                                   and (i_customer_number is null or u.customer_number = i_customer_number)
                                   and (i_currency is null or a.currency = i_currency)
                                   and a.id = d.account_id and d.split_hash = a.split_hash
                                union
                                select a.id
                                     , a.split_hash
                                     , a.agent_id
                                     , i.id card_id
                                     , i.card_mask
                                     , h.cardholder_name
                                     , c.product_id
                                     , c.contract_number
                                     , a.currency
                                  from acc_account    a
                                     , prd_contract   c
                                     , prd_customer   u
                                     , iss_card       i
                                     , iss_cardholder h
                                     , crd_payment    p
                                 where a.inst_id = i_inst_id
                                   and c.product_id = i_product_id
                                   and c.split_hash = a.split_hash
                                   and a.contract_id = c.id
                                   and a.customer_id = u.id
                                   and u.split_hash = a.split_hash
                                   and i.customer_id = a.customer_id
                                   and i.contract_id = a.contract_id
                                   and i.split_hash = a.split_hash
                                   and i.cardholder_id = h.id
                                   and (i_agent_id is null or a.agent_id = i_agent_id)
                                   and (i_contract_number is null or c.contract_number = i_contract_number)
                                   and (i_customer_number is null or u.customer_number = i_customer_number)
                                   and (i_currency is null or a.currency = i_currency)
                                   and a.id = p.account_id and p.split_hash = a.split_hash
                                union
                                select a.id
                                     , a.split_hash
                                     , a.agent_id
                                     , i.id card_id
                                     , i.card_mask
                                     , h.cardholder_name
                                     , c.product_id
                                     , c.contract_number
                                     , a.currency
                                  from acc_account    a
                                     , prd_contract   c
                                     , prd_customer   u
                                     , iss_card       i
                                     , iss_cardholder h
                                     , lty_bonus      b
                                 where a.inst_id = i_inst_id
                                   and c.product_id = i_product_id
                                   and c.split_hash = a.split_hash
                                   and a.contract_id = c.id
                                   and a.customer_id = u.id
                                   and u.split_hash = a.split_hash
                                   and i.customer_id = a.customer_id
                                   and i.contract_id = a.contract_id
                                   and i.split_hash = a.split_hash
                                   and i.cardholder_id = h.id
                                   and (i_agent_id is null or a.agent_id = i_agent_id)
                                   and (i_contract_number is null or c.contract_number = i_contract_number)
                                   and (i_customer_number is null or u.customer_number = i_customer_number)
                                   and (i_currency is null or a.currency = i_currency)
                                   and  a.id = b.account_id and b.split_hash = a.split_hash
                               )
                         order by agent_id
                             , cardholder_name
                             , product_id
                             , contract_number
                             , currency
    )
    loop

        --get account id
        l_account_id      := cur_account.id;
        l_split_hash      := cur_account.split_hash;
        l_card_id         := cur_account.card_id;
        l_card_mask       := cur_account.card_mask;
        l_cardholder_name := cur_account.cardholder_name;

        l_interest_detail := null;

        -- get last invoice
        select max(i.id)
          into l_invoice_id
          from crd_invoice_vw i
         where i.account_id    = l_account_id
           and i.invoice_date <= l_settl_date;

        -- calc start date
        if i_start_date is not null then
            l_start_date := i_start_date;
        elsif l_invoice_id is null then
             begin
                select o.start_date
                  into l_start_date
                  from prd_service_object o
                     , prd_service s
                where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  and object_id         = l_account_id
                  and s.id              = o.service_id
                  and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;

                l_entry_balance := 0;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
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
        l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount(
                              i_account_id  => l_account_id
                            , i_date        => l_settl_date
                            , i_date_type   => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                          );
        -- get overdue balance
        l_overdue_balance := acc_api_balance_pkg.get_balance_amount(
                                 i_account_id    => l_account_id
                               , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE
                               , i_date          => l_settl_date
                               , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                             );
        -- get overdue intr balance
        l_overdue_intr_balance := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id    => l_account_id
                                    , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                    , i_date          => l_settl_date
                                    , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                  );

        --get credit limit
        l_exceed_limit := acc_api_balance_pkg.get_balance_amount(
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
        l_ledger_balance := acc_api_balance_pkg.get_balance_amount(
                                i_account_id        => l_account_id
                              , i_balance_type      => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                              , i_date              => l_settl_date
                              , i_date_type         => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                              , i_mask_error        => com_api_const_pkg.TRUE
                            );

        l_from_id := com_api_id_pkg.get_from_id(i_date => l_start_date);
        l_till_id := com_api_id_pkg.get_till_id(i_date => l_settl_date);

        -- get output_balance and total_expence
        select sum(decode(b.balance_type, acc_api_const_pkg.BALANCE_TYPE_LEDGER, 0, nvl(b.amount, 0)))
             , sum(nvl(d.amount, 0))
          into l_output_balance
             , l_total_expence
          from (
                select d.id debt_id
                     , d.amount
                  from crd_debt d
                 where d.account_id = l_account_id
                   and d.split_hash = l_split_hash
                   and d.id between l_from_id and l_till_id
             ) d
             , crd_debt_balance b
         where b.debt_id(+)    = d.debt_id
           and b.split_hash(+) = l_split_hash
           and b.id between l_from_id and l_till_id;

        -- get total_income
        select sum(amount)
          into l_total_income
          from crd_payment
         where account_id = l_account_id
           and split_hash = l_split_hash
           and id between l_from_id and l_till_id;
        
        -- get last interest period date   
        select nvl(max(e.posting_date), l_settl_date)
          into l_interest_period_date 
          from acc_entry e
         where e.account_id = l_account_id
           and e.transaction_type = 'TRNT1003';

        -- Get calc interest end date ICED
        l_calc_interest_end_attr :=
            crd_interest_pkg.get_interest_calc_end_date(
                i_account_id  => l_account_id
              , i_eff_date    => i_eff_date
              , i_split_hash  => l_split_hash
              , i_inst_id     => i_inst_id
            );

        -- header
        select
            xmlconcat(
                xmlelement("account"
                  , xmlelement("account_number", t.customer_account)
                  , xmlelement("currency", t.account_currency)
                  , xmlelement("currency_name", com_api_i18n_pkg.get_text('com_currency', 'name', l_currency_id, l_lang))
                  , xmlelement("account_type", t.account_type)
                  , xmlelement("inst_id", t.inst_id)
                  , xmlelement("inst_name", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', t.inst_id, l_lang))              
                  , xmlelement("agent_id", t.agent_id)
                  , xmlelement("agent_name", com_api_i18n_pkg.get_text('OST_AGENT','NAME', t.agent_id, l_lang))
                  , xmlelement("generation_date", to_char(com_api_sttl_day_pkg.get_sysdate, 'dd/mm/yyyy'))
                  , xmlelement("customer"
                      , xmlelement("customer_number", t.customer_number)
                      , xmlelement("customer_category", t.category)
                      , xmlelement("resident", t.resident)
                      , xmlelement("customer_relation", t.relation)
                      , xmlelement("nationality", t.nationality)
                      , xmlelement("is_person", t.is_person)
                      , xmlelement("person"
                          , xmlelement("person_name"
                              , xmlelement("surname", t.surname)
                              , xmlelement("first_name", t.first_name)
                              , xmlelement("second_name", t.second_name)
                            )
                          , xmlelement("identity_card"
                              , xmlelement("id_type", to_char(null))
                              , xmlelement("id_series", to_char(null))
                              , xmlelement("id_number", to_char(null))
                            )
                        )
                      , xmlelement("company"
                          , xmlelement("company_name", t.company_name)
                        )
                      , xmlelement("contact"
                          , xmlelement("contact_type", to_char(null))
                          , xmlelement("preferred_lang", to_char(null))
                          , xmlelement("contact_data"
                              , xmlelement("commun_method", to_char(null))
                              , xmlelement( "commun_address", to_char(null))
                            )
                        )
                      , xmlelement("address"
                          , xmlelement("address_type", t.address_type)
                          , xmlelement("country", t.country)
                          , xmlelement("address_name"
                              , xmlelement("region", nvl(t.region, ''))
                              , xmlelement("city", nvl(t.city, ''))
                              , xmlelement("street", nvl(t.street, ''))
                              , xmlelement("house", nvl(t.house, ''))
                              , xmlelement("apartment", nvl(t.apartment, ''))
                            )
                        )
                    )
                  , xmlelement("contract"
                      , xmlelement("contract_type", t.contract_type)
                      , xmlelement("product_id", t.product_id)
                      , xmlelement("product_name", t.product_name)
                      , xmlelement("contract_number", t.contract_number)
                      , xmlelement("contract_date", to_char(t.contract_date, 'dd/mm/yyyy'))
                      , xmlelement("opening_balance", nvl(entry_balance, 0))
                      , xmlelement("closing_balance", nvl(output_balance, 0))
                      , xmlelement("start_date", to_char(start_date, 'dd/mm/yyyy'))
                      , xmlelement("invoice_date", to_char(invoice_date, 'dd/mm/yyyy'))
                      , xmlelement("total_income", nvl(total_income, 0))
                      , xmlelement("total_expence", nvl(total_expence, 0))
                      , xmlelement("overdue", nvl(l_overdue_balance.amount, 0))
                      , xmlelement("overdue_interest", nvl(l_overdue_intr_balance.amount, 0))
                      , xmlelement("interest_sum", nvl(total_interest, 0))
                      , xmlelement("available_balance", nvl(l_aval_balance.amount, 0))
                      , xmlelement("serial_number", to_char(null))
                      , xmlelement("invoice_type", to_char(null))
                      , xmlelement("exceed_limit", nvl(credit_limit, 0))
                      , xmlelement("total_amount_due", nvl(output_balance, 0))
                      , xmlelement("own_funds", nvl(ledger_balance, 0))
                      , xmlelement("min_amount_due", to_char(null))
                      , xmlelement("grace_date", to_char(null))
                      , xmlelement("due_date", to_char(null))
                      , xmlelement("penalty_date", to_char(null))
                      , xmlelement("aging_period", to_char(null)) 
                      , xmlelement("interest_period_date", to_char(interest_period_date, 'dd/mm/yyyy'))                     
                      , xmlelement("statement_message", 'Statement Message')
                      , xmlelement("promotional_messages", 'Promotional Messages')
                    )
                )
            )
        into l_header
        from (
            select a.account_number customer_account
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
                 , get_text(
                       i_table_name => 'prd_product'
                    , i_column_name => 'label'
                    , i_object_id   => r.product_id
                    , i_lang        => l_lang
                   ) product_name
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
                 , l_interest_period_date interest_period_date
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
                 , a.interest_amount
                 , a.is_charged
                 , a.is_grace_enable
                 , i.due_date
              from crd_debt_interest a
                 , crd_debt d
                 , crd_invoice i
             where d.account_id      = l_account_id
               and d.id              = a.debt_id
               and a.split_hash      = l_split_hash
               and a.id between l_from_id and l_till_id
               and a.invoice_id      = i.id(+)
             order by d.id
        ) loop
            if nvl(r.interest_amount, 0) = 0 and r.is_charged = 0 and r.is_grace_enable = 0 then
            
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
                      , i_end_date          => case l_calc_interest_end_attr
                                                   when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                                       then r.end_date
                                                   when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                                       then nvl(r.due_date, r.end_date)
                                                   else r.end_date
                                               end
                    )
                  , 4
                );
                trc_log_pkg.debug(
                    i_text        => 'Calc interest [#1] [#2] [#3] [#4] [#5]'
                  , i_env_param1  => r.fee_id
                  , i_env_param2  => r.amount
                  , i_env_param3  => r.debt_id
                  , i_env_param4  => r.start_date
                  , i_env_param5  => r.end_date
                );

            else 
                -- if interests already charged
                l_interest_amount := r.interest_amount;
                
            end if;

            l_total_interest := l_total_interest + l_interest_amount;

            -- create detail
            if l_debt_id = r.debt_id then
                l_debt_interest_amount := l_debt_interest_amount + l_interest_amount;
            else
                if l_debt_id is not null then
                    -- create new element for previous debt               
                    add_element_to_detail(i_header => l_header);
                end if;

                -- save new debt
                l_debt_id := r.debt_id;
                l_oper_description := nvl(r.oper_type, '') || ' ' || nvl(r.oper_date, '');
                l_debt_interest_amount := l_interest_amount;
            end if;

        end loop;

        -- create new element for last debt
        if l_debt_id is not null then
            add_element_to_detail(i_header => l_header);
        end if;

        begin
            -- transactions details
            select xmlagg(
                       xmlelement("operation"
                         , l_header
                         , xmlelement("oper_type", oper_type)
                         , xmlelement("oper_description", oper_description)
                         , xmlelement("balance_type", balance_type)
                         , xmlelement("card_mask", object_ref)
                         , xmlelement("cardholder_name", cardholder_name)
                         , xmlelement("card_id", card_id)
                         , xmlelement("posting_date", to_char(posting_date, 'dd/mm/yyyy'))
                         , xmlelement("oper_date", to_char(oper_date, 'dd/mm/yyyy'))
                         , xmlelement("oper_currency", oper_currency)
                         , xmlelement("oper_amount", nvl(oper_amount, 0))
                         , xmlelement("credit_oper_amount", nvl(oper_amount_in, 0))
                         , xmlelement("debit_oper_amount", nvl(oper_amount_out, 0))
                         , xmlelement("overdraft_amount", nvl(oper_credit, 0))
                         , xmlelement("repayment_amount", nvl(oper_payment, 0))
                         , xmlelement("interest_amount", nvl(oper_interest, 0))
                         , xmlelement("amount_points", 0)
                         , xmlelement("oper_type_interest", 0)
                       )
                   )
            into l_oper_detail
            from (
                select oper_type
                     , nvl2(oper_type, oper_type || ' ', null) || nvl2(oper_date, oper_date || ' ', null) || merchant_address oper_description
                     , to_char(null) balance_type
                     , object_ref
                     , cardholder_name
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
                    select get_article_text(o.oper_type, l_lang) oper_type
                         , nvl2(o.merchant_city, o.merchant_city || ', ', null) || o.merchant_street merchant_address
                         , (select card_mask
                              from iss_card
                             where id = d.card_id) object_ref
                         , (select h.cardholder_name
                              from iss_cardholder h
                                 , iss_card c
                             where c.cardholder_id = h.id
                               and c.id = d.card_id) cardholder_name
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
                     from crd_debt_vw d
                        , opr_operation_vw o
                    where d.account_id = l_account_id  --d.id = e.debt_id
                      and d.split_hash = l_split_hash
                      and d.id between l_from_id and l_till_id
                      and o.id(+) = d.oper_id
                      
                    union all
                    -- credit
                    select get_article_text(o.oper_type, l_lang) oper_type
                         , nvl2(o.merchant_city, o.merchant_city || ', ', null) || o.merchant_street merchant_address
                         , to_char(null) object_ref
                         , (select h.cardholder_name
                              from iss_cardholder h
                                 , iss_card c
                             where c.cardholder_id = h.id
                               and c.id = o.card_id) cardholder_name
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
                        where account_id = l_account_id
                           and split_hash = l_split_hash
                           and id between l_from_id and l_till_id
                        union
                        select id pay_id
                          from crd_payment
                         where account_id = l_account_id
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
                trc_log_pkg.debug(
                    i_text  => 'Operations not found'
                );
        end;

        begin
            -- instalments details
            select xmlagg(
                       xmlelement("operation"
                         , l_header
                         , xmlelement("oper_type", oper_type)
                         , xmlelement("oper_description", oper_description)
                         , xmlelement("balance_type", balance_type)
                         , xmlelement("card_mask", object_ref)
                         , xmlelement("cardholder_name", cardholder_name)
                         , xmlelement("card_id", card_id)
                         , xmlelement("posting_date", to_char(posting_date, 'dd/mm/yyyy'))
                         , xmlelement("oper_date", to_char(oper_date, 'dd/mm/yyyy'))
                         , xmlelement("oper_currency", oper_currency)
                         , xmlelement("oper_amount", nvl(oper_amount, 0))
                         , xmlelement("credit_oper_amount", nvl(oper_amount_in, 0))
                         , xmlelement("debit_oper_amount", nvl(oper_amount_out, 0))
                         , xmlelement("overdraft_amount", nvl(oper_credit, 0))
                         , xmlelement("repayment_amount", nvl(oper_payment, 0))
                         , xmlelement("interest_amount", nvl(oper_interest, 0))
                         , xmlelement("amount_points", 0)
                         , xmlelement("oper_type_interest", 2)
                       )
                   )
            into l_instalment_detail
            from (select get_article_text(d.oper_type, l_lang) oper_type
                       , get_article_text(a.balance_type, l_lang) balance_type
                       , nvl(get_article_text(d.oper_type, l_lang), '') || ' ' || nvl(d.oper_date, '') oper_description
                       , (select card_mask
                              from iss_card
                             where id = d.card_id) object_ref
                       , (select h.cardholder_name
                              from iss_cardholder h
                                 , iss_card c
                             where c.cardholder_id = h.id
                               and c.id = d.card_id) cardholder_name
                       , d.card_id
                       , p.posting_date
                       , d.oper_date
                       , a.pay_amount oper_amount
                       , p.currency oper_currency
                       , null oper_amount_in
                       , null oper_amount_out
                       , null oper_credit
                       , p.amount oper_payment 
                       , null oper_interest
                   from crd_debt_payment a
                      , crd_debt d
                      , crd_payment p
                  where d.account_id      = l_account_id --decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
                    and d.id              = a.debt_id
                    and p.id              = a.pay_id
                    and a.split_hash      = l_split_hash
                    and a.id between l_from_id and l_till_id
                 );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text  => 'Instalments not found'
                );
        end;

        begin
            -- loyalty details
            select xmlagg(
                       xmlelement("operation"
                         , l_header
                         , xmlelement("oper_type", oper_type)
                         , xmlelement("oper_description", oper_description)
                         , xmlelement("balance_type", balance_type)
                         , xmlelement("card_mask", object_ref)
                         , xmlelement("cardholder_name", cardholder_name)
                         , xmlelement("card_id", card_id)
                         , xmlelement("posting_date", to_char(posting_date, 'dd/mm/yyyy'))
                         , xmlelement("oper_date", to_char(oper_date, 'dd/mm/yyyy'))
                         , xmlelement("oper_currency", oper_currency)
                         , xmlelement("oper_amount", nvl(oper_amount, 0))
                         , xmlelement("credit_oper_amount", nvl(oper_amount_in, 0))
                         , xmlelement("debit_oper_amount", nvl(oper_amount_out, 0))
                         , xmlelement("overdraft_amount", nvl(oper_credit, 0))
                         , xmlelement("repayment_amount", nvl(oper_payment, 0))
                         , xmlelement("interest_amount", nvl(oper_interest, 0))
                         , xmlelement("amount_points", nvl(amount_points, 0))
                         , xmlelement("oper_type_interest", 3)
                       )
                   )
            into l_loyalty_detail
            from (select distinct get_article_text(d.oper_type, l_lang) oper_type
                       , nvl(get_article_text(d.oper_type, l_lang), '') || ' ' || nvl(d.oper_date, '') oper_description
                       , to_char(null) balance_type
                       , (select card_mask
                              from iss_card
                             where id = d.card_id) object_ref
                       , (select h.cardholder_name
                              from iss_cardholder h
                                 , iss_card c
                             where c.cardholder_id = h.id
                               and c.id = d.card_id) cardholder_name
                       , d.card_id
                       , m.posting_date
                       , d.oper_date
                       , m.amount oper_amount
                       , m.currency oper_currency
                       , l.amount amount_points
                       , null oper_amount_in
                       , null oper_amount_out
                       , null oper_credit
                       , null oper_payment 
                       , null oper_interest
                      from lty_bonus l
                         , acc_macros m
                         , acc_bunch b
                         , crd_debt_payment p
                         , crd_debt d
                     where l.account_id = l_account_id --decode(l.status, 'DBTSACTV', l.account_id, null) = l_account_id
                       and l.id = m.id
                       and m.id = b.macros_id
                       and m.amount_purpose = 'AMPR0008'
                       and b.id = p.bunch_id
                       and d.id = p.debt_id
                       and p.split_hash = l_split_hash
                       and p.id between l_from_id and l_till_id
                 );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text  => 'Instalments not found'
                );
        end;

        select xmlconcat(
                   l_result
              --   , l_header  
                 , l_oper_detail
                 , l_interest_detail
                 , l_instalment_detail
                 , l_loyalty_detail
               )
        into l_result
        from dual;

    end loop;

    select xmlelement(
               "operations"
             , l_result
           ) r
      into l_result
      from dual;

    l_xml := l_xml||l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'End credit_card_statement'
    );
    return l_xml;
end;

procedure credit_card_statement(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_eff_date              in      date
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in      com_api_type_pkg.t_name         default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is
begin
    o_xml := card_statement(
                 i_inst_id         => i_inst_id
               , i_agent_id        => i_agent_id
               , i_eff_date        => i_eff_date
               , i_product_id      => i_product_id
               , i_contract_number => i_contract_number
               , i_customer_number => i_customer_number
               , i_currency        => i_currency
               , i_introduced_by   => i_introduced_by
               , i_lang            => i_lang
             );
end;

procedure over_six_months_statement(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_star_date             in      date
  , i_end_date              in      date
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in      com_api_type_pkg.t_name         default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is
begin
    o_xml := card_statement(
                 i_inst_id         => i_inst_id
               , i_agent_id        => i_agent_id
               , i_start_date      => i_star_date
               , i_eff_date        => i_end_date
               , i_product_id      => i_product_id
               , i_contract_number => i_contract_number
               , i_customer_number => i_customer_number
               , i_currency        => i_currency
               , i_introduced_by   => i_introduced_by
               , i_lang            => i_lang
             );
end;

procedure report_for_collectors(
    o_xml                      out  clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_collector_name        in      com_api_type_pkg.t_name
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is
    FF_COLLECTOR_NAME               com_api_type_pkg.t_name := 'CST_COLLECTOR_NAME';
    l_xml                           xmltype;
    l_lang                          com_api_type_pkg.t_dict_value;
    l_sysdate                       date;
begin
    l_lang    := coalesce(i_lang, get_user_lang());
    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    select xmlelement("collector_data"
             , xmlelement("collector_name", i_collector_name)
             , xmlagg(
                   xmlelement("account"
                     , xmlelement("customer_number",    t.customer_number)
                     , xmlelement("customer_name",      t.customer_name)
                     , xmlelement("account_number",     t.account_number)
                     , xmlelement("mobile_phone",       t.mobile_phone)
                     , xmlelement("total_amount_due",   t.total_amount_due)
                     , xmlelement("overdue_balance",    t.overdue_balance)
                     , xmlelement("aging_period",       t.aging_period)
                     , xmlelement("current_cycle_date", t.current_cycle_date)
                   )
               )
           )
      into l_xml
      from (
          select c.customer_number
               , (select max(p.surname || ' ' || p.first_name || ' ' || p.second_name)
                             keep (dense_rank first order by decode(p.lang
                                                                  , l_lang, 0
                                                                  , com_api_const_pkg.DEFAULT_LANGUAGE, 1
                                                                  , 2))
                    from com_person p
                   where p.id = c.object_id
                 ) as customer_name
               , a.account_number
               , listagg(cd.commun_address, ', ') within group (order by cd.start_date) as mobile_phone
               , max(i.total_amount_due) keep (dense_rank last order by i.invoice_date) as total_amount_due
               , max(i.overdue_balance)  keep (dense_rank last order by i.invoice_date) as overdue_balance
               , max(i.aging_period)     keep (dense_rank last order by i.invoice_date) as aging_period
               , max(fc.prev_date)       keep (dense_rank last order by fc.prev_date)   as current_cycle_date
            from prd_customer c
            join com_flexible_data fd         on fd.object_id     = c.id
            join com_flexible_field ff        on ff.id            = fd.field_id
            join acc_account a                on a.customer_id    = c.id
                                             and a.split_hash     = c.split_hash
            join prd_service_object so        on so.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                             and so.object_id     = a.id
                                             and so.split_hash    = c.split_hash
            join prd_service s                on s.id             = so.service_id
            join crd_invoice i                on i.account_id     = a.id
                                             and i.split_hash     = c.split_hash
            join fcl_cycle_counter fc         on fc.object_id     = a.id
                                             and fc.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                             and fc.cycle_type    = crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                                             and fc.split_hash    = c.split_hash
            left join com_contact_object co   on co.entity_type   = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                             and co.object_id     = c.id
            left join com_contact_data cd     on cd.contact_id    = co.contact_id
                                             and cd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                             and l_sysdate between nvl(cd.start_date, l_sysdate - 1)
                                                               and nvl(cd.end_date,   l_sysdate + 1)
           where ff.name               = FF_COLLECTOR_NAME
             and lower(fd.field_value) = lower(i_collector_name)
             and c.entity_type         = com_api_const_pkg.ENTITY_TYPE_PERSON
             and c.inst_id             = i_inst_id
             and s.service_type_id     = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
           group by
                 c.object_id
               , c.customer_number
               , a.account_number
      ) t;

    o_xml := l_xml.getclobval();

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.report_for_collectors FAILED: '
                         || 'i_inst_id [#1], i_collector_name [#2], l_lang [#3], l_sysdate [#4]'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_collector_name
          , i_env_param3 => l_lang
          , i_env_param4 => to_char(l_sysdate, com_api_const_pkg.XML_DATE_FORMAT)
        );
        raise;
end report_for_collectors;

function get_cards_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) return xmltype 
is

    l_result    xmltype;
    l_lang      com_api_type_pkg.t_dict_value;
    
begin
    
    l_lang := coalesce(i_lang, get_user_lang(), com_api_const_pkg.DEFAULT_LANGUAGE);
    
    select xmlelement("cards"
             , xmlagg(
                   xmlelement("card"
                     , xmlelement("short_card_mask"
                         , iss_api_card_pkg.get_short_card_mask(
                               i_card_number => s.card_number
                           )
                       )
                     , xmlelement("cardholder_first_name", s.cardholder_first_name)
                     , xmlelement("expiry_date", to_char(s.card_expir_date, 'dd/mm/yyyy'))
                   )
                   order by decode(s.card_category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, -1, s.card_id)
               )
           )
      into l_result
      from
           (
               select p.first_name                             as cardholder_first_name
                    , cn.card_number                           as card_number
                    , cn.card_id                               as card_id
                    , ic.category                              as card_category
                    , ci.expir_date                            as card_expir_date
                    , row_number() over(
                          partition by ci.card_id
                          order by ci.seq_number desc
                      )                                        as card_instance_up
                 from acc_account a
                    , acc_account_object ao
                    , iss_card ic
                    , iss_card_instance ci
                    , iss_card_number cn
                    , iss_cardholder ch
                    , com_person p
                where a.id = i_account_id
                  and ao.account_id = a.id
                  and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                  and ao.split_hash = a.split_hash
                  and ic.id = ao.object_id
                  and ci.card_id = ic.id
                  and ci.split_hash = ic.split_hash
                  and cn.card_id = ic.id
                  and ch.id = ic.cardholder_id
                  and p.id = ch.person_id
                  and p.lang =  l_lang
           ) s
     where s.card_instance_up = 1;
         
    return l_result;
    
end get_cards_data;

function get_invoice_acc_iss_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) return xmltype 
is
    l_result    xmltype;
begin
    select xmlelement("data"
             , xmlelement("account"
                 , xmlelement("number_mask", '*' || substr(s.account_number, -5, 5))
                 , xmlelement("currency_code", s.curr_code)
                 , xmlelement("currency_name", cr.name)
                 , xmlelement("avl_balance"
                     , to_char(
                           s.avl_balance / power(10, cr.exponent)
                         , com_api_const_pkg.XML_NUMBER_FORMAT
                           || rpad('.'
                                , case cr.exponent 
                                       when 0 
                                           then 0
                                       else cr.exponent + 1
                                  end
                                , '0'
                              )
                       )
                   )
               )
             , xmlelement("last_credit_invoice"
                 , xmlelement("grace_date", to_char(s.grace_date, 'dd/mm/yy'))
                 , xmlelement("min_amount_due"
                     , to_char(
                           s.min_amount_due / power(10, cr.exponent)
                         , com_api_const_pkg.XML_NUMBER_FORMAT
                           || rpad('.'
                                , case cr.exponent 
                                       when 0 
                                           then 0
                                       else cr.exponent + 1
                                  end
                                , '0'
                              )
                       )
                   )
                 , xmlelement("total_amount_due"
                     , to_char(
                           s.total_amount_due / power(10, cr.exponent)
                         , com_api_const_pkg.XML_NUMBER_FORMAT
                           || rpad('.'
                                , case cr.exponent 
                                       when 0 
                                           then 0
                                       else cr.exponent + 1
                                  end
                                , '0'
                              )
                       )
                   )
               )
             , get_cards_data(
                   i_account_id => i_account_id
                 , i_lang       => i_lang
               )
           )
      into l_result
      from
           (
               select i.grace_date                             as grace_date
                    , i.min_amount_due                         as min_amount_due
                    , av.account_number                        as account_number
                    , av.currency                              as curr_code
                    , av.balance                               as avl_balance
                    , i.total_amount_due                       as total_amount_due
                    , row_number() over(order by i.id desc)    as invoice_up
                 from acc_ui_account_vs_aval_vw av
                    , crd_invoice i
                where av.id = i_account_id
                  and i.account_id = av.id
                  and i.split_hash = av.split_hash
           ) s,
           com_currency cr
     where s.invoice_up = 1
       and s.curr_code = cr.code;
         
    return l_result;
    
end get_invoice_acc_iss_data;

procedure report_for_notification(
    o_xml                   out     clob
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is

    l_result            xmltype;
    
begin
    trc_log_pkg.debug (
        i_text       => 'Run report for notification [#1] [#2] [#3] [#4] [#5]: Data generation is started'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    then
        begin
            if i_event_type in (GRACE_PERIOD_ENDING_CYCLE, crd_api_const_pkg.OVERDUE_EVENT, EXCEED_MAIN_PART_LIMIT_EVENT)
            then
                l_result :=
                    get_invoice_acc_iss_data(
                        i_account_id => i_object_id
                      , i_lang       => i_lang
                    );
            elsif i_event_type in (acc_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_ACCOUNT, CUSTOMER_BIRTHDAY_CYCLE, CUSTOMER_MARRIAGE_DAY_CYCLE)
            then
                l_result :=
                    get_cards_data(
                        i_account_id => i_object_id
                      , i_lang       => i_lang
                    );
            else
                raise no_data_found;
            end if;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'REPORT_DATA_NOT_FOUND'
                );
        end;
    else
        com_api_error_pkg.raise_error(
            i_error         => 'REPORT_DATA_NOT_FOUND'
        );
    end if;
    
    o_xml := l_result.getclobval();
    
    trc_log_pkg.debug (
        i_text       => 'Run report for notification [#1] [#2] [#3] [#4] [#5]: Data generation is finished success'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text       => 'Run report for notification [#1] [#2] [#3] [#4] [#5]: Data generation is finished failed, error: [#6]'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_lang
          , i_env_param3 => i_inst_id
          , i_env_param4 => i_entity_type
          , i_env_param5 => i_object_id
          , i_env_param6 => SQLERRM
        );
        
        raise;
        
end report_for_notification;

end;
/
