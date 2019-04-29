create or replace package body cst_apc_crd_algo_proc_pkg as
/*********************************************************
*  Asia Pacific specific credit algorithms procedures and related API <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 20.12.2018 <br />
*  Module: CST_APC_CRD_ALGO_PROC_PKG <br />
*  @headcom
**********************************************************/

function get_skip_mad_date(
    i_account_id          in            com_api_type_pkg.t_account_id
) return date
is
    l_date                          date;
begin
    l_date :=
        com_api_flexible_data_pkg.get_flexible_value_date(
            i_field_name   => cst_apc_const_pkg.FLEX_FIELD_SKIP_MAD_DATE
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
        );

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_skip_mad_date(i_account_id => #1) >> [#2]'
      , i_env_param1 => i_account_id
      , i_env_param2 => l_date
    );

    return l_date;
end;

/*
 * Function returns an Extra MAD for the last invoice.
 */
function get_extra_mad(
    i_invoice_id          in            com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_money
is
    l_extra_mad                         com_api_type_pkg.t_money;
begin
    l_extra_mad :=
        com_api_flexible_data_pkg.get_flexible_value_number(
            i_field_name   => cst_apc_const_pkg.FLEX_FIELD_EXTRA_MAD
          , i_entity_type  => crd_api_const_pkg.ENTITY_TYPE_INVOICE
          , i_object_id    => i_invoice_id
        );

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_extra_mad(i_invoice_id => #1) >> [#2]'
      , i_env_param1 => i_invoice_id
      , i_env_param2 => l_extra_mad
    );

    return l_extra_mad;
end;

/*
 * Function calculates value of Extra MAD, it is applicable for MAD algotithm ALGORITHM_MAD_CALC_TWO_MADS only.
 * @param i_fee_type     - fee type of attribute (normal MAD or Extra MAD)
 * @param i_is_daily_mad - if true, then it is a call from calculation of Daily MAD
 */
function calculate_mad(
    i_account             in            acc_api_type_pkg.t_account_rec
  , i_eff_date            in            date
  , i_product_id          in            com_api_type_pkg.t_short_id
  , i_service_id          in            com_api_type_pkg.t_short_id
  , i_fee_type            in            com_api_type_pkg.t_dict_value
  , i_is_daily_mad        in            com_api_type_pkg.t_boolean
  , i_total_amount_due    in            com_api_type_pkg.t_money
) return com_api_type_pkg.t_money
is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_mad ';
    l_mad                               com_api_type_pkg.t_money;
    l_amount                            com_api_type_pkg.t_money;
    l_total_amount_due                  com_api_type_pkg.t_money;
    l_params                            com_api_type_pkg.t_param_tab;
    l_currency                          com_api_type_pkg.t_curr_code := i_account.currency;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_fee_type [#2], i_eff_date [#3], i_is_daily_mad [#4], i_total_amount_due[#5]'
      , i_env_param1 => i_account.account_id
      , i_env_param2 => i_fee_type
      , i_env_param3 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param4 => i_is_daily_mad
      , i_env_param5 => i_total_amount_due
    );

    l_total_amount_due :=
        coalesce(
            i_total_amount_due
          , crd_invoice_pkg.calculate_total_outstanding(
                i_account_id         => i_account.account_id
              , i_payoff_date        => i_eff_date
              , i_product_id         => i_product_id
              , i_service_id         => i_service_id
              , i_apply_exponent     => com_api_const_pkg.FALSE
            )
          , 0
        );

    rul_api_param_pkg.set_param(
        i_name       => 'IS_DAILY_MAD'
      , i_value      => nvl(i_is_daily_mad, com_api_const_pkg.FALSE)
      , io_params    => l_params
    );
    rul_api_param_pkg.set_param(
        i_name       => 'ACCOUNT_ID'
      , i_value      => i_account.account_id
      , io_params    => l_params
    );

    l_mad := 0;

    if  l_total_amount_due > crd_invoice_pkg.get_mad_threshold(
                                 i_account     => i_account
                               , i_product_id  => i_product_id
                               , i_service_id  => i_service_id
                               , i_params      => l_params
                               , i_eff_date    => i_eff_date
                             )
    then
        for b in (
            select b.balance_type
                 , b.amount
              from (select d.id
                      from crd_debt d
                     where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account.account_id
                       and d.split_hash = i_account.split_hash
                       and d.inst_id    = i_account.inst_id
                    union
                    select d.id
                      from crd_debt d
                     where decode(d.is_new, 1, d.account_id, null) = i_account.account_id
                       and d.account_id = i_account.account_id
                       and d.split_hash = i_account.split_hash
                       and d.inst_id    = i_account.inst_id
                   ) debt
                 , crd_debt_balance b
             where b.debt_id    = debt.id
               and b.split_hash = i_account.split_hash
               and b.balance_type not in (acc_api_const_pkg.BALANCE_TYPE_LEDGER)
        ) loop
            rul_api_param_pkg.set_param(
                i_name           => 'BALANCE_TYPE'
              , i_value          => b.balance_type
              , io_params        => l_params
            );
            prd_api_product_pkg.get_fee_amount(
                i_product_id     => i_product_id
              , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id      => i_account.account_id
              , i_fee_type       => i_fee_type
              , i_service_id     => i_service_id
              , i_params         => l_params
              , i_eff_date       => i_eff_date
              , i_split_hash     => i_account.split_hash
              , i_inst_id        => i_account.inst_id
              , i_base_amount    => b.amount
              , i_base_currency  => i_account.currency
              , io_fee_currency  => l_currency
              , o_fee_amount     => l_amount
              , i_mask_error     => com_api_const_pkg.FALSE
            );

            l_mad := l_mad + nvl(l_amount, 0);

            trc_log_pkg.debug(
                i_text       => 'balance_amount [#1], l_amount [#2], l_mad [#3]'
              , i_env_param1 => b.amount
              , i_env_param2 => l_amount
              , i_env_param3 => l_mad
            );
        end loop;

        l_mad :=
            crd_invoice_pkg.get_min_mad(
                i_mandatory_amount_due  => greatest(0, l_mad)
              , i_total_amount_due      => l_total_amount_due
              , i_account_id            => i_account.account_id
              , i_eff_date              => i_eff_date
              , i_currency              => i_account.currency
              , i_product_id            => i_product_id
              , i_service_id            => i_service_id
              , i_param_tab             => l_params
              , i_split_hash            => i_account.split_hash
              , i_inst_id               => i_account.inst_id
            );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_mad [#1]'
      , i_env_param1 => l_mad
    );

    return l_mad;
end calculate_mad;

/*
 * Procedure sets new skip MAD date.
 * @i_invoice_date - date is used for calculating the following invoice date I;
 * @i_cycle_type   - is used to calculate next date S from date I;
 * @i_skip_mad_window - window in days, it is used to set skip MAD date as (S - i_skip_mad_window).
 */
procedure set_skip_mad_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_invoice_date          in      date                             default null
  , i_cycle_type            in      com_api_type_pkg.t_dict_value
  , i_skip_mad_window       in      com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_skip_mad_date ';
    l_prev_date                     date;
    l_next_date                     date;
    l_date                          date;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || '<< i_account_id [#1], i_split_hash [#2], i_invoice_date [#3]'
                                    ||  ', i_cycle_type [#4], i_skip_mad_window [#5]'
      , i_env_param1  => i_account_id
      , i_env_param2  => i_split_hash
      , i_env_param3  => i_invoice_date
      , i_env_param4  => i_cycle_type
      , i_env_param5  => i_skip_mad_window
    );

    if i_invoice_date is not null then
        l_next_date := i_invoice_date;
    else
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type  => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_split_hash  => i_split_hash
          , i_add_counter => com_api_const_pkg.FALSE
          , o_prev_date   => l_prev_date
          , o_next_date   => l_next_date
        );
    end if;

    l_date :=
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_type   => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_split_hash   => i_split_hash
          , i_start_date   => l_next_date
          , i_raise_error  => com_api_type_pkg.TRUE
        );

    trc_log_pkg.debug(
        i_text        => 'Next invoice date is [#1], the following invoice date is [#2]'
      , i_env_param1  => l_next_date
      , i_env_param2  => l_date
    );

    if i_cycle_type is not null then
        l_date :=
            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_type   => i_cycle_type
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_split_hash   => i_split_hash
              , i_start_date   => l_date
              , i_raise_error  => com_api_type_pkg.TRUE
            );
    end if;

    trc_log_pkg.debug(
        i_text       => 'Base date for calculating skip MAD date is [#1]'
      , i_env_param1 => l_date
    );

    l_date := l_date - i_skip_mad_window;

    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name   => cst_apc_const_pkg.FLEX_FIELD_SKIP_MAD_DATE
      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id    => i_account_id
      , i_field_value  => l_date
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> [#1]'
      , i_env_param1 => l_date
    );
end set_skip_mad_date;

/*
 * Returns current Extra due date, it is applicable for MAD algotithm ALGORITHM_MAD_CALC_TWO_MADS only.
 */
function get_extra_due_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
) return date
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_extra_due_date ';
    l_prev_date                     date;
    l_next_date                     date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_split_hash [#2]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_split_hash
    );

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type   => cst_apc_const_pkg.EXTRA_DUE_DATE_CYCLE_TYPE
      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id    => i_account_id
      , i_split_hash   => i_split_hash
      , i_add_counter  => com_api_const_pkg.FALSE
      , o_prev_date    => l_prev_date
      , o_next_date    => l_next_date
    );
    trc_log_pkg.debug(
        i_text       => '[#3] cycle counter: l_prev_date [#1], l_next_date [#2]'
      , i_env_param1 => l_prev_date
      , i_env_param2 => l_next_date
      , i_env_param3 => cst_apc_const_pkg.EXTRA_DUE_DATE_CYCLE_TYPE
    );

    if l_prev_date is null then
        -- If Extra Due date cycle is not initiated,
        -- switch it (so its next date is calculated from next invoice date)
        l_product_id :=
            coalesce(
                i_product_id
              , prd_api_product_pkg.get_product_id(
                    i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => i_account_id
                )
            );
        l_service_id :=
            coalesce(
                i_service_id
              , prd_api_service_pkg.get_active_service_id(
                    i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id        => i_account_id
                  , i_attr_name        => null
                  , i_service_type_id  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                  , i_split_hash       => i_split_hash
                  , i_eff_date         => null
                  , i_mask_error       => com_api_const_pkg.TRUE
                )
            );
        switch_extra_due_cycle(
            i_account_id          => i_account_id
          , i_eff_date            => null
          , i_start_date          => null
          , i_split_hash          => i_split_hash
          , i_inst_id             => i_inst_id
          , i_product_id          => l_product_id
          , i_service_id          => l_service_id
          , o_new_extra_due_date  => l_next_date
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_next_date [#1]'
      , i_env_param1 => l_next_date
    );

    return l_next_date;
end; --get_extra_due_date

/*
 * Switch cycle of type EXTRA_DUE_DATE_CYCLE_TYPE either from date <i_start_date>,
 * or from next invoicing date if date <i_start_date> is not specified.
 */
procedure switch_extra_due_cycle(
    i_account_id          in            com_api_type_pkg.t_account_id
  , i_eff_date            in            date                             default null
  , i_start_date          in            date                             default null
  , i_split_hash          in            com_api_type_pkg.t_tiny_id
  , i_inst_id             in            com_api_type_pkg.t_inst_id
  , i_product_id          in            com_api_type_pkg.t_short_id
  , i_service_id          in            com_api_type_pkg.t_short_id
  , o_new_extra_due_date     out        date
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.switch_extra_due_cycle ';
    l_eff_date                          date;
    l_params                            com_api_type_pkg.t_param_tab;
    l_prev_date                         date;
    l_start_date                        date;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_split_hash [#2], i_eff_date [#3]'
                                   ||  ', i_start_date [#4], i_inst_id [#5]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_split_hash
      , i_env_param3 => i_eff_date
      , i_env_param4 => i_start_date
      , i_env_param5 => i_inst_id
    );

    l_eff_date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id));

    if i_start_date is not null then
        l_start_date := i_start_date;
    else
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type   => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_split_hash   => i_split_hash
          , i_add_counter  => com_api_const_pkg.FALSE
          , o_prev_date    => l_prev_date
          , o_next_date    => l_start_date
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_start_date [#1]'
      , i_env_param1 => l_start_date
    );

    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => cst_apc_const_pkg.EXTRA_DUE_DATE_CYCLE_TYPE
      , i_product_id        => i_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_service_id        => i_service_id
      , i_params            => l_params
      , i_start_date        => nvl(l_start_date, l_eff_date)
      , i_eff_date          => l_eff_date
      , o_new_finish_date   => o_new_extra_due_date
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> o_new_extra_due_date [#1]'
      , i_env_param1 => o_new_extra_due_date
    );
end switch_extra_due_cycle;

/*
 * Procedure calculates value of Daily MAD, it is applicable for MAD algotithm ALGORITHM_MAD_CALC_TWO_MADS only.
 */
procedure calculate_daily_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date                             default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_check_mad_algorithm   in      com_api_type_pkg.t_boolean       default null
  , i_use_rounding          in      com_api_type_pkg.t_boolean       default null
  , o_daily_mad                out  com_api_type_pkg.t_money
  , o_skip_mad                 out  com_api_type_pkg.t_boolean
  , o_extra_due_date           out  date
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_daily_mad ';
    l_mad_calc_algorithm            com_api_type_pkg.t_dict_value;
    l_invoice                       crd_api_type_pkg.t_invoice_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_eff_date                      date;
    l_skip_mad_date                 date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_params                        com_api_type_pkg.t_param_tab;
    l_is_overdue                    boolean;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_account_id [#1], i_eff_date [#2], i_product_id [#3]'
                                   ||  ', i_service_id [#4], i_check_mad_algorithm [#5], i_use_rounding [#6]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_eff_date
      , i_env_param3 => i_product_id
      , i_env_param4 => i_service_id
      , i_env_param5 => i_check_mad_algorithm
      , i_env_param6 => i_use_rounding
    );

    l_account    := acc_api_account_pkg.get_account(
                        i_account_id   => i_account_id
                      , i_mask_error   => com_api_const_pkg.FALSE
                    );

    l_eff_date   := coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_account.inst_id));

    trc_log_pkg.debug(
        i_text       => 'l_eff_date [#1]'
      , i_env_param1 => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );


    l_product_id := coalesce(
                        i_product_id
                      , prd_api_product_pkg.get_product_id(
                            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id    => l_account.account_id
                        )
                    );
    l_service_id := coalesce(
                        i_service_id
                      , crd_api_service_pkg.get_active_service(
                            i_account_id   => l_account.account_id
                          , i_eff_date     => l_eff_date
                          , i_split_hash   => l_account.split_hash
                          , i_mask_error   => com_api_const_pkg.FALSE
                        )
                    );

    if nvl(i_check_mad_algorithm, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
        l_mad_calc_algorithm :=
            prd_api_product_pkg.get_attr_value_char(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account.account_id
              , i_attr_name         => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
              , i_product_id        => l_product_id
              , i_service_id        => l_service_id
              , i_params            => l_params
              , i_eff_date          => l_eff_date
              , i_split_hash        => l_account.split_hash
              , i_inst_id           => l_account.inst_id
              , i_use_default_value => com_api_const_pkg.TRUE
              , i_default_value     => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
            );
        if l_mad_calc_algorithm != cst_apc_const_pkg.ALGORITHM_MAD_CALC_TWO_MADS then
            com_api_error_pkg.raise_error(
                i_error       => 'IMPOSSIBLE_TO_CALCULATE_DAILY_MAD'
              , i_env_param1  => l_mad_calc_algorithm
              , i_env_param2  => cst_apc_const_pkg.ALGORITHM_MAD_CALC_TWO_MADS
            );
        end if;
    end if;

    l_skip_mad_date := get_skip_mad_date(i_account_id => i_account_id);

    -- If condition of MAD skipping is NOT satisfied, MAD should be calculated (otherwise, it is zero)
    if l_eff_date <= l_skip_mad_date then
        o_skip_mad  := com_api_const_pkg.TRUE;
        o_daily_mad := 0;

    else
        o_skip_mad  := com_api_const_pkg.FALSE;

        -- Get date of cycle Extra due date (next_date value)
        o_extra_due_date :=
            get_extra_due_date(
                i_account_id   => l_account.account_id
              , i_split_hash   => l_account.split_hash
              , i_inst_id      => l_account.inst_id
              , i_product_id   => l_product_id
              , i_service_id   => l_service_id
            );
        l_invoice :=
            crd_invoice_pkg.get_last_invoice(
                i_account_id   => l_account.account_id
              , i_split_hash   => l_account.split_hash
              , i_mask_error   => com_api_const_pkg.TRUE
            );
        trc_log_pkg.debug(
            i_text       => 'Last invoice: due_date [#1], aging_period [#2]'
          , i_env_param1 => l_invoice.due_date
          , i_env_param2 => l_invoice.aging_period
        );

        l_is_overdue := nvl(l_invoice.aging_period, 0) > 0;

        if l_is_overdue then
            -- Both Due dates are expired, daily MAD is equal to total outstanding
            o_daily_mad :=
                crd_invoice_pkg.calculate_total_outstanding(
                    i_account_id      => l_account.account_id
                  , i_payoff_date     => l_eff_date
                  , i_product_id      => l_product_id
                  , i_service_id      => l_service_id
                  , i_apply_exponent  => com_api_const_pkg.FALSE
                );
            -- Extra due date (Due date 1) is:
        elsif l_eff_date <= o_extra_due_date and o_extra_due_date < l_invoice.due_date then
            -- a) not expired;
            o_daily_mad := get_extra_mad(i_invoice_id => l_invoice.id);

        elsif l_eff_date <= o_extra_due_date then
            -- b) already switched because of repayment of MAD1 (Extra MAD) or MAD2 (common MAD) in time,
            --    or satisfying of conditions for skipping MAD;
            -- c) empty when there is no invoices for the account yet;
            trc_log_pkg.debug(
                i_text       => 'Extra due date has NOT expired, calculate daily MAD using fee type [#1]'
              , i_env_param1 => crd_api_const_pkg.EXTRA_MAD_FEE_TYPE
            );
            o_daily_mad :=
                calculate_mad(
                    i_account          => l_account
                  , i_eff_date         => l_eff_date
                  , i_product_id       => l_product_id
                  , i_service_id       => l_service_id
                  , i_fee_type         => crd_api_const_pkg.EXTRA_MAD_FEE_TYPE
                  , i_is_daily_mad     => com_api_const_pkg.TRUE
                  , i_total_amount_due => null -- total outstanding will be used as a TAD
                );
        else
            -- Extra due date (Due date 1) has expired but Due date (Due date 2) hasn't expired,
            -- so Daily MAD should be equal to normal MAD (MAD 2)
            trc_log_pkg.debug(
                i_text       => 'Extra due date has expired, use MAD2 (common MAD) [#1] as a daily MAD'
              , i_env_param1 => l_invoice.min_amount_due
            );
            o_daily_mad := l_invoice.min_amount_due;
        end if;
    end if;

    if  nvl(i_use_rounding, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
        and o_daily_mad > 0 and not l_is_overdue
    then
        o_daily_mad :=
            crd_invoice_pkg.round_up_mad(
                i_account     => l_account
              , i_mad         => o_daily_mad
              , i_tad         => null -- total outstanding will be used as a TAD
              , i_eff_date    => l_eff_date
              , i_product_id  => l_product_id
              , i_service_id  => l_service_id
            );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> o_daily_mad [#1], o_extra_due_date [#2], o_skip_mad [#3]'
      , i_env_param1 => o_daily_mad
      , i_env_param2 => o_extra_due_date
      , i_env_param3 => o_skip_mad
    );
end calculate_daily_mad;

-- Algorithms procedures

/*
 * MAD modification procedure, it is intended to be used as an algorithm procedure
 * with MAD calculation algorithm ALGORITHM_MAD_CALC_TWO_MADS.
 */
procedure mad_algorithm_two_mad
is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.mad_algorithm_two_mad';
    l_account                           acc_api_type_pkg.t_account_rec;
    l_product_id                        com_api_type_pkg.t_short_id;
    l_service_id                        com_api_type_pkg.t_short_id;
    l_invoice_id                        com_api_type_pkg.t_medium_id;
    l_eff_date                          date;
    l_skip_mad                          com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_mad                               com_api_type_pkg.t_money;
    l_tad                               com_api_type_pkg.t_money;
    l_modified_mad                      com_api_type_pkg.t_money;
    l_extra_mad                         com_api_type_pkg.t_money;
    l_extra_due_date                    date;
    l_aging_period                      com_api_type_pkg.t_tiny_id;
    l_mad_threshold                     com_api_type_pkg.t_money;
    l_params                            com_api_type_pkg.t_param_tab;
begin
    l_account           := crd_api_algo_proc_pkg.get_account();
    l_product_id        := crd_api_algo_proc_pkg.get_param_num(i_name => 'PRODUCT_ID');
    l_service_id        := crd_api_algo_proc_pkg.get_param_num(i_name => 'SERVICE_ID');
    l_invoice_id        := crd_api_algo_proc_pkg.get_param_num(i_name => 'INVOICE_ID');
    l_mad               := crd_api_algo_proc_pkg.get_param_num(i_name => 'MAD_VALUE');
    l_tad               := crd_api_algo_proc_pkg.get_param_num(i_name => 'TAD_VALUE');
    l_aging_period      := crd_api_algo_proc_pkg.get_param_num(i_name => 'AGING_PERIOD');
    l_eff_date          := crd_api_algo_proc_pkg.get_param_date(i_name => 'EFF_DATE');

    -- If condition of MAD skipping is NOT satisfied, MAD should be calculated (otherwise, it is zero)
    if l_eff_date <= nvl(get_skip_mad_date(i_account_id => l_account.account_id), l_eff_date - 1) then
        l_skip_mad := com_api_const_pkg.TRUE;
    end if;

    if l_skip_mad = com_api_const_pkg.TRUE then
        l_extra_mad    := 0;
        l_modified_mad := 0; -- Set MAD = 0 if skip MAD condition is satisfied

    elsif nvl(l_aging_period, 0) > 0 then
        -- For an overdue account, consider that Extra MAD should not be calculated
        l_extra_mad := l_mad;

    else
        l_extra_mad := calculate_mad(
                           i_account          => acc_api_account_pkg.get_account(
                                                     i_account_id     => l_account.account_id
                                                   , i_mask_error     => com_api_const_pkg.FALSE
                                                 )
                         , i_eff_date         => l_eff_date
                         , i_product_id       => l_product_id
                         , i_service_id       => l_service_id
                         , i_fee_type         => crd_api_const_pkg.EXTRA_MAD_FEE_TYPE
                         , i_is_daily_mad     => com_api_const_pkg.FALSE
                         , i_total_amount_due => l_tad
                       );
    end if;

    l_modified_mad := nvl(l_modified_mad, l_mad);

    switch_extra_due_cycle(
        i_account_id           => l_account.account_id
      , i_eff_date             => l_eff_date
      , i_start_date           => case
                                      when l_skip_mad = com_api_const_pkg.TRUE
                                      then null       -- switch from next invoice date
                                      else l_eff_date -- switch from current invoice date
                                  end
      , i_split_hash           => l_account.split_hash
      , i_inst_id              => l_account.inst_id
      , i_product_id           => l_product_id
      , i_service_id           => l_service_id
      , o_new_extra_due_date   => l_extra_due_date
    );

    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name           => cst_apc_const_pkg.FLEX_FIELD_EXTRA_MAD
      , i_entity_type          => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id            => l_invoice_id
      , i_field_value          => l_extra_mad
    );
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name           => cst_apc_const_pkg.FLEX_FIELD_EXTRA_DUE_DATE
      , i_entity_type          => crd_api_const_pkg.ENTITY_TYPE_INVOICE
      , i_object_id            => l_invoice_id
      , i_field_value          => l_extra_due_date
    );

    if l_skip_mad = com_api_const_pkg.FALSE then
        l_mad_threshold :=
            crd_invoice_pkg.get_mad_threshold(
               i_account     => l_account
             , i_product_id  => l_product_id
             , i_service_id  => l_service_id
             , i_params      => l_params
             , i_eff_date    => l_eff_date
           );
        if l_mad_threshold < nvl(l_tad, 0) then
            l_modified_mad :=
                crd_invoice_pkg.get_min_mad(
                    i_mandatory_amount_due  => l_modified_mad
                  , i_total_amount_due      => l_tad
                  , i_account_id            => l_account.account_id
                  , i_eff_date              => l_eff_date
                  , i_currency              => l_account.currency
                  , i_product_id            => l_product_id
                  , i_service_id            => l_service_id
                  , i_param_tab             => l_params
                );
        else
            l_modified_mad := 0;
        end if;
    end if;

    -- Setting outgoing parameters
    crd_api_algo_proc_pkg.set_param(
        i_name   => 'MAD_VALUE'
      , i_value  => l_modified_mad
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> Extra MAD [#1] and Extra due date [#2] saved; l_skip_mad [#3]'
      , i_env_param1 => l_extra_mad
      , i_env_param2 => l_extra_due_date
      , i_env_param3 => case when l_skip_mad = com_api_const_pkg.TRUE then 'TRUE' else 'FALSE' end
    );
end mad_algorithm_two_mad;

/*
 * Implement specific actions for algorithm ALGORITHM_MAD_CALC_TWO_MADS:
 * a) if Extra MAD (MAD 1) is being repaid, make MAD equal to Extra MAD to force its repayment on checking overdue;
 * b) for overdue account, if total outstanding is repaid, register an event to allow reset of current aging period;
 * c) if daily MAD is repaid within a single day in specified time interval, check the account for skipping MAD.
 */
procedure check_mad_repayment
is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_mad_repayment ';
    l_account                   acc_api_type_pkg.t_account_rec;
    l_invoice                   crd_api_type_pkg.t_invoice_rec;
    l_eff_date                  date;
    l_product_id                com_api_type_pkg.t_short_id;
    l_service_id                com_api_type_pkg.t_short_id;
    l_payment_amount            com_api_type_pkg.t_money;
    l_mad                       com_api_type_pkg.t_money;
    l_daily_mad                 com_api_type_pkg.t_money;
    l_extra_due_date            date;
    l_next_date                 date;
    l_prev_date                 date;
    l_paid_amount               com_api_type_pkg.t_money;
    l_daily_paid_amount         com_api_type_pkg.t_money;
    l_skip_mad                  com_api_type_pkg.t_boolean;
    l_repayment_skip_mad_window com_api_type_pkg.t_tiny_id;

    -- Procedure change current invoice MAD with new value of <i_new_mad>.
    -- It is used in the case MAD1/MAD2 algorithm: "common" MAD (MAD 2) need make equal to Extra MAD (MAD 1)
    -- with appropriate changing field min_amount_due for all debt balances.
    -- Important(!): for calculation of Extra MAD (MAD 1) must be used the same balance types
    --               as for calculation of normal MAD (MAD 2) are used.
    procedure change_mad(
        i_invoice           in out nocopy crd_api_type_pkg.t_invoice_rec
      , i_new_mad           in            com_api_type_pkg.t_money
    ) is
        LOG_PREFIX               constant com_api_type_pkg.t_name :=
            lower($$PLSQL_UNIT) || '.check_mad_repayment->change_mad ';
        l_coefficient                     com_api_type_pkg.t_money;
        l_debt_balance_id_tab             com_api_type_pkg.t_number_tab;
        l_debt_intr_id_tab                com_api_type_pkg.t_number_tab;
        l_mad_tab                         com_api_type_pkg.t_money_tab;
        l_old_mad                         com_api_type_pkg.t_money;
        l_new_mad                         com_api_type_pkg.t_money;
    begin
        l_coefficient := i_new_mad / i_invoice.min_amount_due;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '<< i_new_mad [#1], l_coefficient [#2]'
          , i_env_param1 => i_new_mad
          , i_env_param2 => l_coefficient
        );

        update crd_invoice
           set min_amount_due = i_new_mad
         where id             = i_invoice.id
           and split_hash     = i_invoice.split_hash;

        trc_log_pkg.debug(
            i_text       => 'Invoice updated: #1'
          , i_env_param1 => sql%rowcount
        );

        select b.id
             , b.debt_intr_id
             , b.min_amount_due
          bulk collect into
               l_debt_balance_id_tab
             , l_debt_intr_id_tab
             , l_mad_tab
          from crd_debt         d
          join crd_debt_balance b    on b.debt_id    = d.id
                                    and b.split_hash = d.split_hash
         where d.account_id     = i_invoice.account_id
           and d.split_hash     = i_invoice.split_hash
           and d.id in (select i.debt_id
                          from crd_invoice_debt i
                         where i.invoice_id = i_invoice.id
                           and i.split_hash = i_invoice.split_hash)
           and b.min_amount_due > 0
         order by
               d.id
             , b.balance_type;

        -- Debug logging for debt_balance/interest changes
        if trc_config_pkg.get_trace_conf().trace_level >= trc_config_pkg.DEBUG then
            l_old_mad := 0;
            l_new_mad := 0;
            for i in 1 .. l_debt_balance_id_tab.count() loop
                l_old_mad := l_old_mad + l_mad_tab(i);
                for r in (select * from crd_debt_balance where id = l_debt_balance_id_tab(i)) loop
                    trc_log_pkg.debug(
                        i_text       => '1) crd_debt_balance.id [#1], balance_type [#2], old [#3] -> new [#4]'
                      , i_env_param1 => r.id
                      , i_env_param2 => r.balance_type
                      , i_env_param3 => round(r.min_amount_due, 4)
                      , i_env_param4 => round(l_coefficient * r.min_amount_due, 4)
                    );
                    l_new_mad := l_new_mad + l_coefficient * r.min_amount_due;
                end loop;
                for r in (select * from crd_debt_interest where id = l_debt_intr_id_tab(i)) loop
                    trc_log_pkg.debug(
                        i_text       => '2) crd_debt_interest.id [#1], balance_type [#2], old [#3] -> new [#4]'
                      , i_env_param1 => r.id
                      , i_env_param2 => r.balance_type
                      , i_env_param3 => round(r.min_amount_due, 4)
                      , i_env_param4 => round(l_coefficient * r.min_amount_due, 4)
                    );
                end loop;
            end loop;
            trc_log_pkg.debug(
                i_text       => 'Calculated old MAD [#1], new MAD [#2]'
              , i_env_param1 => l_old_mad
              , i_env_param2 => l_new_mad
            );
        end if;

        forall i in 1 .. l_debt_balance_id_tab.count()
            update crd_debt_balance
               set min_amount_due = l_coefficient * min_amount_due
             where id         = l_debt_balance_id_tab(i)
               and split_hash = i_invoice.split_hash;

        trc_log_pkg.debug(
            i_text       => 'crd_debt_balance: sql%rowcount = #1'
          , i_env_param1 => sql%rowcount
        );

        forall i in 1 .. l_debt_intr_id_tab.count()
            update crd_debt_interest
               set min_amount_due = l_coefficient * min_amount_due
             where id         = l_debt_intr_id_tab(i)
               and split_hash = i_invoice.split_hash;

        trc_log_pkg.debug(
            i_text       => 'crd_debt_interest: sql%rowcount = #1'
          , i_env_param1 => sql%rowcount
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> l_debt_balance_id_tab.count() = #1'
          , i_env_param1 => l_debt_balance_id_tab.count()
        );
    end change_mad;

begin
    l_account           := crd_api_algo_proc_pkg.get_account();
    l_product_id        := crd_api_algo_proc_pkg.get_param_num(i_name => 'PRODUCT_ID');
    l_service_id        := crd_api_algo_proc_pkg.get_param_num(i_name => 'SERVICE_ID');
    l_payment_amount    := crd_api_algo_proc_pkg.get_param_num(i_name => 'PAYMENT_AMOUNT');
    l_eff_date          := crd_api_algo_proc_pkg.get_param_date(i_name => 'EFF_DATE');

    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => l_account.account_id
          , i_split_hash   => l_account.split_hash
          , i_mask_error   => com_api_const_pkg.TRUE
        );
    trc_log_pkg.debug(
        i_text        => 'Last invoice: due_date [#1], aging_period [#2], min_amount_due [#3], invoice_date [#4]'
      , i_env_param1  => l_invoice.due_date
      , i_env_param2  => l_invoice.aging_period
      , i_env_param3  => l_invoice.min_amount_due
      , i_env_param4  => to_char(l_invoice.invoice_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
        i_account_id           => l_account.account_id
      , i_eff_date             => l_eff_date
      , i_product_id           => l_product_id
      , i_service_id           => l_service_id
      , i_check_mad_algorithm  => com_api_const_pkg.FALSE
      , o_daily_mad            => l_daily_mad
      , o_skip_mad             => l_skip_mad
      , o_extra_due_date       => l_extra_due_date
    );

    if l_skip_mad = com_api_const_pkg.FALSE then
        if l_invoice.id is not null then
            -- Calculate payment amount since last invoice date till date <l_eff_date>,
            -- and daily payment amount for date <l_eff_date>
            crd_payment_pkg.get_total_payments(
                i_account           => l_account
              , i_since_date        => l_invoice.invoice_date
              , i_payment_date      => l_eff_date
              , o_paid_amount       => l_paid_amount
              , o_daily_paid_amount => l_daily_paid_amount
            );
            -- Check repayment of total outstanding balance (total amount of active and new debts)
            if l_invoice.aging_period > 0 then
                l_mad :=
                    crd_invoice_pkg.calculate_total_outstanding(
                        i_account_id      => l_account.account_id
                      , i_payoff_date     => l_eff_date
                      , i_product_id      => l_product_id
                      , i_service_id      => l_service_id
                      , i_apply_exponent  => com_api_const_pkg.FALSE
                    );
                if  l_mad - l_payment_amount <= 0
                    and (l_extra_due_date < l_invoice.due_date or l_extra_due_date is null)
                then
                    -- If current payment repays current total outstanding,
                    -- switch Extra due date (DD1) to next invoicing period Extra due date (next DD1).
                    -- Thus, function calculate_daily_mad will use Extra MAD rate until next DD1.
                    cst_apc_crd_algo_proc_pkg.switch_extra_due_cycle(
                        i_account_id          => l_account.account_id
                      , i_eff_date            => l_eff_date
                      , i_split_hash          => l_account.split_hash
                      , i_inst_id             => l_account.inst_id
                      , i_product_id          => l_product_id
                      , i_service_id          => l_service_id
                      , o_new_extra_due_date  => l_extra_due_date
                    );
                end if;

            -- Check repayment of MAD1 (Extra MAD) or MAD2 (common MAD)
            elsif l_invoice.min_amount_due > 0 then -- just reassurance, normally MAD is always positive
                if l_eff_date <= l_extra_due_date and l_extra_due_date < l_invoice.due_date then
                    -- DD1 and DD2 (common Due date) are NOT expired
                    l_mad := cst_apc_crd_algo_proc_pkg.get_extra_mad(i_invoice_id => l_invoice.id);
                    -- Replace invoice MAD2 (common MAD) with MAD1 (= Extra MAD)
                    -- to avoid credit account overdue on check_overdue
                    if 0 < l_mad and l_mad <= l_paid_amount then
                        change_mad(
                            i_invoice  => l_invoice
                          , i_new_mad  => l_mad
                        );
                    end if;

                elsif l_eff_date <= l_invoice.due_date and l_invoice.min_amount_due <= l_paid_amount then
                    -- DD1 is expired, DD2 is NOT expired. Switch Extra due date if MAD2 is repaid:
                    -- 1) to force using Extra MAD rate for daily MAD calculation;
                    -- 2) for correct check of skipping MAD condition when
                    --    l_eff_date is in range [l_extra_due_date - REPAYMENT_SKIP_MAD_WINDOW_DAYS; DD2]
                    cst_apc_crd_algo_proc_pkg.switch_extra_due_cycle(
                        i_account_id           => l_account.account_id
                      , i_eff_date             => l_eff_date
                      , i_split_hash           => l_account.split_hash
                      , i_inst_id              => l_account.inst_id
                      , i_product_id           => l_product_id
                      , i_service_id           => l_service_id
                      , o_new_extra_due_date   => l_extra_due_date
                    );
                    -- After switch cycle get new daily MAD
                    cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
                        i_account_id           => l_account.account_id
                      , i_eff_date             => l_eff_date
                      , i_product_id           => l_product_id
                      , i_service_id           => l_service_id
                      , i_check_mad_algorithm  => com_api_const_pkg.FALSE
                      , o_daily_mad            => l_daily_mad
                      , o_skip_mad             => l_skip_mad
                      , o_extra_due_date       => l_extra_due_date
                    );
                end if;
            end if;

            l_mad := nvl(l_mad, crd_invoice_pkg.get_invoice(i_invoice_id => l_invoice.id).min_amount_due);
        end if;

        l_repayment_skip_mad_window :=
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id          => l_account.account_id
              , i_attr_name          => cst_apc_const_pkg.REPAYMENT_SKIP_MAD_WINDOW
              , i_service_id         => l_service_id
              , i_eff_date           => l_eff_date
              , i_split_hash         => l_account.split_hash
              , i_inst_id            => l_account.inst_id
              , i_use_default_value  => com_api_const_pkg.TRUE
              , i_default_value      => null
            );

        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type  => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => l_account.account_id
          , i_split_hash  => l_account.split_hash
          , i_add_counter => com_api_const_pkg.FALSE
          , o_prev_date   => l_prev_date
          , o_next_date   => l_next_date
        );

        if nvl(l_repayment_skip_mad_window, 0) <= 0 then
            trc_log_pkg.info(
                i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
              , i_env_param1 => 'skipping MAD window is not defined'
            );
        -- If current cycle MAD is paid and then a single repayment >= daily MAD is paid within "next invoice date - skip_mad_window" - next invoice date
        -- then condition of skipping MAD is satisfied, and set new Skip MAD date
        elsif l_eff_date between l_next_date - l_repayment_skip_mad_window
                             and l_next_date
            and l_invoice.aging_period   = 0
            and l_paid_amount           >= l_mad + round(l_daily_mad)
            and l_payment_amount        >= round(l_daily_mad)
        then
            cst_apc_crd_algo_proc_pkg.set_skip_mad_date(
                i_account_id       => l_account.account_id
              , i_split_hash       => l_account.split_hash
              , i_invoice_date     => l_next_date
              , i_cycle_type       => null
              , i_skip_mad_window  => l_repayment_skip_mad_window
            );
        end if;
    end if; -- l_skip_mad = com_api_const_pkg.FALSE

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>>'
    );
end check_mad_repayment;

/*
 * For algorithm MAD 1/MAD 2 it is necessary to repay entire current TAD to reset aging period,
 * that's why MAD_REPAYMENT_EVENT should be ignored, and aging period is reseted by TAD_REPAYMENT_EVENT.
 */
procedure check_reset_aging
is
begin
    crd_api_algo_proc_pkg.set_param(
        i_name   => 'REGISTER_EVENT'
      , i_value  => com_api_const_pkg.FALSE
    );
end check_reset_aging;

/*
 * MAD modification procedure, it is intended to be used as an algorithm procedure
 * with MAD calculation algorithm ALGORITHM_MAD_CALC_TWO_MADS on checking overdue.
 */
procedure recalculate_mad
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_invoice                       crd_api_type_pkg.t_invoice_rec;
    l_eff_date                      date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_mad                               com_api_type_pkg.t_money;
    l_tolerance_amount              com_api_type_pkg.t_money;
    l_total_payment_amount          com_api_type_pkg.t_money;
    l_extra_due_date                date;
    l_non_mad_paid                  com_api_type_pkg.t_money;

    procedure debug_logging is
        l_tad                           com_api_type_pkg.t_money := 0;
        l_non_mad_paid                  com_api_type_pkg.t_money := 0;
        l_interest_balance              com_api_type_pkg.t_money;
        l_interest_amount               com_api_type_pkg.t_money;
        l_fee_amount                    com_api_type_pkg.t_money;
    begin
        if trc_config_pkg.get_trace_conf().trace_level >= trc_config_pkg.DEBUG then
            -- Select fields for logging
            select interest_balance
                 , interest_amount
                 , fee_amount
              into l_interest_balance
                 , l_interest_amount
                 , l_fee_amount
              from crd_invoice
             where id         = l_invoice.id;

            trc_log_pkg.debug(
                i_text       => 'Moving TAD to overdue; TAD [#1], invoice_date [#2]'
                             || ', l_interest_balance [#3], l_interest_amount [#4], l_fee_amount [#5]'
              , i_env_param1 => l_invoice.total_amount_due
              , i_env_param2 => l_invoice.invoice_date
              , i_env_param3 => l_interest_balance
              , i_env_param4 => l_interest_amount
              , i_env_param5 => l_fee_amount
            );

            for r in (
                select 'invoiced' as is_invoiced
                     , row_number() over (order by inv.debt_id, i.balance_type) as rn
                     , inv.debt_id
                     , i.min_amount_due
                     , i.amount
                     , i.balance_type
                     , sum(nvl(p.pay_amount, 0)) as pay_amount
                     , sum(nvl(p.pay_mandatory_amount, 0)) as pay_mad
                  from      crd_invoice_debt  inv
                  join      crd_debt          d    on d.id           = inv.debt_id
                                                  and d.split_hash   = inv.split_hash
                  join      crd_debt_interest i    on i.id           = inv.debt_intr_id
                                                  and i.debt_id      = inv.debt_id
                                                  and i.split_hash   = inv.split_hash
                  left join crd_debt_payment  p    on p.debt_id      = inv.debt_id
                                                  and p.balance_type = i.balance_type
                                                  and p.eff_date    >= l_invoice.invoice_date
                                                  and p.split_hash   = inv.split_hash
                 where inv.invoice_id = l_invoice.id
                   and inv.split_hash = l_invoice.split_hash
                   and i.id between trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
                                and trunc(d.id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
                   and i.balance_date >= l_invoice.invoice_date
                   and nvl(i.is_waived, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
              group by inv.debt_id
                     , i.min_amount_due
                     , i.amount
                     , i.balance_type
             union all -- Get total paid amount of uninvoiced debts
                select 'not invoiced' as is_invoiced
                     , row_number() over (order by d.id, p.balance_type) as rn
                     , d.id
                     , 0
                     , 0
                     , p.balance_type
                     , sum(nvl(p.pay_amount, 0)) as pay_amount
                     , 0
                  from crd_debt         d
                  join crd_debt_payment p    on p.debt_id      = d.id
                                            and p.eff_date    >= l_invoice.invoice_date
                                            and p.split_hash   = d.split_hash
                 where decode(d.is_new, 1, d.account_id, null) = l_invoice.account_id
                   and d.account_id = l_invoice.account_id
                   and d.split_hash = l_invoice.split_hash
                   and d.inst_id    = l_invoice.inst_id
              group by d.id
                     , p.balance_type
              order by debt_id
                     , balance_type
            ) loop
                l_tad          := l_tad          + case when r.min_amount_due > 0 then r.amount     else 0 end;
                l_non_mad_paid := l_non_mad_paid + case when r.pay_mad = 0        then r.pay_amount else 0 end;
                trc_log_pkg.debug(
                    i_text       => '[' || r.is_invoiced || '][' || r.rn || '] debt_id [#1][#2]: '
                                 || 'amount [#3], mad [#4], pay_amount [#5], pay_mad [#6]'
                                 || '; l_tad [' || l_tad || '], l_non_mad_paid [' || l_non_mad_paid || ']'
                  , i_env_param1 => r.debt_id
                  , i_env_param2 => r.balance_type
                  , i_env_param3 => r.amount
                  , i_env_param4 => r.min_amount_due
                  , i_env_param5 => r.pay_amount
                  , i_env_param6 => r.pay_mad
                );
            end loop;
        end if;
    end debug_logging;

begin
    l_account              := crd_api_algo_proc_pkg.get_account();
    l_product_id           := crd_api_algo_proc_pkg.get_param_num(i_name => 'PRODUCT_ID');
    l_service_id           := crd_api_algo_proc_pkg.get_param_num(i_name => 'SERVICE_ID');
    l_mad                  := crd_api_algo_proc_pkg.get_param_num(i_name => 'MAD_VALUE');
    l_tolerance_amount     := crd_api_algo_proc_pkg.get_param_num(i_name => 'THRESHOLD_AMOUNT');
    l_total_payment_amount := crd_api_algo_proc_pkg.get_param_num(i_name => 'PAYMENT_AMOUNT');
    l_eff_date             := crd_api_algo_proc_pkg.get_param_date(i_name => 'EFF_DATE');

    if l_mad - l_tolerance_amount <= l_total_payment_amount then
        -- If MAD is paid, switch Extra due date (Due date 1), this way daily MAD will be calculated in real time
        -- (i. e., without using MAD1/MAD2) until this new Due date 1
        cst_apc_crd_algo_proc_pkg.switch_extra_due_cycle(
            i_account_id          => l_account.account_id
          , i_eff_date            => l_eff_date
          , i_split_hash          => l_account.split_hash
          , i_inst_id             => l_account.inst_id
          , i_product_id          => l_product_id
          , i_service_id          => l_service_id
          , o_new_extra_due_date  => l_extra_due_date
        );
    else
        -- If MAD is not entirely paid, make it equal to TAD on overdue

        l_invoice :=
            crd_invoice_pkg.get_invoice(
                i_invoice_id  => crd_api_algo_proc_pkg.get_param_num(i_name => 'INVOICE_ID')
              , i_mask_error  => com_api_const_pkg.FALSE
            );

        -- Calculate TAD that will be used as new MAD,
        -- it should include only those balances for which MAD percentage is specified.
        -- Also it should include amount of repaid debts not included into MAD for correct calculation
        -- of unpaid MAD amount [l_min_amount_due_unpaid] in procedure check_overdue.
        select sum(case when t.min_amount_due > 0 then t.amount     else 0 end) as tad
             , sum(case when t.pay_mad = 0        then t.pay_amount else 0 end) as non_mad_paid
          into l_mad
             , l_non_mad_paid
          from (
              select inv.debt_id
                   , i.min_amount_due
                   , i.amount
                   , i.balance_type
                   , sum(nvl(p.pay_amount, 0)) as pay_amount
                   , sum(nvl(p.pay_mandatory_amount, 0)) as pay_mad
                from      crd_invoice_debt  inv
                join      crd_debt          d    on d.id           = inv.debt_id
                                                and d.split_hash   = inv.split_hash
                join      crd_debt_interest i    on i.id           = inv.debt_intr_id
                                                and i.debt_id      = inv.debt_id
                                                and i.split_hash   = inv.split_hash
                left join crd_debt_payment  p    on p.debt_id      = inv.debt_id
                                                and p.balance_type = i.balance_type
                                                and p.eff_date    >= l_invoice.invoice_date
                                                and p.split_hash   = inv.split_hash
               where inv.invoice_id = l_invoice.id
                 and inv.split_hash = l_invoice.split_hash
                 and i.id between trunc(d.id, com_api_id_pkg.DAY_ROUNDING)
                              and trunc(d.id, com_api_id_pkg.DAY_ROUNDING) + com_api_id_pkg.DAY_TILL_ID
                 and i.balance_date >= l_invoice.invoice_date
                 and nvl(i.is_waived, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
            group by inv.debt_id
                   , i.min_amount_due
                   , i.amount
                   , i.balance_type
           union all -- Get total paid amount of uninvoiced debts
              select d.id
                   , 0
                   , 0
                   , p.balance_type
                   , sum(nvl(p.pay_amount, 0)) as pay_amount
                   , 0
                from crd_debt         d
                join crd_debt_payment p    on p.debt_id      = d.id
                                          and p.eff_date    >= l_invoice.invoice_date
                                          and p.split_hash   = d.split_hash
               where decode(d.is_new, 1, d.account_id, null) = l_invoice.account_id
                 and d.account_id = l_invoice.account_id
                 and d.split_hash = l_invoice.split_hash
                 and d.inst_id    = l_invoice.inst_id
            group by d.id
                   , p.balance_type
            order by debt_id
                   , balance_type
          ) t;

        debug_logging();

        trc_log_pkg.debug(
            i_text       => 'TAD of balance included into MAD [#1] + paid debt amount of balances not included into MAD [#2]'
          , i_env_param1 => l_mad
          , i_env_param2 => l_non_mad_paid
        );

        l_mad := l_mad + l_non_mad_paid;
    end if;

    -- Setting outgoing parameters
    crd_api_algo_proc_pkg.set_param(
        i_name   => 'MAD_VALUE'
      , i_value  => l_mad
    );
    crd_api_algo_proc_pkg.set_param(
        i_name   => 'MAKE_TAD_EQUAL_MAD'
      , i_value  => com_api_const_pkg.TRUE
    );
end recalculate_mad;

procedure get_additional_ui_info
is
    l_sql                       com_api_type_pkg.t_param_value;
    l_account                   acc_api_type_pkg.t_account_rec;
    l_eff_date                  date;
    l_product_id                com_api_type_pkg.t_short_id;
    l_service_id                com_api_type_pkg.t_short_id;
    l_daily_mad                 com_api_type_pkg.t_money;
    l_skip_mad                  com_api_type_pkg.t_boolean;
    l_extra_due_date            date;
    l_number_f_format           com_api_type_pkg.t_name;
    l_nls_numeric_characters    com_api_type_pkg.t_name;
    l_exponent                  com_api_type_pkg.t_tiny_id;
    l_lang                      com_api_type_pkg.t_dict_value := com_ui_user_env_pkg.get_user_lang();
begin
    l_account    := crd_api_algo_proc_pkg.get_account();
    l_product_id := crd_api_algo_proc_pkg.get_param_num(i_name => 'PRODUCT_ID');
    l_service_id := crd_api_algo_proc_pkg.get_param_num(i_name => 'SERVICE_ID');
    l_eff_date   := crd_api_algo_proc_pkg.get_param_date(i_name => 'EFF_DATE');

    -- Get Extra due date (Due date 1) and Daily MAD
    begin
        cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
            i_account_id           => l_account.account_id
          , i_eff_date             => l_eff_date
          , i_product_id           => l_product_id
          , i_service_id           => l_service_id
          , i_check_mad_algorithm  => com_api_const_pkg.FALSE
          , o_daily_mad            => l_daily_mad
          , o_skip_mad             => l_skip_mad
          , o_extra_due_date       => l_extra_due_date
        );
    exception
        when com_api_error_pkg.e_application_error then
            l_daily_mad := null;
    end;

    l_exponent               := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_account.currency);
    l_number_f_format        := com_api_const_pkg.get_number_f_format_with_sep();
    l_nls_numeric_characters := com_ui_user_env_pkg.get_nls_numeric_characters();

    l_sql := 'union all select ''' || cst_apc_const_pkg.EXTRA_DUE_DATE || ''', '''
          || com_api_i18n_pkg.get_text(
                 i_table_name  => 'prd_attribute'
               , i_column_name => 'label'
               , i_object_id   => prd_api_attribute_pkg.get_attribute(
                                      i_attr_name => cst_apc_const_pkg.EXTRA_DUE_DATE
                                  ).id
               , i_lang        => l_lang
             )
          || ''', '''
          || nvl(
                 to_char(l_extra_due_date, crd_api_const_pkg.DATE_FORMAT)
               , 'N/A'
             )
          || ''' from dual '
          || 'union all select ''' || crd_api_const_pkg.EXTRA_MANDATORY_AMOUNT_DUE || ''', '''
          || com_api_i18n_pkg.get_text(
                 i_table_name  => 'prd_attribute'
               , i_column_name => 'label'
               , i_object_id   => prd_api_attribute_pkg.get_attribute(
                                      i_attr_name => crd_api_const_pkg.EXTRA_MANDATORY_AMOUNT_DUE
                                  ).id
               , i_lang        => l_lang
             )
          || ''', '''
          || nvl(
                 to_char(
                     round(nvl(
                               cst_apc_crd_algo_proc_pkg.get_extra_mad(
                                   i_invoice_id => crd_invoice_pkg.get_last_invoice_id(
                                                       i_account_id  => l_account.account_id
                                                     , i_split_hash  => l_account.split_hash
                                                   )
                               )
                             , 0
                           )
                           /
                           power(10, l_exponent))
                   , l_number_f_format
                   , l_nls_numeric_characters
                 )
               , 'N/A'
             )
          || ''' from dual '
          || 'union all select ''' || cst_apc_const_pkg.DAILY_MAD_AMOUNT || ''', '''
          || com_api_label_pkg.get_label_text(
                 i_name => cst_apc_const_pkg.DAILY_MAD_AMOUNT
               , i_lang => l_lang
             )
          || ''', '''
          || nvl(
                 to_char(
                     round(l_daily_mad) / power(10, l_exponent)
                   , l_number_f_format
                   , l_nls_numeric_characters
                 )
               , 'N/A'
             )
          || ''' from dual '
          || 'union all select ''' || cst_apc_const_pkg.FLEX_FIELD_SKIP_MAD_DATE || ''', '''
          || com_api_label_pkg.get_label_text(
                 i_name => cst_apc_const_pkg.FLEX_FIELD_SKIP_MAD_DATE
               , i_lang => l_lang
             )
          || ''', '''
          || nvl(
                 to_char(
                     com_api_flexible_data_pkg.get_flexible_value_date(
                         i_field_name   => cst_apc_const_pkg.FLEX_FIELD_SKIP_MAD_DATE
                       , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       , i_object_id    => l_account.account_id
                     )
                   , com_api_const_pkg.DATE_FORMAT
                 )
               , 'N/A'
             )
          || ''' from dual '
    ;
    -- Setting outgoing parameters
    crd_api_algo_proc_pkg.set_param(
        i_name   => 'TEXT'
      , i_value  => l_sql
    );
end get_additional_ui_info;

end;
/
