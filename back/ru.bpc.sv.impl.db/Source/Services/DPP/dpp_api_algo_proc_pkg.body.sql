create or replace package body dpp_api_algo_proc_pkg is

g_params                com_api_type_pkg.t_param_tab;
g_dpp                   dpp_api_type_pkg.t_dpp_program;
g_instalments           dpp_api_type_pkg.t_dpp_instalment_tab;

procedure clear_shared_data is
begin
    rul_api_param_pkg.clear_params(io_params => g_params);
end;

procedure set_dpp(
    i_dpp                 in            dpp_api_type_pkg.t_dpp_program
) is
begin
    g_dpp := i_dpp;
end;

procedure set_instalments(
    i_instalments         in            dpp_api_type_pkg.t_dpp_instalment_tab
) is
begin
    if i_instalments.count() > 0 then
        g_instalments := i_instalments;
    else
        g_instalments.delete;
    end if;
end;

function get_dpp return dpp_api_type_pkg.t_dpp_program is
begin
    return g_dpp;
end;

function get_instalments return dpp_api_type_pkg.t_dpp_instalment_tab is
begin
    return g_instalments;
end;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return number is
begin
    return rul_api_param_pkg.get_param_num(
               i_name         => i_name
             , io_params      => g_params
             , i_mask_error   => i_mask_error
             , i_error_value  => i_error_value
           );
end;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return date is
begin
    return rul_api_param_pkg.get_param_date(
               i_name         => i_name
             , io_params      => g_params
             , i_mask_error   => i_mask_error
             , i_error_value  => i_error_value
           );
end;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_param_value is
begin
    return rul_api_param_pkg.get_param_char(
               i_name         => i_name
             , io_params      => g_params
             , i_mask_error   => i_mask_error
             , i_error_value  => i_error_value
           );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            number
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            date
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure process_algorithm(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date                in            date
  , i_first_payment_date      in            date
  , i_debt_rest               in            com_api_type_pkg.t_money
) is
begin
    set_dpp(i_dpp => io_dpp);
    set_instalments(i_instalments=> io_instalments);

    set_param(
        i_name   => 'EFF_DATE'
      , i_value  => i_eff_date
    );
    set_param(
        i_name   => 'FIRST_PAYMENT_DATE'
      , i_value  => i_first_payment_date
    );
    set_param(
        i_name   => 'DEBT_REST'
      , i_value  => i_debt_rest
    );

    rul_api_algorithm_pkg.execute_algorithm(i_algorithm => io_dpp.calc_algorithm);

    io_dpp         := get_dpp();
    io_instalments := get_instalments();
end process_algorithm;

-- Algorithms procedures

procedure calc_gih is
    LOG_PREFIX                     constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.calc_gih: ';
    AMOUNT_FORMAT                  constant com_api_type_pkg.t_money := '9999999999';
    l_service_id                            com_api_type_pkg.t_short_id;
    l_params                                com_api_type_pkg.t_param_tab;
    l_eff_date                              date;
    l_first_payment_date                    date;
    l_debt_rest                             com_api_type_pkg.t_money;
    l_principal_repayment                   com_api_type_pkg.t_money;
    l_interest_amount_rest                  com_api_type_pkg.t_money;
    l_interest_instalment_count             com_api_type_pkg.t_tiny_id;
    l_principal_instalment_count            com_api_type_pkg.t_tiny_id;
    l_interest_instalment_amount            com_api_type_pkg.t_money;
    l_principal_instalment_amount           com_api_type_pkg.t_money;

    procedure get_interest_rest(
        i_interest_repayment      in            com_api_type_pkg.t_money
      , o_interest_amount_rest       out        com_api_type_pkg.t_money
    ) is
        l_last_instalment_number                com_api_type_pkg.t_tiny_id;
        l_interest_principal_repayment          com_api_type_pkg.t_money;
        l_instalment_count                      com_api_type_pkg.t_tiny_id;
        l_currency                              com_api_type_pkg.t_curr_code;
    begin
        l_last_instalment_number := dpp_api_instalment_pkg.get_last_paid_instalm_number(
                                        i_dpp_id => g_dpp.dpp_id
                                    );

        l_instalment_count := greatest(g_dpp.instalment_count, 1);
        l_currency         := g_dpp.dpp_currency;

        l_interest_principal_repayment :=
            round(
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id          => g_dpp.fee_id
                  , i_base_amount     => l_principal_repayment
                  , io_base_currency  => l_currency
                  , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id       => g_dpp.account_id
                  , i_eff_date        => l_eff_date
                )
                * (l_instalment_count - l_last_instalment_number)
                /  l_instalment_count
            );

        o_interest_amount_rest := nvl(
                                      dpp_api_payment_plan_pkg.get_dpp(
                                          i_dpp_id => g_dpp.dpp_id
                                      ).interest_amount
                                    , 0
                                  )
                                - l_interest_principal_repayment - i_interest_repayment;
    end get_interest_rest;

begin
    if g_dpp.acceleration_reason is not null then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'acceleration_reason [#1]'
          , i_env_param1 => g_dpp.acceleration_reason
        );
    end if;

    l_eff_date           := get_param_date(i_name => 'EFF_DATE');
    l_first_payment_date := get_param_date(i_name => 'FIRST_PAYMENT_DATE');
    l_debt_rest          := greatest(get_param_num(i_name => 'DEBT_REST'), 0);

    l_principal_repayment := g_dpp.dpp_amount - l_debt_rest;

    if g_dpp.acceleration_type is not null then
        get_interest_rest(
            i_interest_repayment    => g_instalments(1).repayment - l_principal_repayment
          , o_interest_amount_rest  => l_interest_amount_rest
        );
    else
        -- Instalment amount should not be specified
        if g_dpp.instalment_count = 0 or nvl(g_dpp.instalment_amount, 0) != 0 then
            raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
        end if;

        l_interest_amount_rest := round(
                                      fcl_api_fee_pkg.get_fee_amount(
                                          i_fee_id         => g_dpp.fee_id
                                        , i_base_amount    => l_debt_rest
                                        , io_base_currency => g_dpp.dpp_currency
                                      )
                                  );
    end if;

    dpp_api_payment_plan_pkg.check_full_repayment(
        io_dpp          => g_dpp
      , io_instalments  => g_instalments
      , i_debt_rest     => l_debt_rest + l_interest_amount_rest
    );

    if  g_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_NEW_INSTLMT_CNT
        or
        g_dpp.acceleration_type is null
    then
        l_interest_instalment_count   := ceil(l_interest_amount_rest * g_dpp.instalment_count
                                               / (l_debt_rest + l_interest_amount_rest));
        l_principal_instalment_count  := g_dpp.instalment_count - l_interest_instalment_count;

    elsif g_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_AMT then
        l_principal_instalment_count  := ceil(l_debt_rest / g_dpp.instalment_amount);
        l_interest_instalment_count   := ceil(l_interest_amount_rest / g_dpp.instalment_amount);

        g_dpp.instalment_count := l_principal_instalment_count + l_interest_instalment_count;

    elsif g_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_CNT then
        l_principal_instalment_count  := ceil(l_debt_rest / l_principal_repayment);
        l_interest_instalment_count   := ceil(l_interest_amount_rest / l_principal_repayment);

        g_dpp.instalment_count := l_principal_instalment_count + l_interest_instalment_count;

    else
        raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
    end if;

    l_interest_instalment_amount := ceil(l_interest_amount_rest / greatest(l_interest_instalment_count, 1));

    -- In case of acceleration/restructuring l_interest_instalment_count = g_dpp.instalment_count
    if  g_dpp.instalment_count = l_interest_instalment_count and l_interest_amount_rest > 0 then
        if g_dpp.acceleration_type is null then
            raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
        end if;

        g_dpp.instalment_count := 1;
    end if;

    -- If principal is unpaid
    if l_principal_instalment_count > 0 then
        l_principal_instalment_amount := ceil(l_debt_rest / l_principal_instalment_count);
    else
        l_principal_instalment_amount := 0;
    end if;

    dpp_api_payment_plan_pkg.prepare_instalments(
        i_dpp                => g_dpp
      , io_instalments       => g_instalments
      , i_eff_date           => l_eff_date
      , i_first_payment_date => l_first_payment_date
    );

    if g_dpp.account_id is not null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id        => g_dpp.account_id
              , i_attr_name        => null
              , i_service_type_id  => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
              , i_split_hash       => g_dpp.split_hash
              , i_eff_date         => l_eff_date
              , i_mask_error       => com_api_const_pkg.FALSE
              , i_inst_id          => g_dpp.inst_id
            );
        -- For using in checking of modifiers on getting an interest fee
        rul_api_param_pkg.set_param(
            i_name     => 'INSTALMENT_COUNT'
          , i_value    => g_dpp.instalment_count
          , io_params  => l_params
        );
    end if;

    if l_service_id is not null then
        for n in 1..g_dpp.instalment_count loop
            rul_api_param_pkg.set_param(
                i_name    => 'INSTALMENT_NUMBER'
              , i_value   => n
              , io_params => l_params
            );
            g_instalments(n).fee_id :=
                prd_api_product_pkg.get_fee_id(
                    i_product_id   => g_dpp.product_id
                  , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => g_dpp.account_id
                  , i_fee_type     => dpp_api_const_pkg.FEE_TYPE_INTEREST
                  , i_params       => l_params
                  , i_service_id   => l_service_id
                  , i_eff_date     => l_eff_date
                  , i_split_hash   => g_dpp.split_hash
                  , i_inst_id      => g_dpp.inst_id
                  , i_mask_error   => com_api_const_pkg.TRUE
                );
        end loop;
    end if;

    -- For interest instalments fill amount and interest = "interest instalment amount"
    for n in 1..g_dpp.instalment_count loop
        -- If instalment is Principal
        if l_debt_rest > 0 then
            g_instalments(n).amount   := l_principal_instalment_amount;
            g_instalments(n).interest := 0;
            l_debt_rest               := greatest(0, l_debt_rest - g_instalments(n).amount);
        -- If instalment is Interest
        elsif l_interest_amount_rest > 0 then
            --Last instalment of each period should be filled with remainder of "debt rest" and "total interest amount"
            if n = g_dpp.instalment_count then
                g_instalments(n).amount := l_interest_amount_rest;
            else
                g_instalments(n).amount := l_interest_instalment_amount;
            end if;

            g_instalments(n).interest := l_interest_instalment_amount;
            l_interest_amount_rest    := greatest(0, l_interest_amount_rest - g_instalments(n).amount);
        else
            raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
        end if;

        if g_dpp.acceleration_reason is not null then
            g_instalments(n).acceleration_reason := g_dpp.acceleration_reason;
        end if;

        trc_log_pkg.debug(
            i_text => 'n = ' || to_char(n, '999')
                   || ', id ['                      || g_instalments(n).id
                   || ']: amount ['                 || to_char(g_instalments(n).amount,   AMOUNT_FORMAT)
                   || '], interest ['               || to_char(g_instalments(n).interest, AMOUNT_FORMAT)
                   || '], l_debt_rest ['            || to_char(l_debt_rest,               AMOUNT_FORMAT)
                   || '], period_days_count ['      || g_instalments(n).period_days_count
                   || '], l_interest_amount_rest [' || to_char(l_interest_amount_rest,    AMOUNT_FORMAT) || ']'
        );
    end loop;
end calc_gih;

procedure calc_balloon
is
    LOG_PREFIX         constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.calc_balloon: ';
    l_eff_date                  date;
    l_first_payment_date        date;
    l_debt_rest                 com_api_type_pkg.t_money := 0;
    l_service_id                com_api_type_pkg.t_short_id;
    l_balloon_rate               com_api_type_pkg.t_money := 0;
    l_balloon_fee_id            com_api_type_pkg.t_short_id;
    l_balloon_debt_rest         com_api_type_pkg.t_money := 0;
    l_balloon_interest_amount   com_api_type_pkg.t_money := 0;
    l_reg_installment_principal com_api_type_pkg.t_money := 0;
    l_reg_installment_interest  com_api_type_pkg.t_money := 0;
    l_total_interest_amount     com_api_type_pkg.t_money := 0;
    l_params                    com_api_type_pkg.t_param_tab;
    l_period_percent_rate       com_api_type_pkg.t_rate;
    l_day_percent_rate          com_api_type_pkg.t_rate;
begin
    l_eff_date :=
        coalesce(
            get_param_date(i_name => 'EFF_DATE')
          , com_api_sttl_day_pkg.get_calc_date(i_inst_id => g_dpp.inst_id)
        );
    l_debt_rest          := get_param_num(i_name => 'DEBT_REST');
    l_first_payment_date := get_param_date(i_name => 'FIRST_PAYMENT_DATE');

    dpp_api_payment_plan_pkg.get_period_rates(
        i_fee_id               => g_dpp.fee_id
      , i_rate_algorithm       => g_dpp.rate_algorithm
      , o_period_percent_rate  => l_period_percent_rate
      , o_day_percent_rate     => l_day_percent_rate
    );

    if      nvl(l_debt_rest, 0) <= 0 
        or  nvl(l_period_percent_rate, 0) = 0
        or  g_dpp.instalment_count <= 1
        or  nvl(g_dpp.instalment_amount, 0) <> 0
    then
        raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_period_percent_rate [' || to_char(l_period_percent_rate, '90.999999')
                             || '], l_day_percent_rate ['    || to_char(l_day_percent_rate, '90.999999') || ']'
    );

    dpp_api_payment_plan_pkg.check_full_repayment(
        io_dpp          => g_dpp
      , io_instalments  => g_instalments
      , i_debt_rest     => l_debt_rest
    );

    if g_dpp.acceleration_type is null then
        if g_dpp.oper_id is not null then
            l_balloon_rate :=
                to_number(
                    aup_api_tag_pkg.get_tag_value(
                        i_auth_id  => g_dpp.oper_id
                      , i_tag_id   => aup_api_tag_pkg.find_tag_by_reference('DF8E26')
                    )
                  , com_api_const_pkg.XML_FLOAT_FORMAT
                );

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'tag <DF8E26> value [#1]'
              , i_env_param1 => l_balloon_rate
            );
        else
            raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
        end if;

        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id        => g_dpp.account_id
              , i_attr_name        => null
              , i_service_type_id  => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
              , i_split_hash       => g_dpp.split_hash
              , i_eff_date         => l_eff_date
              , i_mask_error       => com_api_const_pkg.FALSE
              , i_inst_id          => g_dpp.inst_id
            );

        if l_balloon_rate is not null then
            fcl_api_fee_pkg.save_fee(
                io_fee_id       => l_balloon_fee_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => g_dpp.account_id
              , i_attr_name     => dpp_api_const_pkg.ATTR_BALLOON_RATE
              , i_percent_rate  => l_balloon_rate
              , i_product_id    => g_dpp.product_id
              , i_service_id    => l_service_id
              , i_eff_date      => l_eff_date
              , i_fee_currency  => g_dpp.oper_currency
              , i_fee_type      => dpp_api_const_pkg.FEE_TYPE_BALLOON_RATE
              , i_fee_rate_calc => fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
              , i_fee_base_calc => fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
              , i_length_type   => fcl_api_const_pkg.CYCLE_LENGTH_YEAR
              , i_inst_id       => g_dpp.inst_id
              , i_split_hash    => g_dpp.split_hash
              , i_search_fee    => com_api_const_pkg.TRUE
              , io_params       => l_params
            );
        end if;
    end if;

    l_balloon_fee_id :=
        prd_api_product_pkg.get_fee_id(
            i_product_id   => g_dpp.product_id
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => g_dpp.account_id
          , i_fee_type     => dpp_api_const_pkg.FEE_TYPE_BALLOON_RATE
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_eff_date
          , i_split_hash   => g_dpp.split_hash
          , i_inst_id      => g_dpp.inst_id
          , i_mask_error   => com_api_const_pkg.TRUE
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_balloon_fee_id [#1]'
      , i_env_param1 => l_balloon_fee_id
    );

    if l_balloon_fee_id is null then
        raise dpp_api_payment_plan_pkg.e_unable_to_calculate_dpp;
    end if;

    l_total_interest_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id         => g_dpp.fee_id
          , i_base_amount    => l_debt_rest
          , io_base_currency => g_dpp.dpp_currency
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => g_dpp.account_id
          , i_eff_date       => l_eff_date
          , i_split_hash     => g_dpp.split_hash
        );

    l_balloon_debt_rest :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id         => l_balloon_fee_id
          , i_base_amount    => l_debt_rest
          , io_base_currency => g_dpp.dpp_currency
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => g_dpp.account_id
          , i_eff_date       => l_eff_date
          , i_split_hash     => g_dpp.split_hash
        );

    l_balloon_interest_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id         => l_balloon_fee_id
          , i_base_amount    => l_total_interest_amount
          , io_base_currency => g_dpp.dpp_currency
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => g_dpp.account_id
          , i_eff_date       => l_eff_date
          , i_split_hash     => g_dpp.split_hash
        );

    l_reg_installment_principal :=
        ceil((l_debt_rest - l_balloon_debt_rest) / (g_dpp.instalment_count - 1));

    l_reg_installment_interest  :=
        ceil((l_total_interest_amount - l_balloon_interest_amount) / (g_dpp.instalment_count - 1));

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_balloon_debt_rest [#1], l_balloon_interest_amount [#2]'
                                   || ', l_reg_installment_principal [#3], l_reg_installment_interest [#4]'
      , i_env_param1 => l_balloon_debt_rest
      , i_env_param2 => l_balloon_interest_amount
      , i_env_param3 => l_reg_installment_principal
      , i_env_param4 => l_reg_installment_interest
    );

    dpp_api_payment_plan_pkg.prepare_instalments(
        i_dpp                => g_dpp
      , io_instalments       => g_instalments
      , i_eff_date           => l_eff_date
      , i_first_payment_date => l_first_payment_date
    );

    -- Calculate first n-1 instalments
    for i in 1 .. g_instalments.count loop
        if i < g_instalments.count then
            g_instalments(i).interest := l_reg_installment_interest;
            g_instalments(i).amount   := l_reg_installment_principal + l_reg_installment_interest;

            l_debt_rest             := greatest(0, l_debt_rest - (g_instalments(i).amount - g_instalments(i).interest));
            l_total_interest_amount := greatest(0, l_total_interest_amount - g_instalments(i).interest);
        else -- Calculate balloon instalment for the last record
            g_instalments(i).interest := l_total_interest_amount;
            g_instalments(i).amount   := l_debt_rest + l_total_interest_amount;
        end if;

        trc_log_pkg.debug(
           i_text => LOG_PREFIX || 'g_instalments(' || to_char(i, '999') || ') = '
                  || '{amount [#1], interest [#2], period_days_count [#3], instalment_date [#4]}; '
                  || 'l_debt_rest [#5], l_total_interest_amount [#6]'
          , i_env_param1 => g_instalments(i).amount
          , i_env_param2 => g_instalments(i).interest
          , i_env_param3 => g_instalments(i).period_days_count
          , i_env_param4 => g_instalments(i).instalment_date
          , i_env_param5 => l_debt_rest
          , i_env_param6 => l_total_interest_amount
        );
    end loop;
end calc_balloon;

end;
/
