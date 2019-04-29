create or replace package body iss_cst_report_pkg is

CREDIT_STATEMENT_REPORT_INIT   constant com_api_type_pkg.t_byte_id := 0;
CREDIT_STATEMENT_REPORT_EXT    constant com_api_type_pkg.t_byte_id := 1;


procedure card_mailer_report(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is
    l_start_date                  date;
    l_end_date                    date;
    l_lang                        com_api_type_pkg.t_dict_value;
    l_detail                      xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_cst_report_pkg.card_mailer_report [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    -- details
    begin
        select
            xmlelement("cards"
              , xmlagg(
                  xmlelement("card"
                    , xmlelement("inst_id", inst_id)
                    , xmlelement("inst", inst)
                    , xmlelement("agent_id", agent_id)
                    , xmlelement("agent_name", agent_name)
                    , xmlelement("card_mask", card_mask)
                    , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                    , xmlelement("iss_date", to_char(iss_date, 'dd.mm.yyyy'))
                    , xmlelement("issuer_range", to_char(min_iss_date, 'dd.mm.yyyy') || ' - ' || to_char(max_expir_date, 'dd.mm.yyyy'))
                    , xmlelement("cardholder_name", cardholder_name)
                    , xmlelement("company_name", company_name)
                    , xmlelement("account_number", account_number)
                    , xmlelement("person_name", person_name)
                    , xmlelement("card_type", card_type)
                    , xmlelement("start_date", to_char(start_date, 'dd.mm.yyyy'))
                    , xmlelement("cardholder_id", cardholder_id)
                    , xmlelement("embossed_name", embossed_name)
                    , xmlelement("currency_code", currency_code)
                    , xmlelement("currency", currency)
                    , xmlelement("account_atm_limit", account_atm_limit)
                    , xmlelement("credit_limit", credit_limit)
                    , xmlelement("first_name", first_name)
                    , xmlelement("second_name", second_name)
                    , xmlelement("surname", surname)
                    , xmlelement("birthday", to_char(birthday, 'dd.mm.yyyy'))
                    , xmlelement("person_id", person_id)
                    , xmlelement("address", address)
                    , xmlelement("region", region)
                    , xmlelement("country", country)
                    , xmlelement("postal_code", postal_code)
                    , xmlelement("mobile_phone", mobile_phone)
                  )
                  order by
                      inst_id
                    , agent_id
                    , account_number
                    , card_mask
                )
            )
          into l_detail
          from (select ci.inst_id inst_id
                     , com_api_i18n_pkg.get_text('ost_institution','name', ci.inst_id, l_lang) inst
                     , ci.agent_id
                     , com_api_i18n_pkg.get_text('ost_agent','name', ci.agent_id, l_lang) agent_name
                     , c.card_mask
                     , com_api_i18n_pkg.get_text('net_card_type','name', c.card_type_id, l_lang) card_type
                     , ci.start_date
                     , c.cardholder_id
                     , ch.cardholder_name
                     , ci.cardholder_name embossed_name
                     , com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', cs.object_id, l_lang) company_name
                     , ac.account_number
                     , ac.currency currency_code
                     , u.name currency
                     , fcl_api_limit_pkg.get_sum_limit(
                           i_limit_type        => 'LMTP0100'
                         , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                         , i_object_id         => c.id
                         , i_split_hash        => c.split_hash
                         , i_mask_error        => com_api_const_pkg.TRUE 
                       ) / power(10, u.exponent) account_atm_limit
                     , (select (l.balance - nvl(sum(e.amount * e.balance_impact), 0)) balance
                              from acc_entry e
                                 , acc_balance l
                                 , acc_account a
                             where a.id = ac.id
                               and l.account_id      = a.id
                               and l.split_hash      = a.split_hash
                               and l.balance_type    = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                               and e.account_id(+)   = l.account_id
                               and e.balance_type(+) = l.balance_type
                               and e.split_hash(+)   = l.split_hash
                               and e.sttl_date(+)    > l_end_date
                               and e.id(+)           > com_api_id_pkg.get_from_id(com_api_sttl_day_pkg.get_sttl_day_open_date(i_sttl_date => l_end_date, i_inst_id => a.inst_id))
                               and l.currency        = ac.currency
                             group by l.balance
                       ) / power(10, u.exponent) credit_limit
                     , com_ui_person_pkg.get_person_name(ch.person_id, l_lang) person_name
                     , p.first_name
                     , p.second_name
                     , p.surname
                     , p.birthday
                     , trim(com_api_dictionary_pkg.get_article_text(d.id_type, l_lang) || nvl2(d.id_series, ' ' || d.id_series, null) || nvl2(d.id_number, ' ' || d.id_number, null)) person_id
                     , com_api_address_pkg.get_address_string(
                           i_city         => a.city
                         , i_street       => a.street
                         , i_house        => a.house
                         , i_apartment    => a.apartment
                         , i_inst_id      => a.inst_id
                         , i_enable_empty => com_api_const_pkg.TRUE) address
                     , a.region
                     , a.country
                     , a.postal_code
                     , cn.mobile_phone
                     , ci.iss_date
                     , ci.expir_date
                     , min(ci.iss_date) over (partition by ci.inst_id, ci.agent_id) min_iss_date
                     , max(ci.expir_date) over (partition by ci.inst_id, ci.agent_id) max_expir_date
                  from iss_card_instance    ci
                     , iss_card             c
                     , iss_cardholder       ch
                     , acc_account_object   obj
                     , acc_account          ac
                     , com_person           p
                     , com_currency         u
                     , prd_customer         cs
                     , (select x.object_id
                             , x.id
                             , x.id_type
                             , x.id_series
                             , x.id_number
                             , row_number() over (partition by object_id order by x.id desc) rn
                          from com_id_object x
                         where x.entity_type = com_api_const_pkg.entity_type_person) d
                     , (select x.object_id
                             , x.address_id
                             , row_number() over (partition by object_id order by x.id desc) rn
                             , x.address_type
                             , a.id adr_id
                             , a.lang adr_lang
                             , a.country
                             , a.region
                             , a.city
                             , a.street
                             , a.house
                             , a.apartment
                             , a.postal_code
                             , a.region_code
                             , a.inst_id
                             , x.entity_type
                          from com_address_object x
                             , com_address a
                         where x.entity_type = 'ENTTCRDH'--com_api_const_pkg.entity_type_person
                           and a.id = x.address_id) a
                     , (select o.object_id cardholder_id
                             , cd.commun_address mobile_phone
                             , row_number() over (partition by o.object_id order by cd.id desc) rn
                          from com_contact_object o 
                             , com_contact_data cd
                         where o.entity_type = 'ENTTCRDH'
                           and o.contact_id = cd.contact_id 
                           and cd.commun_method = 'CMNM0001') cn
                 where c.id            = ci.card_id
                   and ch.id(+)        = c.cardholder_id
                   and obj.object_id   = c.id
                   and obj.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and obj.account_id  = ac.id
                   and c.customer_id   = cs.id(+)
                   and ch.person_id    = p.id(+)
                   and p.lang(+)       = l_lang
                   and ac.currency     = u.code
                   and p.id            = d.object_id(+)
                   and d.rn(+)         = 1
                   and a.object_id(+)  = ch.id
                   and a.rn(+)         = 1
                   and a.adr_lang(+)   = l_lang
                   and cn.cardholder_id(+) = ch.id
                   and cn.rn(+)        = 1 
                   and (i_inst_id is null or ci.inst_id = i_inst_id)
                   and (i_agent_id is null or ci.agent_id = i_agent_id)
                   and ci.iss_date between l_start_date and l_end_date
        );
    exception
        when no_data_found then
            select xmlelement("cards", '')
              into l_detail
              from dual;

            trc_log_pkg.debug(
                i_text  => 'Cards not found'
            );
    end;

    select xmlelement(
               "report"
             , iss_api_report_pkg.get_header(i_inst_id, i_agent_id, l_start_date, l_end_date, l_lang)
             , l_detail
           ).getclobval()
      into o_xml
      from dual;

    trc_log_pkg.debug(
         i_text => 'iss_cst_report_pkg.card_mailer_report - ok'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text   => sqlerrm
        );
        raise;
end;

procedure card_holder_statement_rep_base(
    o_xml                  out      nocopy clob 
  , i_standard_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_start_date            in      date
  , i_end_date              in      date
  , i_product_id            in      com_api_type_pkg.t_short_id     default null
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_statement_service     in      com_api_type_pkg.t_boolean      default null
  , i_e_statement_service   in      com_api_type_pkg.t_boolean      default null
  , i_lang                  in      com_api_type_pkg.t_dict_value
)
is
    LOG_PREFIX                       constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.card_holder_statement_rep_base: ';
    ARRAY_ID_OPER_TYPE_FOR_REPORT    constant    com_api_type_pkg.t_medium_id  := -50000007;

    l_accounts_cur            sys_refcursor;
    l_header                  xmltype;
    l_oper_detail             clob;

    l_account_id              com_api_type_pkg.t_account_id;
    l_aval_balance            com_api_type_pkg.t_amount_rec;
    l_hold_balance            com_api_type_pkg.t_amount_rec;
    l_opening_balance         com_api_type_pkg.t_money      := 0;
    l_output_balance          com_api_type_pkg.t_money      := 0;

    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_from_id                 com_api_type_pkg.t_long_id;
    l_till_id                 com_api_type_pkg.t_long_id;
    l_customer_id             com_api_type_pkg.t_medium_id;
    
    l_address_rec             com_api_type_pkg.t_address_rec;
    l_statement_message       com_api_type_pkg.t_name;
    l_promotional_message     com_api_type_pkg.t_name;
    
    l_total_debit_amount      com_api_type_pkg.t_money;
    l_total_credit_amount     com_api_type_pkg.t_money;
    l_later_debit_amount      com_api_type_pkg.t_money      := 0;
    l_later_credit_amount     com_api_type_pkg.t_money      := 0;
    l_delivery_note           com_api_type_pkg.t_text;
    l_use_account             com_api_type_pkg.t_boolean;
    l_statement_service_id    com_api_type_pkg.t_short_id;
    l_e_statement_service_id  com_api_type_pkg.t_short_id;

    type t_account_rec is record (
        account_id       com_api_type_pkg.t_account_id
      , split_hash       com_api_type_pkg.t_tiny_id
      , customer_id      com_api_type_pkg.t_medium_id
    );

    type t_account_tab is table of t_account_rec index by binary_integer;

    l_accounts                t_account_tab;
    l_card_mask               com_api_type_pkg.t_card_number;
    l_cardholder_name         com_api_type_pkg.t_name;
    l_card_id                 com_api_type_pkg.t_name;
    l_card_category           com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run with params standard_id [#1], start_date [#2], end_date [#3], lang [#4]'
      , i_env_param1  => i_standard_id 
      , i_env_param2  => to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3  => to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param4  => i_lang
    );

    l_from_id := com_api_id_pkg.get_from_id(i_date => i_start_date);
    l_till_id := com_api_id_pkg.get_till_id(i_date => i_end_date);

    if i_contract_number is not null then

        open l_accounts_cur for
            select a.id              as account_id
                 , a.split_hash
                 , u.id              as customer_id
              from prd_contract   c
                 , acc_account    a
                 , prd_customer   u
             where reverse(c.contract_number)  = reverse(i_contract_number)
               and c.inst_id+0                 = i_inst_id
               and (c.product_id               = i_product_id      or i_product_id      is null)
               and a.contract_id               = c.id
               and a.split_hash                = c.split_hash
               and (a.agent_id                 = i_agent_id        or i_agent_id        is null)
               and (a.currency                 = i_currency        or i_currency        is null)
               and u.id                        = a.customer_id
               and u.split_hash                = a.split_hash
               and (u.customer_number          = i_customer_number or i_customer_number is null)
             order by a.agent_id
                    , u.id
                    , c.product_id
                    , c.contract_number
                    , a.currency;

    elsif i_customer_number is not null then

        open l_accounts_cur for
            select a.id              as account_id
                 , a.split_hash
                 , u.id              as customer_id
              from prd_customer   u
                 , acc_account    a
                 , prd_contract   c
             where reverse(u.customer_number)  = reverse(i_customer_number)
               and u.inst_id+0                 = i_inst_id
               and a.customer_id               = u.id
               and a.split_hash                = u.split_hash
               and (a.agent_id                 = i_agent_id        or i_agent_id        is null)
               and (a.currency                 = i_currency        or i_currency        is null)
               and c.id                        = a.contract_id
               and c.split_hash                = a.split_hash
               and i_contract_number is null
               and (c.product_id               = i_product_id      or i_product_id      is null)
             order by a.agent_id
                    , u.id
                    , c.product_id
                    , c.contract_number
                    , a.currency;

    elsif i_product_id is not null then

        open l_accounts_cur for
            select /*+ ordered use_nl(c, a, u) full(c) index(a acc_account_contract_ndx) index(u prd_customer_pk) */
                   a.id              as account_id
                 , a.split_hash
                 , u.id              as customer_id
              from prd_contract   c
                 , acc_account    a
                 , prd_customer   u
             where c.product_id       = i_product_id
               and c.inst_id          = i_inst_id
               and i_contract_number is null
               and a.contract_id      = c.id
               and a.split_hash       = c.split_hash
               and (a.agent_id        = i_agent_id        or i_agent_id        is null)
               and (a.currency        = i_currency        or i_currency        is null)
               and u.id               = a.customer_id
               and u.split_hash       = a.split_hash
               and i_customer_number is null
             order by a.agent_id
                    , u.id
                    , c.product_id
                    , c.contract_number
                    , a.currency;

    elsif i_agent_id is not null then

        open l_accounts_cur for
            select /*+ ordered use_nl(a, u, c) full(a) index(u prd_customer_pk) index(c prd_contract_pk) */
                   a.id              as account_id
                 , a.split_hash
                 , u.id              as customer_id
              from acc_account    a
                 , prd_customer   u
                 , prd_contract   c
             where a.agent_id         = i_agent_id
               and a.inst_id          = i_inst_id
               and (a.currency        = i_currency        or i_currency        is null)
               and u.id               = a.customer_id
               and u.split_hash       = a.split_hash
               and i_customer_number is null
               and c.id               = a.contract_id
               and c.split_hash       = a.split_hash
               and i_product_id      is null
               and i_contract_number is null
             order by a.agent_id
                    , u.id
                    , c.product_id
                    , c.contract_number
                    , a.currency;

    end if;

    trc_log_pkg.debug(
        i_text  => 'Cursor is opened'
    );

    fetch l_accounts_cur bulk collect into l_accounts;
    close l_accounts_cur;

    for i in 1 .. l_accounts.count loop

        l_use_account := com_api_type_pkg.TRUE;

        if i_standard_id = CREDIT_STATEMENT_REPORT_EXT then

            l_statement_service_id   := prd_api_service_pkg.get_active_service_id(
                                            i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                          , i_object_id       => l_accounts(i).customer_id
                                          , i_attr_name       => null
                                          , i_service_type_id => cst_icc_api_const_pkg.STATEMENT_SERVICE_TYPE_ID
                                          , i_split_hash      => l_accounts(i).split_hash
                                          , i_eff_date        => i_end_date
                                          , i_last_active     => com_api_type_pkg.FALSE
                                          , i_mask_error      => com_api_type_pkg.TRUE
                                          , i_inst_id         => i_inst_id
                                        );

            l_e_statement_service_id := prd_api_service_pkg.get_active_service_id(
                                            i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                          , i_object_id       => l_accounts(i).customer_id
                                          , i_attr_name       => null
                                          , i_service_type_id => cst_icc_api_const_pkg.E_STATEMENT_SERVICE_TYPE_ID
                                          , i_split_hash      => l_accounts(i).split_hash
                                          , i_eff_date        => i_end_date
                                          , i_last_active     => com_api_type_pkg.FALSE
                                          , i_mask_error      => com_api_type_pkg.TRUE
                                          , i_inst_id         => i_inst_id
                                        );

            if (i_statement_service      = com_api_const_pkg.TRUE  and l_statement_service_id is     null)
               or (i_statement_service   = com_api_const_pkg.FALSE and l_statement_service_id is not null)
               or (i_e_statement_service = com_api_const_pkg.TRUE  and l_statement_service_id is     null)
               or (i_e_statement_service = com_api_const_pkg.FALSE and l_statement_service_id is not null)
            then
                l_use_account := com_api_type_pkg.FALSE;
            end if;

        end if;

        if l_use_account = com_api_type_pkg.TRUE then

            -- get account id
            l_account_id         := l_accounts(i).account_id;
            l_split_hash         := l_accounts(i).split_hash;
            l_customer_id        := l_accounts(i).customer_id;
            
            -- get aval balance
            l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount(
                                  i_account_id  => l_account_id
                                , i_date        => i_end_date
                                , i_date_type   => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                              );
            -- get hold balance
            l_hold_balance := acc_api_balance_pkg.get_balance_amount(   
                                  i_account_id          => l_account_id
                                , i_balance_type        => acc_api_const_pkg.BALANCE_TYPE_HOLD
                                , i_date                => i_end_date
                                , i_date_type           => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                , i_mask_error          => com_api_const_pkg.TRUE
                              );
                              
            -- get primary card
            begin
                select iss_api_card_pkg.get_card_mask(i_card_number => s.card_number)
                     , s.cardholder_name
                     , to_char(s.card_id)
                     , com_api_dictionary_pkg.get_article_text(
                           i_article => s.category
                         , i_lang    => i_lang
                       )
                  into l_card_mask
                     , l_cardholder_name
                     , l_card_id
                     , l_card_category
                  from (
                        select ao.account_id
                             , ici.card_id
                             , iss_api_card_pkg.get_card_number(i_card_id => ici.card_id) as card_number
                             , ic.category
                             , ch.cardholder_name
                             , row_number() over(partition by ao.account_id order by decode(ic.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1), ici.seq_number desc) rnk
                          from acc_account_object ao
                             , iss_card ic
                             , iss_card_instance ici
                             , iss_cardholder ch
                         where ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and ao.object_id     = ic.id
                           and ici.card_id      = ic.id
                           and ao.account_id    = l_account_id
                           and ic.cardholder_id = ch.id
                       ) s
                 where s.rnk = 1;
            exception
                when no_data_found then
                    l_card_mask       := '';
                    l_cardholder_name := '';
                    l_card_id         := '';
                    l_card_category   := '';
            end;
            
            -- get extend data for CREDIT_STATEMENT_REPORT_EXT standart
            if i_standard_id = CREDIT_STATEMENT_REPORT_EXT then
                -- get address part
                begin
                    select id
                         , seqnum
                         , lang
                         , country
                         , region
                         , city
                         , street
                         , house
                         , apartment
                         , postal_code
                         , region_code
                         , latitude
                         , longitude
                         , inst_id
                         , place_code
                         , address_type
                      into l_address_rec
                      from (
                            select a.id
                                 , a.seqnum
                                 , a.lang
                                 , a.country
                                 , a.region
                                 , a.city
                                 , a.street
                                 , a.house
                                 , a.apartment
                                 , a.postal_code
                                 , a.region_code
                                 , a.latitude
                                 , a.longitude
                                 , a.inst_id
                                 , a.place_code
                                 , ao.address_type
                              from com_address a
                                 , com_address_object ao
                             where ao.entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               and ao.object_id    = l_customer_id
                               and a.id            = ao.address_id
                             order by
                                   decode(
                                       ao.address_type
                                     , com_api_const_pkg.ADDRESS_TYPE_STMT_DELIVERY
                                     , 0
                                     , com_api_const_pkg.ADDRESS_TYPE_HOME
                                     , 1
                                     , com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                                     , 2
                                     , 3
                                   )
                                 , decode(
                                       a.lang
                                     , i_lang
                                     , 0
                                     , com_api_const_pkg.DEFAULT_LANGUAGE
                                     , 1
                                     , 2
                                   )
                      )
                     where rownum = 1;
                exception
                    when no_data_found then
                        trc_log_pkg.debug(
                            i_text        => LOG_PREFIX || 'Not address data for: standard_id [#1] customer_id [#2]'
                          , i_env_param1  => i_standard_id 
                          , i_env_param2  => l_customer_id
                        );
                end;

                -- get delivery note
                begin
                    select com_api_i18n_pkg.get_text(
                               i_table_name  => ntb_api_const_pkg.NOTE_TABLE
                             , i_column_name => 'TEXT'
                             , i_object_id   => note_id
                           )
                      into l_delivery_note
                      from (
                          select n.id note_id
                               , n.entity_type
                               , n.object_id
                               , row_number() over(partition by n.entity_type, n.object_id order by n.id desc) rnk
                            from ntb_note n
                           where n.object_id   = l_customer_id
                             and n.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                             and coalesce(
                                     n.start_date
                                   , trunc(n.reg_date)
                                   , i_end_date
                                 ) <= i_end_date
                             and n.note_type   = ntb_api_const_pkg.NOTE_TYPE_DELIVERY_NOTE
                      ) nt
                     where nt.rnk = 1
                    ;
                exception
                    when no_data_found then
                        trc_log_pkg.debug(
                            i_text        => LOG_PREFIX || 'Not delivery note data for: standard_id [#1] customer_id [#2]'
                          , i_env_param1  => i_standard_id 
                          , i_env_param2  => l_customer_id
                        );
                end;

                -- get statement message
                l_statement_message := prd_api_product_pkg.get_attr_value_char(
                                           i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                         , i_object_id      => l_account_id
                                         , i_attr_name      => crd_api_const_pkg.CREDIT_STATEMENT_MESSAGE
                                         , i_eff_date       => i_end_date
                                         , i_split_hash     => l_split_hash
                                         , i_inst_id        => i_inst_id
                                         , i_mask_error     => com_api_const_pkg.TRUE
                                       );

                -- get promotional message
                l_promotional_message := prd_api_product_pkg.get_attr_value_char(
                                             i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                           , i_object_id    => l_customer_id
                                           , i_attr_name    => ntf_api_const_pkg.CUSTOMER_PROMOTIONAL_MESSAGE
                                           , i_eff_date     => i_end_date
                                           , i_split_hash   => l_split_hash
                                           , i_inst_id      => i_inst_id
                                           , i_mask_error   => com_api_const_pkg.TRUE
                                         );

                -- get opening_balance as the available balance from the previous cycle + holds amounts from the previous cycle
                l_opening_balance := acc_api_balance_pkg.get_aval_balance_amount(
                                         i_account_id       => l_account_id
                                       , i_date             => trunc(i_start_date) - com_api_const_pkg.ONE_SECOND
                                       , i_date_type        => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                     ).amount
                                   + acc_api_balance_pkg.get_balance_amount(   
                                         i_account_id       => l_account_id
                                       , i_balance_type     => acc_api_const_pkg.BALANCE_TYPE_HOLD
                                       , i_date             => trunc(i_start_date) - com_api_const_pkg.ONE_SECOND
                                       , i_date_type        => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                       , i_mask_error       => com_api_const_pkg.TRUE
                                     ).amount;

                -- get totals debit/credit
                select sum(entry_amount * decode(balance_impact, com_api_const_pkg.DEBIT,  1, 0))
                     , sum(entry_amount * decode(balance_impact, com_api_const_pkg.CREDIT, 1, 0))
                     , sum(
                           case
                               when posting_date > i_end_date
                               then entry_amount * decode(balance_impact, com_api_const_pkg.DEBIT,  1, 0)
                               else 0
                           end
                       )
                     , sum(
                           case
                               when posting_date > i_end_date
                               then entry_amount * decode(balance_impact, com_api_const_pkg.CREDIT, 1, 0)
                               else 0
                           end
                       )
                  into l_total_debit_amount
                     , l_total_credit_amount
                     , l_later_debit_amount
                     , l_later_credit_amount
                  from (
                    select e1.amount as entry_amount
                         , e1.balance_impact
                         , e1.posting_date
                      from acc_ui_entry_vw    e1
                         , com_array_element  e
                         , opr_participant    p
                         , opr_operation      o
                     where p.account_id       = l_account_id
                       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                       and p.oper_id    between l_from_id and l_till_id
                       and o.id               = p.oper_id
                       and e1.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and e1.object_id       = o.id
                       and e.array_id         = ARRAY_ID_OPER_TYPE_FOR_REPORT
                       and e.element_value    = e1.oper_type
                       and e1.status         != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                       and e1.account_id      = l_account_id
                       and e1.balance_type   != acc_api_const_pkg.BALANCE_TYPE_HOLD
                               
                    union all

                    select eb.amount as entry_amount
                         , eb.balance_impact
                         , eb.posting_date
                      from acc_entry_buffer   eb
                         , acc_macros         m2
                         , com_array_element  e
                         , opr_operation      o
                         , opr_participant    p
                     where p.account_id       = l_account_id
                       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                       and p.oper_id    between l_from_id and l_till_id
                       and o.id               = p.oper_id
                       and e.array_id         = ARRAY_ID_OPER_TYPE_FOR_REPORT
                       and e.element_value    = o.oper_type
                       and m2.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m2.object_id       = o.id
                       and eb.macros_id       = m2.id
                       and eb.status          = acc_api_const_pkg.ENTRY_SOURCE_BUFFER
                       and eb.account_id      = l_account_id
                       and eb.balance_type   != acc_api_const_pkg.BALANCE_TYPE_HOLD
                  )
                ;

                -- get output balances
                l_output_balance := nvl(l_aval_balance.amount, 0) - nvl(l_later_debit_amount, 0) - nvl(l_later_credit_amount, 0);

            end if;

            -- header
            select
                xmlconcat(
                    xmlelement("account"
                      , xmlelement("account_number",    t.customer_account)
                      , xmlelement("currency",          t.account_currency)
                      , xmlelement("currency_exponent", power(10, currency_exponent))
                      , xmlelement("amount_format",     '###0.' || lpad('0', greatest(currency_exponent, 2), '0')
                                                   || ';-###0.' || lpad('0', greatest(currency_exponent, 2), '0'))
                      , xmlelement("currency_name",     case when l_aval_balance.currency is not null then 
                                                            com_api_currency_pkg.get_currency_name(i_curr_code => l_aval_balance.currency)
                                                        end
                        )
                      , xmlelement("account_type", t.account_type)
                      , xmlelement("inst_id",      t.inst_id)
                      , xmlelement("inst_name",    com_api_i18n_pkg.get_text(
                                                       i_table_name    => 'OST_INSTITUTION'
                                                     , i_column_name   => 'NAME'
                                                     , i_object_id     => t.inst_id
                                                     , i_lang          => i_lang
                                                   )
                        )              
                      , xmlelement("agent_id",     t.agent_id)
                      , xmlelement("agent_name",   com_api_i18n_pkg.get_text(
                                                       i_table_name    => 'OST_AGENT'
                                                     , i_column_name   => 'NAME'
                                                     , i_object_id     => t.agent_id
                                                     , i_lang          => i_lang
                                                   )
                        )
                      , xmlelement("generation_date",             to_char(com_api_sttl_day_pkg.get_sysdate, 'dd/mm/yyyy'))
                      , xmlelement("customer"
                          , xmlelement("customer_number",         t.customer_number)
                          , xmlelement("customer_category",       t.category)
                          , xmlelement("resident",                t.resident)
                          , xmlelement("customer_relation",       t.relation)
                          , xmlelement("nationality",             t.nationality)
                          , xmlelement("is_person",               t.is_person)
                          , xmlelement("person"
                              , xmlelement("person_name"
                                  , xmlelement("surname",         t.surname)
                                  , xmlelement("first_name",      t.first_name)
                                  , xmlelement("second_name",     t.second_name)
                                )
                              , xmlelement("identity_card"
                                  , xmlelement("id_type",         to_char(null))
                                  , xmlelement("id_series",       to_char(null))
                                  , xmlelement("id_number",       to_char(null))
                                )
                            )
                          , xmlelement("company"
                              , xmlelement("company_name",        t.company_name)
                            )
                          , xmlelement("contact"
                              , xmlelement("contact_type",        to_char(null))
                              , xmlelement("preferred_lang",      to_char(null))
                              , xmlelement("contact_data"
                                  , xmlelement("commun_method",   to_char(null))
                                  , xmlelement( "commun_address", to_char(null))
                                )
                            )
                          , xmlelement("address"
                              , xmlelement("address_type",          decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.address_type, t.address_type))
                              , xmlelement("country",               decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.country, t.country))
                              , xmlelement("country_name",          com_api_country_pkg.get_country_full_name(
                                                                        i_code        => decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.country, t.country)
                                                                      , i_lang        => i_lang
                                                                      , i_raise_error => com_api_const_pkg.FALSE
                                                                    )
                                )
                              , xmlelement("address_name"
                                  , xmlelement("region",            decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.region, nvl(t.region, '')))
                                  , xmlelement("city",              decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.city, nvl(t.city, '')))
                                  , xmlelement("street",            decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.street, nvl(t.street, '')))
                                  , xmlelement("house",             decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.house, nvl(t.house, '')))
                                  , xmlelement("apartment",         decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.apartment, nvl(t.apartment, '')))
                                  , xmlelement("postal_code",       decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.postal_code, ''))
                                  , xmlelement("place_code",        decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_address_rec.place_code, ''))
                                  , xmlelement(
                                        "delivery_note"
                                      , decode(
                                            i_standard_id
                                          , CREDIT_STATEMENT_REPORT_EXT
                                          , l_delivery_note
                                          , ''
                                        )
                                    )
                                )
                            )
                        )
                      , xmlelement("contract"
                          , xmlelement("contract_type",        t.contract_type)
                          , xmlelement("product_id",           t.product_id)
                          , xmlelement("product_name",         t.product_name)
                          , xmlelement("product_description",  t.product_description)
                          , xmlelement("contract_number",      t.contract_number)
                          , xmlelement("contract_date",        to_char(t.contract_date, 'dd/mm/yyyy'))
                          , xmlelement("opening_balance",      nvl(opening_balance, 0))
                          , xmlelement("closing_balance",      nvl(output_balance, 0))
                          , xmlelement("start_date",           to_char(start_date,      'dd/mm/yyyy'))
                          , xmlelement("invoice_date",         to_char(invoice_date,    'dd/mm/yyyy'))
                          , xmlelement("total_income",         0)
                          , xmlelement("total_expence",        0)
                          , xmlelement("total_debit",          nvl(total_debit, 0))
                          , xmlelement("total_credit",         nvl(total_credit, 0))
                          , xmlelement("overdue",              0)
                          , xmlelement("overdue_interest",     0)
                          , xmlelement("interest_sum",         0)
                          , xmlelement("available_balance",    nvl(l_aval_balance.amount, 0))
                          , xmlelement("hold_amount",          nvl(l_hold_balance.amount, 0))
                          , xmlelement("serial_number",        to_char(null))
                          , xmlelement("invoice_type",         to_char(null))
                          , xmlelement("exceed_limit",         0)
                          , xmlelement("total_amount_due",     nvl(output_balance, 0))
                          , xmlelement("own_funds",            0)
                          , xmlelement("min_amount_due",       to_char(null))
                          , xmlelement("grace_date",           to_char(null))
                          , xmlelement("due_date",             to_char(null))
                          , xmlelement("penalty_date",         to_char(null))
                          , xmlelement("aging_period",         to_char(null)) 
                          , xmlelement("interest_period_date", null)                     
                          , xmlelement("statement_message",    decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_statement_message, 'Statement Message'))
                          , xmlelement("promotional_messages", decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, l_promotional_message, 'Promotional Messages'))
                        )
                    )
                )
            into l_header
            from (
                select a.account_number       as customer_account
                     , a.currency             as account_currency
                     , com_api_currency_pkg.get_currency_exponent(a.currency) as currency_exponent
                     , a.account_type
                     , a.inst_id
                     , a.agent_id
                     , c.customer_number
                     , c.category
                     , c.resident
                     , com_api_dictionary_pkg.get_article_text(i_article => c.relation, i_lang => i_lang) as relation
                     , c.nationality
                     , r.contract_type
                     , r.product_id
                     , get_text(
                           i_table_name  => 'prd_product'
                         , i_column_name => 'label'
                         , i_object_id   => r.product_id
                         , i_lang        => i_lang
                       ) as product_name
                     , get_text(
                           i_table_name  => 'prd_product'
                         , i_column_name => 'description'
                         , i_object_id   => r.product_id
                         , i_lang        => i_lang
                       ) as product_description
                     , r.contract_number
                     , r.start_date           as contract_date
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
                     , i_start_date           as start_date
                     , i_end_date             as invoice_date
                     , l_opening_balance      as opening_balance
                     , l_output_balance       as output_balance
                     , l_total_debit_amount   as total_debit
                     , l_total_credit_amount  as total_credit
                     , case c.entity_type
                           when com_api_const_pkg.ENTITY_TYPE_COMPANY
                           then com_api_i18n_pkg.get_text(
                                    i_table_name  => 'com_company'
                                  , i_column_name => 'label'
                                  , i_object_id   => c.object_id
                                  , i_lang        => i_lang
                                )
                           else null
                       end as company_name
                     , decode(c.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON, 1, 0) as is_person
                 from acc_account_vw  a
                    , prd_customer_vw c
                    , prd_contract    r
                    , com_person      p
                    , com_address_object_vw ob1
                    , com_address     d
                where a.id    = l_account_id
                  and c.id    = a.customer_id
                  and r.id    = a.contract_id
                  and p.id(+) = c.object_id
                  and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
                  and ob1.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  and ob1.object_id(+)   = c.id
                  and d.id(+)            = ob1.address_id
                  and rownum             = 1
            ) t;

            begin
                trc_log_pkg.debug(
                    i_text       => 'l_account_id [#1] l_split_hash[#2] l_from_id[#3] l_till_id[#4]'
                  , i_env_param1 => l_account_id
                  , i_env_param2 => l_split_hash
                  , i_env_param3 => l_from_id
                  , i_env_param4 => l_till_id
                );

                -- transactions details
                select xmlagg(
                           xmlelement("operation"
                             , l_header
                             , xmlelement("oper_type",               get_article_text(oper_type, i_lang))
                             , xmlelement("oper_description",        oper_description
                                                                  || decode(
                                                                         i_standard_id
                                                                       , CREDIT_STATEMENT_REPORT_EXT
                                                                       , case
                                                                             when oper_reason like 'FETP%'
                                                                                 then get_article_text(oper_type, i_lang) || ' (' || get_article_text(oper_reason, i_lang) || ')'
                                                                             else get_article_text(oper_type, i_lang)
                                                                         end
                                                                       , get_article_text(oper_type, i_lang)
                                                                     )
                                                                  || ' '
                                                                  || decode(
                                                                         i_standard_id
                                                                       , CREDIT_STATEMENT_REPORT_EXT
                                                                       , null
                                                                       , nvl2(oper_date,        to_char(oper_date, 'dd/mm/yyyy') || ' ', null)
                                                                     )
                                                                  || nvl2(trim(merchant_name),    trim(regexp_replace(merchant_name,   ' {2,}', ' '))  || ' ', null)
                                                                  || nvl2(trim(merchant_city),    trim(regexp_replace(merchant_city,   ' {2,}', ' '))  || nvl2(trim(merchant_street), ', ', null), null)
                                                                  || nvl2(trim(merchant_street),  trim(regexp_replace(merchant_street, ' {2,}', ' '))  || ' ', null)
                                                                  || case
                                                                         when amount_purpose like 'FETP%'
                                                                         then '(' || get_article_text(amount_purpose, i_lang) || ')'
                                                                         else null
                                                                     end
                                                                  || nvl2(oper_description, ')', '')
                                                                  || ' - ' || i.card_mask
                               )
                             , xmlelement("balance_type",            to_char(null))
                             , xmlelement("card_mask",               l_card_mask)
                             , xmlelement("cardholder_name",         l_cardholder_name)
                             , xmlelement("card_id",                 l_card_id)
                             , xmlelement("card_category",           com_api_dictionary_pkg.get_article_text(
                                                                         i_article => l_card_category
                                                                       , i_lang    => i_lang
                                                                     ))
                             , xmlelement("posting_date",            to_char(posting_date, 'dd/mm/yyyy'))
                             , xmlelement("oper_date",               to_char(oper_date, 'dd/mm/yyyy'))
                             , xmlelement("oper_currency",           oper_currency)
                             , xmlelement("oper_currency_exponent",  case when oper_currency is not null then 
                                                                         power(10, com_api_currency_pkg.get_currency_exponent(oper_currency))
                                                                     end
                               )
                             , xmlelement("oper_amount_format",      case when oper_currency is not null then
                                                                     '###0.' || lpad('0', greatest(com_api_currency_pkg.get_currency_exponent(oper_currency), 2), '0')
                                                                || ';-###0.' || lpad('0', greatest(com_api_currency_pkg.get_currency_exponent(oper_currency), 2), '0')
                                                                     end
                               )
                             , xmlelement("oper_currency_name",      case when oper_currency is not null then
                                                                         com_api_currency_pkg.get_currency_name(i_curr_code => oper_currency)
                                                                     end
                               )
                             , xmlelement("oper_amount",             nvl(oper_amount,     0))
                             , xmlelement("entry_currency",          entry_currency)
                             , xmlelement("entry_currency_exponent", power(10, com_api_currency_pkg.get_currency_exponent(entry_currency)))
                             , xmlelement("entry_amount_format",     '###0.' || lpad('0', greatest(com_api_currency_pkg.get_currency_exponent(entry_currency), 2), '0')
                                                                || ';-###0.' || lpad('0', greatest(com_api_currency_pkg.get_currency_exponent(entry_currency), 2), '0'))
                             , xmlelement("entry_currency_name",     com_api_currency_pkg.get_currency_name(i_curr_code => entry_currency))
                             , xmlelement("entry_amount",            nvl(entry_amount,     0))
                             , xmlelement("credit_oper_amount",     0)
                             , xmlelement("debit_oper_amount",      nvl(oper_amount, 0))
                             , xmlelement("overdraft_amount",       0)
                             , xmlelement("repayment_amount",       0)
                             , xmlelement("interest_amount",        0)
                             , xmlelement("amount_points",          0)
                             , xmlelement("oper_type_interest",     0)
                             , xmlelement("present_details",        1)
                           )
                       ).getclobval()
                 into l_oper_detail
                 from (
                     select oper_type
                          , oper_reason
                          , card_id
                          , posting_date
                          , oper_date
                          , merchant_city
                          , merchant_street
                          , merchant_name
                          , nvl2(amount_purpose, null, oper_currency) as oper_currency
                          , nvl2(amount_purpose, null, oper_amount)   as oper_amount -- hide operation amount for child-row
                          , entry_currency
                          , amount_purpose
                          , entry_amount
                          , oper_description
                       from (
                           select oper_type
                                , oper_reason
                                , card_id
                                , posting_date
                                , oper_date
                                , merchant_city
                                , merchant_street
                                , merchant_name
                                , oper_currency
                                , oper_amount * decode(balance_impact, com_api_const_pkg.DEBIT, -1, 1) as oper_amount
                                , entry_currency
                                , case
                                      when amount_purpose is null  -- Original operation
                                           or amount_purpose not like 'FETP%' -- Original operation with filled amount_purpose
                                           or amount_purpose in (
                                                  'FETP5021'       -- Account Cross Border Fee
                                                , 'FETP5022'       -- Account Markup Fee
                                              )
                                      then null                    -- Single row for these three amounts ("Original operation" + "Account Cross Border Fee" + "Account Markup Fee")
                                      else amount_purpose          -- Separated row for any other fee
                                  end as amount_purpose
                                , sum(decode(balance_impact, com_api_const_pkg.DEBIT, -1, 1) * nvl(entry_amount, 0)) as entry_amount
                                , oper_description
                           from (
                               select e1.object_id          as oper_id
                                    , e1.oper_type
                                    , o.oper_reason
                                    , p.card_id
                                    , decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, trunc(e1.posting_date), e1.host_date) as posting_date 
                                    , o.oper_date
                                    , o.oper_amount
                                    , o.oper_currency
                                    , e1.amount             as entry_amount
                                    , e1.currency           as entry_currency
                                    , e1.amount_purpose
                                    , e1.transaction_id
                                    , e1.merchant_city
                                    , e1.merchant_street
                                    , e1.merchant_name
                                    , e1.balance_impact
                                    , case 
                                          when o.is_reversal = 1
                                          then 'Reversal ('
                                          when o.dispute_id is not null and o.original_id is not null
                                          then 'Dispute ('
                                          when o.msg_type in (
                                                   opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                                 , opr_api_const_pkg.MESSAGE_TYPE_RETRIEVAL_REQUEST
                                                 , opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT
                                               )
                                          then 'Dispute ('
                                          when o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                           and o.oper_type in (
                                                   opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST
                                                 , opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST
                                               )
                                         then 'Dispute ('
                                          else ''
                                      end as oper_description
                                 from acc_ui_entry_vw    e1
                                    , com_array_element  e
                                    , opr_participant    p
                                    , opr_operation      o
                                where p.account_id       = l_account_id
                                  and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                  and p.oper_id    between l_from_id and l_till_id
                                  and o.id               = p.oper_id
                                  and e1.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                  and e1.object_id       = o.id
                                  and e.array_id         = ARRAY_ID_OPER_TYPE_FOR_REPORT
                                  and e.element_value    = e1.oper_type
                                  and e1.status         != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                                  and e1.account_id      = l_account_id
                                  and e1.balance_type   != acc_api_const_pkg.BALANCE_TYPE_HOLD

                               union all

                               select o.id                  as oper_id
                                    , o.oper_type
                                    , o.oper_reason
                                    , p.card_id
                                    , decode(i_standard_id, CREDIT_STATEMENT_REPORT_EXT, trunc(eb.posting_date), o.host_date) as posting_date
                                    , o.oper_date
                                    , o.oper_amount
                                    , o.oper_currency
                                    , eb.amount             as entry_amount
                                    , eb.currency           as entry_currency
                                    , m2.amount_purpose
                                    , eb.transaction_id
                                    , o.merchant_city
                                    , o.merchant_street
                                    , o.merchant_name
                                    , eb.balance_impact
                                    , case 
                                          when o.is_reversal = 1
                                          then 'Reversal ('
                                          when o.dispute_id is not null and o.original_id is not null
                                          then 'Dispute ('
                                          when o.msg_type in (
                                                   opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                                 , opr_api_const_pkg.MESSAGE_TYPE_RETRIEVAL_REQUEST
                                                 , opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT
                                               )
                                          then 'Dispute ('
                                          when o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                           and o.oper_type in (
                                                   opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST
                                                 , opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST
                                               )
                                          then 'Dispute ('
                                          else ''
                                      end as oper_description
                                 from acc_entry_buffer   eb
                                    , acc_macros         m2
                                    , com_array_element  e
                                    , opr_operation      o
                                    , opr_participant    p
                                where p.account_id       = l_account_id
                                  and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                  and p.oper_id    between l_from_id and l_till_id
                                  and o.id               = p.oper_id
                                  and e.array_id         = ARRAY_ID_OPER_TYPE_FOR_REPORT
                                  and e.element_value    = o.oper_type
                                  and m2.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                  and m2.object_id       = o.id
                                  and eb.macros_id       = m2.id
                                  and eb.status          = acc_api_const_pkg.ENTRY_SOURCE_BUFFER
                                  and eb.account_id      = l_account_id
                                  and eb.balance_type   != acc_api_const_pkg.BALANCE_TYPE_HOLD
                            )
                            group by oper_id
                                   , oper_type
                                   , card_id
                                   , posting_date
                                   , oper_date
                                   , merchant_city
                                   , merchant_street
                                   , merchant_name
                                   , oper_currency
                                   , oper_amount
                                   , entry_currency
                                   , balance_impact
                                   , case
                                         when amount_purpose is null  -- Original operation
                                              or amount_purpose not like 'FETP%' -- Original operation with filled amount_purpose
                                              or amount_purpose in (
                                                     'FETP5021'       -- Account Cross Border Fee
                                                   , 'FETP5022'       -- Account Markup Fee
                                                 )
                                         then null                    -- Single row for these three amounts ("Original operation" + "Account Cross Border Fee" + "Account Markup Fee")
                                         else amount_purpose          -- Separated row for any other fee
                                     end
                                   , oper_reason
                                   , oper_description
                            order by posting_date -- tag "posting_date" in report
                                   , oper_id
                                   , amount_purpose nulls first
                           )
                       ) m
                     , iss_card i
                 where i.id(+) = m.card_id;

            exception
                when no_data_found then
                    trc_log_pkg.debug(
                        i_text  => 'Operations not found'
                    );
            end;

            if l_oper_detail is null then
                select xmlelement("operation"
                         , l_header
                         , xmlelement("card_mask", l_card_mask)
                         , xmlelement("cardholder_name", l_cardholder_name)
                         , xmlelement("card_id", l_card_id)
                         , xmlelement("card_category", l_card_category)
                         , xmlelement("present_details",   0)
                       ).getclobval()
                  into l_oper_detail
                  from dual;
            end if;
        end if;

        o_xml := o_xml || l_oper_detail;

    end loop;

    o_xml := '<operations>'
             || o_xml
             || '</operations>';

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'End'
    );

exception
    when others then
        if l_accounts_cur%isopen then
            close l_accounts_cur;
        end if;

        trc_log_pkg.debug(
            i_text   => sqlerrm
        );
        raise;
end card_holder_statement_rep_base;

procedure card_holder_statement_report(
    o_xml                  out      nocopy clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_eff_date              in      date                            default null
  , i_product_id            in      com_api_type_pkg.t_short_id     default null
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in      com_api_type_pkg.t_name         default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
)
is
    LOG_PREFIX              constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.card_holder_statement_report: ';
    
    l_start_date            date;
    l_end_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run with params [#1] [#2] [#3] [#4] [#5] [#6] ['||i_currency||'] ['||i_introduced_by||'] ['||i_lang||']'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_agent_id
      , i_env_param3  => i_eff_date
      , i_env_param4  => i_product_id
      , i_env_param5  => i_contract_number
      , i_env_param6  => i_customer_number
    );

    l_lang        := nvl(i_lang, get_user_lang);
    l_end_date    := trunc(nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_start_date  := add_months(l_end_date, -1) + com_api_const_pkg.ONE_SECOND;

    card_holder_statement_rep_base(
        o_xml                   => o_xml
      , i_standard_id           => CREDIT_STATEMENT_REPORT_INIT
      , i_inst_id               => i_inst_id
      , i_agent_id              => i_agent_id
      , i_start_date            => l_start_date
      , i_end_date              => l_end_date
      , i_product_id            => i_product_id
      , i_contract_number       => i_contract_number
      , i_customer_number       => i_customer_number
      , i_currency              => i_currency
      , i_statement_service     => null
      , i_e_statement_service   => null
      , i_lang                  => l_lang
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'End'
    );

end card_holder_statement_report;

procedure card_holder_statement_rep_ext(
    o_xml                  out      nocopy clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_date_from             in      date                            default null
  , i_date_to               in      date
  , i_product_id            in      com_api_type_pkg.t_short_id     default null
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in      com_api_type_pkg.t_name         default null
  , i_statement_service     in      com_api_type_pkg.t_boolean      default null
  , i_e_statement_service   in      com_api_type_pkg.t_boolean      default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
)
is
    LOG_PREFIX              constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.card_holder_statement_rep_ext: ';
    
    l_start_date            date;
    l_end_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run with params [#1] [#2] [#3] [#4] [#5] [#6] ['||i_customer_number||'] ['||i_currency||'] ['||i_introduced_by||'] ['||i_statement_service||'] ['||i_e_statement_service||'] ['||i_lang||']'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_agent_id
      , i_env_param3  => i_date_from
      , i_env_param4  => i_date_to
      , i_env_param5  => i_product_id
      , i_env_param6  => i_contract_number
    );

    l_lang        := nvl(i_lang, get_user_lang);
    l_end_date    := trunc(nvl(i_date_to, com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_start_date  := nvl(trunc(i_date_from), trunc(l_end_date, 'mm'));

    card_holder_statement_rep_base(
        o_xml                   => o_xml
      , i_standard_id           => CREDIT_STATEMENT_REPORT_EXT
      , i_inst_id               => i_inst_id
      , i_agent_id              => i_agent_id
      , i_start_date            => l_start_date
      , i_end_date              => l_end_date
      , i_product_id            => i_product_id
      , i_contract_number       => i_contract_number
      , i_customer_number       => i_customer_number
      , i_currency              => i_currency
      , i_statement_service     => i_statement_service
      , i_e_statement_service   => i_e_statement_service
      , i_lang                  => l_lang
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'End'
    );

end card_holder_statement_rep_ext;

procedure card_holder_sttmnt_rep_determ(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is
    l_customer_number       com_api_type_pkg.t_name;
begin
    l_customer_number :=
        prd_api_customer_pkg.get_customer_number(
            i_customer_id => i_object_id
          , i_inst_id     => i_inst_id
        );
    
    card_holder_statement_report(
        o_xml                  => o_xml
      , i_inst_id              => i_inst_id
      , i_eff_date             => i_eff_date
      , i_customer_number      => l_customer_number
      , i_lang                 => i_lang
    );
end;

procedure card_hold_stmnt_rep_ext_determ(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) is
    l_customer_number       com_api_type_pkg.t_name;
    l_start_date            date;
    l_end_date              date;
begin
    l_end_date    := trunc(nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_start_date  := add_months(l_end_date, -1) + com_api_const_pkg.ONE_SECOND;
    l_customer_number :=
        prd_api_customer_pkg.get_customer_number(
            i_customer_id => i_object_id
          , i_inst_id     => i_inst_id
        );
    
    card_holder_statement_rep_ext(
        o_xml                  => o_xml
      , i_inst_id              => i_inst_id
      , i_date_from            => l_start_date
      , i_date_to              => l_end_date
      , i_customer_number      => l_customer_number
      , i_lang                 => i_lang
    );
end card_hold_stmnt_rep_ext_determ;

procedure card_holder_sttmnt_rep_event(
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
    l_month             com_api_type_pkg.t_attr_name;
begin
    trc_log_pkg.debug(
        i_text       => 'Card holder statment event notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    l_end_date   := trunc(i_eff_date);
    l_start_date := add_months(l_end_date, -1);
    l_month := to_char(l_end_date, 'Month', 'NLS_DATE_LANGUAGE=AMERICAN');

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
                   and entity_type   = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and document_type = rpt_api_const_pkg.DOCUMENT_TYPE_CUST_STTMT
                   and c.document_id = d.id
                 order by c.id desc
                  )
             where rownum = 1 
        ) t;
    exception
        when no_data_found then
            null;
    end;      
    
    select
        xmlelement("report"
          , xmlconcat(
                xmlelement("attachments"     , l_attach)
              , xmlelement("first_name"      , t.first_name)
              , xmlelement("second_name"     , t.second_name)
              , xmlelement("surname"         , t.surname)
              , xmlelement("start_date"      , to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement("end_date"        , to_char(l_end_date  , com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement("subject"         , 'Monthly statement for month ' || l_month)
           )
        )
      into l_result
      from (
        select com_ui_person_pkg.get_first_name(i_person_id => s.object_id, i_lang => i_lang) first_name
             , com_ui_person_pkg.get_second_name(i_person_id => s.object_id, i_lang => i_lang) second_name
             , com_ui_person_pkg.get_surname(i_person_id => s.object_id, i_lang => i_lang) surname
          from prd_customer s 
         where s.id = i_object_id
    ) t;
    
    o_xml := l_result.getclobval();
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );          
end;

procedure card_mailer_list_report(
    o_xml                  out    clob
  , i_inst_id               in    com_api_type_pkg.t_inst_id
  , i_agent_id              in    com_api_type_pkg.t_agent_id     default null
  , i_product_id            in    com_api_type_pkg.t_short_id     default null
  , i_customer_number       in    com_api_type_pkg.t_name         default null
  , i_card_mask             in    com_api_type_pkg.t_card_number  default null
  , i_is_express_card       in    com_api_type_pkg.t_boolean      default null
  , i_start_date            in    date                            default null
  , i_end_date              in    date                            default null
  , i_lang                  in    com_api_type_pkg.t_dict_value   default null
) is
    l_card_mask                   com_api_type_pkg.t_card_number;
    l_customer_number             com_api_type_pkg.t_name         := upper(i_customer_number);
    l_lang                        com_api_type_pkg.t_dict_value;
    l_start_date                  date;
    l_end_date                    date;
    l_generation_date             date;
    l_detail                      xmltype;
begin
    trc_log_pkg.debug (
        i_text        => 'iss_cst_report_pkg.card_mailer_list_report Start: inst_id [#1] agent_id [#2] product_id [#3] customer_number [#4] is_express_card [#5]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_agent_id
      , i_env_param3  => i_product_id
      , i_env_param4  => l_customer_number
      , i_env_param5  => i_is_express_card
    );

    l_lang            := nvl(i_lang, get_user_lang);
    l_generation_date := get_sysdate;
    l_start_date      := trunc(nvl(i_start_date, l_generation_date));
    l_end_date        := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    if i_card_mask is not null then
        l_card_mask := iss_api_card_pkg.get_card_mask(i_card_number => i_card_mask);
    end if;

    trc_log_pkg.debug (
        i_text        => 'iss_cst_report_pkg.card_mailer_list_report: card_mask [#1] lang [#2] start_date [#3] end_date [#4]'
      , i_env_param1  => l_card_mask
      , i_env_param2  => l_lang
      , i_env_param3  => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param4  => com_api_type_pkg.convert_to_char(l_end_date)
    );

    -- details
    begin
        select
            xmlelement("cards"
              , xmlagg(
                  xmlelement("card"
                      -- Parameter values
                    , xmlelement("param_inst_id",          i_inst_id)
                    , xmlelement("param_inst",             com_api_i18n_pkg.get_text('ost_institution',    'name', i_inst_id,  i_lang))
                    , xmlelement("param_agent_id",         i_agent_id)
                    , xmlelement("param_agent_name",       com_api_i18n_pkg.get_text('ost_agent',          'name', i_agent_id, i_lang))
                    , xmlelement("param_start_date",       to_char(l_start_date,      'dd.mm.yyyy'))
                    , xmlelement("param_end_date",         to_char(l_end_date,        'dd.mm.yyyy'))
                    , xmlelement("param_generation_date",  to_char(l_generation_date, 'dd.mm.yyyy hh24:mi:ss'))
                    , xmlelement("param_product_id",       i_product_id)
                    , xmlelement("param_product_name",     com_api_i18n_pkg.get_text('prd_product',       'label', i_product_id,   l_lang))
                    , xmlelement("param_customer_number",  i_customer_number)
                    , xmlelement("param_card_mask",        i_card_mask)
                    , xmlelement("param_is_express_card",  nvl2(i_is_express_card, get_article_text('BOOL000' || i_is_express_card), null) )
                    , xmlelement("param_lang",             get_article_text(i_lang, i_lang))
                      -- Detail data
                    , xmlelement("inst_id",                m.inst_id)
                    , xmlelement("inst",                   com_api_i18n_pkg.get_text('ost_institution',    'name', m.inst_id,      l_lang))
                    , xmlelement("agent_id",               m.agent_id)
                    , xmlelement("agent_name",             m.agent_name)
                    , xmlelement("card_type",              com_api_i18n_pkg.get_text('net_card_type',      'name', m.card_type_id, l_lang))
                    , xmlelement("card_mask",              m.card_mask)
                    , xmlelement("customer_number",        m.customer_number)
                    , xmlelement("product_id",             m.product_id)
                    , xmlelement("product_desc",           m.product_desc)
                    , xmlelement("iss_date",               to_char(m.iss_date,   'mm/yyyy'))
                    , xmlelement("expir_date",             to_char(m.expir_date, 'mm/yyyy'))
                    , xmlelement("embossed_name",          m.embossed_name)
                    , xmlelement("company_name",           m.company_name)
                    , (
                          select xmlelement("card_currency_list", trim(listagg(cur.name, ', ') within group (order by cur.name)))
                            from acc_account_object obj
                               , acc_account        ac
                               , com_currency       cur
                           where obj.object_id   = m.card_id
                             and obj.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                             and ac.id           = obj.account_id
                             and cur.code        = ac.currency
                      ) as card_currency_list
                    , xmlelement("is_express_card"
                        , get_article_text(
                              'BOOL000'
                              || to_char(case
                                             when m.perso_priority = iss_api_const_pkg.PERSO_PRIORITY_EXPRESS
                                             then com_api_type_pkg.TRUE
                                             else com_api_type_pkg.FALSE
                                         end)
                          )
                      )
                     , (select xmlelement("sms_mobile_number", max(cd.commun_address))
                          from com_contact_object o 
                             , com_contact_data cd
                         where o.object_id      = m.cardholder_id
                           and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                           and o.contact_type   = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                           and cd.contact_id    = o.contact_id
                           and cd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                           and cd.id in (
                                            select max(mcd.id)
                                              from com_contact_object mo
                                                 , com_contact_data mcd
                                             where mo.object_id      = o.object_id
                                               and mo.entity_type    = o.entity_type
                                               and mo.contact_type   = o.contact_type
                                               and mcd.contact_id    = mo.contact_id
                                               and mcd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                        )
                       )
                     , (select xmlelement("primary_mobile_number", max(cd.commun_address))
                          from com_contact_object o 
                             , com_contact_data cd
                         where o.object_id   = m.customer_id
                           and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           and o.contact_type   = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                           and cd.contact_id    = o.contact_id
                           and cd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                           and cd.id in (
                                            select max(mcd.id)
                                              from com_contact_object mo
                                                 , com_contact_data mcd
                                             where mo.object_id      = o.object_id
                                               and mo.entity_type    = o.entity_type
                                               and mo.contact_type   = o.contact_type
                                               and mcd.contact_id    = mo.contact_id
                                               and mcd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                        )
                       )
                    , xmlelement("card_status",          card_status)
                    , xmlelement("card_status_name",     get_article_text(card_status, l_lang))
                    , xmlelement("card_id",              card_id)
                    , xmlelement("cardholder_id",        cardholder_id)
                    , xmlelement("customer_id",          customer_id)
                      -- Customer address
                    , xmlelement("address_id",  ma.address_id)
                    , xmlelement("address", 
                          com_api_address_pkg.get_address_string(
                              i_country      => (select com_api_i18n_pkg.get_text('com_country', 'name', cc.id, ma.lang) from com_country cc where cc.code = ma.country)
                            , i_region       => ma.region
                            , i_city         => ma.city
                            , i_street       => ma.street
                            , i_house        => ma.house
                            , i_apartment    => ma.apartment
                            , i_postal_code  => ma.postal_code
                            , i_inst_id      => ma.inst_id
                            , i_enable_empty => com_api_type_pkg.TRUE)
                      )
                    , xmlelement("city",        ma.city)
                    , xmlelement("region",      ma.region)
                    , xmlelement("country",     ma.country)
                    , xmlelement("postal_code", ma.postal_code)
                      -- Delivery address
                    , xmlelement("card_delivery_address_id",  da.address_id)
                    , xmlelement("card_delivery_address", 
                          com_api_address_pkg.get_address_string(
                              i_country      => (select com_api_i18n_pkg.get_text('com_country', 'name', cc.id, da.lang) from com_country cc where cc.code = da.country)
                            , i_region       => da.region
                            , i_city         => da.city
                            , i_street       => da.street
                            , i_house        => da.house
                            , i_apartment    => da.apartment
                            , i_postal_code  => da.postal_code
                            , i_inst_id      => da.inst_id
                            , i_enable_empty => com_api_type_pkg.TRUE)
                      )
                    , xmlelement("card_delivery_city",        da.city)
                    , xmlelement("card_delivery_region",      da.region)
                    , xmlelement("card_delivery_country",     da.country)
                    , xmlelement("card_delivery_postal_code", da.postal_code)
                  )
                  order by
                      m.agent_name
                    , m.product_desc
                    , m.embossed_name
                    , m.customer_number
                )
            )
          into l_detail
          from (
              -- Use index "reverse(card_mask)"
              select ci.inst_id
                   , ci.agent_id
                   , com_api_i18n_pkg.get_text('ost_agent', 'name', ci.agent_id, l_lang) as agent_name
                   , ci.card_id
                   , ci.split_hash
                   , ci.perso_priority
                   , ci.cardholder_name as embossed_name
                   , ci.iss_date
                   , ci.expir_date
                   , c.card_type_id
                   , c.card_mask
                   , c.customer_id
                   , c.cardholder_id
                   , c.contract_id
                   , cs.customer_number
                   , ci.company_name
                   , ct.product_id
                   , com_api_i18n_pkg.get_text('prd_product', 'description', ct.product_id, l_lang) as product_desc
                   , ci.status as card_status
                from iss_card             c
                   , iss_card_instance    ci
                   , prd_customer         cs
                   , prd_contract         ct
                   , iss_cardholder       ch
               where i_card_mask       is not null
                 and reverse(c.card_mask) = reverse(i_card_mask)
                 and ci.card_id    = c.id
                 and ci.split_hash = c.split_hash
                 and cs.id         = c.customer_id
                 and cs.split_hash = c.split_hash
                 and ct.id         = c.contract_id
                 and ct.split_hash = c.split_hash
                 and ch.id(+)      = c.cardholder_id
                 and ci.state      = iss_api_const_pkg.CARD_STATE_ACTIVE
                 and ci.status    in (iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                    , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)
                 and ci.inst_id    = i_inst_id
                 and (i_agent_id        is null or ci.agent_id                 = i_agent_id)
                 and (i_product_id      is null or ct.product_id               = i_product_id)
                 and (l_customer_number is null or reverse(cs.customer_number) = reverse(l_customer_number))
                 and (i_is_express_card is null or (case
                                                        when ci.perso_priority = iss_api_const_pkg.PERSO_PRIORITY_EXPRESS
                                                        then com_api_type_pkg.TRUE
                                                        else com_api_type_pkg.FALSE
                                                    end) = i_is_express_card)
                 and ci.iss_date between l_start_date and l_end_date

              union all
              -- Use index "reverse(customer_number)"
              select ci.inst_id
                   , ci.agent_id
                   , com_api_i18n_pkg.get_text('ost_agent', 'name', ci.agent_id, l_lang) as agent_name
                   , ci.card_id
                   , ci.split_hash
                   , ci.perso_priority
                   , ci.cardholder_name
                   , ci.iss_date
                   , ci.expir_date
                   , c.card_type_id
                   , c.card_mask
                   , c.customer_id
                   , c.cardholder_id
                   , c.contract_id
                   , cs.customer_number
                   , ci.company_name
                   , ct.product_id
                   , com_api_i18n_pkg.get_text('prd_product', 'description', ct.product_id, l_lang) as product_desc
                   , ci.status as card_status
                from prd_customer         cs
                   , iss_card             c
                   , iss_card_instance    ci
                   , prd_contract         ct
                   , iss_cardholder       ch
               where i_card_mask       is null
                 and l_customer_number is not null
                 and reverse(cs.customer_number) = reverse(l_customer_number)
                 and c.customer_id = cs.id
                 and c.split_hash  = cs.split_hash
                 and ci.card_id    = c.id 
                 and ci.split_hash = c.split_hash
                 and ct.id         = c.contract_id
                 and ct.split_hash = c.split_hash
                 and ch.id(+)      = c.cardholder_id
                 and ci.state      = iss_api_const_pkg.CARD_STATE_ACTIVE
                 and ci.status    in (iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                    , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)
                 and ci.inst_id    = i_inst_id
                 and (i_agent_id        is null or ci.agent_id          = i_agent_id)
                 and (i_product_id      is null or ct.product_id        = i_product_id)
                 and (i_card_mask       is null or reverse(c.card_mask) = reverse(i_card_mask))
                 and (i_is_express_card is null or (case
                                                        when ci.perso_priority = iss_api_const_pkg.PERSO_PRIORITY_EXPRESS
                                                        then com_api_type_pkg.TRUE
                                                        else com_api_type_pkg.FALSE
                                                    end) = i_is_express_card)
                 and ci.iss_date between l_start_date and l_end_date
              union all
              -- Full scan
              select ci.inst_id
                   , ci.agent_id
                   , com_api_i18n_pkg.get_text('ost_agent', 'name', ci.agent_id, l_lang) as agent_name
                   , ci.card_id
                   , ci.split_hash
                   , ci.perso_priority
                   , ci.cardholder_name
                   , ci.iss_date
                   , ci.expir_date
                   , c.card_type_id
                   , c.card_mask
                   , c.customer_id
                   , c.cardholder_id
                   , c.contract_id
                   , cs.customer_number
                   , ci.company_name
                   , ct.product_id
                   , com_api_i18n_pkg.get_text('prd_product', 'description', ct.product_id, l_lang) as product_desc
                   , ci.status as card_status
                from iss_card_instance    ci
                   , iss_card             c
                   , prd_customer         cs
                   , prd_contract         ct
                   , iss_cardholder       ch
               where i_card_mask       is null
                 and l_customer_number is null
                 and c.id          = ci.card_id
                 and c.split_hash  = ci.split_hash
                 and cs.id         = c.customer_id
                 and cs.split_hash = c.split_hash
                 and ct.id         = c.contract_id
                 and ct.split_hash = c.split_hash
                 and ch.id(+)      = c.cardholder_id
                 and ci.state      = iss_api_const_pkg.CARD_STATE_ACTIVE
                 and ci.status    in (iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                    , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)
                 and ci.inst_id    = i_inst_id
                 and (i_agent_id        is null or ci.agent_id                 = i_agent_id)
                 and (i_product_id      is null or ct.product_id               = i_product_id)
                 and (l_customer_number is null or reverse(cs.customer_number) = reverse(l_customer_number))
                 and (i_card_mask       is null or reverse(c.card_mask)        = reverse(i_card_mask))
                 and (i_is_express_card is null or (case
                                                        when ci.perso_priority = iss_api_const_pkg.PERSO_PRIORITY_EXPRESS
                                                        then com_api_type_pkg.TRUE
                                                        else com_api_type_pkg.FALSE
                                                    end) = i_is_express_card)
                 and ci.iss_date between l_start_date and l_end_date
        ) m
        , (select x.object_id
                , x.address_id
                , row_number() over (partition by object_id order by x.id desc) as rn
                , x.address_type
                , a.id adr_id
                , a.lang
                , a.country
                , a.region
                , a.city
                , a.street
                , a.house
                , a.apartment
                , a.postal_code
                , a.region_code
                , a.inst_id
                , x.entity_type
             from com_address_object x
                , com_address a
            where x.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
              and x.address_type in ('ADTPHOME', 'ADTPBSNA')
              and a.id            = x.address_id
          ) ma
        , (select x.object_id
                , x.address_id
                , row_number() over (partition by object_id order by x.id desc) as rn
                , x.address_type
                , a.id adr_id
                , a.lang
                , a.country
                , a.region
                , a.city
                , a.street
                , a.house
                , a.apartment
                , a.postal_code
                , a.region_code
                , a.inst_id
                , x.entity_type
             from com_address_object x
                , com_address a
            where x.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
              and x.address_type = 'ADTPCDAD'
              and a.id           = x.address_id
          ) da
    where ma.object_id(+) = m.customer_id
      and ma.rn(+)        = 1
      and ma.lang(+)      = l_lang
      and da.object_id(+) = m.cardholder_id
      and da.rn(+)        = 1
      and da.lang(+)      = l_lang;

    exception
        when no_data_found then

            select xmlelement("cards", '')
              into l_detail
              from dual;

            trc_log_pkg.debug(
                i_text  => 'Cards not found'
            );
    end;

    select xmlelement(
               "report"
             , iss_api_report_pkg.get_header(i_inst_id, i_agent_id, l_start_date, l_end_date, l_lang)
             , l_detail
           ).getclobval()
      into o_xml
      from dual;

    trc_log_pkg.debug(
         i_text => 'iss_cst_report_pkg.card_mailer_list_report Finish: ok'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text   => sqlerrm
        );
        raise;
end card_mailer_list_report;

end iss_cst_report_pkg;
/
