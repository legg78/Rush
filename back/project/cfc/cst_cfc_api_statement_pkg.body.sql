create or replace package body cst_cfc_api_statement_pkg is

STATEMENT_PATH_PART         constant com_api_type_pkg.t_name := 'Credit_Statement';
STATEMENT_NUMBER_FORMAT     constant com_api_type_pkg.t_name := 'FM999,999,999,999';
STATEMENT_DATE_FORMAT       constant com_api_type_pkg.t_name := cst_cfc_api_const_pkg.CST_PRT_DATE_FORMAT;
function get_bann_filename(
    i_mess_id               in  com_api_type_pkg.t_text
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
                     and c.text         = i_mess_id
                     and c.object_id    = b.id
                 );

    return l_filename;
end get_bann_filename;

function get_bann_mess(
    i_mess_id               in  com_api_type_pkg.t_text
  , i_lang                  in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text
is
    l_mess                      com_api_type_pkg.t_text;
begin
    select com_api_i18n_pkg.get_text('RPT_BANNER', 'DESCRIPTION', c.object_id, '')
      into l_mess
      from com_i18n c
     where c.table_name     = 'RPT_BANNER'
       and c.column_name    = 'LABEL'
       and c.text           = i_mess_id
       and exists (
                   select 1
                     from rpt_banner b
                    where b.id      = c.object_id
                      and b.status  = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE --'BNST0100'
                  );

    return l_mess;
end get_bann_mess;

function get_address_string(
    i_customer_id           in  com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_text
is
    l_address_string com_api_type_pkg.t_text;
begin
    select substr(
                   nvl2(d.apartment, d.apartment || ' ', '')
                || nvl2(d.house, d.house || ' ', '')
                || nvl2(d.street, d.street || ' ', '')
                || nvl2(d.city, d.city || ' ', '')
                || nvl2(d.region, d.region || ' ', '')
                 , 1
                 , 4000
                 )
      into l_address_string
      from prd_customer_vw c
         , com_address_object_vw ob1
         , com_address d
     where c.id = i_customer_id
       and c.entity_type        in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
       and ob1.entity_type(+)   = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and ob1.object_id(+)     = c.id
       and d.id(+)              = ob1.address_id
       and rownum = 1;

    return trim(l_address_string);
exception
    when no_data_found then
        return null;
end get_address_string;

function get_phone_number(
    i_customer_id           in  com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name
is
    l_mobile_phone              com_api_type_pkg.t_name;
    l_landline_phone            com_api_type_pkg.t_name;
begin

    select com_api_contact_pkg.get_contact_string(
               i_contact_id     => contact_id
             , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE --'CMNM0001'
             , i_start_date     => get_sysdate)
         , com_api_contact_pkg.get_contact_string(
               i_contact_id     => contact_id
             , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_PHONE --'CMNM0012'
             , i_start_date     => get_sysdate)
      into l_mobile_phone
         , l_landline_phone
      from com_contact_object
     where object_id        = i_customer_id
       and entity_type      = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
       and contact_type     = com_api_const_pkg.CONTACT_TYPE_PRIMARY --'CNTTPRMC'
    ;
    return nvl(l_mobile_phone, l_landline_phone);
exception
    when no_data_found then
        return null;
end get_phone_number;

function format_amount(
    i_amount                in  com_api_type_pkg.t_money
  , i_curr_code             in  com_api_type_pkg.t_curr_code
  , i_mask_curr_code        in  com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator         in  com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error            in  com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_format_base           com_api_type_pkg.t_name;
    l_result                com_api_type_pkg.t_name;
begin
    if i_use_separator = com_api_type_pkg.TRUE then
        l_format_base := STATEMENT_NUMBER_FORMAT;
    else
        l_format_base := com_api_const_pkg.XML_NUMBER_FORMAT;
    end if;

    if i_amount is not null then -- return null if i_amount is null
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
    l_detail                    xmltype;
    l_result                    xmltype;
    l_agent_number              com_api_type_pkg.t_name;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_account_id                com_api_type_pkg.t_account_id;
    l_account_number            com_api_type_pkg.t_account_number;
    l_main_card_id              com_api_type_pkg.t_medium_id;
    l_main_card_number          com_api_type_pkg.t_card_number;
    l_invoice_id                com_api_type_pkg.t_medium_id;
    l_invoice_date              date;
    l_start_date                date;
    l_due_date_1                date;
    l_due_date_2                date;
    l_period_start_date         date; -- Start of the billing period shown in statement
    l_period_end_date           date; -- End of the billing period shown in statement
    l_mad_1                     com_api_type_pkg.t_money;
    l_mad_2                     com_api_type_pkg.t_money;
    l_tad                       com_api_type_pkg.t_money;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_currency                  com_api_type_pkg.t_dict_value;
    l_currency_name             com_api_type_pkg.t_dict_value;
    l_currency_exp              com_api_type_pkg.t_tiny_id;
    l_exceed_limit              com_api_type_pkg.t_amount_rec;
    l_credit_limit              com_api_type_pkg.t_balance_id;
    l_avail_credit_amount       com_api_type_pkg.t_money := 0;
    l_prev_invoice              crd_api_type_pkg.t_invoice_rec;
    l_total_payment             com_api_type_pkg.t_money := 0;
    l_fee_amount                com_api_type_pkg.t_money := 0;
    l_interest_amount           com_api_type_pkg.t_money := 0;
    l_waive_interest_amount     com_api_type_pkg.t_money := 0;
    l_expense_amount            com_api_type_pkg.t_money := 0; -- Expense including fees (value from invoice)
    l_cash_amount               com_api_type_pkg.t_money := 0;
    l_own_funds                 com_api_type_pkg.t_money := 0;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_statement_path            com_api_type_pkg.t_name;
    l_tod                       com_api_type_pkg.t_money;
    l_attachment_name           com_api_type_pkg.t_name;
    l_name_params               com_api_type_pkg.t_param_tab;
    l_subject                   com_api_type_pkg.t_full_desc;
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
             , abs(i.interest_amount) + abs(i.overdue_intr_balance)
             , i.waive_interest_amount
             , a.account_number
             , nvl(i.expense_amount, 0)
             , crd_invoice_pkg.round_up_mad(
                   i_account_id      => a.id
                 , i_mad             => round(nvl(cst_apc_crd_algo_proc_pkg.get_extra_mad(i_invoice_id => i.id), 0))
                 , i_tad             => i.total_amount_due
               ) as mad_1
             , crd_invoice_pkg.round_up_mad(
                   i_account_id      => a.id
                 , i_mad             => i.min_amount_due
                 , i_tad             => i.total_amount_due
               ) as mad_2
             , to_date(
                   com_api_flexible_data_pkg.get_flexible_value(
                       i_field_name  => cst_apc_const_pkg.FLEX_FIELD_EXTRA_DUE_DATE
                     , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                     , i_object_id   => i.id
                   )
                 , com_api_const_pkg.DATE_FORMAT
               ) as due_date_1
             , i.due_date as due_date_2
             , i.total_amount_due
             , i.fee_amount
             , a.split_hash
             , nvl(i.available_balance, 0)
             , nvl(i.own_funds, 0)
             , ag.agent_number
          into l_customer_id
             , l_account_id
             , l_invoice_date
             , l_interest_amount
             , l_waive_interest_amount
             , l_account_number
             , l_expense_amount
             , l_mad_1
             , l_mad_2
             , l_due_date_1
             , l_due_date_2
             , l_tad
             , l_fee_amount
             , l_split_hash
             , l_avail_credit_amount
             , l_own_funds
             , l_agent_number
          from crd_invoice i
             , acc_account a
             , ost_agent ag
         where a.id = i.account_id
           and i.agent_id = ag.id(+)
           and i.id = l_invoice_id;

        trc_log_pkg.debug (
            i_text        => 'Current invoice [#1]: l_interest_amount=[#2]'
                          || ', l_expense_amount=[#3]'
          , i_env_param1  => l_invoice_id
          , i_env_param2  => l_interest_amount
          , i_env_param3  => l_expense_amount
        );
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'INVOICE_NOT_FOUND'
              , i_env_param1  => l_invoice_id
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
              , i_object_id   => l_invoice_id
            );
    end;

    -- Get previous invoice information
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
          into l_prev_invoice
          from crd_invoice_vw i1
             , (
                select a.id
                     , lag(a.id) over (order by a.invoice_date, a.id) lag_id
                  from crd_invoice_vw a
                 where a.account_id = l_account_id
               ) i2
         where i1.id = i2.lag_id
           and i2.id = l_invoice_id;

    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Previous invoice not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
              , i_object_id   => l_invoice_id
            );
    end;

    --Get defined subject
    l_subject := crd_cst_report_pkg.get_subject (
        i_account_id  => l_account_id
      , i_eff_date    => sysdate
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

    -- Calculate start date
    if l_prev_invoice.id is null then
        begin
            select o.start_date
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and o.object_id = l_account_id
               and o.split_hash = l_split_hash
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
        l_start_date := l_prev_invoice.invoice_date;
    end if;

    trc_log_pkg.debug (
        i_text        => 'Calculated start date: [#1]'
      , i_env_param1  => to_char(l_start_date, STATEMENT_DATE_FORMAT )
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
      , i_object_id   => l_invoice_id
    );

    l_period_start_date := l_start_date;
    l_period_end_date   := l_invoice_date - com_api_const_pkg.ONE_SECOND;

    -- Get account currency information
    select aa.currency
         , cc.name
         , cc.exponent
      into l_currency
         , l_currency_name
         , l_currency_exp
      from acc_account aa
         , com_currency cc
     where aa.currency      = cc.code(+)
       and aa.id            = l_account_id
       and aa.split_hash    = l_split_hash;

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

    -- Get total oustanding amoun
    l_tod := crd_invoice_pkg.calculate_total_outstanding(i_account_id => l_account_id, i_payoff_date => sysdate);

    -- Get main card (Primary or other existing)
    l_main_card_id :=
        cst_cfc_com_pkg.get_main_card_id (
            i_account_id    => l_account_id
          , i_split_hash    => l_split_hash
        );

    select iss_api_token_pkg.decode_card_number(
               i_card_number => icn.card_number
             , i_mask_error  => com_api_type_pkg.TRUE
           ) as card_number
      into l_main_card_number
      from iss_card_number icn
     where icn.card_id = l_main_card_id;

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

    -- Total cash amount:
    select nvl(sum(d.amount), 0)
      into l_cash_amount
      from crd_debt d
     where d.id in (
                    select debt_id
                      from crd_invoice_debt_vw
                     where invoice_id = l_invoice_id
                       and is_new = com_api_type_pkg.TRUE
                   )
       and d.oper_type in (
                            opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
                          , opr_api_const_pkg.OPERATION_TYPE_POS_CASH -- 'OPTP0012'
                          )
       and d.macros_type_id = cst_cfc_api_const_pkg.MACROS_DEBIT_OPR;

    -- Create header:
    select xmlconcat(
               xmlelement("customer_number", t.customer_number)
             , xmlelement("customer_name", t.customer_name)
             , xmlelement("post_phone", t.customer_phone)
             , xmlelement("post_addr", t.customer_address)
             , xmlelement("account_number", l_account_number)
             , xmlelement("account_currency", l_currency_name)
             , xmlelement("main_card_number", substr(l_main_card_number, 1, 4) || '***' || substr(l_main_card_number, -4))
             , xmlelement("credit_limit", format_amount(nvl(l_credit_limit, 0), l_currency))
             , xmlelement("available_credit_amount", format_amount(nvl(l_avail_credit_amount, 0), l_currency))
             , xmlelement("invoice_date", to_char((l_invoice_date), STATEMENT_DATE_FORMAT ))
             , xmlelement("start_date", to_char(l_period_start_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("end_date", to_char(l_period_end_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("opening_balance", format_amount(nvl(l_prev_invoice.total_amount_due, 0) - nvl(l_prev_invoice.own_funds, 0), l_currency))
             , xmlelement("expense_amount", format_amount(nvl(l_cash_amount, 0), l_currency))
             , xmlelement("interest_amount", format_amount(nvl(l_interest_amount + l_fee_amount + ((l_expense_amount - l_cash_amount)), 0), l_currency))
             , xmlelement("total_payment", format_amount(nvl(l_total_payment, 0), l_currency))
             , xmlelement("min_amount_due", format_amount(nvl(l_mad_1, 0), l_currency))
             , xmlelement("due_date", to_char(l_due_date_1, STATEMENT_DATE_FORMAT ))
             , xmlelement("min_amount_due_2", format_amount(nvl(l_mad_2, 0), l_currency))
             , xmlelement("due_date_2", to_char(l_due_date_2, STATEMENT_DATE_FORMAT ))
             , xmlelement("total_amount_due", format_amount(nvl(l_tad, 0) - l_own_funds, l_currency))
             , xmlelement("hdr_logo_path", t.hdr_logo_path)
             , xmlelement("promo_mess", t.promo_mess)
             , xmlelement("imp_mess", t.imp_mess)
             , xmlelement("attachments"
                 , xmlelement("attachment"
                     , xmlelement("attachment_path", l_statement_path)
                     , xmlelement("attachment_name", l_attachment_name)
                   )
               )
            , xmlelement("total_outstanding", format_amount(nvl(l_tod, 0), l_currency))
           )
      into l_header
      from (
            select c.customer_number
                 , c.id as customer_id
                 , get_bann_filename('STMT_HDR_LOGO', l_lang) hdr_logo_path
                 , get_bann_mess('STMT_PROMO_MESS', l_lang) promo_mess
                 , get_bann_mess('STMT_IMP_MESS', l_lang) imp_mess
                 , case c.entity_type
                       when com_api_const_pkg.ENTITY_TYPE_PERSON
                       then com_ui_person_pkg.get_person_name (c.object_id, l_lang)
                       when com_api_const_pkg.ENTITY_TYPE_COMPANY
                       then get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
                   end as customer_name
                 , get_address_string(
                       i_customer_id => c.id
                   ) as customer_address
                 , get_phone_number(
                       i_customer_id => c.id
                   ) as customer_phone
              from prd_customer_vw c
             where c.id = l_customer_id
               and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
           ) t;

    -- Create details:
    begin
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("oper_part_num", td.oper_part_num)
                         , xmlelement("oper_id", td.oper_id)
                         , xmlelement("card_num", substr(td.card_number, -4))
                         , xmlelement("oper_date", to_char(td.oper_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("posting_date", to_char(td.posting_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("oper_amount", format_amount(td.oper_amount, td.oper_currency))
                         , xmlelement("oper_currency", td.oper_currency_name)
                         , xmlelement("oper_currency_expo", td.oper_currency_expo)
                         , xmlelement("posting_currency", nvl(td.currency_name, l_currency))
                         , xmlelement("posting_currency_expo", td.currency_expo)
                         , xmlelement("posting_amount", format_amount(td.transaction_amount, l_currency))
                         , xmlelement("posting_amount_number", td.transaction_amount)
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
                         , xmlelement("expo", nvl(td.currency_expo, l_currency_exp))
                      )
                      order by td.oper_part_num asc
                             , td.card_number asc
                             , td.oper_id asc
                   )
               )
          into l_detail
          from (select l_account_number as account_number
                     , t.oper_id as oper_id
                     , t.oper_part_num as oper_part_num
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
                             , 1 as oper_part_num
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
                                           and is_new = com_api_type_pkg.TRUE
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
                         union all
                        select oo.id as oper_id
                             , 2 as oper_part_num
                             , oo.oper_date
                             , l_main_card_id as card_id
                             , replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '') as oper_type_name
                             , cp.posting_date
                             , oo.merchant_name
                             , oo.merchant_country
                             , oo.oper_currency
                             , -oo.oper_amount as oper_amount
                             , -nvl(cp.amount, 0) as account_amount
                             , cp.currency as account_currency
                          from crd_invoice_payment cip
                             , crd_payment cp
                             , opr_operation oo
                             , opr_participant iss
                         where cip.invoice_id = l_invoice_id
                           and cp.id = cip.pay_id
                           and cip.split_hash = l_split_hash
                           and cp.split_hash = l_split_hash
                           and cip.is_new = com_api_type_pkg.TRUE
                           and cp.oper_id = oo.id
                           and iss.oper_id(+) = oo.id
                           and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                      ) t
                    , iss_card_number icn
                    , com_currency cc1
                    , com_currency cc2
                where t.card_id = icn.card_id(+)
                  and t.currency = cc1.code(+)
                  and t.oper_currency = cc2.code(+)
                union all
               select l_account_number as account_number
                    , com_api_id_pkg.get_till_id(l_period_end_date) as oper_id
                    , 3 as oper_part_num
                    , l_period_end_date as oper_date
                    , l_main_card_id as card_id
                    , com_api_label_pkg.get_label_text(cst_cfc_api_const_pkg.WAIVE_INTEREST, l_lang) as oper_type_name
                    , l_period_end_date as posting_date
                    , to_char(null) as merchant_name
                    , to_char(null) as merchant_country
                    , l_currency as oper_currency
                    , l_currency_name as oper_currency_name
                    , l_currency_exp as oper_currency_expo
                    , l_waive_interest_amount as oper_amount
                    , l_waive_interest_amount as transaction_amount
                    , l_currency_name as currency_name
                    , l_currency_exp as currency_expo
                    , l_main_card_number as card_number
                 from dual
                where l_waive_interest_amount > 0
                ) td;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
    end;

    select xmlconcat(
               xmlelement("subject", l_subject)
             , xmlelement(
                   "report"
                 , l_header
                 , l_detail
               )
           ) r
      into
           l_result
      from dual;

    o_xml := l_result.getclobval();

end run_report;

procedure run_demand_report(
    o_xml                   out clob
  , i_inst_id               in  com_api_type_pkg.t_inst_id          default null
  , i_lang                  in  com_api_type_pkg.t_dict_value       default null
  , i_account_number        in  com_api_type_pkg.t_account_number
  , i_start_date            in  date                                default null
  , i_end_date              in  date                                default null
  , i_attachment_format_id  in  com_api_type_pkg.t_tiny_id          default null
) is
    l_header                    xmltype;
    l_detail                    xmltype;
    l_result                    xmltype;
    l_account_id                com_api_type_pkg.t_account_id;
    l_agent_number              com_api_type_pkg.t_name;
    l_account_number            com_api_type_pkg.t_account_number;
    l_main_card_id              com_api_type_pkg.t_medium_id;
    l_main_card_number          com_api_type_pkg.t_card_number;
    l_invoice_id                com_api_type_pkg.t_medium_id;
    l_invoice_date              date;
    l_period_start_date         date; -- Start of the billing period shown in statement
    l_period_end_date           date; -- End of the billing period shown in statement
    l_lang                      com_api_type_pkg.t_dict_value;
    l_currency                  com_api_type_pkg.t_dict_value;
    l_currency_name             com_api_type_pkg.t_dict_value;
    l_currency_exp              com_api_type_pkg.t_tiny_id;
    l_exceed_limit              com_api_type_pkg.t_amount_rec;
    l_credit_limit              com_api_type_pkg.t_balance_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_prev_invoice              crd_api_type_pkg.t_invoice_rec;
    l_interest_amount           com_api_type_pkg.t_money := 0;
    l_waive_interest_amount     com_api_type_pkg.t_money := 0;
    l_fee_amount                com_api_type_pkg.t_money := 0;
    l_daily_mad                 com_api_type_pkg.t_money := 0;
    l_total_outstanding         com_api_type_pkg.t_money := 0;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_statement_path            com_api_type_pkg.t_name;

    l_account_rec               acc_api_type_pkg.t_account_rec;
    l_attachment_name           com_api_type_pkg.t_name;
    l_name_params               com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text        => 'Demand statement report, language [#1], account number [#2], start date [#3], end date [#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_account_number
      , i_env_param3  => i_start_date
      , i_env_param4  => i_end_date
    );

    l_lang := coalesce(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, cst_cfc_api_const_pkg.DEFAULT_INST);
    l_account_number := i_account_number;
    l_account_rec := acc_api_account_pkg.get_account(
                        i_account_id        => null
                      , i_account_number    => i_account_number
                      , i_inst_id           => l_inst_id
                      , i_mask_error        => com_api_const_pkg.FALSE
                    );
    l_account_id := l_account_rec.account_id;


    l_split_hash := com_api_hash_pkg.get_split_hash(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, l_account_id);

    if coalesce(i_start_date, i_end_date) is not null then
        l_period_start_date := coalesce(i_start_date, add_months(i_end_date, -1));
        l_period_end_date   := coalesce(i_end_date, add_months(i_start_date, 1));
        select max(id)
          into l_invoice_id
          from crd_invoice
         where invoice_date between l_period_start_date and l_period_end_date
           and account_id   = l_account_id;
    end if;

    if l_invoice_id is null then
        l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id => l_account_id
                          , i_split_hash => l_split_hash
                        );
    end if;

    l_daily_mad := round(nvl(cst_apc_crd_algo_proc_pkg.get_extra_mad(i_invoice_id => l_invoice_id), 0));
    l_daily_mad :=
        crd_invoice_pkg.round_up_mad(
            i_account_id    => l_account_id
          , i_mad           => l_daily_mad
          , i_tad           => nvl(
                                   crd_invoice_pkg.get_invoice(
                                       i_invoice_id  => l_invoice_id
                                     , i_mask_error  => com_api_const_pkg.TRUE
                                   ).total_amount_due
                                 , l_daily_mad
                               )
        );

    l_prev_invoice := null;
    -- Preliminary checks
    if l_invoice_id is null then
        com_api_error_pkg.raise_error(
            i_error  => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- Get previous invoice information
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
          into l_prev_invoice
          from crd_invoice_vw i1
             , (
                select a.id
                     , lag(a.id) over (order by a.invoice_date, a.id) lag_id
                  from crd_invoice_vw a
                 where a.account_id = l_account_id
               ) i2
         where i1.id = i2.lag_id
           and i2.id = l_invoice_id;

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text        => 'Previous invoice not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
              , i_object_id   => l_invoice_id
            );
    end;

    -- Get statement path:
    begin
        select directory_path
          into l_statement_path
          from prc_directory
         where lower(directory_path) like '%' || lower(STATEMENT_PATH_PART) || '%';
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'DIRECTORY_NOT_FOUND'
              , i_env_param1  => STATEMENT_PATH_PART
            );
    end;
    -- Get attachmennt file name
    if i_attachment_format_id is null then
        l_agent_number := ost_ui_agent_pkg.get_agent_number(i_agent_id => l_account_rec.agent_id);
        l_attachment_name := trim(l_agent_number) || '_' || to_char(i_account_number) || '.pdf';
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

    -- Calculate start date
    if l_period_start_date is null then
        if l_prev_invoice.id is null then
            begin
                select o.start_date
                  into l_period_start_date
                  from prd_service_object o
                     , prd_service s
                 where o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and o.object_id = l_account_id
                   and o.split_hash = l_split_hash
                   and s.id = o.service_id
                   and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
                      , i_env_param1  => l_account_id
                      , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                    );
            end;
        else
            l_period_start_date := l_prev_invoice.invoice_date;
        end if;

        l_period_end_date   := l_invoice_date - com_api_const_pkg.ONE_SECOND;
    end if;

    trc_log_pkg.debug(
        i_text        => 'Statement start date: [#1] - end date: [#2]'
      , i_env_param1  => to_char(l_period_start_date, STATEMENT_DATE_FORMAT )
      , i_env_param2  => to_char(l_period_end_date, STATEMENT_DATE_FORMAT )
    );
    -- Get total interest in input period
    l_interest_amount := cst_cfc_com_pkg.get_charged_interest(
                             i_account_id   => l_account_id
                           , i_start_date   => l_period_start_date
                           , i_end_date     => l_period_end_date);
    -- Get total waived interest in input period
    l_waive_interest_amount := cst_cfc_com_pkg.get_total_waived_interest(
                                   i_account_id     => l_account_id
                                 , i_split_hash     => l_split_hash
                                 , i_start_date     => l_period_start_date
                                 , i_end_date       => l_period_end_date
                               );
    -- Get total fee in input period
    l_fee_amount := cst_cfc_com_pkg.get_tran_fee(
                        i_account_id        => l_account_id
                      , i_start_date        => l_period_start_date
                      , i_end_date          => l_period_end_date);

    trc_log_pkg.debug(
        i_text        => 'Total interest [#1] - total fee [#2]'
      , i_env_param1  => l_interest_amount
      , i_env_param2  => l_fee_amount
    );
    -- Get account currency information
    select aa.currency
         , cc.name
         , cc.exponent
      into l_currency
         , l_currency_name
         , l_currency_exp
      from acc_account aa
         , com_currency cc
     where aa.currency      = cc.code(+)
       and aa.id            = l_account_id
       and aa.split_hash    = l_split_hash;

    -- Get main card (Primary or other existing)
    l_main_card_id :=
        cst_cfc_com_pkg.get_main_card_id(
            i_account_id    => l_account_id
          , i_split_hash    => l_split_hash
        );

    select iss_api_token_pkg.decode_card_number(
               i_card_number => icn.card_number
             , i_mask_error  => com_api_type_pkg.TRUE
           ) as card_number
      into l_main_card_number
      from iss_card_number icn
     where icn.card_id = l_main_card_id;

    -- Get credit limit and cash limit:
    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount(
            i_account_id    => l_account_id
          , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_date          => l_invoice_date
          , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error    => com_api_const_pkg.TRUE
        );
    l_credit_limit := nvl(l_exceed_limit.amount, 0);

    -- Get total outstanding
    select nvl(sum(nvl(b.amount, 0)), 0)
      into l_total_outstanding
      from (select d.id debt_id
              from crd_debt d
             where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_id
               and d.split_hash = l_split_hash
               and is_new       = com_api_type_pkg.TRUE
               and posting_date between l_period_start_date and l_period_end_date
             union
            select d.id debt_id
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = l_account_id
               and d.split_hash = l_split_hash
               and is_new       = com_api_type_pkg.TRUE
               and posting_date between l_period_start_date and l_period_end_date
         ) d
         , crd_debt_balance b
     where b.debt_id    = d.debt_id
       and b.split_hash = l_split_hash
       and b.balance_type not in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER, crd_api_const_pkg.BALANCE_TYPE_LENDING);

    -- Create header:
    select xmlconcat(
               xmlelement("customer_number", t.customer_number)
             , xmlelement("customer_name", t.customer_name)
             , xmlelement("post_phone", t.customer_phone)
             , xmlelement("post_addr", t.customer_address)
             , xmlelement("account_number", l_account_number)
             , xmlelement("account_currency", l_currency_name)
             , xmlelement("main_card_number", substr(l_main_card_number, 1, 4) || '***' || substr(l_main_card_number, -4))
             , xmlelement("credit_limit", format_amount(nvl(l_credit_limit, 0), l_currency))
             , xmlelement("start_date", to_char(l_period_start_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("end_date", to_char(l_period_end_date, STATEMENT_DATE_FORMAT ))
             , xmlelement("fee_interest_amount", format_amount(nvl(l_interest_amount + l_fee_amount, 0), l_currency))
             , xmlelement("outstanding_balance", format_amount(nvl(l_total_outstanding, 0), l_currency))
             , xmlelement("daily_mad", format_amount(nvl(l_daily_mad, 0), l_currency))
             , xmlelement("hdr_logo_path", t.hdr_logo_path)
             , xmlelement("promo_mess", t.promo_mess)
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
          select c.customer_number
               , c.id as customer_id
               , get_bann_filename('STMT_HDR_LOGO', l_lang) hdr_logo_path
               , get_bann_mess('STMT_PROMO_MESS', l_lang) promo_mess
               , get_bann_mess('STMT_IMP_MESS', l_lang) imp_mess
               , case c.entity_type
                     when com_api_const_pkg.ENTITY_TYPE_PERSON
                     then com_ui_person_pkg.get_person_name (c.object_id, l_lang)
                     when com_api_const_pkg.ENTITY_TYPE_COMPANY
                     then get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
                 end as customer_name
               , get_address_string(
                     i_customer_id => c.id
                 ) as customer_address
              , get_phone_number(
                     i_customer_id => c.id
                 ) as customer_phone
            from prd_customer_vw c
               , acc_account     a
           where a.id = l_account_id
             and c.id = a.customer_id
             and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
         ) t;

    -- Create details:
    begin
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("oper_part_num", td.oper_part_num)
                         , xmlelement("oper_id", td.oper_id)
                         , xmlelement("card_num", substr(td.card_number, -4))
                         , xmlelement("oper_date", to_char(td.oper_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("posting_date", to_char(td.posting_date, STATEMENT_DATE_FORMAT ))
                         , xmlelement("oper_amount", format_amount(td.oper_amount, td.oper_currency))
                         , xmlelement("oper_currency", td.oper_currency_name)
                         , xmlelement("oper_currency_expo", td.oper_currency_expo)
                         , xmlelement("posting_currency", nvl(td.currency_name, l_currency))
                         , xmlelement("posting_currency_expo", td.currency_expo)
                         , xmlelement("posting_amount", format_amount(td.transaction_amount, l_currency))
                         , xmlelement("posting_amount_number", td.transaction_amount)
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
                         , xmlelement("expo", nvl(td.currency_expo, l_currency_exp))
                      )
                      order by td.oper_part_num asc
                             , td.card_number asc
                             , td.oper_id asc
                   )
               )
          into l_detail
          from (select l_account_number as account_number
                     , t.oper_id as oper_id
                     , t.oper_part_num as oper_part_num
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
                             , 1 as oper_part_num
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
                                     , cd.currency
                                     , sum(cd.transaction_amount) as transaction_amount
                                     , sum(cd.fee_amount) as fee_amount
                                     , min(cd.posting_date) as posting_date
                                  from (select d.id
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
                                         where posting_date between l_period_start_date and l_period_end_date
                                           and account_id   = l_account_id
                                           and d.status     in (crd_api_const_pkg.DEBT_STATUS_PAID, crd_api_const_pkg.DEBT_STATUS_ACTIVE
                                                               )
                                       ) cd -- amounts from debts
                                 group by
                                       cd.account_id
                                     , cd.card_id
                                     , cd.oper_id
                                     , cd.oper_type
                                     , cd.currency
                               ) d
                             , opr_operation oo
                         where d.oper_id = oo.id(+)
                         union all
                        select oo.id as oper_id
                             , 2 as oper_part_num
                             , oo.oper_date
                             , l_main_card_id as card_id
                             , replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '') as oper_type_name
                             , cp.posting_date
                             , oo.merchant_name
                             , oo.merchant_country
                             , oo.oper_currency
                             , -oo.oper_amount as oper_amount
                             , -nvl(cp.amount, 0) as account_amount
                             , cp.currency as account_currency
                          from crd_invoice_payment cip
                             , crd_payment cp
                             , opr_operation oo
                             , opr_participant iss
                         where cp.posting_date  between l_period_start_date and l_period_end_date
                           and cp.account_id    = l_account_id
                           and cp.id            = cip.pay_id
                           and cip.split_hash   = l_split_hash
                           and cp.split_hash    = l_split_hash
                           and cip.is_new       = com_api_type_pkg.TRUE
                           and cp.oper_id       = oo.id
                           and iss.oper_id(+)   = oo.id
                           and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                      ) t
                    , iss_card_number icn
                    , com_currency cc1
                    , com_currency cc2
                where t.card_id         = icn.card_id(+)
                  and t.currency        = cc1.code(+)
                  and t.oper_currency   = cc2.code(+)
                union all
               select l_account_number as account_number
                    , com_api_id_pkg.get_till_id(l_period_end_date) as oper_id
                    , 3 as oper_part_num
                    , l_period_end_date as oper_date
                    , l_main_card_id as card_id
                    , com_api_label_pkg.get_label_text(cst_cfc_api_const_pkg.WAIVE_INTEREST, l_lang) as oper_type_name
                    , l_period_end_date as posting_date
                    , to_char(null) as merchant_name
                    , to_char(null) as merchant_country
                    , l_currency as oper_currency
                    , l_currency_name as oper_currency_name
                    , l_currency_exp as oper_currency_expo
                    , nvl(l_waive_interest_amount, 0) as oper_amount
                    , nvl(l_waive_interest_amount, 0) as transaction_amount
                    , l_currency_name as currency_name
                    , l_currency_exp as currency_expo
                    , l_main_card_number as card_number
                 from dual
                where l_waive_interest_amount > 0
                ) td;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
    end;

    select xmlelement (
               "report"
             , l_header
             , l_detail
           ) r
      into
           l_result
      from dual;

    o_xml := l_result.getclobval();

end run_demand_report;

end cst_cfc_api_statement_pkg;
/
