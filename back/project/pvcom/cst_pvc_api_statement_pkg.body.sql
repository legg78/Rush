create or replace package body cst_pvc_api_statement_pkg is

STATEMENT_PATH_PART         constant com_api_type_pkg.t_name := 'Credit_Statement';
STATEMENT_NUMBER_FORMAT     constant com_api_type_pkg.t_name := 'FM999,999,999,999';
STATEMENT_DATE_FORMAT       constant com_api_type_pkg.t_name := cst_pvc_api_const_pkg.CST_PRT_DATE_FORMAT;

function get_bann_filename(
    i_message_id            in  com_api_type_pkg.t_text
  , i_lang                  in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name
is
    l_filename                  com_api_type_pkg.t_name;
begin
    select filename
      into l_filename
      from rpt_banner b
     where exists(
                  select 1
                    from com_i18n c
                   where c.table_name   = 'RPT_BANNER'
                     and c.column_name  = 'LABEL'
                     and c.text         = i_message_id
                     and c.object_id    = b.id
                 );

    return l_filename;
end get_bann_filename;

function get_bann_message(
    i_message_id            in  com_api_type_pkg.t_text
  , i_lang                  in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text
is
    l_message                   com_api_type_pkg.t_text;
begin
    select com_api_i18n_pkg.get_text('RPT_BANNER', 'DESCRIPTION', c.object_id, '')
      into l_message
      from com_i18n c
     where c.table_name     = 'RPT_BANNER'
       and c.column_name    = 'LABEL'
       and c.text           = i_message_id
       and exists (
                   select 1
                     from rpt_banner b
                    where b.id      = c.object_id
                      and b.status  = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE --'BNST0100'
                  );

    return l_message;
end get_bann_message;

function format_amount(
    i_amount                in  com_api_type_pkg.t_money
  , i_curr_code             in  com_api_type_pkg.t_curr_code
  , i_mask_curr_code        in  com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator         in  com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error            in  com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_format_base               com_api_type_pkg.t_name;
    l_result                    com_api_type_pkg.t_name;
begin
    if i_use_separator = com_api_type_pkg.TRUE then
        l_format_base := STATEMENT_NUMBER_FORMAT;
    else
        l_format_base := com_api_const_pkg.XML_NUMBER_FORMAT;
    end if;

    if i_amount is not null then
        select to_char( round(i_amount) / power(10, exponent)
                      , l_format_base ||
                        case
                            when exponent > 0
                            then '.' || rpad('0', exponent, '0')
                            else null
                        end
                      )
               || case
                      when i_mask_curr_code = com_api_type_pkg.FALSE
                      then ' ' || name
                      else ''
                  end
          into l_result
          from com_currency
         where code = i_curr_code;
    end if;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return to_char(i_amount);
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CURRENCY_NOT_FOUND'
              , i_env_param1 => i_curr_code
            );
        end if;
end format_amount;

procedure run_report(
    o_xml                   out clob
  , i_lang                  in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_medium_id
  , i_entity_type           in  com_api_type_pkg.t_dict_value  default crd_api_const_pkg.ENTITY_TYPE_INVOICE
  , i_attachment_format_id  in  com_api_type_pkg.t_tiny_id     default null
)is
    l_header                    xmltype;
    l_detail_1                  xmltype;
    l_detail_2                  xmltype;
    l_detail_3                  xmltype;
    l_result                    xmltype;
    l_agent_number              com_api_type_pkg.t_name;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_address_rec               com_api_type_pkg.t_address_rec;
    l_address_str                com_api_type_pkg.t_full_desc;
    l_account_id                com_api_type_pkg.t_account_id;
    l_account_number            com_api_type_pkg.t_account_number;
    l_lty_account_id_tab        num_tab_tpt := num_tab_tpt();
    l_lty_account               acc_api_type_pkg.t_account_rec;
    l_main_card_id              com_api_type_pkg.t_medium_id;
    l_main_card_number          com_api_type_pkg.t_card_number;
    l_card_number               com_api_type_pkg.t_name;
    l_card_type_desc            com_api_type_pkg.t_short_desc;
    l_invoice_id                com_api_type_pkg.t_medium_id;
    l_invoice_date              date;
    l_start_date                date;
    l_due_date                  date;

    l_mad                       com_api_type_pkg.t_money;
    l_tad                       com_api_type_pkg.t_money;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_currency                  com_api_type_pkg.t_dict_value;

    l_exceed_limit              com_api_type_pkg.t_amount_rec;
    l_credit_limit              com_api_type_pkg.t_balance_id;
    l_avail_credit_amount       com_api_type_pkg.t_money := 0;
    l_prev_invoice              crd_api_type_pkg.t_invoice_rec;
    l_total_payment             com_api_type_pkg.t_money := 0;

    l_own_funds                 com_api_type_pkg.t_money := 0;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_statement_path            com_api_type_pkg.t_name;

    l_attachment_name           com_api_type_pkg.t_name;
    l_name_params               com_api_type_pkg.t_param_tab;
    l_inst_id                   com_api_type_pkg.t_inst_id;

begin

    trc_log_pkg.debug (
        i_text        => 'Run statement report, language [#1], entity type [#2], object id [#3]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_entity_type
      , i_env_param3  => i_object_id
    );

    l_lang := nvl(i_lang, get_user_lang);

    l_prev_invoice := null;

    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => i_entity_type
                          , i_object_id   => i_object_id
                          , i_mask_error  => com_api_const_pkg.FALSE
                        );
        l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id => i_object_id
                          , i_split_hash => l_split_hash
                          , i_mask_error => com_api_const_pkg.FALSE
                        );
    elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_invoice_id := i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;

    -- Preliminary checks
    if i_object_id is null then
        com_api_error_pkg.raise_error (
            i_error  => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- Get invoice and account information
    begin
        select a.customer_id
             , i.account_id
             , i.invoice_date
             , a.account_number
             , crd_invoice_pkg.round_up_mad(
                   i_account_id => a.id
                 , i_mad        => i.min_amount_due
                 , i_tad        => i.total_amount_due
               ) as mad
             , i.due_date as due_date
             , i.total_amount_due
             , a.split_hash
             , nvl(i.available_balance, 0)
             , nvl(i.own_funds, 0)
             , ag.agent_number
             , a.inst_id
             , a.currency
          into l_customer_id
             , l_account_id
             , l_invoice_date
             , l_account_number
             , l_mad
             , l_due_date
             , l_tad
             , l_split_hash
             , l_avail_credit_amount
             , l_own_funds
             , l_agent_number
             , l_inst_id
             , l_currency
          from crd_invoice i
             , acc_account a
             , ost_agent ag
         where a.id = i.account_id
           and i.agent_id = ag.id(+)
           and i.id = l_invoice_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'INVOICE_NOT_FOUND'
              , i_env_param1  => l_invoice_id
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
              , i_object_id   => l_invoice_id
            );
    end;

    l_address_rec :=
        com_api_address_pkg.get_address(
            i_object_id     => l_customer_id
          , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_address_type  => null
        );

    l_address_str :=
        com_api_address_pkg.get_address_string(
            i_country       => l_address_rec.country
          , i_region        => l_address_rec.region
          , i_city          => l_address_rec.city
          , i_street        => l_address_rec.street
          , i_house         => l_address_rec.house
          , i_apartment     => l_address_rec.apartment
          , i_postal_code   => l_address_rec.postal_code
          , i_region_code   => l_address_rec.region_code
          , i_inst_id       => l_inst_id
        );

    -- Get previous invoice information
    select lag(a.id) over (order by a.invoice_date, a.id) lag_id
      into l_prev_invoice.id
      from crd_invoice_vw a
     where a.id = l_invoice_id;

    if l_prev_invoice.id is null then
        trc_log_pkg.debug (
            i_text  => 'Previous invoice not found'
          , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
          , i_object_id   => l_invoice_id
        );
        -- Calculate start date
        begin
            select o.start_date
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and o.object_id    = l_account_id
               and o.split_hash   = l_split_hash
               and s.id = o.service_id
               and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
                  , i_env_param1  => l_account_id
                  , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                );
        end;
    else
        l_prev_invoice := crd_invoice_pkg.get_invoice(
                              i_invoice_id  => l_prev_invoice.id
                          );
        l_start_date := l_prev_invoice.invoice_date;
    end if;

    trc_log_pkg.debug (
        i_text        => 'Calculated start date: [#1]'
      , i_env_param1  => to_char(l_start_date, STATEMENT_DATE_FORMAT )
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
      , i_object_id   => l_invoice_id
    );

    -- Get statement path:
    begin
        select directory_path
          into l_statement_path
          from prc_directory
         where lower(directory_path) like '%' || lower(STATEMENT_PATH_PART) || '%';
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'DIRECTORY_NOT_FOUND'
              , i_env_param1  => STATEMENT_PATH_PART
            );
    end;

    -- Get attachmennt file name
    if i_attachment_format_id is null then
        l_attachment_name := 'NOTIF_INVOICE_' || to_char(l_invoice_id) || '_' || trim(l_agent_number) || '.pdf';
    else
        rul_api_param_pkg.set_param (
            i_name      => 'SYS_DATE'
          , i_value     => trunc(sysdate)
          , io_params   => l_name_params
        );
        l_attachment_name := rul_api_name_pkg.get_name (
            i_format_id => i_attachment_format_id
          , i_param_tab => l_name_params
        );
    end if;

    -- Get total payments amount
    select nvl(sum(p.amount), 0)
      into l_total_payment
      from crd_invoice_payment i
         , crd_payment p
     where i.invoice_id     = l_invoice_id
       and p.id             = i.pay_id
       and i.split_hash     = l_split_hash
       and p.split_hash     = l_split_hash
       and i.is_new         = com_api_type_pkg.TRUE
    ;

    trc_log_pkg.debug (
        i_text        => 'Total payments amount: [#1]'
      , i_env_param1  => l_total_payment
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => l_invoice_id
    );

    -- Get main card (Primary or other existing)
    l_main_card_id :=
        cst_pvc_com_pkg.get_main_card_id (
            i_account_id    => l_account_id
          , i_split_hash    => l_split_hash
        );

    select card_mask
         , com_api_i18n_pkg.get_text('NET_CARD_TYPE','NAME', ic.card_type_id, l_lang) card_type_desc
      into l_main_card_number
         , l_card_type_desc
      from iss_card ic
     where ic.id = l_main_card_id;

    -- Get card list (start with primary card)
    select listagg(t.card_mask, '|') within group (order by t.seqnum) as card_list
      into l_card_number
      from (
           select c.card_mask
                , row_number() over (order by
                                    case
                                        when c.category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY then 1
                                        when c.category = iss_api_const_pkg.CARD_CATEGORY_DOUBLE then 2
                                        when c.category = iss_api_const_pkg.CARD_CATEGORY_UNDEFINED then 3
                                        when c.category = iss_api_const_pkg.CARD_CATEGORY_VIRTUAL then 4
                                    end) as seqnum
             from iss_card_vw c
                , acc_account_object ao
            where ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
              and ao.object_id     = c.id
              and ao.account_id    = l_account_id
           ) t;

    -- Get credit limit and cash limit:
    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id    => l_account_id
          , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_date          => l_invoice_date
          , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error    => com_api_const_pkg.TRUE
        );
    l_credit_limit := nvl(l_exceed_limit.amount, 0);

    -- Create header:
    select xmlconcat(
               xmlelement("customer_name", t.customer_name)
             , xmlelement("post_addr", t.customer_address)
             , xmlelement("card_number", l_card_number)
             , xmlelement("card_type", l_card_type_desc)
             , xmlelement("credit_limit", format_amount(nvl(l_credit_limit, 0), l_currency))
             , xmlelement("available_credit_amount", format_amount(nvl(l_avail_credit_amount, 0), l_currency))
             , xmlelement("invoice_date", to_char((l_invoice_date), STATEMENT_DATE_FORMAT ))
             , xmlelement("start_date", to_char(l_start_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("end_date", to_char(l_invoice_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("due_date", to_char(l_due_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("opening_balance", format_amount(greatest(l_prev_invoice.total_amount_due - l_prev_invoice.own_funds - l_total_payment, 0), l_currency))
             , xmlelement("min_amount_due", format_amount(nvl(l_mad, 0), l_currency))
             , xmlelement("total_amount_due", format_amount(greatest(l_tad - l_own_funds, 0), l_currency))
             , xmlelement("hdr_logo_path", t.hdr_logo_path)
             , xmlelement("imp_mess", t.imp_mess)
             , xmlelement("attachments"
                 , xmlelement("attachment"
                     , xmlelement("attachment_path", l_statement_path)
                     , xmlelement("attachment_name", l_attachment_name)
                   )
               )
           )
      into l_header
      from (
            select get_bann_filename('STMT_HDR_LOGO', l_lang) hdr_logo_path
                 , get_bann_message('STMT_IMP_MESS', l_lang) imp_mess
                 , case c.entity_type
                       when com_api_const_pkg.ENTITY_TYPE_PERSON
                       then com_ui_person_pkg.get_person_name (c.object_id, l_lang)
                       when com_api_const_pkg.ENTITY_TYPE_COMPANY
                       then get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
                   end as customer_name
                 , l_address_str as customer_address
              from prd_customer_vw c
             where c.id = l_customer_id
               and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
           ) t;

    -- Create details: Payment
    begin
        select xmlelement("payments",
                   xmlagg(
                       xmlelement("payment"
                         , xmlelement("account_number", aa.account_number)
                         , xmlelement("posting_date", to_char(cp.posting_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("payment_amount", format_amount(cp.amount, cp.currency))
                         , xmlelement("payment_currency", cp.currency)
                         , xmlelement("payment_currency_expo", cc.exponent)
                         , xmlelement("transaction_desc", com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang))
                       )
                   )
               )
          into l_detail_1
          from crd_invoice_payment cip
             , crd_payment cp
             , acc_account aa
             , opr_operation oo
             , com_currency  cc
         where cip.invoice_id = l_invoice_id
           and cip.pay_id     = cp.id
           and cip.split_hash = l_split_hash
           and cp.split_hash  = l_split_hash
           and cp.account_id  = aa.id
           and cp.oper_id     = oo.id
           and cp.currency    = cc.code
         order by cp.posting_date;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Payment has not found '
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
    end;
    -- Create details: Transaction
    -- Need to code DPP convert credit later
    begin
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("card_num", td.card_number)
                         , xmlelement("oper_date", to_char(td.oper_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("posting_date", to_char(td.posting_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("oper_amount", format_amount(td.oper_amount, td.oper_currency))
                         , xmlelement("oper_currency", td.oper_currency_name)
                         , xmlelement("oper_currency_expo", td.oper_currency_expo)
                         , xmlelement("posting_amount", format_amount(td.transaction_amount, l_currency))
                         , xmlelement("posting_currency", nvl(td.currency_name, l_currency))
                         , xmlelement("posting_currency_expo", td.currency_expo)
                         , xmlelement("transaction_desc",
                               td.oper_type_name
                            || nvl2(td.merchant_name || td.merchant_country, ' / ', null)
                            || nvl2(td.merchant_name, td.merchant_name, null)
                            || case when td.merchant_country is not null and td.merchant_name is not null
                                    then ' - '
                                    else null
                               end
                            || nvl2(td.merchant_country, com_api_country_pkg.get_country_name(
                                                             i_code => td.merchant_country
                                                           , i_raise_error => com_api_const_pkg.FALSE
                                                         ), null)
                           )
                       )
                   order by td.card_number asc
                          , td.posting_date asc
                   )
               )
          into l_detail_2
          from (select t.oper_id as oper_id
                     , t.oper_date as oper_date
                     , nvl(t.card_id, l_main_card_id) as card_id
                     , t.oper_type_name as oper_type_name
                     , t.posting_date as posting_date
                     , trim(t.merchant_name) as merchant_name
                     , trim(t.merchant_country) as merchant_country
                     , t.oper_currency as oper_currency
                     , cc2.name as oper_currency_name
                     , cc2.exponent as oper_currency_expo
                     , t.oper_amount as oper_amount
                     , t.transaction_amount as transaction_amount
                     , cc1.name as currency_name
                     , cc1.exponent as currency_expo
                     , nvl(
                            iss_api_token_pkg.decode_card_number(
                                i_card_number => icn.card_number
                              , i_mask_error  => com_api_type_pkg.TRUE
                            )
                          , l_main_card_number
                          ) as card_number
                  from (select oo.id as oper_id
                             , oo.oper_date
                             , d.card_id
                             , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                                    then com_api_dictionary_pkg.get_article_text(oo.oper_reason, l_lang)
                                    when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                                    then 'DPP'
                                    else case when d.fee_amount > 0
                                              then decode(l_lang, 'LANGENG', 'Fee for ', 'Phí cho') || lower(replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', ''))
                                              else replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
                                         end
                               end as oper_type_name
                             , d.posting_date
                             , oo.merchant_name
                             , oo.merchant_country
                             , case when d.fee_amount > 0
                                    then d.currency
                                    else oo.oper_currency
                               end as oper_currency
                             , case when d.fee_amount > 0
                                    then d.fee_amount
                                    else oo.oper_amount
                               end as oper_amount
                             , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                                    then d.fee_amount
                                    else case when d.fee_amount > 0
                                              then d.fee_amount
                                              else d.transaction_amount
                                         end
                               end as transaction_amount
                             , d.currency
                          from (select cd.account_id
                                     , cd.card_id
                                     , cd.oper_id
                                     , cd.oper_type
                                     , cd.id as debt_id
                                     , cd.currency
                                     , sum(cd.transaction_amount) as transaction_amount
                                     , sum(cd.fee_amount) as fee_amount
                                     , min(cd.posting_date) as posting_date
                                  from (select distinct debt_id
                                          from crd_invoice_debt_vw
                                         where invoice_id = l_invoice_id
                                           and split_hash = l_split_hash
                                           --and is_new = com_api_type_pkg.TRUE
                                       ) cid -- debts included into invoice
                                     , (select d.id
                                             , d.account_id
                                             , d.card_id
                                             , d.service_id
                                             , d.oper_id
                                             , d.oper_type
                                             , d.currency
                                             , d.posting_date
                                             , case when d.macros_type_id in (1007, 1008, 1009, 1010, 7001, 7002, 7011, 8027, 8028)
                                                    then 0
                                                    when d.macros_type_id in (1003, 1006, 1022, 1024)
                                                    then -d.amount
                                                    else d.amount
                                               end as transaction_amount
                                             , case when d.macros_type_id in (1007, 1009, 7001, 7002)
                                                    then d.amount
                                                    when d.macros_type_id in (1008, 1010)
                                                    then -d.amount
                                                    else 0
                                               end as fee_amount
                                          from crd_debt d
                                         where d.status in (
                                                             crd_api_const_pkg.DEBT_STATUS_PAID
                                                           , crd_api_const_pkg.DEBT_STATUS_ACTIVE
                                                           )
                                       ) cd -- amounts from debts
                                 where cd.id = cid.debt_id
                                 group by
                                       cd.account_id
                                     , cd.card_id
                                     , cd.oper_id
                                     , cd.id
                                     , cd.oper_type
                                     , cd.currency
                               ) d
                             , opr_operation oo
                         where d.oper_id = oo.id(+)
                      ) t
                    , iss_card_number icn
                    , com_currency cc1
                    , com_currency cc2
                where t.card_id = icn.card_id(+)
                  and t.currency = cc1.code(+)
                  and t.oper_currency = cc2.code(+)
                ) td;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operation has not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
    end;

    -- Create details: Loyalty
    begin
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
            end if;
        end loop;

        select xmlelement("loyalty",
                   xmlforest(nvl(loyalty_earned, 0) as "point_earned"
                            ,nvl(loyalty_spent, 0)  as "point_spent"
                            ,nvl(loyalty_outgoing, 0) as "total_point"
                            )
               )
               into l_detail_3
          from (select sum(decode(a.balance_impact, 1, a.amount, null)) as loyalty_earned
                     , sum(decode(a.balance_impact, -1, a.amount, null)) as loyalty_spent
                     , min(balance) keep (dense_rank last order by posting_order) as loyalty_outgoing
                  from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                     , acc_entry a
                 where a.account_id   = b.column_value
                   and a.split_hash   = l_split_hash
                   and a.posting_date between l_start_date and l_invoice_date
                );
        exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Loyalty entry has not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
    end;

    select xmlelement (
               "report"
             , l_header
             , l_detail_1
             , l_detail_2
             , l_detail_3
           ) r
      into
           l_result
      from dual;

    o_xml := l_result.getclobval();

end run_report;

end cst_pvc_api_statement_pkg;
/
