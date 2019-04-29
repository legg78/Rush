create or replace package body lty_api_report_pkg as

procedure loyalty_statement(
    i_account_id        in      com_api_type_pkg.t_medium_id
  , i_start_date        in      date
  , i_end_date          in      date
  , i_lang              in      com_api_type_pkg.t_dict_value
  , o_xml                  out  clob
) is
    l_end_date              date;
    l_eff_date              date;
    l_service_id            com_api_type_pkg.t_short_id;
    l_product_id            com_api_type_pkg.t_short_id;
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_external_number       com_api_type_pkg.t_name;
    l_service_name          com_api_type_pkg.t_name;
    l_object_name           com_api_type_pkg.t_name;
    l_address_id            com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_params                com_api_type_pkg.t_param_tab;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;

    l_account_number        com_api_type_pkg.t_account_number;
    l_currency              com_api_type_pkg.t_curr_code;
    l_currency_name         com_api_type_pkg.t_curr_name;
    l_currency_full_name    com_api_type_pkg.t_name;
    l_currency_exponent     com_api_type_pkg.t_exponent;
    l_loyalty_expired       com_api_type_pkg.t_money;

    l_header                xmltype;
    l_details               xmltype;
    l_result                xmltype;
begin

    l_end_date := nvl(i_end_date, com_api_sttl_day_pkg.get_sysdate);
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    l_split_hash := com_api_hash_pkg.get_split_hash(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, i_account_id);
    
    begin
        select a.object_id
             , a.entity_type
             , s.id
             , c.product_id
             , c.customer_id
             , get_text('prd_service', 'label', s.id, i_lang) 
             , c.inst_id
             , aa.currency
             , aa.account_number
          into l_object_id
             , l_entity_type
             , l_service_id
             , l_product_id
             , l_customer_id
             , l_service_name
             , l_inst_id
             , l_currency
             , l_account_number
          from acc_account_object a
             , acc_account aa
             , prd_contract c
             , prd_service s
             , prd_service_object o
        where a.account_id      = i_account_id
          and a.account_id      = aa.id
          and o.object_id       = a.object_id
          and o.entity_type     = a.entity_type
          and o.service_id      = s.id
          and o.split_hash      = l_split_hash
          and s.service_type_id in (lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
                                  , lty_api_const_pkg.LOYALTY_SERVICE_ACC_TYPE_ID
                                  , lty_api_const_pkg.LOYALTY_SERVICE_MRCH_TYPE_ID
                                  , lty_api_const_pkg.LOYALTY_SERVICE_CUST_TYPE_ID
                                   )
          and o.contract_id     = c.id 
          and (l_end_date   >= o.start_date or o.start_date is null)
          and (i_start_date <= o.end_date   or o.end_date   is null);
    
    exception
        when no_data_found then
            trc_log_pkg.debug('lty_api_report_pkg.loyalty_statement: Unable to find loyalty service for account '||i_account_id);
            return;
    end;
    
    l_currency_exponent  := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_currency);
    l_currency_name      := com_api_currency_pkg.get_currency_name(i_curr_code => l_currency);
    l_currency_full_name := 
        com_api_currency_pkg.get_currency_full_name(
            i_curr_code => l_currency
          , i_lang      => i_lang
        );
    
    l_external_number := 
        prd_api_product_pkg.get_attr_value_char(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                  i_attr_name    => lty_api_const_pkg.LOYALTY_EXTERNAL_NUMBER
                                , i_entity_type  => l_entity_type
                              )   
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_eff_date
          , i_inst_id      => l_inst_id
        ); 
    
    if l_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
         l_object_name := 
             acq_api_merchant_pkg.get_merchant_name(
                 i_merchant_id   => l_object_id
               , i_mask_error    => com_api_const_pkg.FALSE
             );
         l_address_id := 
             acq_api_merchant_pkg.get_merchant_address_id(
                 i_merchant_id => l_object_id
               , i_lang        => i_lang
             ); 
    else
         begin
             select com_api_dictionary_pkg.get_article_text(a.title, i_lang)||' '||
                    a.first_name || ' ' ||
                    a.surname
               into l_object_name
               from com_person a
                  , prd_customer b
              where b.id = l_customer_id
                and b.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                and b.object_id = a.id;
         exception when no_data_found then 
             null;
         end;
         
         begin
             select a.id
               into l_address_id
               from com_address_object o
                  , com_address a
              where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                and o.object_id   = l_customer_id
                and a.id          = o.address_id
                and a.lang        = i_lang
                and rownum        = 1;
         exception when no_data_found then 
             null;
         end;
    end if;
    
    select sum(l.amount - l.spent_amount)
      into l_loyalty_expired
      from lty_bonus l
     where l.account_id = i_account_id
       and l.expire_date between i_start_date and i_end_date
       and l.status     = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
       and l.split_hash = l_split_hash;
    
    select xmlconcat(
               xmlelement("service_name", l_service_name)
             , xmlelement("inst_id",      l_inst_id)
             , xmlelement(
                   "inst_name"
                 , com_api_i18n_pkg.get_text(
                       i_table_name    => 'OST_INSTITUTION'
                     , i_column_name   => 'NAME'
                     , i_object_id     => l_inst_id
                     , i_lang          => i_lang
                   )
               )
             , xmlelement("member_number", l_external_number)
             , xmlelement("member_name",   l_object_name)
             , (
                   select xmlelement("member_address"
                            , xmlelement("region", a.region)
                            , xmlelement("city", a.city)
                            , xmlelement("street", a.street)
                            , xmlelement("house", a.house)
                            , xmlelement("apartment", a.apartment)
                            , xmlelement("postal_code", a.postal_code)
                          )
                     from com_address_object o
                        , com_address a
                    where a.id          = o.address_id
                      and a.lang        = i_lang
                      and o.address_id  = l_address_id
               )
             , xmlelement("account_number",     l_account_number)
             , xmlelement("currency",           l_currency)
             , xmlelement("currency_name",      l_currency_name)
             , xmlelement("currency_full_name", l_currency_full_name)
             , xmlelement("currency_exponent",  power(10, l_currency_exponent))
             , xmlelement("amount_format",      '###,###,###,##0.' || lpad('0', greatest(l_currency_exponent, 2), '0')
                                           || ';-###,###,###,##0.' || lpad('0', greatest(l_currency_exponent, 2), '0'))
             , xmlelement("start_date",         i_start_date)
             , xmlelement("end_date",           l_end_date)
             , xmlelement("incoming",           nvl(incoming, 0))
             , xmlelement("earned",             nvl(earned, 0))
             , xmlelement("spent",              nvl(spent, 0) - nvl(l_loyalty_expired,0))
             , xmlelement("expired",            nvl(l_loyalty_expired, 0))
             , xmlelement("outgoing",           nvl(outgoing, 0))
           )
      into l_header
      from (
            select max(balance - amount) keep (dense_rank first order by posting_order) over () as incoming
                 , sum(decode(a.balance_impact, 1, a.amount, null)) over () as earned
                 , sum(decode(a.balance_impact, -1, a.amount, null)) over () as spent
                 , min(balance) keep (dense_rank last order by posting_order) over () as outgoing
              from acc_entry a
             where a.account_id = i_account_id
               and a.posting_date between i_start_date and l_end_date
               and a.split_hash = l_split_hash
           )
           , dual
     where rownum = 1;
    
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "record"
                     , xmlelement("oper_id",       oper_id)
                     , xmlelement("oper_date",     oper_date)
                     , xmlelement("oper_amount",   oper_amount)
                     , xmlelement("oper_amount2",  oper_amount2)
                     , xmlelement("oper_currency", oper_currency)
                     , xmlelement("oper_curr_exp", power(10, oper_currency_exponent))
                     , xmlelement("oper_desc",     oper_desc)
                     , xmlelement("bonus_desc",    bonus_desc)
                     , xmlelement("bonus_type",    bonus_type)
                     , xmlelement("bonus_credit",  bonus_credit)
                     , xmlelement("bonus_debit",   bonus_debit)
                     , xmlelement("bonus_amount",  bonus_amount)
                     , xmlelement("posting_date",  posting_date)
                     , xmlelement("charge_date",   charge_date)
                     , xmlelement("expire_date",   expire_date)
                     , xmlelement("bonus_summary", bonus_summary)
                     , xmlelement("oper_amount_format"
                         , '###,###,###,##0.' || lpad('0', greatest(oper_currency_exponent, 2), '0')
                        || ';-###,###,###,##0.' || lpad('0', greatest(oper_currency_exponent, 2), '0')
                       )
                   )
                   order by bonus_type, posting_date, oper_date
               )
           )
      into l_details
      from (        
            select b.object_id oper_id
                 , b.oper_date
                 , b.oper_amount as oper_amount2
                 , b.oper_amount/power(10, e.exponent) as oper_amount
                 , e.name oper_currency
                 , e.exponent as oper_currency_exponent
                 , com_api_dictionary_pkg.get_article_text(b.oper_type, i_lang) 
                || case when l_entity_type <> acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                       '/' 
                    || b.merchant_name || '/' 
                    || b.merchant_street ||', '
                    || b.merchant_city
                   end as oper_desc
                 , get_text('acc_bunch_type', 'name', f.bunch_type_id, i_lang) as bonus_desc
                 , 0 bonus_type 
                 , decode(a.balance_impact, 1, a.amount, null) as bonus_credit
                 , decode(a.balance_impact, -1, a.amount, null) as bonus_debit
                 , a.amount*a.balance_impact as bonus_amount
                 , b.posting_date
                 , d.start_date as charge_date
                 , d.expire_date
                 , sum(a.amount*a.balance_impact) over () as bonus_summary
              from acc_entry a
                 , acc_ui_macros_oper_vw b
                 , lty_bonus d
                 , com_currency e
                 , acc_bunch f 
             where a.account_id    = i_account_id
               and a.posting_date between i_start_date and l_end_date
               and a.split_hash    = l_split_hash
               and a.macros_id     = b.id
               and b.id            = d.id(+)
               and b.oper_currency = e.code
               and f.id            = a.bunch_id
            union all
            select b.object_id oper_id
                 , b.oper_date
                 , b.oper_amount as oper_amount2
                 , b.oper_amount/power(10, e.exponent)
                 , e.name oper_currency
                 , e.exponent as oper_currency_exponent
                 , com_api_dictionary_pkg.get_article_text(b.oper_type, i_lang)
                || case when l_entity_type <> acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                       '/' 
                    || b.merchant_name || '/' 
                    || b.merchant_street ||', '
                    || b.merchant_city
                   end as oper_desc
                 , get_text('acc_bunch_type', 'name', f.bunch_type_id, i_lang) bonus_desc
                 , 1 bonus_type 
                 , decode(a.balance_impact, 1, a.amount, null) as bonus_credit
                 , decode(a.balance_impact, -1, a.amount, null) as bonus_debit
                 , a.amount*a.balance_impact as bonus_amount
                 , b.posting_date
                 , d.start_date charge_date
                 , d.expire_date
                 , sum(a.amount*a.balance_impact) over () bonus_summary
              from acc_entry a
                 , acc_ui_macros_oper_vw b
                 , lty_bonus d
                 , com_currency e
                 , acc_bunch f 
             where d.account_id    = i_account_id
               and d.expire_date between l_eff_date and l_eff_date + 30
               and d.split_hash    = l_split_hash
               and d.id            = b.id 
               and a.macros_id     = b.id
               and b.oper_currency = e.code
               and f.id            = a.bunch_id
           );
    
    select xmlelement(
               "statement"
             , l_header
             , l_details
           )
      into l_result
      from dual;
            
    o_xml := l_result.getclobval();
end;

procedure loyalty_statement_batch(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) as
    l_account                   acc_api_type_pkg.t_account_rec;
    l_start_date                date;
    l_end_date                  date;

begin
    trc_log_pkg.debug(
        i_text       => 'loyalty_invoice [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    lty_api_bonus_pkg.get_lty_account(
        i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_inst_id          => i_inst_id
      , i_eff_date         => i_eff_date
      , i_mask_error       => com_api_const_pkg.FALSE
      , o_account          => l_account
    );
    
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type        => i_event_type
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_split_hash        => l_account.split_hash
      , i_add_counter       => com_api_type_pkg.FALSE
      , o_prev_date         => l_start_date
      , o_next_date         => l_end_date
    );
    
    loyalty_statement(
        i_account_id        => l_account.account_id
      , i_start_date        => l_start_date
      , i_end_date          => l_end_date
      , i_lang              => i_lang
      , o_xml               => o_xml
    );
end;

procedure loyalty_statement_notify(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
    l_attach            xmltype;
    l_start_date        date;
    l_end_date          date;
    l_customer_id       com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => 'loyalty_invoice_notify [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type        => i_event_type
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_add_counter       => com_api_type_pkg.FALSE
      , o_prev_date         => l_start_date
      , o_next_date         => l_end_date
    );

    l_customer_id := prd_api_customer_pkg.get_customer_id(
        i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_inst_id               => i_inst_id
      , i_mask_error            => com_api_const_pkg.TRUE
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
            select file_name
                 , attach_path
              from ( 
                select c.file_name
                     , c.save_path attach_path
                  from rpt_document d
                     , rpt_document_content c
                 where object_id     = i_object_id
                   and entity_type   = i_entity_type
                   and document_type = rpt_api_const_pkg.DOCUMENT_TYPE_LTY_STTMT
                   and c.document_id = d.id
                 order by c.id desc
                  )
             where rownum = 1 
        ) t;
    exception
        when no_data_found then
            null;
    end;      
    
    if i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        select xmlconcat(
                   xmlelement("attachments", l_attach)
                 , xmlelement("entity_type", i_entity_type)
                 , xmlelement(
                       "company_short_name"
                     , com_api_i18n_pkg.get_text(
                           i_table_name  => 'COM_COMPANY'
                         , i_column_name => 'LABEL'
                         , i_object_id   => l_customer_id
                         , i_lang        => i_lang
                       )
                   )
                 , xmlelement(
                       "company_full_name"
                     , com_api_i18n_pkg.get_text(
                           i_table_name  => 'COM_COMPANY'
                         , i_column_name => 'DESCRIPTION'
                         , i_object_id   => l_customer_id
                         , i_lang        => i_lang
                       )
                   )
                 , xmlelement("merchant_name"   , m.merchant_name)
                 , xmlelement("merchant_number" , m.merchant_number)
                 , xmlelement("start_date"      , to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT))
                 , xmlelement("end_date"        , to_char(l_end_date,   com_api_const_pkg.XML_DATE_FORMAT))
                 , xmlelement("subject"         , 'Monthly loyalty statement')
               )
          into l_result
          from acq_merchant m
          where m.id = i_object_id;
    else
        select xmlconcat(
                   xmlelement("attachments"     , l_attach)
                 , xmlelement("entity_type"     , i_entity_type)
                 , xmlelement("first_name"      , t.first_name)
                 , xmlelement("second_name"     , t.second_name)
                 , xmlelement("surname"         , t.surname)
                 , xmlelement("start_date"      , to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT))
                 , xmlelement("end_date"        , to_char(l_end_date,   com_api_const_pkg.XML_DATE_FORMAT))
                 , xmlelement("subject"         , 'Monthly loyalty statement')
               )
          into l_result
          from (
            select com_ui_person_pkg.get_first_name(i_person_id => s.object_id, i_lang => i_lang) first_name
                 , com_ui_person_pkg.get_second_name(i_person_id => s.object_id, i_lang => i_lang) second_name
                 , com_ui_person_pkg.get_surname(i_person_id => s.object_id, i_lang => i_lang) surname
              from prd_customer s 
             where s.id = l_customer_id
        ) t;
    end if;
    
    o_xml := l_result.getclobval();
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );          
end;

end;
/
