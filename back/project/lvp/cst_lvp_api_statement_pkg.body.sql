create or replace package body cst_lvp_api_statement_pkg is

STATEMENT_PATH_PART   constant com_api_type_pkg.t_name := 'Credit_Statement';

function get_bann_filename (
    i_mess_id    in  com_api_type_pkg.t_text
  , i_lang       in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
    l_filename   com_api_type_pkg.t_name;
begin
    select filename
      into l_filename
      from rpt_banner b
     where exists (
                    select 1
                      from com_i18n c
                     where c.table_name = 'RPT_BANNER'
                       and c.column_name = 'LABEL'
                       and c.text = i_mess_id
                       and c.object_id = b.id
                  );

    return l_filename;
end get_bann_filename;

function get_bann_mess (
    i_mess_id    in  com_api_type_pkg.t_text
  , i_lang       in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text is
    l_mess com_api_type_pkg.t_text;
begin
    select com_api_i18n_pkg.get_text('RPT_BANNER', 'DESCRIPTION', c.object_id, '')
      into l_mess
      from com_i18n c
     where c.table_name = 'RPT_BANNER'
       and c.column_name = 'LABEL'
       and c.text = i_mess_id
       and exists (
                   select 1
                     from rpt_banner b
                    where b.id = c.object_id
                      and b.status = 'BNST0100'
                  );

    return l_mess;
end get_bann_mess;

function get_address_string (
    i_customer_id in com_api_type_pkg.t_medium_id
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
       and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
       and ob1.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and ob1.object_id(+) = c.id
       and d.id(+) = ob1.address_id
       and rownum <= 1;

    return trim(l_address_string);

exception
    when no_data_found then
        return null;
end get_address_string;

function get_lty_points_name (
    i_card_id  in com_api_type_pkg.t_medium_id
  , i_date     in date default get_sysdate
) return com_api_type_pkg.t_text
is
begin
    return
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id   => i_card_id
          , i_attr_name   => 'LTY_POINT_NAME'
          , i_eff_date    => i_date
        );

exception
    when no_data_found then
        return null;
end get_lty_points_name;

function format_amount(
    i_amount         in com_api_type_pkg.t_money
  , i_curr_code      in com_api_type_pkg.t_curr_code
  , i_mask_curr_code in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator  in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error     in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_format_base com_api_type_pkg.t_name;
    l_result      com_api_type_pkg.t_name;
begin
    if i_use_separator = com_api_type_pkg.TRUE then
        l_format_base := 'FM999,999,999,999,990';
    else
        l_format_base := 'FM999999999999990';
    end if;

    if i_amount is not null then -- return null if i_amount is null
        select to_char(
                        round(i_amount) / power(10, exponent)
                      , l_format_base || case
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

function get_customer_name(
    i_account_id    in  com_api_type_pkg.t_long_id
) return  com_api_type_pkg.t_name
is
    l_customer_name     com_api_type_pkg.t_name;
    l_lang              com_api_type_pkg.t_dict_value := get_user_lang;
begin
    select case c.entity_type
             when com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
             then com_ui_person_pkg.get_person_name (c.object_id, l_lang)
             when com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
             then get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
           end as customer_name
      into l_customer_name
      from prd_customer c
         , acc_account a
     where c.id = a.customer_id
       and a.id = i_account_id;
    return l_customer_name;
exception
    when no_data_found then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_customer_name(i_account_id => [' || i_account_id || ']) No data found.');
        return null;        
end get_customer_name;

procedure get_cash_limit_value(
    i_account_id  in     com_api_type_pkg.t_account_id
  , i_split_hash  in     com_api_type_pkg.t_tiny_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_date        in     date default get_sysdate
  , o_value          out com_api_type_pkg.t_money
  , o_current_sum    out com_api_type_pkg.t_money
)
is
begin
    select case when l.limit_base is not null and l.limit_rate is not null
                then
                    nvl(fcl_api_limit_pkg.get_limit_border_sum(
                            i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id            => i_account_id
                          , i_limit_type           => crd_api_const_pkg.ACCOUNT_CASH_VALUE_LIMIT_TYPE
                          , i_limit_base           => l.limit_base
                          , i_limit_rate           => l.limit_rate
                          , i_currency             => l.currency
                          , i_inst_id              => i_inst_id
                          , i_product_id           => prd_api_product_pkg.get_product_id(
                                                          i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                        , i_object_id         => i_account_id
                                                        , i_inst_id           => i_inst_id
                                                      )
                          , i_split_hash           => i_split_hash
                          , i_mask_error           => com_api_const_pkg.TRUE
                        ), 0
                    )
                else
                    nvl(l.sum_limit, 0)
           end
         , nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                   i_limit_type  => l.limit_type
                 , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id   => i_account_id
                 , i_limit_id    => l.id
                 , i_split_hash  => i_split_hash
                 , i_mask_error  => com_api_const_pkg.TRUE 
              )
              , 0
           )
      into o_value
         , o_current_sum
      from fcl_limit l
         , (select to_number(limit_id, 'FM000000000000000000.0000') limit_id
                 , row_number() over (partition by account_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                 , level_priority
                                                                                 , start_date desc
                                                                                 , register_timestamp desc) rn
                 , account_id
                 , split_hash
                 , start_date
                 , end_date
              from (
                    select v.attr_value limit_id
                         , 0 level_priority
                         , a.object_type limit_type
                         , v.register_timestamp
                         , v.start_date
                         , v.end_date
                         , v.object_id  account_id
                         , v.split_hash
                      from prd_attribute_value v
                         , prd_attribute a
                     where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                       and a.id           = v.attr_id
                       and i_date between nvl(v.start_date, i_date) and nvl(v.end_date, trunc(i_date)+1)
                    union all
                    select v.attr_value
                         , p.level_priority
                         , a.object_type limit_type
                         , v.register_timestamp
                         , v.start_date
                         , v.end_date
                         , ac.id  account_id
                         , ac.split_hash
                      from (
                            select connect_by_root id product_id
                                 , level level_priority
                                 , id parent_id
                                 , product_type
                                 , case when parent_id is null then 1 else 0 end top_flag
                              from prd_product
                           connect by prior parent_id = id
                           ) p
                         , prd_attribute_value v
                         , prd_attribute a
                         , prd_service_type st
                         , prd_service s
                         , prd_product_service ps
                         , prd_contract c
                         , acc_account ac
                     where v.service_id      = s.id
                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                       and v.attr_id         = a.id
                       and i_date between nvl(v.start_date, i_date) and nvl(v.end_date, trunc(i_date)+1)
                       and a.service_type_id = s.service_type_id
                       and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                       and st.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and st.id             = s.service_type_id
                       and p.product_id      = ps.product_id
                       and s.id              = ps.service_id
                       and ps.product_id     = c.product_id
                       and c.id              = ac.contract_id
                       and c.split_hash      = ac.split_hash
                       and a.object_type     = crd_api_const_pkg.ACCOUNT_CASH_VALUE_LIMIT_TYPE --'LMTP0408'
                       -- Get active service id with subquery instead of the "prd_api_service_pkg.get_active_service_id" function
                       and s.id = coalesce (
                                            (
                                             select min(service_id)
                                               from prd_service_object o
                                                  , prd_service s
                                              where o.service_id      = s.id
                                                and s.service_type_id = a.service_type_id
                                                and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                and o.object_id       = ac.id
                                                and o.split_hash      = ac.split_hash
                                                and i_date between nvl(trunc(o.start_date), i_date) and nvl(o.end_date, trunc(i_date)+1)
                                            )
                                            -- Save debug message when active service is not exist
                                          , prd_api_service_pkg.message_no_active_service(
                                                i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                              , i_object_id            => ac.id
                                              , i_limit_type           => a.object_type
                                              , i_eff_date             => i_date
                                            )
                                           )
                    ) tt
           ) limits
         , fcl_cycle c
         , fcl_cycle_counter b
     where limits.account_id = i_account_id
       and limits.split_hash = i_split_hash
       and limits.rn         = 1
       and l.id              = limits.limit_id
       and c.id(+)           = l.cycle_id
       and b.cycle_type(+)   = c.cycle_type
       and b.entity_type(+)  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and b.object_id(+)    = i_account_id
       and b.split_hash(+)   = i_split_hash;

exception
    when no_data_found then
        o_value := -1;
        o_current_sum := 0;
end get_cash_limit_value;

function get_cash_limit_value(
    i_account_id  in  com_api_type_pkg.t_account_id
  , i_split_hash  in  com_api_type_pkg.t_tiny_id
  , i_inst_id     in  com_api_type_pkg.t_inst_id
  , i_date        in  date default get_sysdate
)
return com_api_type_pkg.t_money
is
    l_result        com_api_type_pkg.t_money;
    l_current_sum   com_api_type_pkg.t_money;
begin
    get_cash_limit_value(
        i_account_id  => i_account_id
      , i_split_hash  => i_split_hash
      , i_inst_id     => i_inst_id
      , i_date        => i_date
      , o_value       => l_result
      , o_current_sum => l_current_sum
    );

    return l_result;
end get_cash_limit_value;

procedure run_report (
    o_xml           out clob
  , i_lang       in     com_api_type_pkg.t_dict_value
  , i_object_id  in     com_api_type_pkg.t_medium_id
) is
    l_header                  xmltype;
    l_detail                  xmltype;
    l_result                  xmltype;
    l_account_id              com_api_type_pkg.t_account_id;
    l_agent_number            com_api_type_pkg.t_name;
    l_account_number          com_api_type_pkg.t_account_number;
    l_loyalty_account_id      com_api_type_pkg.t_account_id;
    l_loyalty_account         acc_api_type_pkg.t_account_rec;
    l_main_card_id            com_api_type_pkg.t_medium_id;
    l_main_card_number        com_api_type_pkg.t_card_number;
    l_invoice_id              com_api_type_pkg.t_medium_id;
    l_invoice_date            date;
    l_start_date              date;
    l_due_date                date;
    l_period_start_date       date; -- Start of the billing period shown in statement
    l_period_end_date         date; -- End of the billing period shown in statement
    l_lang                    com_api_type_pkg.t_dict_value;
    l_currency                com_api_type_pkg.t_dict_value;
    l_currency_name           com_api_type_pkg.t_dict_value;
    l_currency_exp            com_api_type_pkg.t_tiny_id;
    l_exceed_limit            com_api_type_pkg.t_amount_rec;
    l_credit_limit            com_api_type_pkg.t_balance_id;
    l_cash_limit              com_api_type_pkg.t_balance_id;
    l_avail_credit_amount     com_api_type_pkg.t_money := 0;
    l_avail_cash_amount       com_api_type_pkg.t_money := 0;
    l_current_points          com_api_type_pkg.t_balance_id;
    l_earned_points           com_api_type_pkg.t_balance_id;
    l_expire_points           com_api_type_pkg.t_balance_id;
    l_open_points             com_api_type_pkg.t_balance_id;
    l_redeem_points           com_api_type_pkg.t_balance_id;
    l_lty_service_name        com_api_type_pkg.t_text;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_prev_invoice            crd_api_type_pkg.t_invoice_rec;
    l_total_payment           com_api_type_pkg.t_money := 0;
    l_interest_amount         com_api_type_pkg.t_money := 0;
    l_expense_amount          com_api_type_pkg.t_money := 0; -- Expense including fees (value from invoice)
    l_overdue_balance         com_api_type_pkg.t_money := 0;
    l_overdue_intr_balance    com_api_type_pkg.t_money := 0;
    l_overdraft_balance       com_api_type_pkg.t_money := 0;
    l_cash_amount             com_api_type_pkg.t_money := 0;
    l_own_funds               com_api_type_pkg.t_money := 0;
    l_from_id                 com_api_type_pkg.t_long_id;
    l_till_id                 com_api_type_pkg.t_long_id;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_total_dpp_repayment     com_api_type_pkg.t_money := 0; -- total amount of DPP "repayments"
    l_dpp_interest            com_api_type_pkg.t_money := 0; -- DPP interest amount
    l_total_expense           com_api_type_pkg.t_money := 0; -- expense for this period (incl. fees) + interest - DPP repayments - DPP interest
    l_statement_path          com_api_type_pkg.t_name;

begin

    trc_log_pkg.debug (
        i_text        => 'Run statement report, language [#1], invoice [#2]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_object_id
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => i_object_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_invoice_id := i_object_id;
    l_prev_invoice := null;

    -- Preliminary checks
    if i_object_id is null then
        com_api_error_pkg.raise_error (
            i_error  => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- Get invoice and account information
    begin
        select i.account_id
             , i.invoice_date
             , a.inst_id
             , nvl(i.interest_amount, 0)
             , a.account_number
             , nvl(i.overdue_balance, 0)
             , nvl(i.overdue_intr_balance, 0)
             , nvl(i.overdraft_balance, 0)
             , nvl(i.expense_amount, 0)
             , i.due_date
             , a.split_hash
             , nvl(i.available_balance, 0)
             , nvl(i.own_funds, 0)
             , ag.agent_number
          into l_account_id
             , l_invoice_date
             , l_inst_id
             , l_interest_amount
             , l_account_number
             , l_overdue_balance
             , l_overdue_intr_balance
             , l_overdraft_balance
             , l_expense_amount
             , l_due_date
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
            i_text        => 'Current invoice: l_interest_amount=[#1]'
                          || ', l_overdue_balance=[#2]'
                          || ', l_overdue_intr_balance=[#3]'
                          || ', l_expense_amount=[#4]'
          , i_env_param1  => l_interest_amount
          , i_env_param2  => l_overdue_balance
          , i_env_param3  => l_overdue_intr_balance
          , i_env_param4  => l_expense_amount
          , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
          , i_object_id   => l_invoice_id
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

    -- Get statement path:
    begin
        select directory_path
          into l_statement_path
          from prc_directory
         where lower(directory_path) like '%' || lower(STATEMENT_PATH_PART) || '%';
         
        if substr(l_statement_path, -1) = '/' then
            null;
        elsif length(l_statement_path) > 0 then
            l_statement_path := l_statement_path || '/';
        end if;
    exception
        when NO_DATA_FOUND then
            com_api_error_pkg.raise_error (
                i_error       => 'DIRECTORY_NOT_FOUND'
              , i_env_param1  => STATEMENT_PATH_PART
            );
    end;

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
        if l_start_date < add_months(l_invoice_date, -1) then
            l_start_date := add_months(l_invoice_date, -1);
        end if;
    else
        l_start_date := l_prev_invoice.invoice_date;
    end if;

    trc_log_pkg.debug (
        i_text        => 'Calculated start date: [#1]'
      , i_env_param1  => to_char(l_start_date, 'dd/mm/yyyy')
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
      , i_object_id   => l_invoice_id
    );

    l_period_start_date := l_start_date;
    l_period_end_date := l_invoice_date - com_api_const_pkg.ONE_SECOND;

    -- Get account currency information
    select aa.currency
         , cc.name
         , cc.exponent
      into l_currency
         , l_currency_name
         , l_currency_exp
      from acc_account aa
         , com_currency cc
     where aa.currency = cc.code(+)
       and aa.id = l_account_id
       and aa.split_hash = l_split_hash;

    -- Get total payments amount
    select nvl(sum(p.amount), 0)
      into l_total_payment
      from crd_invoice_payment i
         , crd_payment p
     where i.invoice_id = l_invoice_id
       and p.id = i.pay_id
       and i.split_hash = l_split_hash
       and p.split_hash = l_split_hash
       and i.is_new = com_api_type_pkg.TRUE
       and not exists
           (select 1
              from opr_operation po
             where po.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
               and po.id = p.oper_id);

    trc_log_pkg.debug (
        i_text        => 'Total payments amount: [#1]'
      , i_env_param1  => l_total_payment
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => l_invoice_id
    );

    -- DPP repayments amount:
    select nvl(sum(p.amount), 0)
      into l_total_dpp_repayment
      from crd_invoice_payment i
         , crd_payment p
     where i.invoice_id = l_invoice_id
       and p.id = i.pay_id
       and i.split_hash = l_split_hash
       and p.split_hash = l_split_hash
       and exists
           (select 1
              from opr_operation po
             where po.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
               and po.id = p.oper_id);

    trc_log_pkg.debug (
        i_text        => 'Total DPP repayments amount: [#1]'
      , i_env_param1  => l_total_dpp_repayment
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => l_invoice_id
    ); 

    -- Get DPP interest total (currently it's being counted twice in invoice: in expense_amount and interest_amount)
    l_dpp_interest := 0;
--    -- >> Phase 2
--    
--    select nvl(sum(amount), 0)
--      into l_dpp_interest
--      from crd_debt
--     where macros_type_id = 7182 -- DPP interest
--       and split_hash = l_split_hash
--       and oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
--       and status in (
--                       crd_api_const_pkg.DEBT_STATUS_PAID
--                     , crd_api_const_pkg.DEBT_STATUS_ACTIVE
--                     )
--       and id in (select debt_id
--                    from crd_invoice_debt_vw
--                   where invoice_id = l_invoice_id
--                     and is_new = com_api_type_pkg.TRUE);

    trc_log_pkg.debug (
        i_text        => 'DPP interest: [#1]'
      , i_env_param1  => l_dpp_interest
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
      , i_object_id   => l_invoice_id
    ); 
    -- Get this period total expense (incl. fees, interest, excl. DPP):
    l_total_expense :=
        nvl(l_expense_amount, 0) -- expense for this period (incl. fees)
      + nvl(l_interest_amount, 0) -- interest for this period
      - nvl(l_total_dpp_repayment, 0) -- we don't show DPP repayments
      - nvl(l_dpp_interest, 0); -- currently it's included into both l_expense_amount and l_interest_amount

    trc_log_pkg.debug (
        i_text        => 'Total expense: expense from invoice [#1] + interest from invoice [#2]'
                      || ' - total DPP repayments [#3] - DPP interest [#4] = [#5]'
      , i_env_param1  => l_expense_amount
      , i_env_param2  => l_interest_amount
      , i_env_param3  => l_total_dpp_repayment
      , i_env_param4  => l_dpp_interest
      , i_env_param5  => l_total_expense
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => l_invoice_id
    );

    -- Get main card (Primary or other existing)
    l_main_card_id := 
        cst_lvp_com_pkg.get_main_card_id (
            i_account_id => l_account_id
          , i_split_hash => l_split_hash
        );

    select iss_api_token_pkg.decode_card_number(
               i_card_number => icn.card_number
             , i_mask_error  => com_api_type_pkg.TRUE
           ) as card_number
      into l_main_card_number
      from iss_card_number icn
     where icn.card_id = l_main_card_id;

    -- Get loyalty account
    begin
        select a2.id
          into l_loyalty_account_id
          from acc_account a1
             , acc_account a2
         where a1.contract_id = a2.contract_id
           and a1.id = l_account_id
           and a1.split_hash = l_split_hash
           and a2.split_hash = l_split_hash
           and a2.account_type = cst_woo_const_pkg.ACCT_TYPE_LOYALTY --'ACTPLOYT'
           and a2.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE --'ACSTACTV'
           and rownum <= 1;

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text  => 'crd_api_exterenal_pkg.loyalty_points_sum: Unable to find loyalty service for customer'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
              , i_object_id   => l_invoice_id
            );
    end;

    -- Get loyalty points summary:
    l_current_points := 0;
    l_earned_points := 0;
    l_expire_points := 0;
    l_open_points := 0;
    l_redeem_points := 0;

    if l_loyalty_account_id is not null then
        l_from_id := com_api_id_pkg.get_from_id(l_start_date);
        select nvl(sum(balance_impact * amount), 0)
          into l_earned_points
          from acc_entry
         where account_id = l_loyalty_account_id
           and id >= l_from_id
           and split_hash = l_split_hash
           and posting_date >= l_start_date
           and posting_date < l_invoice_date
           and balance_type = 'BLTP5001';

        l_from_id := com_api_id_pkg.get_from_id(l_invoice_date);
        select nvl(sum(balance_impact * amount), 0)
          into l_current_points
          from acc_entry
         where account_id = l_loyalty_account_id
           and id >= l_from_id
           and split_hash = l_split_hash
           and posting_date >= l_invoice_date
           and balance_type = 'BLTP5001';

        select l.balance - l_current_points
          into l_current_points
          from acc_balance l
         where l.split_hash = l_split_hash
           and l.balance_type = 'BLTP5001'
           and l.account_id = l_loyalty_account_id;

        select nvl(sum(b.amount - b.spent_amount), 0)
          into l_expire_points
          from lty_bonus b
         where b.expire_date > l_invoice_date
           and trunc(b.expire_date, 'yyyy') = trunc(l_invoice_date, 'yyyy')
           and b.status = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
           and b.account_id = l_loyalty_account_id;

    end if;

    -- Get credit limit and cash limit:
    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id     => l_account_id
          , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_date           => l_invoice_date
          , i_date_type      => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error     => com_api_const_pkg.TRUE
        );
    l_credit_limit := l_exceed_limit.amount;

    get_cash_limit_value(
        i_account_id     => l_account_id
      , i_split_hash     => l_split_hash
      , i_inst_id        => l_inst_id
      , i_date           => l_invoice_date
      , o_value          => l_cash_limit
      , o_current_sum    => l_avail_cash_amount
    );

    if l_cash_limit = -1 then
        l_cash_limit := l_credit_limit;
    end if;

    l_credit_limit := nvl(l_credit_limit, 0);
    l_cash_limit := nvl(l_cash_limit, 0);
    l_avail_cash_amount := greatest(l_cash_limit - l_avail_cash_amount, 0);

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
       and d.macros_type_id = 1004;

    -- Create header:
    select
        xmlconcat(
            xmlelement("customer_number", t.customer_number)
          , xmlelement("attachments"
              , xmlelement("attachment"
                  , xmlelement("attachment_path", l_statement_path)
                  , xmlelement("attachment_name"
                             , 'STATEMENT_'
                             || to_char(l_invoice_id)
                             || '_' 
                             || cst_lvp_api_statement_pkg.get_customer_name(l_account_id)
                             || '_'
                             || to_char(get_sysdate, 'YYYYMMDD')
                             || '.pdf')
                )
            )
          , xmlelement("account_number", l_account_number)
          , xmlelement("account_currency", l_currency_name)
          , xmlelement("start_date", to_char(l_period_start_date, 'dd/mm/yyyy'))
          , xmlelement("end_date", to_char(l_period_end_date, 'dd/mm/yyyy'))
          , xmlelement("invoice_date", to_char((l_invoice_date - 1), 'dd/mm/yyyy'))
          , xmlelement("due_date", to_char(l_due_date, 'dd/mm/yyyy'))
          , xmlelement("credit_limit", format_amount(nvl(l_credit_limit, 0), l_currency))
          , xmlelement("cash_limit", format_amount(nvl(l_cash_limit, 0), l_currency))
          , xmlelement("available_credit_amount", format_amount(nvl(l_avail_credit_amount, 0), l_currency))
          , xmlelement("available_cash", format_amount(nvl(l_avail_cash_amount, 0), l_currency))
          , xmlelement("total_amount_due", format_amount(nvl(t.total_amount_due, 0) - l_own_funds, l_currency))
          , xmlelement("min_amount_due", format_amount(nvl(t.min_amount_due, 0), l_currency))
          , xmlelement("overdue_balance", format_amount(nvl(l_overdue_balance, 0), l_currency))
          , xmlelement("overdue_intr_balance", format_amount(nvl(l_overdue_intr_balance, 0), l_currency))
          , xmlelement("opening_balance", format_amount(nvl(l_prev_invoice.total_amount_due, 0) - nvl(l_prev_invoice.own_funds, 0), l_currency))
          , xmlelement("total_payment", format_amount(nvl(l_total_payment, 0), l_currency))
          , xmlelement("expense_amount", format_amount(nvl(l_total_expense, 0) - nvl(l_cash_amount, 0), l_currency))
          , xmlelement("cash_amount", format_amount(nvl(l_cash_amount, 0), l_currency))
          , xmlelement("earned_points", nvl(l_earned_points, 0))
          , xmlelement("expire_points", nvl(l_expire_points, 0))
          , xmlelement("current_points", nvl(l_current_points, 0))
          , xmlelement("open_points", nvl(l_open_points, 0))
          , xmlelement("redeem_points", nvl(l_redeem_points, 0))
          , xmlelement("hdr_logo_path", t.hdr_logo_path)
          , xmlelement("promo_mess", t.promo_mess)
          , xmlelement("imp_mess", t.imp_mess)
          , xmlelement("post_addr", t.customer_address)
          , xmlelement("customer_name", t.customer_name)
          , xmlelement("agent_name", t.agent_name)
          , xmlelement("sms_card_number", substr(l_main_card_number, 1, 4) || '***' || substr(l_main_card_number, -4))
        )
    into l_header
    from (
          select c.customer_number
               , c.id as customer_id
               , i.invoice_date
               , i.due_date
               , i.total_amount_due
               , i.min_amount_due
               , i.expense_amount
               , i.fee_amount
               , i.interest_amount
               , get_bann_filename('STMT_HDR_LOGO', l_lang) hdr_logo_path
               , get_bann_mess('STMT_PROMO_MESS', l_lang) promo_mess
               , get_bann_mess('STMT_IMP_MESS', l_lang) imp_mess
               , case c.entity_type
                     when com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
                     then com_ui_person_pkg.get_person_name (c.object_id, l_lang)
                     when com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
                     then get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
                 end as customer_name
               , get_address_string(
                     i_customer_id => c.id
                 ) as customer_address
               , o.agent_number || '-' || com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) agent_name
            from crd_invoice_vw i
               , acc_account_vw a
               , prd_customer_vw c
               , ost_agent o
           where i.id = l_invoice_id
             and a.id = i.account_id
             and c.id = a.customer_id
             and a.agent_id = o.id
             and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
         ) t;

    -- Create details:
    begin
        select
            xmlelement("operations",
                xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_date", to_char(td.oper_date, 'dd/mm/yyyy'))
                      , xmlelement("posting_date", to_char(td.posting_date, 'dd/mm/yyyy'))
                      , xmlelement("oper_amount", format_amount(td.oper_amount, td.oper_currency))
                      , xmlelement("oper_currency", td.oper_currency_name)
                      , xmlelement("oper_currency_expo", td.oper_currency_expo)
                      , xmlelement("posting_currency", nvl(td.currency_name, l_currency))
                      , xmlelement("posting_currency_expo", td.currency_expo)
                      , xmlelement("posting_amount", format_amount(td.transaction_amount, l_currency))
                      , xmlelement("posting_amount_number", td.transaction_amount)
                      , xmlelement("merchant_name",
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
                      , xmlelement("oper_id", td.oper_id)
                      , xmlelement("card_mask", iss_api_card_pkg.get_card_mask(td.card_number))
                      , xmlelement("expo", nvl(td.currency_expo, l_currency_exp))
                      , xmlelement("section_number", td.section_number)
                      , xmlelement("card_is_main", td.card_is_main)
                   )
                   order by td.section_number asc
                          , td.card_is_main desc
                          , td.card_number asc
                          , td.oper_id asc
                          , td.oper_part_num asc
                )
            )
         into l_detail
         from (
                select 1 as section_number
                     , l_account_number as account_number
                     , 0 as oper_id
                     , 0 as oper_part_num
                     , null as oper_date
                     , l_main_card_id as card_id
                     , 'Opening Balance' as oper_type_name
                     , null as posting_date
                     , to_char(null) as merchant_name
                     , to_char(null) as merchant_country
                     , to_char(null) as oper_currency
                     , to_char(null) as oper_currency_name
                     , to_number(null) as oper_currency_expo
                     , to_number(null) as oper_amount
                     , nvl(l_prev_invoice.total_amount_due, 0) - nvl(l_prev_invoice.own_funds, 0) as transaction_amount
                     , l_currency_name as currency_name
                     , l_currency_exp as currency_expo
                     , l_main_card_number as card_number
                     , com_api_type_pkg.TRUE as card_is_main
                  from dual
                 union all
                 select 2 as section_number
                     , l_account_number as account_number
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
                     , case when t.card_id = l_main_card_id 
                            then com_api_type_pkg.TRUE 
                            else com_api_type_pkg.FALSE
                       end as card_is_main
                  from (
                        select oo.id as oper_id
                             , oo.oper_date
                             , case when d.fee_amount > 0 
                                    then 2
                                    else 1
                               end as oper_part_num
                             , d.card_id
                             , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                                    then com_api_dictionary_pkg.get_article_text(oo.oper_reason, l_lang)
                                    when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                                    then 'DPP'
                                    else case when d.fee_amount > 0
                                              then 'Fee for ' || replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
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
                          from (
                                select cd.account_id
                                     , cd.card_id
                                     , cd.oper_id
                                     , cd.oper_type
                                     , cd.id as debt_id
                                     , cd.currency
                                     , sum(cd.transaction_amount) as transaction_amount
                                     , sum(cd.fee_amount) as fee_amount
                                     , min(cd.posting_date) as posting_date
                                  from (
                                        select distinct debt_id
                                          from crd_invoice_debt_vw
                                         where invoice_id = l_invoice_id
                                           and split_hash = l_split_hash
                                           and is_new = com_api_type_pkg.TRUE
                                       ) cid -- debts included into invoice
                                     , (
                                        select d.id
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
                                             , case when d.macros_type_id in (1007, 1010, 7001, 7002, 7011, 8027, 8028)
                                                    then d.amount
                                                    when d.macros_type_id in (1008, 1009)
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
                             , oo.oper_date
                             , null as oper_part_num
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
                           and oo.oper_type not in (dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER)
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
                select 2 as section_number
                     , l_account_number as account_number
                     , com_api_id_pkg.get_till_id(l_period_end_date) as oper_id
                     , 0 as oper_part_num
                     , l_period_end_date as oper_date
                     , l_main_card_id as card_id
                     , 'Interest Amount' as oper_type_name
                     , l_period_end_date as posting_date
                     , to_char(null) as merchant_name
                     , to_char(null) as merchant_country
                     , l_currency as oper_currency
                     , l_currency_name as oper_currency_name
                     , l_currency_exp as oper_currency_expo
                     , nvl(l_interest_amount, 0) as oper_amount
                     , nvl(l_interest_amount, 0) as transaction_amount
                     , l_currency_name as currency_name
                     , l_currency_exp as currency_expo
                     , l_main_card_number as card_number
                     , com_api_type_pkg.TRUE as card_is_main
                  from dual
                 where nvl(l_interest_amount, 0) > 0
            ) td;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
              , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
              , i_object_id   => l_invoice_id
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

end run_report;


procedure run_sms_report (
    o_xml           out clob
  , i_lang       in     com_api_type_pkg.t_dict_value
  , i_object_id  in     com_api_type_pkg.t_medium_id
) is
    l_result                  xmltype;
    l_account_id              com_api_type_pkg.t_account_id;
    l_account_number          com_api_type_pkg.t_account_number;
    l_main_card_id            com_api_type_pkg.t_medium_id;
    l_main_card_number        com_api_type_pkg.t_card_number;
    l_invoice_id              com_api_type_pkg.t_medium_id;
    l_due_date                date;
    l_lang                    com_api_type_pkg.t_dict_value;
    l_currency                com_api_type_pkg.t_dict_value;
    l_currency_name           com_api_type_pkg.t_dict_value;
    l_currency_exp            com_api_type_pkg.t_tiny_id;
    l_total_amount_due        com_api_type_pkg.t_money;
    l_min_amount_due          com_api_type_pkg.t_money;
    l_split_hash              com_api_type_pkg.t_tiny_id;

begin

    trc_log_pkg.debug (
        i_text        => 'Run statement SMS report, language [#1], invoice [#2]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_object_id
      , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id   => i_object_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_invoice_id := i_object_id;
    
    -- Preliminary checks
    if i_object_id is null then
        com_api_error_pkg.raise_error (
            i_error  => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
        );
    end if;

    -- Get invoice and account information
    begin
        select i.account_id
             , i.due_date
             , i.split_hash
             , nvl(i.total_amount_due, 0)
             , nvl(i.min_amount_due, 0)
          into l_account_id
             , l_due_date
             , l_split_hash
             , l_total_amount_due
             , l_min_amount_due
          from crd_invoice i
         where i.id = l_invoice_id;

         trc_log_pkg.debug (
            i_text        => 'Current invoice: l_total_amount_due=[#1]'
                          || ', l_min_amount_due=[#2]'
          , i_env_param1  => l_total_amount_due
          , i_env_param2  => l_min_amount_due
          , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
          , i_object_id   => l_invoice_id
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

    -- Get account currency information
    select aa.currency
         , cc.name
         , cc.exponent
      into l_currency
         , l_currency_name
         , l_currency_exp
      from acc_account aa
         , com_currency cc
     where aa.currency = cc.code(+)
       and aa.id = l_account_id
       and aa.split_hash = l_split_hash;

    -- Get main card (Primary or other existing)
    l_main_card_id := 
        cst_lvp_com_pkg.get_main_card_id (
            i_account_id => l_account_id
          , i_split_hash => l_split_hash
        );

    select iss_api_token_pkg.decode_card_number(
               i_card_number => icn.card_number
             , i_mask_error  => com_api_type_pkg.TRUE
           ) as card_number
      into l_main_card_number
      from iss_card_number icn
     where icn.card_id = l_main_card_id;

    -- Create report:
    select xmlelement(
               "report"
             , xmlconcat(
                   xmlelement("card_number", substr(l_main_card_number, 1, 4) || '***' || substr(l_main_card_number, -4))
                 , xmlelement("closing_balance", format_amount(i_amount => l_total_amount_due, i_curr_code => l_currency))
                 , xmlelement("min_amount_due", format_amount(i_amount => l_min_amount_due, i_curr_code => l_currency))
                 , xmlelement("due_date", to_char(l_due_date, 'dd/mm/yyyy'))
                 , xmlelement("date_format", 'dd/mm/yyyy')
               )
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

end run_sms_report;

end cst_lvp_api_statement_pkg;
/
