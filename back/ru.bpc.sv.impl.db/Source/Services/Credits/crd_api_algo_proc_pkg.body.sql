create or replace package body crd_api_algo_proc_pkg is
/*********************************************************
*  Credit algorithms procedures and related API <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 20.12.2018 <br />
*  Module: CRD_API_ALGO_PROC_PKG <br />
*  @headcom
**********************************************************/

g_params                com_api_type_pkg.t_param_tab;
g_account               acc_api_type_pkg.t_account_rec;

procedure clear_shared_data is
begin
    g_account := null;

    rul_api_param_pkg.clear_params(
        io_params  => g_params
    );
end;

function get_param_num(
    i_name                    in            com_api_type_pkg.t_name
  , i_mask_error              in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value             in            com_api_type_pkg.t_name       default null
) return number is
begin
    return rul_api_param_pkg.get_param_num(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_date(
    i_name                    in            com_api_type_pkg.t_name
  , i_mask_error              in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value             in            com_api_type_pkg.t_name       default null
) return date is
begin
    return rul_api_param_pkg.get_param_date(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_char(
    i_name                    in            com_api_type_pkg.t_name
  , i_mask_error              in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value             in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_param_value is
begin
    return rul_api_param_pkg.get_param_char(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

procedure set_param(
    i_name                    in            com_api_type_pkg.t_name
  , i_value                   in            com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                    in            com_api_type_pkg.t_name
  , i_value                   in            number
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                    in            com_api_type_pkg.t_name
  , i_value                   in            date
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

function get_account return acc_api_type_pkg.t_account_rec
is
begin
    return g_account;
end;

procedure set_common_parameters(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
) is
begin
    g_account :=
        acc_api_account_pkg.get_account(
            i_account_id  => i_account_id
          , i_mask_error  => com_api_const_pkg.FALSE
        );

    set_param(
        i_name   => 'EFF_DATE'
      , i_value  => coalesce(
                        i_eff_date
                      , com_api_sttl_day_pkg.get_calc_date(
                            i_inst_id => g_account.inst_id
                        )
                    )
    );

    set_param(
        i_name   => 'PRODUCT_ID'
      , i_value  => coalesce(
                        i_product_id
                      , prd_api_product_pkg.get_product_id(
                            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id    => g_account.account_id
                        )
                    )
    );

    set_param(
        i_name   => 'SERVICE_ID'
      , i_value  => coalesce(
                        i_service_id
                      , crd_api_service_pkg.get_active_service(
                            i_account_id   => g_account.account_id
                          , i_eff_date     => get_param_date('EFF_DATE')
                          , i_split_hash   => g_account.split_hash
                          , i_mask_error   => com_api_const_pkg.FALSE
                        )
                    )
    );
end set_common_parameters;

/*
 * Modification of MAD and/or additional actions when creating an invoice.
 */
procedure process_mad_when_invoice(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
  , i_invoice_id              in            com_api_type_pkg.t_medium_id
  , i_aging_period            in            com_api_type_pkg.t_tiny_id
  , i_mad                     in            com_api_type_pkg.t_money
  , i_tad                     in            com_api_type_pkg.t_money
  , i_overdraft_balance       in            com_api_type_pkg.t_money            default null
  , o_mad                        out        com_api_type_pkg.t_money
) is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_mad_when_invoice';
    l_mad_calc_algorithm                    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_account_id [#1], i_invoice_id [#2], i_mad [#3], i_tad [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_invoice_id
      , i_env_param3 => i_mad
      , i_env_param4 => i_tad
    );

    clear_shared_data();

    g_account :=
        acc_api_account_pkg.get_account(
            i_account_id        => i_account_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    l_mad_calc_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => i_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
          , i_params            => g_params
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => g_account.split_hash
          , i_inst_id           => g_account.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
        );

    -- Setting parameters that may be used both     in user-exit modify_mandatory_amount_due() and an algorithm procedure
    set_param(
        i_name   => 'INVOICE_ID'
      , i_value  => i_invoice_id
    );

    if l_mad_calc_algorithm is null or l_mad_calc_algorithm = crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT then
        cst_api_credit_pkg.modify_mandatory_amount_due(
            i_mandatory_amount_due  => i_mad
          , i_total_amount_due      => i_tad
          , i_product_id            => i_product_id
          , i_account_id            => i_account_id
          , i_currency              => g_account.currency
          , i_service_id            => i_service_id
          , i_eff_date              => i_eff_date
          , i_overdraft_balance     => i_overdraft_balance
          , i_aging_period          => i_aging_period
          , o_modified_amount_due   => o_mad
        );
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': preparing incoming parameters for MAD algorithm...'
        );

        set_common_parameters(
            i_account_id  => i_account_id
          , i_product_id  => i_product_id
          , i_service_id  => i_service_id
          , i_eff_date    => i_eff_date
        );

        set_param(
            i_name   => 'AGING_PERIOD'
          , i_value  => i_aging_period
        );
        set_param(
            i_name   => 'MAD_VALUE'
          , i_value  => i_mad
        );
        set_param(
            i_name   => 'TAD_VALUE'
          , i_value  => i_tad
        );
        set_param(
            i_name   => 'OVERDRAFT_BALANCE'
          , i_value  => i_overdraft_balance
        );

        rul_api_algorithm_pkg.execute_algorithm(
            i_algorithm    => l_mad_calc_algorithm
          , i_entry_point  => crd_api_const_pkg.ALGO_ENTR_PT_MODIFY_MAD_INV_CR
        );

        o_mad := nvl(get_param_num(i_name => 'MAD_VALUE'), i_mad);
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> i_mad [#2] (source) -> o_mad [#1] (modified)'
      , i_env_param1 => o_mad
      , i_env_param2 => i_mad
    );
end process_mad_when_invoice;

/*
 * Modification of MAD and/or additional actions on processing (applying) a payment due to specific MAD algorithm.
 */
procedure process_mad_when_payment(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_split_hash              in            com_api_type_pkg.t_tiny_id
  , i_inst_id                 in            com_api_type_pkg.t_inst_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
  , i_payment_amount          in            com_api_type_pkg.t_money
) is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_mad_when_payment';
    l_mad_calc_algorithm                    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_account_id [#1], i_eff_date [#2], i_payment_amount [#3]'
                                   || ', i_product_id [#4], i_service_id [#5]'
      , i_env_param1 => i_account_id
      , i_env_param2 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3 => i_payment_amount
      , i_env_param4 => i_product_id
      , i_env_param5 => i_service_id
    );

    clear_shared_data();

    l_mad_calc_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => i_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
          , i_params            => g_params
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => i_split_hash
          , i_inst_id           => i_inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
        );

    if l_mad_calc_algorithm is null or l_mad_calc_algorithm = crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT then
        null;
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': preparing incoming parameters for MAD algorithm...'
        );

        set_common_parameters(
            i_account_id  => i_account_id
          , i_product_id  => i_product_id
          , i_service_id  => i_service_id
          , i_eff_date    => i_eff_date
        );

        set_param(
            i_name   => 'PAYMENT_AMOUNT'
          , i_value  => i_payment_amount
        );

        rul_api_algorithm_pkg.execute_algorithm(
            i_algorithm    => l_mad_calc_algorithm
          , i_entry_point  => crd_api_const_pkg.ALGO_ENTR_PT_CHECK_MAD_REPAYM
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >>'
    );
end process_mad_when_payment;

/*
 * Checking possibility of resetting aging on executing rule <Reset aging period> due to specific MAD algorithm.
 */
function check_reset_aging(
    io_invoice                in out nocopy crd_api_type_pkg.t_invoice_rec
  , i_eff_date                in            date
  , i_event_type              in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_reset_aging';
    l_mad_calc_algorithm                    com_api_type_pkg.t_dict_value;
    l_result                                com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << account_id [#1], i_eff_date [#2], i_event_type [#3]'
                                   || ', aging_period [#4]'
      , i_env_param1 => io_invoice.account_id
      , i_env_param2 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3 => i_event_type
      , i_env_param4 => io_invoice.aging_period
    );

    clear_shared_data();

    if io_invoice.aging_period > 0 and i_event_type = crd_api_const_pkg.MAD_REPAYMENT_EVENT
    then
        l_mad_calc_algorithm :=
            prd_api_product_pkg.get_attr_value_char(
                i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id          => io_invoice.account_id
              , i_attr_name          => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
              , i_eff_date           => i_eff_date
              , i_split_hash         => io_invoice.split_hash
              , i_inst_id            => io_invoice.inst_id
              , i_use_default_value  => com_api_const_pkg.TRUE
              , i_default_value      => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
            );

        if     l_mad_calc_algorithm is null
            or l_mad_calc_algorithm = crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
        then
            -- Always allow to reset of aging period for default MAD calculation algorithm
            l_result := com_api_const_pkg.TRUE;

        else
            rul_api_algorithm_pkg.execute_algorithm(
                i_algorithm    => l_mad_calc_algorithm
              , i_entry_point  => crd_api_const_pkg.ALGO_ENTR_PT_CHECK_RESET_AGING
            );

            l_result := nvl(get_param_num(i_name => 'REGISTER_EVENT'), com_api_const_pkg.TRUE);
        end if;

    else
        l_result := com_api_const_pkg.TRUE;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> [#1]'
      , i_env_param1 => case when l_result = com_api_const_pkg.TRUE then 'TRUE' else 'FALSE' end
    );

    return l_result;
end check_reset_aging;

/*
 * Modification of MAD and/or additional actions on checking the overdue due to specific MAD algorithm.
 */
procedure process_mad_when_overdue(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
  , i_invoice_id              in            com_api_type_pkg.t_medium_id
  , i_total_payment_amount    in            com_api_type_pkg.t_money
  , i_tolerance_amount        in            com_api_type_pkg.t_money
  , io_mad                    in out        com_api_type_pkg.t_money
  , o_make_tad_equal_mad         out        com_api_type_pkg.t_boolean
) is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_mad_when_overdue';
    l_mad_calc_algorithm                    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_account_id [#1], i_invoice_id [#2], io_mad [#5]'
                                   || ', i_total_payment_amount [#3], i_tolerance_amount [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_invoice_id
      , i_env_param3 => i_total_payment_amount
      , i_env_param4 => i_tolerance_amount
      , i_env_param5 => io_mad
    );

    clear_shared_data();

    g_account :=
        acc_api_account_pkg.get_account(
            i_account_id        => i_account_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    l_mad_calc_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => i_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
          , i_params            => g_params
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => g_account.split_hash
          , i_inst_id           => g_account.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
        );

    if l_mad_calc_algorithm is null or l_mad_calc_algorithm = crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT then
        null;
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': preparing incoming parameters for MAD algorithm...'
        );

        set_common_parameters(
            i_account_id  => i_account_id
          , i_product_id  => i_product_id
          , i_service_id  => i_service_id
          , i_eff_date    => i_eff_date
        );

        set_param(
            i_name   => 'INVOICE_ID'
          , i_value  => i_invoice_id
        );
        set_param(
            i_name   => 'MAD_VALUE'
          , i_value  => io_mad
        );
        set_param(
            i_name   => 'PAYMENT_AMOUNT'
          , i_value  => i_total_payment_amount
        );
        set_param(
            i_name   => 'THRESHOLD_AMOUNT'
          , i_value  => i_tolerance_amount
        );

        rul_api_algorithm_pkg.execute_algorithm(
            i_algorithm    => l_mad_calc_algorithm
          , i_entry_point  => crd_api_const_pkg.ALGO_ENTR_PT_CHECKING_OVERDUE
        );

        io_mad               := nvl(
                                    get_param_num(i_name => 'MAD_VALUE')
                                  , io_mad
                                );
        o_make_tad_equal_mad := nvl(
                                    get_param_num(i_name => 'MAKE_TAD_EQUAL_MAD')
                                  , com_api_const_pkg.FALSE
                                );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> io_mad [#1], o_make_tad_equal_mad [#2]'
      , i_env_param1 => io_mad
      , i_env_param2 => o_make_tad_equal_mad
    );
end process_mad_when_overdue;

/*
 * Additional information for using on GUI (form Account, tab Credit details) due to specific MAD algorithm.
 */
function get_additional_ui_info(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
) return com_api_type_pkg.t_param_value
is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_additional_ui_info';
    l_mad_calc_algorithm                    com_api_type_pkg.t_dict_value;
    l_add_sql                               com_api_type_pkg.t_param_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_account_id [#1], i_eff_date [#2], i_product_id [#3], i_service_id [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3 => i_product_id
      , i_env_param4 => i_service_id
    );

    clear_shared_data();

    g_account :=
        acc_api_account_pkg.get_account(
            i_account_id        => i_account_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    l_mad_calc_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => i_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.MAD_CALCULATION_ALGORITHM
          , i_params            => g_params
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => g_account.split_hash
          , i_inst_id           => g_account.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT
        );

    if l_mad_calc_algorithm is null or l_mad_calc_algorithm = crd_api_const_pkg.ALGORITHM_MAD_CALC_DEFAULT then
        null;
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': preparing incoming parameters for getting additional UI info...'
        );

        set_common_parameters(
            i_account_id  => i_account_id
          , i_product_id  => i_product_id
          , i_service_id  => i_service_id
          , i_eff_date    => i_eff_date
        );

        begin
            rul_api_algorithm_pkg.execute_algorithm(
                i_algorithm    => l_mad_calc_algorithm
              , i_entry_point  => crd_api_const_pkg.ALGO_ENTR_PT_GETTING_UI_INFO
            );

            l_add_sql := get_param_char(i_name => 'TEXT');
        exception
            when com_api_error_pkg.e_value_error then
                trc_log_pkg.error(
                    i_text        => 'PARAMETER_STRING_IS_TOO_LONG'
                  , i_env_param1  => 'TEXT'
                  , i_env_param2  => 'get_additional_ui_info'
                );
        end;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> SQL TEXT length is [#1]'
      , i_env_param1 => length(l_add_sql)
    );

    return l_add_sql;

end get_additional_ui_info;

-- Algorithms procedures

/*
 * MAD modification procedure, it is intended to be used as a algorithm procedure
 * with MAD calculation algorithm ALGORITHM_MAD_CALC_THRESHOLD.
 */
procedure mad_algorithm_threshold
is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.mad_algorithm_threshold';
    l_account                           acc_api_type_pkg.t_account_rec;
    l_product_id                        com_api_type_pkg.t_short_id;
    l_service_id                        com_api_type_pkg.t_short_id;
    l_eff_date                          date;
    l_overdraft_balance                 com_api_type_pkg.t_money;
    l_mad                               com_api_type_pkg.t_money;
    l_tad                               com_api_type_pkg.t_money;
    l_aging_period                      com_api_type_pkg.t_tiny_id;
    l_mad_calc_threshold                com_api_type_pkg.t_money    := 0;
    l_mad_calc_extra                    com_api_type_pkg.t_money    := 0;
    l_balance_total                     com_api_type_pkg.t_money    := 0;
    l_used_condition                    com_api_type_pkg.t_name;
    l_params                            com_api_type_pkg.t_param_tab;
begin
    l_account           := get_account();
    l_product_id        := get_param_num(i_name => 'PRODUCT_ID');
    l_service_id        := get_param_num(i_name => 'SERVICE_ID');
    l_overdraft_balance := get_param_num(i_name => 'OVERDRAFT_BALANCE');
    l_mad               := get_param_num(i_name => 'MAD_VALUE');
    l_tad               := get_param_num(i_name => 'TAD_VALUE');
    l_aging_period      := get_param_num(i_name => 'AGING_PERIOD');
    l_eff_date          := get_param_date(i_name => 'EFF_DATE');

    l_mad_calc_threshold :=
       crd_invoice_pkg.get_mad_threshold(
           i_account     => l_account
         , i_product_id  => l_product_id
         , i_service_id  => l_service_id
         , i_params      => l_params
         , i_eff_date    => l_eff_date
       );

    select nvl(sum(b.amount), 0)
      into l_balance_total
      from (select d.id
              from crd_debt d
             where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account.account_id
               and d.split_hash     = l_account.split_hash
               and d.inst_id        = l_account.inst_id
            union
            select d.id
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = l_account.account_id
               and d.account_id     = l_account.account_id
               and d.split_hash     = l_account.split_hash
               and d.inst_id        = l_account.inst_id
           ) debt
         , crd_debt_balance b
     where b.debt_id        = debt.id
       and b.split_hash     = l_account.split_hash
       and b.balance_type   in (crd_api_const_pkg.BALANCE_TYPE_INTEREST
                              , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                              , crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT
                              , crd_api_const_pkg.BALANCE_TYPE_PENALTY
                              , acc_api_const_pkg.BALANCE_TYPE_FEES);

    prd_api_product_pkg.get_fee_amount(
        i_product_id         => l_product_id
      , i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id          => l_account.account_id
      , i_fee_type           => crd_api_const_pkg.EXTRA_MAD_FEE_TYPE
      , i_params             => l_params
      , i_service_id         => l_service_id
      , i_eff_date           => l_eff_date
      , i_split_hash         => l_account.split_hash
      , i_inst_id            => l_account.inst_id
      , i_base_amount        => l_balance_total
      , i_base_currency      => l_account.currency
      , io_fee_currency      => l_account.currency
      , o_fee_amount         => l_mad_calc_extra
      , i_mask_error         => com_api_const_pkg.TRUE
    );

    l_mad_calc_extra := round(nvl(l_mad_calc_extra, 0), 0);

    if    l_mad_calc_extra    >= l_mad_calc_threshold
    then
        l_used_condition := 'Used condition No.1';
        l_mad            := l_mad + l_mad_calc_extra;

    elsif l_mad_calc_extra    <  l_mad_calc_threshold
      and l_overdraft_balance <  l_mad_calc_threshold
    then
        l_used_condition := 'Used condition No.2';
        l_mad            := l_mad + l_balance_total;

    elsif l_mad_calc_extra    <  l_mad_calc_threshold
      and l_overdraft_balance >= l_mad_calc_threshold
    then
        l_used_condition := 'Used condition No.3';
        l_mad            := l_mad + l_mad_calc_threshold;
    end if;

    cst_api_credit_pkg.modify_mandatory_amount_due(
        i_mandatory_amount_due  => l_mad
      , i_total_amount_due      => l_tad
      , i_product_id            => l_product_id
      , i_account_id            => l_account.account_id
      , i_currency              => l_account.currency
      , i_service_id            => l_service_id
      , i_eff_date              => l_eff_date
      , i_overdraft_balance     => l_overdraft_balance
      , i_aging_period          => l_aging_period
      , o_modified_amount_due   => l_mad
    );

    -- Setting outgoing parameters
    set_param(
        i_name   => 'MAD_VALUE'
      , i_value  => l_mad
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> l_balance_total [#1], l_mad_calc_extra [#2]'
                                   || ', l_mad_calc_threshold [#3], l_used_condition [#4]'
      , i_env_param1 => l_balance_total
      , i_env_param2 => l_mad_calc_extra
      , i_env_param3 => l_mad_calc_threshold
      , i_env_param4 => l_used_condition
    );
end mad_algorithm_threshold;

end;
/
