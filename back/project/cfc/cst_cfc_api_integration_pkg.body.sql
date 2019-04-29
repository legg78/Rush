create or replace package body cst_cfc_api_integration_pkg is

procedure get_payment_due(
    i_short_card_mask   in     com_api_type_pkg.t_card_number
  , i_id_type           in     com_api_type_pkg.t_dict_value
  , i_id_series         in     com_api_type_pkg.t_name              default null
  , i_id_number         in     com_api_type_pkg.t_name
  , o_customer_id          out com_api_type_pkg.t_long_id
  , o_cardholder_name      out com_api_type_pkg.t_name
  , o_account_number       out com_api_type_pkg.t_account_number
  , o_currency             out com_api_type_pkg.t_curr_code
  , o_tad                  out com_api_type_pkg.t_money
  , o_last_payment_flag    out com_api_type_pkg.t_boolean
  , o_due_date             out date
  , o_daily_mad            out com_api_type_pkg.t_money
) is
    l_card_id                  com_api_type_pkg.t_medium_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_card_instance_id         com_api_type_pkg.t_medium_id;
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_account_id               com_api_type_pkg.t_account_id;
    l_service_id               com_api_type_pkg.t_short_id;
    l_product_id               com_api_type_pkg.t_short_id;
    l_sysdate                  date := com_api_sttl_day_pkg.get_sysdate();
    l_expir_date               date;
    l_invoice                  crd_api_type_pkg.t_invoice_rec;
    l_skip_mad                 com_api_type_pkg.t_boolean;
begin
    begin
        select cu.id
             , cu.split_hash
             , c.id
          into o_customer_id
             , l_split_hash
             , l_card_id
          from com_id_object o
             , prd_customer cu
             , iss_card c
             , iss_card_number n
         where o.id_type      = i_id_type
           and nvl(o.id_series, '*') = nvl(i_id_series, '*')
           and o.id_number    = i_id_number
           and o.entity_type  = com_api_const_pkg.ENTITY_TYPE_PERSON
           and cu.object_id   = o.object_id
           and cu.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
           and c.customer_id  = cu.id
           and n.card_id      = c.id
           and reverse(n.card_number) like reverse('%' || i_short_card_mask);
    exception
        when no_data_found then
            trc_log_pkg.warn(
                i_text       => 'CARD_NOT_FOUND'
            );
            return;
    end;

    begin
        select i.id
             , i.cardholder_name
             , i.expir_date
          into l_card_instance_id
             , o_cardholder_name
             , l_expir_date
          from iss_card_instance i
         where i.state      = iss_api_const_pkg.CARD_STATE_ACTIVE -- 'CSTE0200'
           and i.card_id    = l_card_id
           and i.split_hash = l_split_hash;
    exception
        when no_data_found then
             trc_log_pkg.warn(
                 i_text       => 'CARD_INSTANCE_NOT_FOUND'
               , i_env_param1 => i_short_card_mask
               , i_env_param2 => '%'
             );
    end;

    o_last_payment_flag :=
        case
            when trunc(l_expir_date) - trunc(l_sysdate) <= 30
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;

    select min(a.account_number) keep(dense_rank first order by a.id)
         , min(a.currency)       keep(dense_rank first order by a.id)
         , min(a.id)             keep(dense_rank first order by a.id)
      into o_account_number
        ,  o_currency
         , l_account_id
      from acc_account a
     where a.customer_id  = o_customer_id
       and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and exists(
               -- accounts with active credit service
               select 1
                 from prd_service_object_vw o
                    , prd_service_vw s
                where s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID  -- 10000403
                  and o.start_date      < l_sysdate
                  and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  and o.object_id       = a.id
                  and s.id              = o.service_id
                  and o.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE -- 'SROS0020'
                  and nvl(o.end_date, l_sysdate) >= l_sysdate
           );

    if l_account_id is null then
        trc_log_pkg.warn(
            i_text       => 'CUSTOMER_ACCOUNT_NOT_FOUND'
          , i_env_param1 => o_customer_id
          , i_env_param2 => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
          , i_env_param3 => '%'
        );
        return;
    end if;

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id  => l_account_id
          , i_eff_date    => l_sysdate
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account_id
          , i_eff_date    => l_sysdate
          , i_inst_id     => l_inst_id
        );

    o_tad := cst_cfc_com_pkg.get_total_debt(
             i_account_id   => l_account_id
        );
    begin
        cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
            i_account_id          => l_account_id
          , i_eff_date            => l_sysdate
          , i_product_id          => l_product_id
          , i_service_id          => l_service_id
          , i_check_mad_algorithm => com_api_const_pkg.TRUE
          , i_use_rounding        => com_api_const_pkg.TRUE
          , o_daily_mad           => o_daily_mad
          , o_skip_mad            => l_skip_mad
          , o_extra_due_date      => o_due_date
        );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error() not in ('IMPOSSIBLE_TO_CALCULATE_DAILY_MAD') then
                raise;
            end if;
    end;

    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type => 'ENTTACCT'
          , i_object_id   => l_account_id
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_invoice.id is null then
        -- If there is no invoice, o_due_date should be equal to next extra due
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type  => cst_apc_const_pkg.EXTRA_DUE_DATE_CYCLE_TYPE
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account_id
          , i_split_hash  => l_split_hash
          , i_add_counter => com_api_type_pkg.FALSE
          , o_prev_date   => l_invoice.invoice_date
          , o_next_date   => o_due_date
        );
    else
        o_due_date :=
            case
                when trunc(l_sysdate) between trunc(l_invoice.invoice_date)
                                          and trunc(o_due_date)               then o_due_date
                when trunc(l_sysdate) between trunc(l_invoice.invoice_date)
                                          and trunc(l_invoice.due_date)       then l_invoice.due_date
                                                                              else null
            end;

        if o_due_date is null then
            -- After DD2, if customer has not paid MAD2, extra due date is not set to next cycle value
            -- 24.05.2018 CFC confirmed to show closest DD2 for this case
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type  => crd_api_const_pkg.DUE_DATE_CYCLE_TYPE
              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => l_account_id
              , i_split_hash  => l_split_hash
              , i_add_counter => com_api_type_pkg.FALSE
              , o_prev_date   => o_due_date
              , o_next_date   => l_invoice.due_date
            );
        end if;
    end if;

    if com_api_holiday_pkg.is_holiday(
           i_day     => o_due_date
         , i_inst_id => l_inst_id
       ) = com_api_const_pkg.TRUE
    then
        o_due_date := com_api_holiday_pkg.get_next_working_day(
                          i_day     => o_due_date
                        , i_inst_id => l_inst_id
                      );
    end if;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        trc_log_pkg.warn(
            i_text => lower($$PLSQL_UNIT) || '.get_payment_due for card [#1] failed due to application error'
          , i_env_param1 => i_short_card_mask
        );
    when others then
        trc_log_pkg.warn(
            i_text => lower($$PLSQL_UNIT) || '.get_payment_due - unhandle exception - error code [#1]'
          , i_env_param1 => sqlerrm
        );
end get_payment_due;

procedure get_payment_due(
    i_account_number    in     com_api_type_pkg.t_account_number
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , o_customer_id          out com_api_type_pkg.t_long_id
  , o_customer_name        out com_api_type_pkg.t_full_desc
  , o_account_number       out com_api_type_pkg.t_account_number
  , o_currency             out com_api_type_pkg.t_curr_code
  , o_tad                  out com_api_type_pkg.t_money
  , o_last_payment_flag    out com_api_type_pkg.t_boolean
  , o_due_date             out date
  , o_daily_mad            out com_api_type_pkg.t_money
) is
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_account_id               com_api_type_pkg.t_account_id;
    l_customer_id              com_api_type_pkg.t_medium_id;
    l_service_id               com_api_type_pkg.t_short_id;
    l_product_id               com_api_type_pkg.t_short_id;
    l_sysdate                  date := com_api_sttl_day_pkg.get_sysdate();
    l_expir_date               date;
    l_invoice                  crd_api_type_pkg.t_invoice_rec;
    l_own_funds_balance        com_api_type_pkg.t_money;
    l_due_balance              com_api_type_pkg.t_money;
    l_accrued_interest         com_api_type_pkg.t_money;
    l_unsettled_amount         com_api_type_pkg.t_money;
    l_interest_tab             crd_api_type_pkg.t_interest_tab;
    l_skip_mad                 com_api_type_pkg.t_boolean;
begin
    begin
        select a.id
             , a.inst_id
             , a.split_hash
             , a.account_number
             , a.currency
             , a.customer_id
          into l_account_id
             , l_inst_id
             , l_split_hash
             , o_account_number
             , o_currency
             , l_customer_id
          from acc_account a
         where account_number = i_account_number
           and (i_inst_id is null or a.inst_id = i_inst_id);
    exception
        when no_data_found then
            trc_log_pkg.warn(
                i_text       => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => i_account_number
              , i_env_param2 => i_inst_id
            );
        return;
    end;

    select case
               when entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               then com_ui_person_pkg.get_person_name(i_person_id => object_id)
               when entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
               then com_ui_company_pkg.get_company_name(i_company_id => object_id)
               else null
           end
      into o_customer_name
      from prd_customer
     where id = l_customer_id;

     select max(ci.expir_date)
      into l_expir_date
      from acc_account_object ao
         , iss_card_instance  ci
     where ao.account_id    = l_account_id
       and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ci.card_id       = ao.object_id;

    o_last_payment_flag :=
        case
            when trunc(l_expir_date) - trunc(l_sysdate) <= 30
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;

    if l_account_id is null then
        trc_log_pkg.warn(
            i_text       => 'CUSTOMER_ACCOUNT_NOT_FOUND'
          , i_env_param1 => o_customer_id
          , i_env_param2 => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
          , i_env_param3 => '%'
        );
        return;
    end if;

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id  => l_account_id
          , i_eff_date    => l_sysdate
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account_id
          , i_eff_date    => l_sysdate
          , i_inst_id     => l_inst_id
        );

    o_tad := cst_cfc_com_pkg.get_total_debt(
                 i_account_id   => l_account_id
             );
    begin
        cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
            i_account_id          => l_account_id
          , i_eff_date            => l_sysdate
          , i_product_id          => l_product_id
          , i_service_id          => l_service_id
          , i_check_mad_algorithm => com_api_const_pkg.TRUE
          , i_use_rounding        => com_api_const_pkg.TRUE
          , o_daily_mad           => o_daily_mad
          , o_skip_mad            => l_skip_mad
          , o_extra_due_date      => o_due_date
        );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error() not in ('IMPOSSIBLE_TO_CALCULATE_DAILY_MAD') then
                raise;
            end if;
    end;

    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type => 'ENTTACCT'
          , i_object_id   => l_account_id
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_invoice.id is null then
        -- If there is no invoice, o_due_date should be equal to next extra due
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type  => cst_apc_const_pkg.EXTRA_DUE_DATE_CYCLE_TYPE
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account_id
          , i_split_hash  => l_split_hash
          , i_add_counter => com_api_type_pkg.FALSE
          , o_prev_date   => l_invoice.invoice_date
          , o_next_date   => o_due_date
        );
    else
        o_due_date :=
            case
                when trunc(l_sysdate) between trunc(l_invoice.invoice_date)
                                          and trunc(o_due_date)               then o_due_date
                when trunc(l_sysdate) between trunc(l_invoice.invoice_date)
                                          and trunc(l_invoice.due_date)       then l_invoice.due_date
                                                                              else null
            end;

        if o_due_date is null then
            -- After DD2, if customer has not paid MAD2, extra due date is not set to next cycle value
            -- 24.05.2018 CFC confirmed to show closest DD2 for this case
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type  => crd_api_const_pkg.DUE_DATE_CYCLE_TYPE
              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => l_account_id
              , i_split_hash  => l_split_hash
              , i_add_counter => com_api_type_pkg.FALSE
              , o_prev_date   => o_due_date
              , o_next_date   => l_invoice.due_date
            );
        end if;
    end if;

    if  com_api_holiday_pkg.is_holiday(
            i_day     => o_due_date
          , i_inst_id => l_inst_id
        ) = com_api_const_pkg.TRUE
    then
        o_due_date := com_api_holiday_pkg.get_next_working_day(
                          i_day     => o_due_date
                        , i_inst_id => l_inst_id
                      );
    end if;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        trc_log_pkg.warn(
            i_text => lower($$PLSQL_UNIT) || '.get_payment_due for account [#1] failed due to application error'
          , i_env_param1 => i_account_number
        );
    when others then
        trc_log_pkg.warn(
            i_text => lower($$PLSQL_UNIT) || '.get_payment_due - unhandle exception - error code [#1]'
          , i_env_param1 => sqlerrm
        );
end get_payment_due;

end;
/
