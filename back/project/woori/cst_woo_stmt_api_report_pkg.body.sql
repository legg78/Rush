create or replace package body cst_woo_stmt_api_report_pkg is
/************************************************************
* Reports for Credit module <br />
* Created by Aman Weerasinghe(weerasinghe@bpcbt.com) at 01.06.2016  <br />
* Last changed by $Author: Renat Shayukov $  <br />
* $LastChangedDate::  27.07.2017#$ <br />
* Revision: $LastChangedRevision: $ <br />
* Module: cst_woo_stmt_api_report_pkg <br />
* @headcom
************************************************************/

STATEMENT_REPORT_PATH constant com_api_type_pkg.t_name := '/home/weblogic/iofiles/outgoing/Credit_Statement/';
STATEMENT_NAME_PREFIX constant com_api_type_pkg.t_name := 'NOTIF_INVOICE_';

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
    l_contact_id com_api_type_pkg.t_medium_id;
begin
    begin
        select contact_id
          into l_contact_id
          from com_contact_object
         where object_id = i_customer_id
           and entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and contact_type = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION;
    exception
        when no_data_found then
            select contact_id
              into l_contact_id
              from com_contact_object
             where object_id = i_customer_id
               and entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
               and contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY;
    end;
    
    return 
        com_api_contact_pkg.get_contact_string(
            i_contact_id    => l_contact_id
          , i_commun_method => com_api_const_pkg.COMMUNICATION_METHOD_POST
          , i_start_date    => get_sysdate
        );
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

function get_project_interest(
    i_debt_id           in  com_api_type_pkg.t_long_id
  , i_invoice_id        in  com_api_type_pkg.t_medium_id
  , i_split_hash        in  com_api_type_pkg.t_tiny_id
  , i_end_date          in  date
  , i_include_overdraft in  com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_include_overdue   in  com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_round             in  com_api_type_pkg.t_tiny_id default 0
)
return com_api_type_pkg.t_money
is
    l_result   com_api_type_pkg.t_money := 0;
    l_currency com_api_type_pkg.t_dict_value;
    l_current_date date;
begin
    
    for rc in (
        select a.balance_type
             , a.fee_id
             , a.add_fee_id
             , a.debt_id
             , a.amount
             , i.account_id
             , d.currency
             , a.balance_date start_date
             , lead(a.balance_date) over (partition by a.balance_type order by a.id) end_date
             , i.due_date
          from crd_debt_interest a
             , crd_debt d
             , crd_invoice i
         where i.id              = i_invoice_id
           and a.invoice_id      = i.id
           and a.split_hash      = i_split_hash
           and a.is_charged      = com_api_const_pkg.TRUE
           and d.is_grace_enable = com_api_const_pkg.FALSE
           and d.id              = a.debt_id
           and d.id              = i_debt_id
           and not exists (
                            select 1
                              from dpp_payment_plan dpp
                                 , acc_macros acm
                             where acm.id = dpp.id
                               and acm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                               and acm.object_id   = d.oper_id
                               and dpp.status <> dpp_api_const_pkg.DPP_OPERATION_CANCELED -- 'DOST0300'
                          )
           and (
                   (
                        i_include_overdraft = com_api_const_pkg.TRUE
                    and a.balance_type in (
                                            cst_woo_const_pkg.BALANCE_TYPE_OVERDRAFT
                                          , cst_woo_const_pkg.BALANCE_TYPE_INTEREST
                                          )
                   )
                or
                   (
                        i_include_overdue = com_api_const_pkg.TRUE
                    and a.balance_type in (
                                            cst_woo_const_pkg.BALANCE_TYPE_OVERDUE
                                          , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                          )
                   )
               )
         order by d.id
    ) loop
        l_currency := rc.currency;
        
        if rc.end_date is null and rc.start_date < i_end_date then
            l_current_date := rc.start_date;
            while l_current_date < i_end_date - 1 loop
            l_result :=
                l_result
              + round(
                    fcl_api_fee_pkg.get_fee_amount(
                        i_fee_id            => rc.fee_id
                      , i_base_amount       => rc.amount
                      , io_base_currency    => l_currency
                      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => rc.account_id
                      , i_split_hash        => i_split_hash
                      , i_eff_date          => l_current_date
                      , i_start_date        => l_current_date
                      , i_end_date          => l_current_date + 1
                    )
                  , i_round
                );
        if rc.add_fee_id is not null then
            l_result := 
                l_result
              + round(
                    fcl_api_fee_pkg.get_fee_amount(
                        i_fee_id            => rc.add_fee_id
                      , i_base_amount       => rc.amount
                      , io_base_currency    => l_currency
                      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => rc.account_id
                      , i_split_hash        => i_split_hash
                      , i_eff_date          => l_current_date
                      , i_start_date        => l_current_date
                      , i_end_date          => l_current_date + 1
                    )
                  , i_round
                );
        end if;
                l_current_date := l_current_date + 1;
            end loop;
        end if;
    end loop;
    
    return l_result;
end get_project_interest; 

function get_cash_limit_value(
    i_account_id  in  com_api_type_pkg.t_account_id
  , i_split_hash  in  com_api_type_pkg.t_tiny_id
  , i_inst_id     in  com_api_type_pkg.t_inst_id
  , i_date        in  date default get_sysdate
)
return com_api_type_pkg.t_money
is
    l_result com_api_type_pkg.t_money;
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
       into l_result
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
        
    return l_result;
end get_cash_limit_value;      

function get_due_day(
    i_account_id  in  com_api_type_pkg.t_account_id
  , i_eff_date    in  date default get_sysdate
  , i_due_date    in  date
) return com_api_type_pkg.t_tiny_id
is
    l_cycle_id          com_api_type_pkg.t_short_id;
    l_day               com_api_type_pkg.t_tiny_id;
begin
    l_cycle_id := 
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
          , i_object_id   => i_account_id
          , i_attr_name   => 'CRD_DUE_DATE_PERIOD'
              , i_eff_date       => i_eff_date
            );
    
    select nvl(sum(shift_length), 1) 
      into l_day
      from fcl_cycle_shift
     where cycle_id = l_cycle_id 
       and shift_type = fcl_api_const_pkg.CYCLE_SHIFT_MONTH_DAY; 
       
    if l_day not between 1 and 31 then
        l_day := to_number(to_char(i_due_date, 'dd'));
    end if;
    return l_day;
    
exception when others then 
    return to_number(to_char(i_due_date, 'dd'));
end get_due_day;


procedure run_report (
    o_xml           out clob
  , i_lang       in     com_api_type_pkg.t_dict_value
  , i_object_id  in     com_api_type_pkg.t_medium_id
) is
    l_header                  xmltype;
    l_detail                  xmltype;
    l_cards                   xmltype;
    l_result                  xmltype;
    l_account_id              com_api_type_pkg.t_account_id;
    l_account_number          com_api_type_pkg.t_account_number;
    l_loyalty_account_id      com_api_type_pkg.t_account_id;
    l_loyalty_account         acc_api_type_pkg.t_account_rec;
    l_main_card_id            com_api_type_pkg.t_medium_id;
    l_main_card_number        com_api_type_pkg.t_card_number;
    l_invoice_id              com_api_type_pkg.t_medium_id;
    l_invoice_date            date;
    l_start_date              date;
    l_due_date                date;
    l_lang                    com_api_type_pkg.t_dict_value;
    l_currency                com_api_type_pkg.t_dict_value;
    l_currency_name           com_api_type_pkg.t_dict_value;
    l_currency_exp            com_api_type_pkg.t_tiny_id;
    l_credit_limit            com_api_type_pkg.t_balance_id;
    l_cash_limit              com_api_type_pkg.t_balance_id;
    l_current_points          com_api_type_pkg.t_balance_id;
    l_earned_points           com_api_type_pkg.t_balance_id;
    l_expire_points           com_api_type_pkg.t_balance_id;
    l_lty_service_name        com_api_type_pkg.t_text;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_rate_type               com_api_type_pkg.t_dict_value;   
    l_prev_invoice            crd_api_type_pkg.t_invoice_rec;  
    l_total_payment           com_api_type_pkg.t_money := 0;  
    l_cycle_start_date        date;     
    l_cycle_end_date          date;  
    l_cycle_id                com_api_type_pkg.t_short_id;
    l_interest_amount         com_api_type_pkg.t_money := 0;    
    l_expense_amount          com_api_type_pkg.t_money := 0;   
    l_overdue_balance         com_api_type_pkg.t_money := 0;
    l_overdue_intr_balance    com_api_type_pkg.t_money := 0;
    l_overdraft_balance       com_api_type_pkg.t_money := 0;
    l_from_id                 com_api_type_pkg.t_long_id;
    l_till_id                 com_api_type_pkg.t_long_id;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_exceed_limit            com_api_type_pkg.t_amount_rec;
    l_overdraft_last_month    com_api_type_pkg.t_money := 0;
    l_fee_interest_last_month com_api_type_pkg.t_money := 0;
    l_advance_payment         com_api_type_pkg.t_money := 0; -- it's total payments for period subtracting previous invoice TAD (or 0 if it's < 0) 
    l_total_real_payment      com_api_type_pkg.t_money := 0; -- amount of real payments (not reversals, not DPP repayment)
    l_total_dpp_repayment     com_api_type_pkg.t_money := 0; -- total amount of DPP "repayments"
    l_dpp_interest            com_api_type_pkg.t_money := 0; -- DPP interest amount
    l_remaining_last_month    com_api_type_pkg.t_money := 0; -- last month TAD subtracting overdue and overdue interest
    l_total_expense           com_api_type_pkg.t_money := 0;
    l_interest_new_debts      com_api_type_pkg.t_money := 0;
    l_proj_intr_overdue       com_api_type_pkg.t_money := 0;
    l_proj_intr_last_month    com_api_type_pkg.t_money := 0;
    l_proj_intr_current       com_api_type_pkg.t_money := 0;
    
begin
    trc_log_pkg.debug (
        i_text        => 'Run statement report, language [#1], invoice [#2]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_object_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_invoice_id := i_object_id;
    l_rate_type := 'RTTPCUST';
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
          from crd_invoice i
             , acc_account a
         where a.id = i.account_id 
           and i.id = l_invoice_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'INVOICE_NOT_FOUND'
              , i_env_param1  => l_invoice_id
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
        
        select nvl(overdraft_balance, 0)
             , nvl(fee_amount, 0) + nvl(interest_amount, 0)
          into l_overdraft_last_month
             , l_fee_interest_last_month
          from crd_invoice_vw
         where id = l_prev_invoice.id;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Previous invoice not found'
            );
            l_overdraft_last_month := 0;
            l_fee_interest_last_month := 0;
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
    else
        l_start_date := l_prev_invoice.invoice_date;
    end if;
    
    -- Calculate billing period to show in report:
    l_cycle_id := 
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
          , i_object_id   => l_account_id
          , i_attr_name   => 'CRD_FORCED_INTEREST_CHARGE_PERIOD' 
          , i_eff_date    => l_start_date
        );
    fcl_api_cycle_pkg.calc_next_date(
        i_cycle_id          => l_cycle_id
      , i_start_date        => l_start_date
      , i_forward           => com_api_type_pkg.TRUE
      , o_next_date         => l_cycle_end_date
    );
    if l_prev_invoice.id is null then
        l_cycle_start_date := l_start_date;
    else
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_id          => l_cycle_id
          , i_start_date        => l_start_date
          , i_forward           => com_api_type_pkg.FALSE
          , o_next_date         => l_cycle_start_date
        );
        l_cycle_start_date := l_cycle_start_date + com_api_const_pkg.ONE_SECOND;
    end if;
    
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
       and not exists
           (select 1
              from opr_operation po
             where po.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
               and po.id = p.oper_id);
               
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
             where po.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
               and po.id = p.oper_id);
               
    -- Get DPP interest total (currently it's being counted twice in invoice: in expense_amount and interest_amount)
    select nvl(sum(amount), 0)
      into l_dpp_interest
      from crd_debt 
     where macros_type_id = 7182 -- DPP interest
       and split_hash = l_split_hash
       and oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
       and status in (
                       crd_api_const_pkg.DEBT_STATUS_PAID
                     , crd_api_const_pkg.DEBT_STATUS_ACTIVE
                     )
       and id in (select debt_id
                    from crd_invoice_debt_vw
                   where invoice_id = l_invoice_id
                     and is_new = com_api_type_pkg.TRUE);
                     
    --Get total expense amount
    select nvl(sum(n.amount),0)
      into l_total_expense
      from crd_debt_interest n
         , crd_debt d
         , crd_invoice_debt i
     where i.debt_intr_id = n.id 
       and i.debt_id = d.id
       and i.invoice_id = l_invoice_id
       ;
                     
    -- Get remaining_last_month :
    if l_overdue_balance + l_overdue_intr_balance > 0 then
        l_remaining_last_month := nvl(l_prev_invoice.total_amount_due, 0) - l_overdue_balance - l_overdue_intr_balance;
        trc_log_pkg.debug (
            i_text        => 'Overdue balance + interest > 0, l_remaining_last_month = ['
                          || l_remaining_last_month
                          || ']'
          , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE --'ENTTINVC'
          , i_object_id   => l_invoice_id
        );
    else    
        l_remaining_last_month := greatest(nvl(l_prev_invoice.total_amount_due, 0) - l_total_payment, 0);
    end if;  
    
    -- Get advance payment:
    -- This is the payment for the debts still not come to invoice
    --  after invoice_date until the end of current month of invoice
    select nvl(sum(dp.pay_amount), 0)
      into l_advance_payment
      from crd_debt d
         , crd_payment p
         , opr_operation o
         , crd_debt_payment dp
     where dp.pay_id  = p.id
       and dp.debt_id = d.id
       and p.oper_id  = o.id
       and p.is_reversal = com_api_type_pkg.FALSE
       and o.oper_type != dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
       and d.account_id = l_account_id
       and o.oper_date  > l_invoice_date
       and o.oper_date <= last_day(l_invoice_date)
       and not exists (
                        select 1
                          from opr_operation
                         where original_id = o.id
                           and is_reversal = com_api_type_pkg.TRUE
                      )
       and not exists (
                        select 1
                          from dpp_payment_plan dpp
                             , acc_macros acm
                         where acm.id = dpp.id
                           and acm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                           and acm.object_id   = o.id
                      )
       and not exists (
                        select 1
                          from crd_invoice_debt
                         where invoice_id = l_invoice_id
                           and debt_id = d.id
                      );

    -- Calculate interest charged only for new debts (included into current invoice):
    select nvl(sum(round(interest_amount)), 0)
      into l_interest_new_debts
      from crd_debt_interest cdi
     where cdi.debt_id in (
                           select cid.debt_id
                             from crd_invoice_debt cid
                            where cid.invoice_id = l_invoice_id
                              and cid.split_hash = l_split_hash
                              and cid.is_new = com_api_type_pkg.TRUE
                          )
       and cdi.is_charged = com_api_type_pkg.TRUE
       and cdi.balance_date <= l_invoice_date
       and cdi.split_hash = l_split_hash
       and cdi.invoice_id = l_invoice_id;
    
    -- Get main card (Primary or other existing)
    select t.id
         , icn.card_number
      into l_main_card_id
         , l_main_card_number
      from (
            select c.id
                 , row_number() over (order by 
                                      case 
                                          when c.category = 'CRCG0800' then 1
                                          when c.category = 'CRCG0600' then 2
                                          when c.category = 'CRCG0200' then 3
                                          when c.category = 'CRCG0900' then 4
                                      end) as seqnum
              from iss_card_vw c
                 , acc_account_object ao
             where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
               and ao.object_id = c.id
               and ao.account_id = l_account_id
               and ao.split_hash = l_split_hash
           ) t
         , iss_card_number icn
     where t.seqnum = 1
       and icn.card_id = t.id;
     
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
            );
    end;
    
    -- Get loyalty points summary:
    l_current_points := 0;
    l_earned_points := 0;
    l_expire_points := 0;
    
    if l_loyalty_account_id is not null then
        l_from_id := com_api_id_pkg.get_from_id(l_start_date);
        select nvl(sum(balance_impact * amount), 0)
          into l_earned_points
          from acc_entry
         where account_id = l_loyalty_account_id
           and id >= l_from_id
           and split_hash = l_split_hash
           and posting_date >= l_start_date 
           and posting_date < l_invoice_date;
        
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
    
    l_cash_limit := 
        get_cash_limit_value(
            i_account_id     => l_account_id
          , i_split_hash     => l_split_hash
          , i_inst_id        => l_inst_id
          , i_date           => l_invoice_date
        );
    if l_cash_limit = -1 then
        l_cash_limit := l_credit_limit;
    end if;
    
    l_credit_limit := nvl(l_credit_limit, 0);
    l_cash_limit := nvl(l_cash_limit, 0);
    
    -- Calculate project interest (imaginary interest that can be charged for period from billing date up to due date):
    l_till_id := com_api_id_pkg.get_till_id(l_invoice_date);
    -- 1. Project interest for overdue:
    if l_overdue_balance = 0 then
        l_proj_intr_overdue := 0;
    else
        select nvl(
                   sum(get_project_interest(
                           i_debt_id    => d.id
                         , i_invoice_id => l_invoice_id
                         , i_split_hash => l_split_hash
                         , i_end_date   => l_due_date
                         , i_include_overdraft => com_api_type_pkg.FALSE
                         , i_include_overdue   => com_api_type_pkg.TRUE
                         , i_round      => 0
                       )
                   )
                   , 0
                   )
          into l_proj_intr_overdue
          from crd_debt d
         where d.account_id = l_account_id
           and d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
           and d.id < l_till_id;
    end if;
    
    -- 2. Project interest for last month overdraft:
    if l_remaining_last_month = 0 then
        l_proj_intr_last_month := 0;
    else
        select nvl(
                   sum(get_project_interest(
                           i_debt_id    => d.id
                         , i_invoice_id => l_invoice_id
                         , i_split_hash => l_split_hash
                         , i_end_date   => l_due_date
                         , i_include_overdraft => com_api_type_pkg.TRUE
                         , i_include_overdue   => com_api_type_pkg.FALSE
                         , i_round      => 0
                       )
                   )
               , 0
               )
          into l_proj_intr_last_month
          from crd_debt d
         where d.account_id = l_account_id
           and d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
           --and d.aging_period = 0
           and d.id < l_till_id
           and d.id not in (
                          select cid.debt_id
                            from crd_invoice_debt cid
                           where cid.invoice_id = l_invoice_id
                             and cid.is_new = com_api_type_pkg.TRUE
                          );
    end if;
    
    -- 3. Project interest for current invoice:
    select nvl(
               sum(get_project_interest(
                       i_debt_id    => d.id
                     , i_invoice_id => l_invoice_id
                     , i_split_hash => l_split_hash
                     , i_end_date   => l_due_date
                     , i_include_overdraft => com_api_type_pkg.TRUE
                     , i_include_overdue   => com_api_type_pkg.FALSE
                     , i_round      => 0
                   )
               )
               , 0
           )
      into l_proj_intr_current
      from crd_debt d
     where d.account_id = l_account_id
       and d.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE
       --and d.aging_period = 0
       and d.id < l_till_id
       and d.id in (
                    select cid.debt_id
                      from crd_invoice_debt cid
                     where cid.invoice_id = l_invoice_id
                       and cid.is_new = com_api_type_pkg.TRUE
                   );

    
    -- Real payments total amount:
    select nvl(sum(cip.pay_amount), 0)
      into l_total_real_payment 
      from crd_invoice_payment cip
         , crd_payment cp
         , opr_operation oo
     where cip.pay_id = cp.id
       and oo.id = cp.oper_id
       and cip.invoice_id = l_invoice_id
       and cp.is_reversal = com_api_type_pkg.FALSE
       and not exists (
                       select 1
                         from opr_operation oor
                        where oor.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED  -- 'OPST0400'
                          and oor.original_id = oo.id
                          and oor.is_reversal = com_api_type_pkg.TRUE
                      )
       --and oo.oper_type in (
       --                      cst_woo_const_pkg.OPERATION_PAYMENT_DD
       --                    , cst_woo_const_pkg.OPERATION_PAYMENT
       --                    )
    ;

    -- Create header:
    select
        xmlconcat(
            xmlelement("customer_number", t.customer_number)
          , xmlelement("attachments"
              , xmlelement("attachment" 
                  , xmlelement("attachment_path", STATEMENT_REPORT_PATH)
                  , xmlelement("attachment_name", STATEMENT_NAME_PREFIX || to_char(i_object_id) || '.pdf')
                )
            )
          , xmlelement("account_number", l_account_number)
          , xmlelement("account_currency", l_currency_name)   
          , xmlelement("start_date", to_char(l_cycle_start_date, 'dd/mm/yyyy'))          
          , xmlelement("end_date", to_char(l_cycle_end_date, 'dd/mm/yyyy'))          
          , xmlelement("invoice_date", to_char(t.invoice_date, 'dd/mm/yyyy'))
          , xmlelement("due_date", to_char(t.due_date, 'dd/mm/yyyy'))
          , xmlelement("settlement_date", get_due_day(l_account_id, l_cycle_start_date, t.due_date))
          , xmlelement("credit_limit", format_amount(nvl(l_credit_limit, 0), l_currency))
          , xmlelement("cash_limit", format_amount(nvl(l_cash_limit, 0), l_currency))
          , xmlelement("total_amount_due", format_amount(greatest(nvl(t.total_amount_due, 0) - l_total_real_payment + l_proj_intr_overdue + l_proj_intr_last_month + l_proj_intr_current, 0), l_currency))
          , xmlelement("min_amount_due", format_amount(nvl(t.min_amount_due, 0)  + l_proj_intr_overdue + l_proj_intr_last_month + l_proj_intr_current, l_currency))
          , xmlelement("overdue_balance", format_amount(nvl(l_overdue_balance, 0), l_currency))
          , xmlelement("overdue_intr_balance", format_amount(nvl(l_overdue_intr_balance, 0) + l_proj_intr_overdue, l_currency))
          , xmlelement("carry_over_last_month", format_amount(nvl(l_remaining_last_month, 0), l_currency))
          , xmlelement("billing_amt", format_amount(nvl(l_total_expense, 0) + l_proj_intr_last_month + l_proj_intr_current, l_currency))
          , xmlelement("advance_payment_amount", format_amount(nvl(l_advance_payment, 0), l_currency))
          , xmlelement("current_points", nvl(l_current_points, 0))   
          , xmlelement("earned_points", nvl(l_earned_points, 0))   
          , xmlelement("expire_points", nvl(l_expire_points, 0))   
          , xmlelement("hdr_logo_path", t.hdr_logo_path)   
          , xmlelement("kmart_logo_path", t.kmart_logo_path)
          , xmlelement("grab_logo_path", t.grab_logo_path)
          , xmlelement("promo_mess", t.promo_mess)   
          , xmlelement("imp_mess", t.imp_mess)   
          , xmlelement("post_addr", t.customer_address) 
          , xmlelement("customer_name", t.customer_name)               
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
               , get_bann_filename('STMT_ADS_KMART', l_lang) kmart_logo_path
               , get_bann_filename('STMT_ADS_GRAB', l_lang) grab_logo_path
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
            from crd_invoice_vw i
               , acc_account_vw a
               , prd_customer_vw c
           where i.id = l_invoice_id
             and a.id = i.account_id
             and c.id = a.customer_id
             and c.entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON,com_api_const_pkg.ENTITY_TYPE_COMPANY)
         ) t;

    -- Create details:
    begin
        select
            xmlelement("operations",
                xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_date", to_char(td.oper_date, 'yy.mm.dd'))
                      , xmlelement("posting_date", to_char(td.posting_date, 'yy.mm.dd'))
                      , xmlelement("oper_amount", format_amount(td.oper_amount, td.oper_currency))
                      , xmlelement("oper_currency", td.oper_currency_name)
                      , xmlelement("oper_currency_expo", td.oper_currency_expo)
                      , xmlelement("posting_currency", nvl(td.currency_name, l_currency))
                      , xmlelement("posting_currency_expo", td.currency_expo)
                      , xmlelement("posting_amount", format_amount(td.transaction_amount, l_currency))
                      , xmlelement("posting_amount_number", td.transaction_amount)
                      , xmlelement("discount", format_amount(td.discount_amount, l_currency))
                      , xmlelement("overseas", format_amount(td.overseas, mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR))
                      , xmlelement("interest_fee", format_amount((nvl(td.interest_amount, 0) + nvl(td.fee_amount, 0)), l_currency))
                      , xmlelement("interest_fee_number", (nvl(td.interest_amount, 0) + nvl(td.fee_amount, 0)))
                      , xmlelement("exchange_rate", td.exchange_rate)
                      , xmlelement("point_name", td.points_name)
                      , xmlelement("earned_point", td.earned_point)
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
                      , xmlelement("dpp_period", td.instalment_billed)
                      , xmlelement("dpp_count", td.instalment_total)
                      , xmlelement("remaining_balance", format_amount(td.remaining_balance, l_currency))
                      , xmlelement("oper_id", td.oper_id)
                      , xmlelement("card_mask", td.card_number)
                      , xmlelement("expo", nvl(td.currency_expo, l_currency_exp))
                   )
                   order by td.section_number, td.card_number, td.oper_id
                )
            )
         into l_detail   
         from (     
                select 1 as section_number
                     , l_account_number as account_number
                     , to_number(null) as oper_id
                     , to_date(null) as oper_date
                     , l_main_card_id as card_id
                     , 'Delinquency amount' as oper_type_name
                     , to_date(null) as posting_date
                     , to_char(null) as merchant_name
                     , to_char(null) as merchant_country
                     , to_char(null) as oper_currency
                     , to_char(null) as oper_currency_name
                     , to_number(null) as oper_currency_expo
                     , to_number(null) as oper_amount
                     , nvl(l_overdue_balance, 0) as transaction_amount
                     , to_number(null) as fee_amount
                     , (nvl(l_overdue_intr_balance, 0) + l_proj_intr_overdue) as interest_amount
                     , l_currency as currency
                     , l_currency_name as currency_name
                     , l_currency_exp as currency_expo
                     , to_number(null) as discount_amount
                     , to_number(null) as overseas
                     , to_number(null) as exchange_rate
                     , to_number(null) as earned_point
                     , to_char(null) as points_name
                     , to_number(null) as instalment_total
                     , to_number(null) as instalment_billed
                     , to_number(null) as remaining_balance
                     , lpad(substr(l_main_card_number, -4), 19, '****-') as card_number
                  from dual
                 where nvl(l_overdue_balance, 0) + nvl(l_overdue_intr_balance, 0) > 0
                 union all
                select 2 as section_number
                     , l_account_number as account_number
                     , to_number(null) as oper_id
                     , to_date(null) as oper_date
                     , l_main_card_id as card_id
                     , 'Non delinquency Overdue Amount' as oper_type_name
                     , to_date(null) as posting_date
                     , to_char(null) as merchant_name
                     , to_char(null) as merchant_country
                     , to_char(null) as oper_currency
                     , to_char(null) as oper_currency_name
                     , to_number(null) as oper_currency_expo
                     , to_number(null) as oper_amount
                     , l_remaining_last_month as transaction_amount
                     , to_number(null) as fee_amount
                     , (l_interest_amount - l_interest_new_debts - l_dpp_interest + l_proj_intr_last_month) as interest_amount --  l_overdue_intr_balance?
                                                                 -- DPP interest is not included into crd_debt_interest because it's fee
                     , l_currency as currency
                     , l_currency_name as currency_name
                     , l_currency_exp as currency_expo
                     , to_number(null) as discount_amount
                     , to_number(null) as overseas
                     , to_number(null) as exchange_rate
                     , to_number(null) as earned_point
                     , to_char(null) as points_name
                     , to_number(null) as instalment_total
                     , to_number(null) as instalment_billed
                     , to_number(null) as remaining_balance
                     , lpad(substr(l_main_card_number, -4), 19, '****-') as card_number
                  from dual
                 where l_remaining_last_month > 0
                 union all
                select 3 as section_number
                     , l_account_number as account_number
                     , t.oper_id
                     , t.oper_date
                     , nvl(t.card_id, l_main_card_id)
                     , t.oper_type_name
                     , t.posting_date
                     , trim(t.merchant_name) as merchant_name
                     , trim(t.merchant_country) as merchant_country
                     , t.oper_currency
                     , cc2.name as oper_currency_name
                     , cc2.exponent as oper_currency_expo
                     , t.oper_amount
                     , t.transaction_amount
                     , t.fee_amount
                     , t.interest_amount + t.project_interest_amount
                     , t.currency
                     , cc1.name as currency_name
                     , cc1.exponent as currency_expo
                     , t.discount_amount
                     , t.overseas
                     , t.exchange_rate
                     , t.earned_point
                     , case 
                           when nvl(t.earned_point, 0) != 0 
                           then get_lty_points_name(
                                    i_card_id   => t.card_id
                                  , i_date      => t.oper_date
                                )
                           else null
                       end as points_name
                     , t.instalment_total
                     , t.instalment_billed
                     , t.remaining_balance
                     , lpad(substr(nvl(icn.card_number, l_main_card_number), -4), 19, '****-') as card_number
                  from ( 
                        select oo.id as oper_id
                             , oo.oper_date
                             , d.card_id
                             , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119' 
                                    then com_api_dictionary_pkg.get_article_text(oo.oper_reason, l_lang) 
                                    when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                                    then 'DPP'
                                    else replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '')
                               end as oper_type_name
                             , d.posting_date
                             , oo.merchant_name
                             , oo.merchant_country
                             , oo.oper_currency
                             , oo.oper_amount
                             , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'  
                                    then d.fee_amount
                                    when d.dpp_id is not null 
                                    then 0
                                    else d.transaction_amount
                               end as transaction_amount
                             , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119' 
                                    then 0
                                    else d.fee_amount
                               end as fee_amount
                             , round(d.interest_amount) as interest_amount
                             , round(d.project_interest_amount) as project_interest_amount
                             , d.currency
                             , (select sum(-ae.balance_impact * ae.amount)
                                  from acc_entry ae
                                     , acc_macros am
                                 where ae.macros_id = am.id
                                   and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                                   and am.object_id = oo.id
                                   and am.macros_type_id in (7183, 7184, 7186, 7190) -- discount
                                   and ae.balance_impact = -1
                               ) as discount_amount
                             , case 
                                   when oo.oper_currency != l_currency
                                   then decode(
                                               oo.sttl_currency
                                             , mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
                                             , oo.sttl_amount
                                             , com_api_rate_pkg.convert_amount(
                                                   i_src_amount        => d.transaction_amount
                                                 , i_src_currency      => l_currency
                                                 , i_dst_currency      => mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
                                                 , i_rate_type         => l_rate_type
                                                 , i_inst_id           => l_inst_id
                                                 , i_eff_date          => oo.oper_date
                                                 , i_conversion_type   => com_api_const_pkg.CONVERSION_TYPE_BUYING
                                                 , i_mask_exception    => com_api_const_pkg.TRUE
                                                 , i_exception_value   => null
                                               )
                                         )
                                   else null 
                               end as overseas
                             , case 
                                   when oo.oper_currency != cst_woo_const_pkg.VNDONG --'704'
                                   then round(oo.sttl_amount/
                                                  com_api_currency_pkg.get_amount_str(
                                                      i_amount            => oo.oper_amount
                                                    , i_curr_code         => oo.oper_currency
                                                    , i_mask_curr_code    => com_api_const_pkg.TRUE
                                                    , i_format_mask       => null
                                                    , i_mask_error        => com_api_const_pkg.TRUE
                                        )
                                              , 2)
                                   else null 
                               end as exchange_rate
                             , (select sum(ae.balance_impact * ae.amount)
                                  from acc_entry ae
                                     , acc_macros am
                                 where ae.account_id = l_loyalty_account_id
                                   and ae.macros_id = am.id
                                   and ae.split_hash = l_split_hash
                                   and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                                   and am.object_id = d.oper_id
                                   and am.macros_type_id in (7003, 7004) -- loyalty points earn/spend
                               ) as earned_point
                             , case
                                   when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                                   then (select dppi.instalment_total
                                           from dpp_payment_plan dppi
                                          where dppi.reg_oper_id = oo.id
                                            and dppi.split_hash = l_split_hash)
                                   else null
                               end as instalment_total
                             , case
                                   when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                                   then (select dppi.instalment_billed
                                           from dpp_payment_plan dppi
                                          where dppi.reg_oper_id = oo.id
                                            and dppi.split_hash = l_split_hash)
                                   else null
                               end as instalment_billed
                             , case
                                   when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
                                   then (
                                         select sum(din.instalment_amount - nvl(din.interest_amount, 0))
                                          from dpp_payment_plan dpp
                                             , dpp_instalment din
                                         where dpp.id = din.dpp_id
                                            and dpp.reg_oper_id = oo.id
                                           and din.macros_id is null
                                           and dpp.split_hash = l_split_hash
                                            and din.split_hash = l_split_hash
                                        )
                                   else null
                               end as remaining_balance
                          from (
                                select cd.account_id
                                     , cd.card_id
                                     , cd.oper_id
                                     , cd.oper_type
                                     , cd.currency
                                     , sum(cd.transaction_amount) as transaction_amount
                                     , sum(cd.fee_amount) as fee_amount
                                     , sum(cd.interest_amount) as interest_amount
                                     , sum(
                                           get_project_interest(
                                               i_debt_id           => cd.id
                                             , i_invoice_id        => l_invoice_id
                                             , i_split_hash        => l_split_hash
                                             , i_end_date          => l_due_date
                                             , i_include_overdraft => com_api_type_pkg.TRUE
                                             , i_include_overdue   => com_api_type_pkg.TRUE
                                             , i_round             => 0
                                           )
                                       ) as project_interest_amount 
                                     , min(cd.posting_date) as posting_date
                                     , min(dpp.id) as dpp_id
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
                                             , case when d.macros_type_id in (1007, 1008, 1009, 1010, 7001, 7002, 7011, 7039, 7126, 7178, 7179, 7182)
                                                    then 0
                                                    when d.macros_type_id in (1003, 1006, 1022, 1024)
                                                    then -d.amount
                                                    else d.amount
                                               end as transaction_amount
                                             , case when d.macros_type_id in (1007, 1010, 7001, 7002, 7011, 7039, 7126)
                                                    then d.amount
                                                    when d.macros_type_id in (1008, 1009, 7178, 7179)
                                                    then -d.amount
                                                    else 0
                                               end as fee_amount
                                             , case when d.macros_type_id in (7182)
                                                    then d.amount
                                                    else (select nvl(sum(round(di.interest_amount)), 0)
                                                            from crd_debt_interest di
                                                           where di.debt_id = d.id
                                                             and di.is_charged = com_api_type_pkg.TRUE
                                                             and di.balance_date <= l_invoice_date
                                                             and di.invoice_id = l_invoice_id
                                                             and di.split_hash = l_split_hash)
                                               end as interest_amount
                                          from crd_debt d
                                         where d.status in (
                                                             crd_api_const_pkg.DEBT_STATUS_PAID
                                                           , crd_api_const_pkg.DEBT_STATUS_ACTIVE
                                                           )
                                       ) cd -- amounts from debts
                                     , dpp_payment_plan dpp
                                     , acc_macros acm
                                 where cd.id = cid.debt_id
                                   and cd.oper_id = acm.object_id(+)
                                   and acm.id = dpp.id(+)
                                   and acm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
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
                             , oo.oper_date
                             , cp.card_id
                             , replace(com_api_dictionary_pkg.get_article_text(oo.oper_type, l_lang), ' transaction', '') as oper_type_name
                             , cp.posting_date
                             , oo.merchant_name
                             , oo.merchant_country
                             , oo.oper_currency
                             , -oo.oper_amount as oper_amount
                             , (
                                select nvl(-sum(cdp.pay_amount), 0)
                                  from crd_debt_payment cdp
                                 where cdp.pay_id = cp.id
                                   and cdp.debt_id in (select debt_id 
                                                         from crd_invoice_debt cid 
                                                        where cid.invoice_id = l_invoice_id 
                                                          and cid.is_new = com_api_type_pkg.TRUE)
                               ) as account_amount
                             , 0 as fee_amount
                             , 0 as interest_amount
                             , 0 as project_interest_amount
                             , cp.currency as account_currency
                             , (select sum(-ae.balance_impact * ae.amount)
                                  from acc_entry ae
                                     , acc_macros am
                                 where ae.macros_id = am.id
                                   and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                                   and am.object_id = oo.id
                                   and am.macros_type_id in (7183, 7184, 7186, 7190) -- discount
                                   and ae.balance_impact = 1
                               ) as discount_amount
                             , null as overseas
                             , null as exchange_rate
                             , (select sum(ae.balance_impact * ae.amount)
                                  from acc_entry ae
                                     , acc_macros am
                                 where ae.account_id = l_loyalty_account_id
                                   and ae.macros_id = am.id
                                   and ae.split_hash = l_split_hash
                                   and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                                   and am.object_id = oo.id
                                   and am.macros_type_id in (7003, 7004) -- loyalty points earn/spend
                               ) as earned_point
                             , null as instalment_total
                             , null as instalment_billed
                             , null as remaining_balance
                          from crd_invoice_payment cip
                             , crd_payment cp
                             , opr_operation oo
                             , opr_participant iss
                         where cip.invoice_id = l_invoice_id
                           and cp.id = cip.pay_id
                           and cip.split_hash = l_split_hash
                           and cp.split_hash = l_split_hash
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
                --order by t.oper_id
                       --, t.posting_date
            ) td;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
            );
    end;
    
    begin    
        -- list of cards
        select
            xmlelement("cards",
                xmlagg(
                    xmlelement("card"
                      , xmlelement("account_number", account_number)
                      , xmlelement("card_type", card_type_descr)
                      , xmlelement("card_number", card_number)
                      , xmlelement("saving_account_number", saving_account_number)
                      , xmlelement("product_name", product_name)
                    )
                    order by seqnum
                )
            )
         into l_cards   
         from (     
                select a.account_number
                     , c.category as card_type
                     , get_article_text(c.category) as card_type_descr
                     , lpad(substr(c.card_number,-4), 19, '****-') as card_number
                     , asv.account_number as saving_account_number
                     , prd_ui_product_pkg.get_product_name(i_product_id => cn.product_id) as product_name
                     , row_number() over (order by 
                                          case 
                                              when c.category = 'CRCG0800' then 1
                                              when c.category = 'CRCG0600' then 2
                                              when c.category = 'CRCG0200' then 3
                                              when c.category = 'CRCG0900' then 4
                                          end) as seqnum
                  from acc_account a
                     , iss_card_vw c
                     , acc_account_object ao
                     , acc_account_object aosv
                     , acc_account asv
                     , prd_contract cn
                 where a.id = l_account_id
                   and a.id = ao.account_id
                   and asv.id = aosv.account_id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                   and ao.object_id = c.id
                   and aosv.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                   and aosv.object_id = c.id(+)
                   and asv.account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND -- 'ACTP0131'
                   and asv.status = 'ACSTACTV'
                   and c.contract_id = cn.id  
            ) t;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Cards not found'
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
            , l_cards
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();    

end run_report;

end cst_woo_stmt_api_report_pkg;
/
