create or replace package body dpp_api_payment_plan_pkg as
/*********************************************************
*  API for deferred payment plan <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_API_PAYMENT_PLAN_PKG <br />
*  @headcom
**********************************************************/

function get_days_in_year
return com_api_type_pkg.t_tiny_id
is
begin
    return to_number(to_char(add_months(trunc(get_sysdate(), 'YYYY') - 1, 12), 'ddd'));
end;

procedure get_period_rates(
    i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_rate_algorithm          in     com_api_type_pkg.t_dict_value
  , o_period_percent_rate        out com_api_type_pkg.t_rate
  , o_day_percent_rate           out com_api_type_pkg.t_rate
) is
    l_rate    com_api_type_pkg.t_rate;
begin
    trc_log_pkg.debug('get_period_rates; fee_id = ' || i_fee_id ||'; rate_algorithm = ' || i_rate_algorithm);

    if nvl(i_rate_algorithm, dpp_api_const_pkg.DPP_RATE_ALGORITHM_LINEAR) = dpp_api_const_pkg.DPP_RATE_ALGORITHM_LINEAR then
        l_rate := get_year_percent_in_fraction(i_fee_id  => i_fee_id);

    elsif i_rate_algorithm = dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL then
        l_rate :=
            get_year_percent_rate(
                i_rate_algorithm       => dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL
              , i_fee_id               => i_fee_id
              , i_incoming_amount      => null
              , i_incoming_currency    => null
              , i_mask_error           => com_api_const_pkg.FALSE
            ) / 100;
    else
        com_api_error_pkg.raise_error(
            i_error         => 'ALGORITHM_NOT_SUPPORTED'
          , i_env_param1    => i_rate_algorithm
        );
    end if;

    o_day_percent_rate          := l_rate / get_days_in_year();
    --o_period_percent_rate       := l_day_percent_rate * 31;
    o_period_percent_rate       := l_rate / 12;
end;

function get_period_rate(
    i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_rate_algorithm          in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_rate
is
    l_period_percent_rate        com_api_type_pkg.t_rate;
    l_day_percent_rate           com_api_type_pkg.t_rate;
begin
    get_period_rates(
        i_fee_id                => i_fee_id
      , i_rate_algorithm        => i_rate_algorithm
      , o_period_percent_rate   => l_period_percent_rate
      , o_day_percent_rate      => l_day_percent_rate
    );
    return l_period_percent_rate;
end;

function get_year_percent_rate(
    i_rate_algorithm          in     com_api_type_pkg.t_dict_value
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_incoming_amount         in     com_api_type_pkg.t_money
  , i_incoming_currency       in     com_api_type_pkg.t_curr_code
  , i_mask_error              in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money
is
    PROC_NAME               constant com_api_type_pkg.t_name := 'get_year_percent_rate';
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.' || PROC_NAME || ' ';
    l_currency                       com_api_type_pkg.t_curr_code;
    l_fee_rate_calc                  com_api_type_pkg.t_dict_value;
    l_fee_base_calc                  com_api_type_pkg.t_dict_value;
    l_length_type                    com_api_type_pkg.t_dict_value;
    l_cycle_length_type              com_api_type_pkg.t_dict_value;
    l_cycle_length                   com_api_type_pkg.t_tiny_id;
    l_cycle_workdays_only            com_api_type_pkg.t_sign;
    l_length                         com_api_type_pkg.t_tiny_id;
    l_percent_rate                   com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< rate algorithm [#1], fee_id [#2], incoming_amount [#3], incoming_currency [#4]'
      , i_env_param1 => i_rate_algorithm
      , i_env_param2 => i_fee_id
      , i_env_param3 => i_incoming_amount
      , i_env_param4 => i_incoming_currency
    );

    if i_rate_algorithm =  dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL then
        begin
            select s.currency
                 , s.fee_rate_calc
                 , s.fee_base_calc
                 , s.fee_length_type
                 , s.cycle_length_type
                 , s.cycle_length
                 , s.cycle_workdays_only
                 , s.percent_rate
              into l_currency
                 , l_fee_rate_calc
                 , l_fee_base_calc
                 , l_length_type
                 , l_cycle_length_type
                 , l_cycle_length
                 , l_cycle_workdays_only
                 , l_percent_rate
              from (
                    select f.currency
                         , f.fee_rate_calc
                         , f.fee_base_calc
                         , c.length_type as cycle_length_type
                         , c.cycle_length
                         , c.workdays_only as cycle_workdays_only
                         , ft.percent_rate
                         , ft.length_type as fee_length_type
                      from fcl_fee f
                         , fcl_fee_type t
                         , fcl_cycle c
                         , fcl_fee_tier ft
                     where f.id = i_fee_id
                       and f.fee_type = t.fee_type
                       and f.cycle_id = c.id(+)
                       and ft.fee_id  = f.id
                       and (ft.sum_threshold <= i_incoming_amount or i_incoming_amount is null)
                     order by
                           (i_incoming_amount - ft.sum_threshold) asc
              ) s
             where rownum = 1
            ;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'FEE_NOT_FOUND'
                  , i_env_param1    => i_fee_id
                );
        end;

        if l_fee_rate_calc <> fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE then
            com_api_error_pkg.raise_error(
                i_error         => 'FEE_RATE_CALC_NOT_SUPPORTED'
              , i_env_param1    => l_fee_rate_calc
              , i_env_param2    => PROC_NAME
            );
        end if;

        if l_fee_base_calc <> fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT then
            com_api_error_pkg.raise_error(
                i_error         => 'FEE_BASE_CALC_NOT_SUPPORTED'
              , i_env_param1    => l_fee_base_calc
              , i_env_param2    => PROC_NAME
            );
        end if;

        if i_incoming_currency <> l_currency then
            com_api_error_pkg.raise_error(
                i_error         => 'EXPECTED_ANOTHER_CURRENCY'
              , i_env_param1    => l_currency
              , i_env_param2    => i_incoming_currency
            );
        end if;

        if l_length_type is null and l_cycle_length_type is null then
            com_api_error_pkg.raise_error(
                i_error         => 'CYCLE_OR_FCL_LENGTH_MUST_DEFINED'
              , i_env_param1    => PROC_NAME
            );
        elsif l_length_type not in (fcl_api_const_pkg.CYCLE_LENGTH_MONTH, fcl_api_const_pkg.CYCLE_LENGTH_YEAR)
        then
            com_api_error_pkg.raise_error(
                i_error         => 'LENGTH_TYPE_NOT_SUPPORTED'
              , i_env_param1    => l_length_type
              , i_env_param2    => fcl_api_const_pkg.ENTITY_TYPE_FEE
              , i_env_param3    => PROC_NAME
            );
        elsif l_cycle_length_type not in (fcl_api_const_pkg.CYCLE_LENGTH_MONTH, fcl_api_const_pkg.CYCLE_LENGTH_YEAR)
        then
            com_api_error_pkg.raise_error(
                i_error         => 'LENGTH_TYPE_NOT_SUPPORTED'
              , i_env_param1    => l_cycle_length_type
              , i_env_param2    => fcl_api_const_pkg.ENTITY_TYPE_CYCLE
              , i_env_param3    => PROC_NAME
            );
        end if;

        if l_length_type = fcl_api_const_pkg.CYCLE_LENGTH_YEAR
            or l_cycle_length_type = fcl_api_const_pkg.CYCLE_LENGTH_YEAR
        then
            l_length := 12;

        elsif l_length_type = fcl_api_const_pkg.CYCLE_LENGTH_MONTH
           or l_cycle_length_type = fcl_api_const_pkg.CYCLE_LENGTH_MONTH
        then
            l_length := case
                            when l_length_type is not null
                                then 1
                            when l_cycle_length_type is not null
                                then l_cycle_length
                        end;
        end if;

        l_percent_rate := round((power(1 + (l_percent_rate / 100), 1 / l_length) - 1), 4) * 12 * 100;

    else
        com_api_error_pkg.raise_error(
            i_error         => 'ALGORITHM_NOT_SUPPORTED'
          , i_env_param1    => i_rate_algorithm
        );
    end if;

    return l_percent_rate;
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                return null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end get_year_percent_rate;

function get_year_percent_in_fraction(
    i_fee_id                  in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_money
is
    l_percent_rate                   com_api_type_pkg.t_money;
    l_length_type                    com_api_type_pkg.t_dict_value;
    l_fixed_rate                     com_api_type_pkg.t_money;
begin
    select percent_rate
         , length_type
         , fixed_rate
      into l_percent_rate
         , l_length_type
         , l_fixed_rate
      from fcl_fee_tier
     where fee_id           = i_fee_id
       and sum_threshold    = 0
       and count_threshold  = 0;

    if l_fixed_rate > 0
    then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_UNABLE_USE_FIXED_RATE'
          , i_env_param1 => l_fixed_rate
        );
    end if;

    if l_length_type = fcl_api_const_pkg.CYCLE_LENGTH_YEAR or l_length_type is null then
        l_percent_rate := l_percent_rate / 100 ;

    elsif nvl(l_length_type, '1') = fcl_api_const_pkg.CYCLE_LENGTH_MONTH then
        l_percent_rate := 12 * l_percent_rate / 100 ;

    elsif nvl(l_length_type, '1') = fcl_api_const_pkg.CYCLE_LENGTH_WEEK then
        l_percent_rate := get_days_in_year * l_percent_rate / 100 / 7;

    elsif nvl(l_length_type, '1') = fcl_api_const_pkg.CYCLE_LENGTH_DAY then
        l_percent_rate := get_days_in_year * l_percent_rate / 100;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'FCL_INVALID_LENGTH_TYPE'
          , i_env_param1 => i_fee_id
          , i_env_param2 => l_length_type
        );
    end if;

    return l_percent_rate;
end;

procedure get_saved_attribute_value(
    i_attr_name               in     com_api_type_pkg.t_name
  , i_dpp_id                  in     com_api_type_pkg.t_long_id
  , o_value                      out number
  , i_mask_error              in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) is
    l_value                   com_api_type_pkg.t_short_desc;
begin
    select v.value
      into l_value
      from dpp_attribute_value v
         , prd_attribute a
     where a.service_type_id = dpp_api_const_pkg.DPP_SERVICE_TYPE_ID  --  10000884
       and a.data_type       = com_api_const_pkg.DATA_TYPE_NUMBER
       and a.attr_name       = i_attr_name
       and v.attr_id         = a.id
       and v.dpp_id          = i_dpp_id
       and (a.entity_type not in ('ENTTAGRP', 'ENTTSRVT') or a.entity_type is null);

    o_value := to_number(l_value, com_api_const_pkg.NUMBER_FORMAT);
exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        com_api_error_pkg.raise_error(
            i_error      => 'WRONG_PARAM_VALUE_FORMAT'
          , i_env_param1 => i_attr_name
          , i_env_param2 => com_api_const_pkg.DATA_TYPE_NUMBER
          , i_env_param3 => l_value
        );
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ATTRIBUTE_NOT_FOUND'
              , i_env_param1 => i_attr_name
            );
        end if;
end;

procedure get_saved_attribute_value(
    i_attr_name               in     com_api_type_pkg.t_name
  , i_dpp_id                  in     com_api_type_pkg.t_long_id
  , o_value                      out varchar2
  , i_mask_error              in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) is
begin
    select v.value
      into o_value
      from dpp_attribute_value v
         , prd_attribute a
     where a.service_type_id = dpp_api_const_pkg.DPP_SERVICE_TYPE_ID  --  10000884
       and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
       and a.attr_name       = i_attr_name
       and v.attr_id         = a.id
       and v.dpp_id          = i_dpp_id
       and (a.entity_type not in ('ENTTAGRP', 'ENTTSRVT') or a.entity_type is null);
exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ATTRIBUTE_NOT_FOUND'
              , i_env_param1 => i_attr_name
            );
        end if;
end;

/*
 * Function returns a collection with DPPs for specified account that are ordered by date of creation.
 */
function get_dpp(
    i_account_id              in      com_api_type_pkg.t_account_id
) return dpp_api_type_pkg.t_dpp_tab
is
    l_dpp_tab                         dpp_api_type_pkg.t_dpp_tab;
begin
    begin
        select p.id
             , p.oper_id
             , p.account_id
             , p.card_id
             , p.product_id
             , p.oper_date
             , p.oper_amount
             , p.oper_currency
             , p.dpp_amount
             , p.dpp_currency
             , p.interest_amount
             , p.status
             , p.instalment_amount
             , p.instalment_total
             , p.instalment_billed
             , p.next_instalment_date
             , p.debt_balance
             , p.inst_id
             , p.split_hash
             , p.reg_oper_id
             , p.posting_date
             , p.oper_type
             , (select v.value
                  from dpp_attribute_value v
                     , prd_attribute a
                 where a.attr_name = 'DPP_ALGORITHM'
                   and a.id        = v.attr_id
                   and v.dpp_id    = p.id
                ) dpp_algorithm
          bulk collect
          into l_dpp_tab
          from dpp_payment_plan p
         where p.account_id = i_account_id
           and p.status     = dpp_api_const_pkg.DPP_OPERATION_ACTIVE
      order by p.oper_date; -- 1st element of the collection is an oldest DPP
    exception
        when no_data_found then
            null;
    end;
    return l_dpp_tab;
end get_dpp;

function get_dpp(
    i_dpp_id                  in      com_api_type_pkg.t_account_id
  , i_mask_error              in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return dpp_api_type_pkg.t_dpp
is
    l_dpp_rec                         dpp_api_type_pkg.t_dpp;
begin
    begin
        select p.id
             , p.oper_id
             , p.account_id
             , p.card_id
             , p.product_id
             , p.oper_date
             , p.oper_amount
             , p.oper_currency
             , p.dpp_amount
             , p.dpp_currency
             , p.interest_amount
             , p.status
             , p.instalment_amount
             , p.instalment_total
             , p.instalment_billed
             , p.next_instalment_date
             , p.debt_balance
             , p.inst_id
             , p.split_hash
             , p.reg_oper_id
             , p.posting_date
             , p.oper_type
             , (select v.value
                  from dpp_attribute_value v
                     , prd_attribute a
                 where a.attr_name = 'DPP_ALGORITHM'
                   and a.id        = v.attr_id
                   and v.dpp_id    = p.id
                ) dpp_algorithm
          into l_dpp_rec
          from dpp_payment_plan p
         where p.id = i_dpp_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'DPP_IS_NOT_FOUND'
                  , i_env_param1 => i_dpp_id
                );
            else
                trc_log_pkg.warn(
                    i_text       => 'DPP_IS_NOT_FOUND'
                  , i_env_param1 => i_dpp_id
                );
            end if;
    end;
    return l_dpp_rec;
end get_dpp;

function get_dpp(
    i_oper_id                 in      com_api_type_pkg.t_long_id
  , i_mask_error              in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return dpp_api_type_pkg.t_dpp
is
    l_dpp_rec                         dpp_api_type_pkg.t_dpp;
begin
    begin
        select dp.id
             , dp.oper_id
             , dp.account_id
             , dp.card_id
             , dp.product_id
             , dp.oper_date
             , dp.oper_amount
             , dp.oper_currency
             , dp.dpp_amount
             , dp.dpp_currency
             , dp.interest_amount
             , dp.status
             , dp.instalment_amount
             , dp.instalment_total
             , dp.instalment_billed
             , dp.next_instalment_date
             , dp.debt_balance
             , dp.inst_id
             , dp.split_hash
             , dp.reg_oper_id
             , dp.posting_date
             , dp.oper_type
             , (select v.value
                  from dpp_attribute_value v
                     , prd_attribute a
                 where a.attr_name = 'DPP_ALGORITHM'
                   and a.id        = v.attr_id
                   and v.dpp_id    = dp.id
                ) dpp_algorithm
          into l_dpp_rec
          from acc_macros m
             , dpp_payment_plan dp
         where m.object_id         = i_oper_id
           and m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and dp.id               = m.id
        ;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'DPP_FOR_OPERATION_NOT_FOUND'
                  , i_env_param1 => i_oper_id
                );
            else
                trc_log_pkg.warn(
                    i_text       => 'DPP_FOR_OPERATION_NOT_FOUND'
                  , i_env_param1 => i_oper_id
                );
            end if;
    end;
    return l_dpp_rec;
end get_dpp;

procedure check_usury_rate(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , i_eff_date                in            date
) as
    l_params              com_api_type_pkg.t_param_tab;
    l_fee_id              com_api_type_pkg.t_short_id;
    l_usury_percent_rate  com_api_type_pkg.t_rate;
    l_percent_rate        com_api_type_pkg.t_rate;
begin
    begin
        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id      => io_dpp.product_id
              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id       => io_dpp.account_id
              , i_fee_type        => dpp_api_const_pkg.FEE_TYPE_USURY_RATE
              , i_params          => l_params
              , i_eff_date        => i_eff_date
              , i_split_hash      => io_dpp.split_hash
              , i_inst_id         => io_dpp.inst_id
              , i_mask_error      => com_api_const_pkg.TRUE
            );
    exception
        when com_api_error_pkg.e_application_error then
            l_fee_id := null;
    end;

    if l_fee_id is not null and io_dpp.fee_id <> l_fee_id then
        l_percent_rate :=
            get_period_rate(
                i_fee_id          => io_dpp.fee_id
              , i_rate_algorithm  => io_dpp.rate_algorithm
            );
        l_usury_percent_rate :=
            get_period_rate(
                i_fee_id          => l_fee_id
              , i_rate_algorithm  => dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL
            );
        trc_log_pkg.debug(
            i_text       => 'Usury rate ['
                         || l_usury_percent_rate
                         || '] vs regular percent ['
                         || l_percent_rate
                         || ']'
        );

        if l_usury_percent_rate < l_percent_rate then
            io_dpp.fee_id              := l_fee_id;
            io_dpp.rate_algorithm      := dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL;
            io_dpp.acceleration_reason := dpp_api_const_pkg.EVENT_TYPE_USURY_ACCELEARTION;
        end if;
    end if;
end check_usury_rate;

procedure prepare_instalments(
    i_dpp                     in            dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date                in            date
  , i_first_payment_date      in            date
) is
begin
    for i in 1..i_dpp.instalment_count loop
        -- Calculate length of installment period in days for the case of DPP registration
        if  i_dpp.main_cycle_id is not null
            and (i_dpp.first_cycle_id is not null or i_first_payment_date is not null)
        then
            if i = 1 then
                if i_first_payment_date is not null then
                    io_instalments(i).instalment_date := i_first_payment_date;
                else
                    fcl_api_cycle_pkg.calc_next_date(
                        i_cycle_id   => i_dpp.first_cycle_id
                      , i_start_date => i_eff_date
                      , o_next_date  => io_instalments(i).instalment_date
                    );
                end if;
                io_instalments(i).period_days_count := io_instalments(i).instalment_date - trunc(i_eff_date);
            else
                fcl_api_cycle_pkg.calc_next_date(
                    i_cycle_id   => i_dpp.main_cycle_id
                  , i_start_date => io_instalments(i-1).instalment_date
                  , o_next_date  => io_instalments(i).instalment_date
                );
                io_instalments(i).period_days_count := io_instalments(i).instalment_date
                                                     - io_instalments(i-1).instalment_date;
            end if;

        -- Initiate array element if it is necessary
        elsif not io_instalments.exists(i) then
            io_instalments(i).id := null;
        end if;
    end loop;
end prepare_instalments;

/*
 * This procedure checks if a restructuring/acceleration leads to full instalment plan repayment,
 * on success check it processes this case and throws a special exception <e_stop_due_to_full_repayment>
 * to stop further calculations in instalment calculation algorithm-procedures;
 * in case of registering it does nothing because <i_debt_rest> is equal to DPP amount so always greater than 0.
 */
procedure check_full_repayment(
    io_dpp              in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments      in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_debt_rest         in            com_api_type_pkg.t_money
) is
    l_zero_value                      com_api_type_pkg.t_money;
begin
    -- For comparing with near-zero amounts
    l_zero_value := case
                        when io_dpp.oper_currency is not null
                        then power(
                                 10
                               , -com_api_currency_pkg.get_currency_exponent(
                                      i_curr_code => io_dpp.oper_currency
                                  ) - 1
                             )
                        else 0.001
                    end;

    if i_debt_rest <= l_zero_value then
        -- Avoiding any near-zero rest as unpaid DPP amount
        io_instalments(1).repayment := io_dpp.dpp_amount;
        io_instalments(1).amount    := 0;
        io_instalments(1).interest  := 0;
        io_dpp.instalment_count     := 1;
        io_dpp.status               := dpp_api_const_pkg.DPP_OPERATION_PAID;

        trc_log_pkg.debug(
            i_text       => 'Stop processing due to full repayment for dpp_id [#1]'
          , i_env_param1 => io_dpp.dpp_id
        );

        raise e_stop_on_full_repayment;
    end if;
end check_full_repayment;

procedure calc_annuity(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date                in            date
  , i_first_payment_date      in            date
  , i_debt_rest               in            com_api_type_pkg.t_money
) is
    AMOUNT_FORMAT                  constant com_api_type_pkg.t_money := '9999999999';
    l_debt_rest                             com_api_type_pkg.t_money;
    l_period_percent_rate                   number;
    l_day_percent_rate                      number;
begin
    l_debt_rest := i_debt_rest;

    if  io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_FIXED_AMOUNT
        and io_dpp.acceleration_type is null
        and nvl(io_dpp.instalment_amount, 0) = 0
    then
        raise e_unable_to_calculate_dpp;

    -- For algorithm Annuity only one of instalment_amount and instalment_count must have positive value
    elsif io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_ANNUITY
        and io_dpp.acceleration_type is null
        and nvl(io_dpp.instalment_count, 0) = 0
        and nvl(io_dpp.instalment_amount, 0) = 0
    then
        raise e_unable_to_calculate_dpp;
    end if;

    check_full_repayment(
        io_dpp             => io_dpp
      , io_instalments     => io_instalments
      , i_debt_rest        => l_debt_rest
    );

    -- Calculate percent rate for the single period of installment payment (usually a month) and for a day
    get_period_rates(
        i_fee_id               => io_dpp.fee_id
      , i_rate_algorithm       => io_dpp.rate_algorithm
      , o_period_percent_rate  => l_period_percent_rate
      , o_day_percent_rate     => l_day_percent_rate
    );
    trc_log_pkg.debug(
        i_text =>    'l_period_percent_rate [' || to_char(l_period_percent_rate, '90.999999')
               || '], l_day_percent_rate ['    || to_char(l_day_percent_rate, '90.999999')
               || '], l_debt_rest ['           || l_debt_rest
               || ']'
    );

    -- a) count of payments is known, amount of an installment payment is calculated
    if      io_dpp.instalment_count > 0
        and io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_ANNUITY
    then
        io_dpp.instalment_amount := ceil(
                                        l_period_percent_rate * l_debt_rest
                                      / (1 - power(1 + l_period_percent_rate, -io_dpp.instalment_count))
                                    );
    -- b) amount of an installment payment is defined, count of instalments is calculated
    elsif io_dpp.instalment_amount > 0 then
        io_dpp.instalment_count :=
            ceil(log(
                1 + l_period_percent_rate
              , io_dpp.instalment_amount / (io_dpp.instalment_amount - l_period_percent_rate * l_debt_rest)
            ));
    else
         raise e_unable_to_calculate_dpp;
    end if;

    trc_log_pkg.debug(
        i_text =>    'io_dpp.instalment_amount [' || io_dpp.instalment_amount
               || '], io_dpp.instalment_count ['  || io_dpp.instalment_count || ']'
    );

    -- Calculate io_instalments(n).period_days_count [or initialize io_instalments(n)]
    prepare_instalments(
        i_dpp                => io_dpp
      , io_instalments       => io_instalments
      , i_eff_date           => i_eff_date
      , i_first_payment_date => i_first_payment_date
    );

    for n in 1..io_dpp.instalment_count loop
        io_instalments(n).interest :=
            round(l_debt_rest * io_instalments(n).period_days_count * l_day_percent_rate);
        io_instalments(n).amount :=
            case
                when n = io_dpp.instalment_count then
                    l_debt_rest + io_instalments(n).interest
                else
                    io_dpp.instalment_amount
            end;
        l_debt_rest := l_debt_rest - (io_instalments(n).amount - io_instalments(n).interest);
        io_instalments(n).acceleration_reason := io_dpp.acceleration_reason;
        io_instalments(n).fee_id              := io_dpp.fee_id;

        trc_log_pkg.debug(
            i_text => 'n = ' || to_char(n, '999')
                   || ', id ['                 || io_instalments(n).id
                   || ']: amount ['            || to_char(io_instalments(n).amount, AMOUNT_FORMAT)
                   || '], interest ['          || to_char(io_instalments(n).interest, AMOUNT_FORMAT)
                   || '], l_debt_rest ['       || to_char(l_debt_rest, AMOUNT_FORMAT)
                   || '], period_days_count [' || io_instalments(n).period_days_count
                   || '], instalment_date ['   || io_instalments(n).instalment_date || ']'
        );
    end loop;
end calc_annuity;

procedure calc_differentiated(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date                in            date
  , i_first_payment_date      in            date
  , i_debt_rest               in            com_api_type_pkg.t_money
) is
    AMOUNT_FORMAT                  constant com_api_type_pkg.t_money := '9999999999';
    l_debt_rest                             com_api_type_pkg.t_money;
    l_period_percent_rate                   number;
    l_day_percent_rate                      com_api_type_pkg.t_rate;
    l_service_id                            com_api_type_pkg.t_short_id;
    l_params                                com_api_type_pkg.t_param_tab;
begin
    l_debt_rest := i_debt_rest;

    -- In the case of annuity payments field instalment_amount should contain amount including interest.
    -- But in the case of differentiated payments this field should contain amount without interest,
    -- and instalment amounts will be calculated as sums of this value and charged interest (see calc_instalments)
    if io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_DIFFERENTIATED then
        io_dpp.instalment_amount := io_dpp.instalment_wo_interest;
    end if;

    if  nvl(io_dpp.instalment_count, 0)  = 0 and nvl(io_dpp.instalment_amount, 0)  = 0
        or
        nvl(io_dpp.instalment_count, 0) != 0 and nvl(io_dpp.instalment_amount, 0) != 0
    then
        raise e_unable_to_calculate_dpp;
    end if;

    -- Calculate percent rate for the single period of installment payment (usually a month) and for a day
    get_period_rates(
        i_fee_id               => io_dpp.fee_id
      , i_rate_algorithm       => io_dpp.rate_algorithm
      , o_period_percent_rate  => l_period_percent_rate
      , o_day_percent_rate     => l_day_percent_rate
    );

    trc_log_pkg.debug(
        i_text =>    'l_period_percent_rate [' || to_char(l_period_percent_rate, '90.999999')
               || '], l_day_percent_rate ['    || to_char(l_day_percent_rate, '90.999999') || ']'
    );

    check_full_repayment(
        io_dpp         => io_dpp
      , io_instalments => io_instalments
      , i_debt_rest    => l_debt_rest
    );

    -- a) count of payments is known, fixed part of an installment payment amount is calculated one time,
    --    interests for every installment payment are calculated separately for every period
    if io_dpp.instalment_count > 0 then
        io_dpp.instalment_amount := round(l_debt_rest / io_dpp.instalment_count);
    -- b) fixed part of an installment payment amount is defined, count of instalments is calculated
    elsif io_dpp.instalment_amount > 0 then
        io_dpp.instalment_count  := ceil(l_debt_rest / io_dpp.instalment_amount);
    else
        raise e_unable_to_calculate_dpp;
    end if;

    trc_log_pkg.debug(
        i_text =>    'io_dpp.instalment_amount [' || to_char(io_dpp.instalment_amount, AMOUNT_FORMAT)
               || '], io_dpp.instalment_count ['  || io_dpp.instalment_count || ']'
    );

    -- Calculate io_instalments(n).period_days_count [or initialize io_instalments(n)]
    prepare_instalments(
        i_dpp                => io_dpp
      , io_instalments       => io_instalments
      , i_eff_date           => i_eff_date
      , i_first_payment_date => i_first_payment_date
    );

    if io_dpp.account_id is not null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id        => io_dpp.account_id
              , i_attr_name        => null
              , i_service_type_id  => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
              , i_split_hash       => io_dpp.split_hash
              , i_eff_date         => i_eff_date
              , i_mask_error       => com_api_const_pkg.FALSE
              , i_inst_id          => io_dpp.inst_id
            );
        -- For using in checking of modifiers on getting an interest fee
        rul_api_param_pkg.set_param(
            i_name     => 'INSTALMENT_COUNT'
          , i_value    => io_dpp.instalment_count
          , io_params  => l_params
        );
    end if;

    if l_service_id is not null then
        for n in 1..io_dpp.instalment_count loop
            rul_api_param_pkg.set_param(
                i_name    => 'INSTALMENT_NUMBER'
              , i_value   => n
              , io_params => l_params
            );

            io_instalments(n).fee_id :=
                prd_api_product_pkg.get_fee_id(
                    i_product_id   => io_dpp.product_id
                  , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => io_dpp.account_id
                  , i_fee_type     => dpp_api_const_pkg.FEE_TYPE_INTEREST
                  , i_params       => l_params
                  , i_service_id   => l_service_id
                  , i_eff_date     => i_eff_date
                  , i_split_hash   => io_dpp.split_hash
                  , i_inst_id      => io_dpp.inst_id
                  , i_mask_error   => com_api_const_pkg.TRUE
                );
            if io_instalments(n).fee_id is not null and io_instalments(n).fee_id <> io_dpp.fee_id then
                if io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_DIFFERENTIATED then
                    io_instalments(n).period_percent_rate :=
                        get_period_rate(
                            i_fee_id          => io_instalments(n).fee_id
                          , i_rate_algorithm  => io_dpp.rate_algorithm
                        );
                elsif io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_ANNUITY then
                    com_api_error_pkg.raise_error(
                        i_error      => 'DPP_TIERED_INTEREST_FEE_IS_NOT_ALLOWED'
                      , i_env_param1 => io_dpp.calc_algorithm
                    );
                end if;
            end if;
        end loop;
    end if;

    for n in 1..io_dpp.instalment_count loop
        -- Use fixed interest percent rate for any month regardless count of days in it
        io_instalments(n).interest := round(l_debt_rest * nvl(io_instalments(n).period_percent_rate, l_period_percent_rate));
        io_instalments(n).amount   :=
            case
                when n = io_dpp.instalment_count then
                    l_debt_rest + io_instalments(n).interest
                else
                    io_dpp.instalment_amount + io_instalments(n).interest
            end;

        l_debt_rest := greatest(0, l_debt_rest - io_dpp.instalment_amount);
        io_instalments(n).acceleration_reason := io_dpp.acceleration_reason;
        io_instalments(n).fee_id              := io_dpp.fee_id;

        trc_log_pkg.debug(
            i_text => 'n = ' || to_char(n, '999')
                   || ', id ['                 || io_instalments(n).id
                   || ']: amount ['            || to_char(io_instalments(n).amount, AMOUNT_FORMAT)
                   || '], interest ['          || to_char(io_instalments(n).interest, AMOUNT_FORMAT)
                   || '], l_debt_rest ['       || to_char(l_debt_rest, AMOUNT_FORMAT)
                   || '], period_days_count [' || io_instalments(n).period_days_count
                   || '], instalment_date ['   || io_instalments(n).instalment_date || ']'
        );
    end loop;
end calc_differentiated;

/*
 * Procedure calculates instalment payments by incoming parameters of DPP.
 * To calculate instalments the following DPP parameters should be always defined:
 * a) total DPP amount without fee (io_dpp.dpp_amount);
 * b) fee/interest percent rate (io_dpp.repcent_rate);
 * c) calculation algorithm - DPP_ALGORITHM_DIFFERENTIATED or DPP_ALGORITHM_ANNUITY.
 * Also it is necessary to define either COUNT of instalments (io_dpp.instalment_count)
 * or AMOUNT of an instalment (io_dpp.instalment_amount);
 * if a COUNT is defined, an AMOUNT may be calculated, and vise versa.
 * NOTE:
 * 3rd algorithm DPP_ALGORITHM_FIXED_AMOUNT is actually the special case of more general algorithm
 * DPP_ALGORITHM_ANNUITY, since it provides annuity calculation with a given AMOUNT only (COUNT
 * is calculated). At the same time algorithm DPP_ALGORITHM_ANNUITY allows to make annuity
 * calculation 2 different ways - with given AMOUNT or with given COUNT.
 * Therefore, DPP_ALGORITHM_FIXED_AMOUNT + AMOUNT == DPP_ALGORITHM_ANNUITY + AMOUNT
 * but combination DPP_ALGORITHM_FIXED_AMOUNT + COUNT is forbidden (and meaningless) so that
 * DPP_ALGORITHM_ANNUITY + COUNT should be used instead.
 * @i_first_amount - amount of the first instalment payment, it is used in case of DPP acceleration,
                     the rest instalments are calculated by given algorithm
 * @io_instalments - result array with amounts of instalment payments,
 * @io_instalments - result array with amounts of instalment payments,
                     in case of DPP registration it is outgoing parameter only,
                     in case of DPP acceleration is contains pre-calculated lengths of instalment
                     periods in days
 */
procedure calc_instalments(
    io_dpp               in out             dpp_api_type_pkg.t_dpp_program
  , i_first_amount       in                 com_api_type_pkg.t_money
  , io_instalments       in out nocopy      dpp_api_type_pkg.t_dpp_instalment_tab
  , i_first_payment_date in                 date  default null
) is
    l_debt_rest                             com_api_type_pkg.t_money;
    l_period_percent_rate                   number;
    l_day_percent_rate                      number;
    l_eff_date                              date;

    procedure check_instalments(
        io_dpp                    in out nocopy dpp_api_type_pkg.t_dpp_program
      , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
    ) is
        i                         binary_integer;
    begin
        i := io_instalments.count();
        while nvl(i, 0) > 0 loop
            if io_instalments(i).amount < 0 or io_instalments(i).interest < 0 then
                com_api_error_pkg.raise_error(
                    i_error      => 'DPP_INSTALMENTS_CALCULATION_ERROR'
                  , i_env_param1 => to_char(i)
                  , i_env_param2 => com_api_currency_pkg.get_amount_str(
                                        i_amount      => io_instalments(i).amount
                                      , i_curr_code   => io_dpp.dpp_currency
                                      , i_mask_error  => com_api_const_pkg.TRUE
                                    )
                  , i_env_param3 => com_api_currency_pkg.get_amount_str(
                                        i_amount      => io_instalments(i).interest
                                      , i_curr_code   => io_dpp.dpp_currency
                                      , i_mask_error  => com_api_const_pkg.TRUE
                                    )
                  , i_env_param4 => com_api_currency_pkg.get_amount_str(
                                        i_amount      => io_dpp.dpp_amount
                                      , i_curr_code   => io_dpp.dpp_currency
                                      , i_mask_error  => com_api_const_pkg.TRUE
                                    )
                  , i_env_param5 => io_dpp.calc_algorithm
                );
            end if;
            i := io_instalments.prior(i);
        end loop;

        -- For the case of DPP acceleration, it is necessary to delete last array's elements
        -- if count of instalment payments was changed (reduced)
        if io_instalments.count() > io_dpp.instalment_count then
            io_instalments.delete(io_dpp.instalment_count + 1, io_instalments.count());
        end if;
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'calc_instalments() << i_first_amount [' || i_first_amount || '], calc_algorithm [#1'
                     || '], dpp_amount [' || io_dpp.dpp_amount
                     || '], instalment_count [' || io_dpp.instalment_count
                     || '], instalment_amount [' || io_dpp.instalment_amount
                     || '], percent_rate [' || to_char(io_dpp.percent_rate, '0000.99')
                     || '], io_instalments.count() = ' || io_instalments.count()
                     || '], i_first_payment_date = ' || to_char(i_first_payment_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param1 => io_dpp.calc_algorithm
    );

    l_eff_date  := com_api_sttl_day_pkg.get_calc_date(io_dpp.inst_id);

    check_usury_rate(
        io_dpp       => io_dpp
      , i_eff_date   => l_eff_date
    );

    io_dpp.instalment_count     := nvl(io_dpp.instalment_count, 0);
    io_dpp.instalment_amount    := nvl(io_dpp.instalment_amount, 0);

    io_instalments(1).repayment := nvl(i_first_amount, 0);
    -- In case of acceleration/restructuring, field <io_dpp.dpp_amount> contains unpaid principal amount
    l_debt_rest                 := io_dpp.dpp_amount - io_instalments(1).repayment;

    trc_log_pkg.debug(
        i_text =>    'l_period_percent_rate [' || to_char(l_period_percent_rate, '90.999999')
               || '], l_day_percent_rate ['    || to_char(l_day_percent_rate, '90.999999')
               || '], l_debt_rest ['           || l_debt_rest
    );

    begin
        if io_dpp.calc_algorithm = dpp_api_const_pkg.DPP_ALGORITHM_DIFFERENTIATED then
            calc_differentiated(
                io_dpp                => io_dpp
              , io_instalments        => io_instalments
              , i_eff_date            => l_eff_date
              , i_first_payment_date  => i_first_payment_date
              , i_debt_rest           => l_debt_rest
            );
        elsif io_dpp.calc_algorithm in (dpp_api_const_pkg.DPP_ALGORITHM_ANNUITY
                                      , dpp_api_const_pkg.DPP_ALGORITHM_FIXED_AMOUNT)
        then
            calc_annuity(
                io_dpp                => io_dpp
              , io_instalments        => io_instalments
              , i_eff_date            => l_eff_date
              , i_first_payment_date  => i_first_payment_date
              , i_debt_rest           => l_debt_rest
            );
        else
            dpp_api_algo_proc_pkg.process_algorithm(
                io_dpp                => io_dpp
              , io_instalments        => io_instalments
              , i_eff_date            => l_eff_date
              , i_first_payment_date  => i_first_payment_date
              , i_debt_rest           => l_debt_rest
            );
        end if;
    exception
        when e_stop_on_full_repayment then
            null;
    end;


    check_instalments(
        io_dpp         => io_dpp
      , io_instalments => io_instalments
    );

    trc_log_pkg.debug(
        i_text       => 'calc_instalments() >>'
                     ||   ' instalment_count ['        || io_dpp.instalment_count
                     || '], instalment_amount ['       || io_dpp.instalment_amount
                     || '], io_instalments.count() = ' || io_instalments.count()
                     || '], calc_algorithm ['          || io_dpp.calc_algorithm
                     || ']'
    );
exception
    when e_unable_to_calculate_dpp then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_UNABLE_TO_CALCULATE_INSTALMENTS'
          , i_env_param1 => io_dpp.instalment_count
          , i_env_param2 => io_dpp.instalment_amount
          , i_env_param3 => io_dpp.calc_algorithm
        );
end calc_instalments;

function create_dpp_operation(
    i_original_oper_id        in     com_api_type_pkg.t_long_id
  , i_oper_amount             in     com_api_type_pkg.t_money
  , i_oper_currency           in     com_api_type_pkg.t_curr_code
  , i_account_id              in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_long_id
is
    l_issuer                         opr_api_type_pkg.t_oper_part_rec;
    l_oper_id                        com_api_type_pkg.t_long_id;
begin
    -- In the case of wrong configuration, rule set for operation type OPERATION_TYPE_DPP_REGISTER may contain
    -- DPP registering rule, it will lead to infinite recursion. The following check avoids this.
    if opr_api_shared_data_pkg.get_operation().oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER then
        com_api_error_pkg.raise_error(
            i_error       => 'DPP_INVALID_ORIGINAL_OPERATION_TYPE'
          , i_env_param1  => i_original_oper_id
          , i_env_param2  => opr_api_shared_data_pkg.get_operation().oper_type
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => i_original_oper_id
        );
    end if;

    opr_api_create_pkg.create_operation(
        io_oper_id          => l_oper_id
      , i_is_reversal       => com_api_const_pkg.FALSE
      , i_original_id       => i_original_oper_id
      , i_oper_type         => dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
      , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL
      , i_oper_amount       => i_oper_amount
      , i_oper_currency     => i_oper_currency
      , i_oper_reason       => dpp_api_const_pkg.OPER_REASON_GENERATED_BY_DPP
    );

    opr_api_operation_pkg.get_participant(
        i_oper_id           => i_original_oper_id
      , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
      , o_participant       => l_issuer
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type         => dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_client_id_type    => l_issuer.client_id_type
      , i_client_id_value   => l_issuer.client_id_value
      , i_inst_id           => l_issuer.inst_id
      , i_network_id        => l_issuer.network_id
      , i_card_inst_id      => l_issuer.card_inst_id
      , i_card_network_id   => l_issuer.card_network_id
      , i_card_id           => l_issuer.card_id
      , i_card_instance_id  => l_issuer.card_instance_id
      , i_card_type_id      => l_issuer.card_type_id
      , i_card_number       => l_issuer.card_number
      , i_card_hash         => l_issuer.card_hash
      , i_card_seq_number   => l_issuer.card_seq_number
      , i_card_expir_date   => l_issuer.card_expir_date
      , i_card_service_code => l_issuer.card_service_code
      , i_card_country      => l_issuer.card_country
      , i_customer_id       => l_issuer.customer_id
      , i_account_id        => i_account_id
      , i_split_hash        => l_issuer.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );

    return l_oper_id;
end;

/*
 * Process DPP-operation: registration, acceleration, cancellation.
 */
procedure process_operation(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_action                  in     com_api_type_pkg.t_name
) is
    l_operation                      opr_api_type_pkg.t_oper_rec;
begin
    opr_api_process_pkg.process_operation(
        i_operation_id  => i_oper_id
      , i_commit_work   => com_api_const_pkg.FALSE
    );
    opr_api_operation_pkg.get_operation(
        i_oper_id       => i_oper_id
      , o_operation     => l_operation
    );
    -- If the operation is unsuccessfully processed, current DPP action should fail too for consistency.
    if l_operation.status not in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED) then
        com_api_error_pkg.raise_error(
            i_error       => 'DPP_PROCESSING_OPERATION_FAILED'
          , i_env_param1  => l_operation.id
          , i_env_param2  => l_operation.oper_type
          , i_env_param3  => l_operation.status
          , i_env_param4  => l_operation.status_reason
          , i_env_param5  => i_action
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => i_oper_id
        );
    end if;
end process_operation;

/*
 * [Currently is NOT used] Bulk registering a new DPP via XML file.
 * @i_xml          - incoming XML file
 * @i_inst_id      - institution ID
 * @i_sess_file_id - session file ID
 * @o_result       - response XML file with the same structure
 */
procedure register_dpp(
    i_xml              in     xmltype
  , i_inst_id          in     com_api_type_pkg.t_inst_id default null
  , i_sess_file_id     in     com_api_type_pkg.t_long_id default null
  , o_result              out xmltype
) is
    l_file_id                 com_api_type_pkg.t_long_id;
    l_file_type               com_api_type_pkg.t_dict_value;
    l_original_file_id        com_api_type_pkg.t_long_id;
    l_start_date              date;
    l_end_date                date;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_dpp_rec                 dpp_api_type_pkg.t_dpp;
    l_dpp_tab                 dpp_api_type_pkg.t_dpp_tab;
    l_query                   clob;
    l_ids                     clob;
    l_result_xml              xmltype;
    l_attr_id                 com_api_type_pkg.t_short_id;
begin
    if i_xml is not null then
        for rec in (
            select extractvalue(a.column_value, '/dpps/file_id')             file_id
                 , extractvalue(a.column_value, '/dpps/file_type' )          file_type
                 , extractvalue(a.column_value, '/dpps/original_file_id')    original_file_id
                 , extractvalue(a.column_value, '/dpps/start_date')          start_date
                 , extractvalue(a.column_value, '/dpps/end_date')            end_date
                 , extractvalue(a.column_value, '/dpps/inst_id')             inst_id
                 , extractvalue(r.column_value, '/dpp/dpp_id')               dpp_id
                 , extractvalue(r.column_value, '/dpp/oper_id')              oper_id
                 , extractvalue(r.column_value, '/dpp/macros_id')            macros_id
                 , extractvalue(r.column_value, '/dpp/account_id')           account_id
                 , extractvalue(r.column_value, '/dpp/card_id')              card_id
                 , extractvalue(r.column_value, '/dpp/oper_date')            oper_date
                 , extractvalue(r.column_value, '/dpp/oper_amount')          oper_amount
                 , extractvalue(r.column_value, '/dpp/oper_currency')        oper_currency
                 , extractvalue(r.column_value, '/dpp/dpp_amount')           dpp_amount
                 , extractvalue(r.column_value, '/dpp/dpp_currency')         dpp_currency
                 , extractvalue(r.column_value, '/dpp/calc_algorithm')       calc_algorithm
                 , extractvalue(r.column_value, '/dpp/interest_amount')      interest_amount
                 , extractvalue(r.column_value, '/dpp/instalment_amount')    instalment_amount
                 , extractvalue(r.column_value, '/dpp/instalment_count')     instalment_count
                 , extractvalue(r.column_value, '/dpp/next_instalment_date') next_instalment_date
                 , extractvalue(r.column_value, '/dpp/reg_oper_id')          reg_oper_id
              from table(xmlsequence(extract(i_xml, 'dpps')))  a
                 , table(xmlsequence(extract(i_xml, 'dpps/dpp')))  r
        ) loop
            l_file_id          := to_number(rec.file_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            l_original_file_id := to_number(rec.original_file_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            l_file_type        := rec.file_type;
            l_start_date       := to_date(rec.start_date, com_api_const_pkg.XML_DATE_FORMAT);
            l_end_date         := to_date(rec.end_date, com_api_const_pkg.XML_DATE_FORMAT);
            l_inst_id          := to_number(rec.inst_id, com_api_const_pkg.XML_NUMBER_FORMAT);

            l_dpp_rec.id                   := to_number(rec.dpp_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            if l_dpp_rec.id is null then
                l_dpp_rec.id                 := to_number(rec.macros_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            end if;

            l_dpp_rec.oper_id              := to_number(rec.oper_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            l_dpp_rec.inst_id              := to_number(rec.inst_id, com_api_const_pkg.XML_NUMBER_FORMAT);

            if l_dpp_rec.inst_id is not null
           and i_inst_id is not null
           and l_dpp_rec.inst_id != i_inst_id
           and i_inst_id != ost_api_const_pkg.DEFAULT_INST
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'TWO_DIFFERENT_INSTITUTES'
                  , i_env_param1 => l_dpp_rec.inst_id
                  , i_env_param2 => i_inst_id
                );
            end if;

            l_dpp_rec.account_id           := to_number(rec.account_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            l_dpp_rec.card_id              := to_number(rec.card_id, com_api_const_pkg.XML_NUMBER_FORMAT);
            l_dpp_rec.oper_date            := to_date(rec.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT);
            l_dpp_rec.oper_amount          := to_number(rec.oper_amount, com_api_const_pkg.XML_FLOAT_FORMAT);
            l_dpp_rec.oper_currency        := rec.oper_currency;
            l_dpp_rec.dpp_amount           := to_number(rec.dpp_amount, com_api_const_pkg.XML_FLOAT_FORMAT);
            l_dpp_rec.dpp_currency         := rec.dpp_currency;
            l_dpp_rec.dpp_algorithm        := rec.calc_algorithm;
            l_dpp_rec.interest_amount      := to_number(rec.interest_amount, com_api_const_pkg.XML_FLOAT_FORMAT);
            l_dpp_rec.instalment_amount    := to_number(rec.instalment_amount, com_api_const_pkg.XML_FLOAT_FORMAT);
            l_dpp_rec.instalment_total     := to_number(rec.instalment_count, com_api_const_pkg.XML_NUMBER_FORMAT);
            l_dpp_rec.next_instalment_date := to_date(rec.next_instalment_date, com_api_const_pkg.XML_DATE_FORMAT);
            l_dpp_rec.reg_oper_id          := to_number(rec.reg_oper_id, com_api_const_pkg.XML_NUMBER_FORMAT);

            trc_log_pkg.debug('register_dpp(xml): found dpp_id = '||rec.dpp_id);
            l_dpp_tab(l_dpp_tab.count + 1)     := l_dpp_rec;
        end loop;

        if i_sess_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id =>  i_sess_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count => l_dpp_tab.count
            );
        end if;

        register_dpp(
            i_dpp_tab          => l_dpp_tab
        );

        l_attr_id := prd_api_attribute_pkg.get_attribute(i_attr_name => 'DPP_ALGORITHM').id;

        l_query :=
'declare namespace functx = "http://www.functx.com";
declare function functx:lower-case-element-names(
    $nodes as node()*
)  as node()*
{
  for $node in $nodes
   return if ($node instance of element())
          then element
                 {QName("", lower-case(name($node))) }
                 {$node/@*, functx:lower-case-element-names($node/node())
               }
            else if ($node instance of document-node())
            then functx:lower-case-element-names($node/node())
          else $node
 } ;
 for $p in collection("oradb:/' || upper(user) || '/DPP_PAYMENT_PLAN")/ROW
   , $v in collection("oradb:/' || upper(user) || '/DPP_ATTRIBUTE_VALUE")/ROW
   let $x := functx:lower-case-element-names($p)
   where $p/ID = ';

        l_ids := '(';
        for x in l_dpp_tab.first .. l_dpp_tab.last loop
            l_ids := l_ids || to_char(l_dpp_tab(x).id, com_api_const_pkg.XML_NUMBER_FORMAT);
            if x < l_dpp_tab.last then
                l_ids := l_ids || ', ';
            else
                l_ids := l_ids || ') ';
            end if;
        end loop;

       l_query := l_query || l_ids||
 ' and $p/ID = $v/DPP_ID
 and $v/ATTR_ID = $attr_id
 return <dpp>
   <dpp_id>{data($x/id)}</dpp_id>
   {$x/oper_id}
   <macros_id>{data($x/id)}</macros_id>
   {$x/account_id}
   {$x/card_id}
   <oper_date>{normalize-space(xs:string(xs:dateTime($x/oper_date)))}</oper_date>
   {$x/oper_amount}
   {$x/oper_currency}
   {$x/dpp_amount}
   {$x/dpp_currency}
   <calc_algorithm>{data($v/VALUE)}</calc_algorithm>
   {$x/interest_amount}
   {$x/instalment_amount}
   <instalment_count>{data($x/instalment_total)}</instalment_count>
   {$x/next_instalment_date}
   {$x/reg_oper_id}
   </dpp>';

        select XMLQuery(l_query
                        passing to_char(l_attr_id, com_api_const_pkg.XML_NUMBER_FORMAT) as "attr_id"
                        RETURNING CONTENT)
          into l_result_xml
          from dual;

        select XMLConcat(
                   XMLElement("dpps"
                     , xmlattributes('http://bpc.ru/sv/SVXP/dpps' as "xmlns:dpps")
                     , xmlelement("file_id"         , null)
                     , xmlelement("file_type"       , dpp_api_const_pkg.FILE_TYPE_DPP_REGISTRATION)
                     , xmlelement("original_file_id", to_char(i_sess_file_id, com_api_const_pkg.XML_NUMBER_FORMAT))
                     , xmlelement("start_date"      , to_char(l_start_date  , com_api_const_pkg.XML_DATE_FORMAT))
                     , xmlelement("end_date"        , to_char(l_end_date    , com_api_const_pkg.XML_DATE_FORMAT))
                     , xmlelement("inst_id"         , to_char(l_inst_id     , com_api_const_pkg.XML_NUMBER_FORMAT))
                     , l_result_xml
                   )
               )
          into o_result
          from dual;
    else
        trc_log_pkg.debug('empty result file - no response file generated');
    end if;

end;

/*
 * [Currently is NOT used] Bulk registering a new DPP.
 * @i_dpp_tab   - collection-parameter: array of dpp_api_type_pkg.t_dpp_tab
 */
procedure register_dpp(
    i_dpp_tab      in     dpp_api_type_pkg.t_dpp_tab
) is
    l_param_tab           com_api_type_pkg.t_param_tab;
    l_oper_id             com_api_type_pkg.t_long_id;
    l_oper_amount         com_api_type_pkg.t_money;
    l_dpp_amount          com_api_type_pkg.t_money;
begin
    if i_dpp_tab.count > 0 then

        for i in i_dpp_tab.first .. i_dpp_tab.last loop
            l_oper_id     := i_dpp_tab(i).oper_id;
            l_oper_amount := i_dpp_tab(i).oper_amount;
            l_dpp_amount  := i_dpp_tab(i).dpp_amount;

            register_dpp(
                i_account_id        => i_dpp_tab(i).account_id
              , i_dpp_algorithm     => i_dpp_tab(i).dpp_algorithm
              , i_instalment_count  => i_dpp_tab(i).instalment_total
              , i_instalment_amount => i_dpp_tab(i).instalment_amount
              , i_fee_id            => null
              , i_dpp_amount        => i_dpp_tab(i).dpp_amount
              , i_dpp_currency      => i_dpp_tab(i).dpp_currency
              , i_macros_id         => i_dpp_tab(i).id
              , i_oper_id           => i_dpp_tab(i).oper_id
              , i_param_tab         => l_param_tab
            );
          end loop;
    else
        trc_log_pkg.debug(i_text => 'register_dpp: i_dpp_tab.count =0');
    end if;
exception
    when com_api_error_pkg.e_application_error then
        com_api_error_pkg.raise_error(
            i_error        => 'DPP_REGISTERING_ERROR'
          , i_env_param1   => l_oper_id
          , i_env_param2   => l_oper_amount
          , i_env_param3   => l_dpp_amount
          , i_env_param4   => com_api_error_pkg.get_last_message()
         );
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
end register_dpp;

/*
 * Registering a new DPP.
 */
procedure register_dpp(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_dpp_algorithm           in     com_api_type_pkg.t_dict_value
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id
  , i_instalment_amount       in     com_api_type_pkg.t_money
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_percent_rate            in     com_api_type_pkg.t_money       default null
  , i_first_payment_date      in     date                           default null
  , i_dpp_amount              in     com_api_type_pkg.t_money
  , i_dpp_currency            in     com_api_type_pkg.t_curr_code
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_param_tab               in     com_api_type_pkg.t_param_tab
  , i_create_reg_oper         in     com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
) is
    l_service_id                     com_api_type_pkg.t_short_id;
    l_eff_date                       date;
    l_params                         com_api_type_pkg.t_param_tab := i_param_tab;
    l_instalments                    dpp_api_type_pkg.t_dpp_instalment_tab;
    l_interest_amount                com_api_type_pkg.t_money;
    l_min_dpp_amount                 com_api_type_pkg.t_money;
    l_macros_amount                  com_api_type_pkg.t_money;
    l_dpp                            dpp_api_type_pkg.t_dpp_program;
    l_account_type                   com_api_type_pkg.t_dict_value;
    l_dpp_currency                   com_api_type_pkg.t_curr_code;
    l_id                             com_api_type_pkg.t_long_id;
    l_customer_id                    com_api_type_pkg.t_medium_id;
    l_account_status                 com_api_type_pkg.t_dict_value;
    l_allow_billed_oper              com_api_type_pkg.t_boolean;
    l_oper_is_billed                 com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => 'register_dpp() << i_dpp_algorithm [#1]'
                     ||  ', i_account_id ['        || i_account_id
                     || '], i_dpp_amount ['        || i_dpp_amount
                     || '], i_dpp_currency ['      || i_dpp_currency
                     || '], i_instalment_count ['  || i_instalment_count
                     || '], i_instalment_amount [' || i_instalment_amount
                     || '], i_fee_id ['            || i_fee_id
                     || '], i_macros_id ['         || i_macros_id
                     || '], i_oper_id ['           || i_oper_id || ']'
      , i_env_param1 => i_dpp_algorithm
    );

    -- Check mandatory fields
    if i_macros_id is null or i_dpp_amount is null then
        com_api_error_pkg.raise_error(
            i_error       => 'IMPOSSIBLE_TO_REGISTER_DPP'
          , i_env_param1  => i_dpp_amount
          , i_env_param2  => i_macros_id
        );
    else
        l_dpp.dpp_id := i_macros_id;
    end if;

    begin
        select p.card_id
             , o.oper_amount
             , o.oper_currency
             , o.oper_date
             , o.oper_type
             , m.amount
          into l_dpp.card_id
             , l_dpp.oper_amount
             , l_dpp.oper_currency
             , l_dpp.oper_date
             , l_dpp.oper_type
             , l_macros_amount
          from opr_operation   o
             , opr_participant p
             , acc_macros      m
         where o.id               = i_oper_id
           and p.oper_id          = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and m.object_id        = o.id
           and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and m.id               = i_macros_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'DPP_OPERATION_NOT_FOUND'
              , i_env_param1  => i_oper_id
              , i_env_param2  => i_macros_id
            );
    end;

    if i_dpp_amount > l_macros_amount then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_AMOUNT_IS_GREATER_THAN_MACROS_AMOUNT'
          , i_env_param1 => i_account_id
          , i_env_param2 => i_dpp_amount
          , i_env_param3 => l_macros_amount
        );
    end if;

    begin
        select a.id
             , a.split_hash
             , a.account_type
             , a.inst_id
             , c.product_id
             , c.customer_id
             , a.status
          into l_dpp.account_id
             , l_dpp.split_hash
             , l_account_type
             , l_dpp.inst_id
             , l_dpp.product_id
             , l_customer_id
             , l_account_status
          from acc_account a
             , prd_contract c
         where a.contract_id = c.id
           and a.id = i_account_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => i_account_id
            );
    end;

    if l_account_status in (acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
                          , acc_api_const_pkg.ACCOUNT_STATUS_DEBT_RESTRUCT)
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_ACCOUNT_STATUS'
          , i_env_param1 => l_account_status
        );
    end if;

    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_dpp.inst_id);

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id           => i_account_id
          , i_attr_name           => null
          , i_service_type_id     => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
          , i_split_hash          => l_dpp.split_hash
          , i_eff_date            => l_eff_date
          , i_mask_error          => com_api_const_pkg.TRUE
          , i_inst_id             => l_dpp.inst_id
        );
    if l_service_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'DPP_SERVICE_NOT_FOUND'
          , i_env_param2  => i_account_id
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    end if;

    -- Check that DPP amount is not less than the minimum amount of the product (or it is undefined)
    begin
        l_dpp.fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id      => l_dpp.product_id
              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id       => i_account_id
              , i_fee_type        => dpp_api_const_pkg.FEE_TYPE_MINIMUM_AMOUNT
              , i_params          => l_params
              , i_service_id      => l_service_id
              , i_eff_date        => l_eff_date
              , i_split_hash      => l_dpp.split_hash
              , i_inst_id         => l_dpp.inst_id
              , i_mask_error      => com_api_const_pkg.TRUE
            );

        l_dpp_currency   := i_dpp_currency;
        l_min_dpp_amount :=
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id          => l_dpp.fee_id
              , i_base_amount     => 0
              , io_base_currency  => l_dpp_currency
              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id       => i_account_id
              , i_eff_date        => l_eff_date
            );
    exception
        when com_api_error_pkg.e_application_error then
            null;
    end;

    trc_log_pkg.debug(
        i_text       => 'Checking DPP minimum amount: fee_id [#1], l_min_dpp_amount [#2]'
      , i_env_param1 => l_dpp.fee_id
      , i_env_param2 => l_min_dpp_amount
    );

    l_dpp.fee_id := null;

    if i_dpp_amount < l_min_dpp_amount then -- Ignore nullable min DPP value
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_AMOUNT_IS_LESS_THAN_MINIMUM_AMOUNT'
          , i_env_param1 => i_account_id
          , i_env_param2 => i_dpp_amount
          , i_env_param3 => l_min_dpp_amount
        );
    end if;

    rul_api_shared_data_pkg.load_account_params(
        i_account_id    => i_account_id
      , io_params       => l_params
    );

    rul_api_shared_data_pkg.load_card_params(
        i_card_id       => l_dpp.card_id
      , io_params       => l_params
    );

    rul_api_shared_data_pkg.load_customer_params(
        i_customer_id   => l_customer_id
      , io_params       => l_params
    );

    l_dpp.calc_algorithm :=
        coalesce(
            i_dpp_algorithm
          , prd_api_product_pkg.get_attr_value_char(
                i_product_id   => l_dpp.product_id
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_attr_name    => dpp_api_const_pkg.ATTR_ALGORITHM
              , i_params       => l_params
              , i_service_id   => l_service_id
              , i_eff_date     => l_eff_date
              , i_split_hash   => l_dpp.split_hash
              , i_inst_id      => l_dpp.inst_id
            )
        );

    l_dpp.instalment_count :=
        coalesce(
            i_instalment_count
          , prd_api_product_pkg.get_attr_value_number(
                i_product_id   => l_dpp.product_id
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_attr_name    => dpp_api_const_pkg.ATTR_INSTALMENT_COUNT
              , i_params       => l_params
              , i_service_id   => l_service_id
              , i_eff_date     => l_eff_date
              , i_split_hash   => l_dpp.split_hash
              , i_inst_id      => l_dpp.inst_id
            )
        );

    -- needed for determine fee_id in depend of installment count
    rul_api_param_pkg.set_param(
        i_name    => 'INSTALMENT_COUNT'
      , i_value   => l_dpp.instalment_count
      , io_params => l_params
    );

    l_dpp.instalment_amount := i_instalment_amount;

    if l_dpp.instalment_amount is null then
        l_dpp.fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id    => l_dpp.product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
              , i_fee_type      => dpp_api_const_pkg.FEE_TYPE_FIXED_PAYMENT
              , i_split_hash    => l_dpp.split_hash
              , i_service_id    => l_service_id
              , i_params        => l_params
              , i_eff_date      => l_eff_date
              , i_inst_id       => l_dpp.inst_id
            );

        l_dpp_currency := i_dpp_currency;

        l_dpp.instalment_amount := round(
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id            => l_dpp.fee_id
              , i_base_amount       => 0
              , io_base_currency    => l_dpp_currency
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_eff_date          => l_eff_date
            )
        );

        l_dpp.fee_id := null;
    end if;

    rul_api_param_pkg.set_param(
        i_name    => 'INSTALMENT_FIXED_AMOUNT'
      , i_value   => l_dpp.instalment_amount
      , io_params => l_params
    );

    if i_fee_id is not null then
        l_dpp.fee_id := i_fee_id;
    end if;

    trc_log_pkg.debug(
        i_text => 'percent rate from auth_tag = ' || i_percent_rate
    );

    fcl_api_fee_pkg.save_fee(
        io_fee_id       => l_dpp.fee_id
      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id     => l_dpp.account_id
      , i_attr_name     => dpp_api_const_pkg.ATTR_FEE_ID
      , i_percent_rate  => i_percent_rate
      , i_product_id    => l_dpp.product_id
      , i_service_id    => l_service_id
      , i_eff_date      => l_eff_date
      , i_fee_currency  => l_dpp.oper_currency
      , i_fee_type      => dpp_api_const_pkg.FEE_TYPE_INTEREST
      , i_fee_rate_calc => fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
      , i_fee_base_calc => fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
      , i_length_type   => fcl_api_const_pkg.CYCLE_LENGTH_YEAR
      , i_inst_id       => l_dpp.inst_id
      , i_split_hash    => l_dpp.split_hash
      , i_search_fee    => com_api_const_pkg.TRUE
      , io_params       => l_params
    );

    if l_dpp.fee_id is not null then
        l_dpp.percent_rate := get_year_percent_in_fraction(l_dpp.fee_id);
    end if;

    l_dpp.first_cycle_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_FIRST_CYCLE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
        );

    l_dpp.main_cycle_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_MAIN_CYCLE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
        );

    l_dpp.dpp_limit :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_LIMIT
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.cancel_fee_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CANCEL_FEE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.min_early_repayment:=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_MIN_EARLY_REPAYMENT
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.accel_fee_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_ACCEL_FEE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.fixed_instalment :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_FIXED_INSTALMENTS
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.macros_type_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_MACROS_TYPE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_dpp.macros_intr_type_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_MACROS_INTR_TYPE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_dpp.cancel_m_type_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CANCEL_M_TYPE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_dpp.cancel_m_intr_type_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CANCEL_M_INTR_TYPE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_dpp.repay_macros_type_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_REPAY_MACROS_TYPE_ID
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.rate_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_RATE_ALGORITHM
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.credit_macros_type :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CREDIT_MACROS_TYPE
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.credit_macros_intr_type :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CREDIT_MACROS_INTR_TYPE
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.credit_repay_macros_type :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CREDIT_REPAY_MACROS_TYPE
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.cancel_credit_m_type :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CANCEL_CREDIT_M_TYPE
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    l_dpp.cancel_intr_credit_m_type :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_CANCEL_INTR_CREDIT_M_TYPE
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_use_default_value => com_api_const_pkg.TRUE
        );

    -- Saving attributes values
    dpp_api_attribute_value_pkg.save_attribute_values(
        i_dpp  => l_dpp
    );

    l_dpp.dpp_amount   := i_dpp_amount;

    -- checking to prevent annu payment for 0%
    if  l_dpp.calc_algorithm in (dpp_api_const_pkg.DPP_ALGORITHM_ANNUITY
                               , dpp_api_const_pkg.DPP_ALGORITHM_FIXED_AMOUNT)
        and l_dpp.percent_rate = 0
    then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_REGISTER_DPP_ZERO_PERCENT'
          , i_env_param1 => l_dpp.calc_algorithm
        );
    end if;

    calc_instalments(
        io_dpp               => l_dpp
      , i_first_amount       => null
      , io_instalments       => l_instalments
      , i_first_payment_date => i_first_payment_date
    );

    l_interest_amount := 0;
    for i in 1..l_instalments.count loop
        l_interest_amount := l_interest_amount + l_instalments(i).interest;
    end loop;

    -- For the check below and adding DPP instalment payment amount l_instalments(1).amount is used
    -- instead of l_dpp.isntalment_amount because for the case of differentiated payments field
    -- l_dpp.isntalment_amount contains fixed part of instalment payment (without interest amount)

    -- Custom check of DPP
    dpp_cst_payment_plan_pkg.check_dpp_before_register(
        i_account_id         => i_account_id
      , i_dpp_algorithm      => i_dpp_algorithm
      , i_instalment_count   => l_dpp.instalment_count
      , i_instalment_amount  => l_instalments(1).amount
      , i_fee_id             => i_fee_id
      , i_dpp_amount         => i_dpp_amount
      , i_dpp_currency       => i_dpp_currency
      , i_macros_id          => i_macros_id
      , i_oper_id            => i_oper_id
      , i_param_tab          => i_param_tab
      , i_service_id         => l_service_id
      , i_product_id         => l_dpp.product_id
      , i_split_hash         => l_dpp.split_hash
      , i_account_type       => l_account_type
      , i_card_id            => l_dpp.card_id
      , i_inst_id            => l_dpp.inst_id
      , i_oper_amount        => l_dpp.oper_amount
      , i_oper_currency      => l_dpp.oper_currency
      , i_eff_date           => l_eff_date
    );

    if i_create_reg_oper = com_api_const_pkg.TRUE then
        l_dpp.reg_oper_id :=
            create_dpp_operation(
                i_original_oper_id  => i_oper_id
              , i_oper_amount       => i_dpp_amount
              , i_oper_currency     => i_dpp_currency
              , i_account_id        => i_account_id
            );
    else
        l_dpp.reg_oper_id := i_oper_id;
    end if;

    l_allow_billed_oper :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_dpp.product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => dpp_api_const_pkg.ATTR_ALLOW_BILLED_OPER
          , i_params            => l_params
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_dpp.split_hash
          , i_inst_id           => l_dpp.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => com_api_const_pkg.FALSE
        );

    l_oper_is_billed := crd_api_debt_pkg.check_operation_billing(i_oper_id => i_oper_id);

    trc_log_pkg.debug(
        i_text        => 'l_allow_billed_oper = [#1], l_oper_is_billed = [#2]'
      , i_env_param1  => l_allow_billed_oper
      , i_env_param2  => l_oper_is_billed
    );

    if l_allow_billed_oper = com_api_const_pkg.FALSE and l_oper_is_billed = com_api_const_pkg.TRUE then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_REGISTER_DPP'
          , i_env_param1 => i_oper_id
        );
    end if;

    add_payment_plan(
        i_id                   => i_macros_id
      , i_oper_id              => i_oper_id
      , i_reg_oper_id          => l_dpp.reg_oper_id
      , i_account_id           => i_account_id
      , i_card_id              => l_dpp.card_id
      , i_product_id           => l_dpp.product_id
      , i_oper_date            => l_dpp.oper_date
      , i_oper_amount          => l_dpp.oper_amount
      , i_oper_currency        => l_dpp.oper_currency
      , i_dpp_amount           => i_dpp_amount
      , i_dpp_currency         => i_dpp_currency
      , i_interest_amount      => l_interest_amount
      , i_status               => dpp_api_const_pkg.DPP_OPERATION_ACTIVE
      , i_instalment_amount    => l_instalments(1).amount
      , i_instalment_total     => l_dpp.instalment_count
      , i_instalment_billed    => 0
      , i_next_instalment_date => l_instalments(1).instalment_date
      , i_debt_balance         => i_dpp_amount
      , i_inst_id              => l_dpp.inst_id
      , i_split_hash           => l_dpp.split_hash
      , i_posting_date         => l_eff_date
      , i_oper_type            => l_dpp.oper_type
    );

    for n in 1..l_instalments.count loop
        dpp_api_instalment_pkg.add_instalment(
            o_id                   => l_id
          , i_dpp_id               => i_macros_id
          , i_instalment_number    => n
          , i_instalment_date      => l_instalments(n).instalment_date
          , i_instalment_amount    => l_instalments(n).amount
          , i_payment_amount       => null -- early repayment isn't possible on DPP registration
          , i_interest_amount      => l_instalments(n).interest
          , i_macros_id            => null
          , i_macros_intr_id       => null
          , i_acceleration_type    => null
          , i_split_hash           => l_dpp.split_hash
          , i_fee_id               => l_instalments(n).fee_id
          , i_acceleration_reason  => l_instalments(n).acceleration_reason
        );
    end loop;

    if i_create_reg_oper = com_api_const_pkg.TRUE then
        -- If DPP is registered not by GUI (e.g. by some rule during processing some parent operation),
        -- a transaction shouldn't be commited to provide possibility to rollback changes (e.g., on some
        -- error during processing mentioned parent operation)
        process_operation(
            i_oper_id         => l_dpp.reg_oper_id
          , i_action          => 'registration'
        );
    end if;

    evt_api_event_pkg.register_event(
        i_event_type      => dpp_api_const_pkg.EVENT_TYPE_REGISTER_PLAN
      , i_eff_date        => l_eff_date
      , i_entity_type     => dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN
      , i_object_id       => i_macros_id
      , i_inst_id         => l_dpp.inst_id
      , i_split_hash      => l_dpp.split_hash
      , i_param_tab       => l_params
    );
end register_dpp;

function get_dpp_program(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
) return dpp_api_type_pkg.t_dpp_program
is
    l_dpp_program                    dpp_api_type_pkg.t_dpp_program;
begin
    select to_number(substr(instalment_count, 9),     com_api_const_pkg.NUMBER_FORMAT)      as instalment_count
         , instalment_amount
         , to_number(substr(main_cycle_id, 9),        com_api_const_pkg.NUMBER_FORMAT)      as main_cycle_id
         , to_number(substr(first_cycle_id, 9),       com_api_const_pkg.NUMBER_FORMAT)      as first_cycle_id
         , to_number(substr(fee_id, 9),               com_api_const_pkg.NUMBER_FORMAT)      as fee_id
         , substr(calc_algorithm, 9)                                                        as calc_algorithm
         , to_number(substr(fixed_instalment, 9),     com_api_const_pkg.NUMBER_FORMAT)      as fixed_instalment
         , to_number(substr(fixed_amount, 9),         com_api_const_pkg.NUMBER_FORMAT)      as fixed_amount
         , to_number(substr(accel_fee_id, 9),         com_api_const_pkg.NUMBER_FORMAT)      as accel_fee_id
         , to_number(substr(min_early_repayment, 9),  com_api_const_pkg.NUMBER_FORMAT)      as min_early_repayment
         , to_number(substr(cancel_fee_id, 9),        com_api_const_pkg.NUMBER_FORMAT)      as cancel_fee_id
         , to_number(substr(dpp_limit, 9),            com_api_const_pkg.NUMBER_FORMAT)      as dpp_limit
         , oper_date
         , oper_amount
         , oper_currency
         , account_id
         , to_number(substr(macros_type_id, 9),       com_api_const_pkg.NUMBER_FORMAT)      as macros_type_id
         , to_number(substr(macros_intr_type_id, 9),  com_api_const_pkg.NUMBER_FORMAT)      as macros_intr_type_id
         , to_number(substr(repay_macros_type_id, 9), com_api_const_pkg.NUMBER_FORMAT)      as repay_macros_type_id
         , inst_id
         , split_hash
         , dpp_amount
         , dpp_currency
         , card_id
         , dpp_api_payment_plan_pkg.get_year_percent_in_fraction(
               i_fee_id => to_number(substr(fee_id, 19, 8))
           )                                                                                as percent_rate
         , status
         , id                                                                               as dpp_id
         , oper_id
         , reg_oper_id
         , posting_date
         , product_id
         , oper_type
         , to_number(substr(cancel_m_type_id, 9), com_api_const_pkg.NUMBER_FORMAT)          as cancel_m_type_id
         , to_number(substr(cancel_m_intr_type_id, 9), com_api_const_pkg.NUMBER_FORMAT)     as cancel_m_intr_type_id
         , null
         , substr(rate_algorithm, 9)                                                        as rate_algorithm
         , to_number(substr(credit_macros_type, 9),        com_api_const_pkg.NUMBER_FORMAT) as credit_macros_type
         , to_number(substr(credit_macros_intr_type, 9),   com_api_const_pkg.NUMBER_FORMAT) as credit_macros_intr_type
         , to_number(substr(credit_repay_macros_type, 9),  com_api_const_pkg.NUMBER_FORMAT) as credit_repay_macros_type
         , to_number(substr(cancel_credit_m_type, 9),      com_api_const_pkg.NUMBER_FORMAT) as cancel_credit_m_type
         , to_number(substr(cancel_intr_credit_m_type, 9), com_api_const_pkg.NUMBER_FORMAT) as cancel_intr_credit_m_type
         , null
         , null
      into l_dpp_program
      from (
          select a.attr_name
               , a.data_type
               , da.value
               , pp.instalment_amount
               , pp.oper_date
               , pp.oper_amount
               , pp.oper_currency
               , pp.account_id
               , pp.inst_id
               , pp.split_hash
               , pp.dpp_amount
               , pp.dpp_currency
               , pp.card_id
               , pp.status
               , pp.id
               , pp.oper_id
               , pp.reg_oper_id
               , pp.posting_date
               , pp.product_id
               , pp.oper_type
            from dpp_attribute_value da
               , prd_attribute a
               , dpp_payment_plan pp
           where pp.id = i_dpp_id
             and da.dpp_id = pp.id
             and pp.split_hash = da.split_hash
             and a.id = da.attr_id
      )
    pivot (
        max(data_type || value)
        for attr_name in (
            'DPP_INSTALMENT_COUNT'                   as instalment_count
          , 'DPP_INSTALMENT_PERIOD'                  as main_cycle_id
          , 'DPP_FIRST_INSTALMENT_DATE'              as first_cycle_id
          , 'DPP_INTEREST_RATE'                      as fee_id
          , 'DPP_ALGORITHM'                          as calc_algorithm
          , 'DPP_FIXED_INSTALMENTS'                  as fixed_instalment
          , 'DPP_ACCELERATION_FEE'                   as accel_fee_id
          , 'DPP_MIN_EARLY_REPAYMENT'                as min_early_repayment
          , 'DPP_CANCELATION_FEE'                    as cancel_fee_id
          , 'DPP_LIMIT'                              as dpp_limit
          , 'DPP_INSTALMENT_MACROS_TYPE'             as macros_type_id
          , 'DPP_INSTALMENT_MACROS_INTEREST_TYPE'    as macros_intr_type_id
          , 'DPP_EARLY_REPAYMENT_MACROS_TYPE'        as repay_macros_type_id
          , 'DPP_INSTALMENT_FIXED_AMOUNT'            as fixed_amount
          , 'DPP_CANCEL_MACROS_TYPE'                 as cancel_m_type_id
          , 'DPP_CANCEL_MACROS_INTEREST_TYPE'        as cancel_m_intr_type_id
          , 'DPP_RATE_CALC_ALGRORITHM'               as rate_algorithm
          , 'DPP_CREDIT_MACROS_TYPE'                 as credit_macros_type
          , 'DPP_CREDIT_MACROS_INTR_TYPE'            as credit_macros_intr_type
          , 'DPP_EARLY_REPAYMENT_CREDIT_MACROS_TYPE' as credit_repay_macros_type
          , 'DPP_CANCEL_CREDIT_MACROS_TYPE'          as cancel_credit_m_type
          , 'DPP_CANCEL_INTEREST_CREDIT_MACROS_TYPE' as cancel_intr_credit_m_type
          , 'DPP_CALC_INTEREST_SINCE_LAST_BILL_DATE' as calc_intr_last_bill
          , 'DPP_MINIMUM_AMOUNT'                     as minimum_amount
          , 'DPP_USE_AUTOCREATION'                   as use_autocreation
          , 'DPP_AUTOCREATION_THRESHOLD'             as autocreation_threshold
          , 'DPP_USURY_RATE'                         as usury_rate
        )
    );
    return l_dpp_program;
end get_dpp_program;

procedure check_acceleration_type(
    io_dpp                    in out dpp_api_type_pkg.t_dpp_program
  , i_new_count               in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount          in     com_api_type_pkg.t_money      default null
) is
    e_invalid_acceleration_params    exception;
begin
    if io_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_NEW_INSTLMT_CNT then
        -- Recalculate the rest of DPP debt for new count of installment payments,
        -- <i_payment_amount> may be undefined for the case of DPP restructuring
        if     nvl(i_new_count, 0) = 0
            or nvl(i_new_count, 0) > io_dpp.instalment_count
        then
            raise e_invalid_acceleration_params;
        end if;

    elsif io_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_AMT then
        if     nvl(i_new_count, 0) != 0 -- Count of new installment payments is calculated
            or nvl(i_payment_amount, 0) = 0
        then
            raise e_invalid_acceleration_params;
        end if;

    elsif io_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_CNT then
        if     nvl(i_new_count, 0) != 0 -- Count of installment payments is not changed
            or nvl(i_payment_amount, 0) = 0
        then
            raise e_invalid_acceleration_params;
        end if;

    elsif io_dpp.acceleration_type = dpp_api_const_pkg.DPP_RESTRUCTURIZATION then
        if nvl(i_new_count, 0) = 0 then
            raise e_invalid_acceleration_params;
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_ACCELERATION_TYPE'
          , i_env_param1 => io_dpp.acceleration_type
        );
    end if;

exception
    when e_invalid_acceleration_params then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_INVALID_ACCELERATION_PARAMS'
          , i_env_param1 => io_dpp.dpp_id
          , i_env_param2 => io_dpp.acceleration_type
          , i_env_param3 => io_dpp.calc_algorithm
          , i_env_param4 => i_new_count
          , i_env_param5 => io_dpp.instalment_count
          , i_env_param6 => i_payment_amount
        );
end check_acceleration_type;

/*
 * DPP acceleration (repayment).
 * @i_payment_amount    - amount of full/partial early repayment, this amount is used to pay DPP amount
                          partially or entirely;
                          in case of partial repayment, the rest of debt transfromed into new
                          (recalculated) installment payments;
 * @i_new_count         - new count of unpaid installment payments, see <i_acceleration_type>;
 * @i_acceleration_type - acceleraion algorithm that may be one of the following:
 *     DPP_ACCELERT_KEEP_INSTLMT_CNT - keep unchangeable count of unpaid installment payments,
                                       installment amount should be recalculate (reduced);
 *     DPP_ACCELERT_KEEP_INSTLMT_AMT - keep unchangeable installment payment amount,
                                       therefore, count of unpaid installment payments should be reduced;
                                       it is the only one acceleration type that may be used with
                                       algorithm DPP_ALGORITHM_FIXED_AMOUNT (since all others
                                       consider change of instalment payment amount);
 *     DPP_ACCELERT_NEW_INSTLMT_CNT  - change count of unpaid installment payments by <i_new_count> parameter,
                                       it should be less than current count of them (in current realization),
                                       installment amount should be recalculate (reduced);
                                       this algorithm allows undefined <i_payment_amount> so that
                                       DPP acceleration is actually DPP restructuring;
 *     DPP_RESTRUCTURIZATION         - a new (any!) count of unpaid instalment payments is set,
                                       the instalment amount is recalculated automatically,
                                       the amount of early repayment is optional;
 */
procedure accelerate_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_new_count               in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount          in     com_api_type_pkg.t_money      default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
) is
    l_count                          com_api_type_pkg.t_count := 0;
    l_account                        acc_api_type_pkg.t_account_rec;
    l_dpp                            dpp_api_type_pkg.t_dpp_program;
    l_dpp_rec                        dpp_api_type_pkg.t_dpp;
    l_instalments                    dpp_api_type_pkg.t_dpp_instalment_tab;
    l_last_number                    pls_integer;
    l_fee_type                       com_api_type_pkg.t_dict_value;
    l_fee_amount                     com_api_type_pkg.t_money;
    l_eff_date                       date;
    l_params                         com_api_type_pkg.t_param_tab;
    l_new_amount                     com_api_type_pkg.t_money;
    l_fee_oper_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'accelerate_dpp() << i_dpp_id [' || i_dpp_id
                     || '], i_new_count [' || i_new_count
                     || '], i_payment_amount [' || i_payment_amount
                     || '], i_acceleration_type [#1]'
      , i_env_param1 => i_acceleration_type
    );

    l_dpp                   := get_dpp_program(i_dpp_id => i_dpp_id);
    l_dpp.acceleration_type := i_acceleration_type;

    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_dpp.inst_id);

    check_advanced_repayment(
        io_dpp      => l_dpp
      , i_amount    => i_payment_amount
      , i_eff_date  => l_eff_date
    );

    select count(*) - count(macros_id)                                                          as unpaid_instalments
         , sum(case when macros_id is null then instalment_amount - interest_amount else 0 end) as unpaid_debt
           -- Field instalment_amount contains an instalment amount with interest
         , min(instalment_amount)
               keep (dense_rank first order by macros_id nulls first, instalment_number)        as instalment
         , min(instalment_amount - interest_amount)
               keep (dense_rank first order by macros_id nulls first, instalment_number)        as instalment_wo_interest
         , max(case when macros_id is null then 0 else instalment_number end)                   as last_paid_instalment
      into l_dpp.instalment_count       -- unpaid/remain instalments
         , l_dpp.dpp_amount             -- unpaid debt
         , l_dpp.instalment_amount      -- installment amount with included interest
         , l_dpp.instalment_wo_interest -- installment amount without included interest
         , l_last_number                -- sequential number of last paid instalment
      from dpp_instalment
     where dpp_id = i_dpp_id
       and split_hash = l_dpp.split_hash;

    trc_log_pkg.debug(
        i_text       => 'accelerate_dpp(): unpaid instalments [#1], unpaid debt [#2], last paid instalment [#5]'
                     || ', next instalment with/without interest [#3]/[#4]'
      , i_env_param1 => l_dpp.instalment_count
      , i_env_param2 => l_dpp.dpp_amount
      , i_env_param3 => l_dpp.instalment_amount
      , i_env_param4 => l_dpp.instalment_wo_interest
      , i_env_param5 => l_last_number
    );

    check_acceleration_type(
        io_dpp           => l_dpp
      , i_new_count      => i_new_count
      , i_payment_amount => i_payment_amount
    );

    if l_dpp.acceleration_type in (dpp_api_const_pkg.DPP_ACCELERT_NEW_INSTLMT_CNT
                                 , dpp_api_const_pkg.DPP_RESTRUCTURIZATION)
    then
        l_dpp.instalment_count  := i_new_count;
        l_dpp.instalment_amount := null;
    elsif l_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_AMT then
        l_dpp.instalment_count  := null;
    elsif l_dpp.acceleration_type = dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_CNT then
        l_dpp.instalment_amount := null;
    end if;

    for rec in (
        select id
             , row_number() over (order by instalment_date) rn
             , instalment_date
             , lag(instalment_date) over (order by instalment_date) as prev_date
             , instalment_amount
          from dpp_instalment
         where decode(macros_id, null, dpp_id, null) = i_dpp_id
           and split_hash = l_dpp.split_hash
      order by instalment_date
    ) loop
        l_instalments(rec.rn).id                := rec.id;
        l_instalments(rec.rn).period_days_count :=
            trunc(rec.instalment_date)
          - trunc(coalesce(rec.prev_date, l_eff_date));
    end loop;

    l_count := l_instalments.count();

    calc_instalments(
        io_dpp         => l_dpp
      , i_first_amount => i_payment_amount
      , io_instalments => l_instalments
    );

    l_instalments(1).acceleration_type := l_dpp.acceleration_type;

    forall n in l_instalments.first..l_instalments.last
        update dpp_instalment
           set instalment_amount   = l_instalments(n).amount
             , payment_amount      = nvl(payment_amount, 0) + l_instalments(n).repayment
             , interest_amount     = l_instalments(n).interest
             , acceleration_type   = l_instalments(n).acceleration_type
             , acceleration_reason = l_instalments(n).acceleration_reason
             , fee_id              = l_instalments(n).fee_id
         where dpp_id     = i_dpp_id
           and id         = l_instalments(n).id
           and split_hash = l_dpp.split_hash;

    if l_count < l_instalments.count() then
        -- Add new instalments if it is the restructurization with greater count of instalments
        for n in l_count + 1 .. l_instalments.count() loop
            dpp_api_instalment_pkg.add_instalment(
                o_id                   => l_instalments(n).id
              , i_dpp_id               => i_dpp_id
              , i_instalment_number    => n
              , i_instalment_date      => l_instalments(n).instalment_date
              , i_instalment_amount    => l_instalments(n).amount
              , i_payment_amount       => null
              , i_interest_amount      => l_instalments(n).interest
              , i_macros_id            => null
              , i_macros_intr_id       => null
              , i_acceleration_type    => null
              , i_split_hash           => l_dpp.split_hash
              , i_fee_id               => l_instalments(n).fee_id
              , i_acceleration_reason  => l_instalments(n).acceleration_reason
            );
        end loop;

        trc_log_pkg.debug(
            i_text       => 'accelerate_dpp(): [#1] instalments were added'
          , i_env_param1 => l_instalments.count() - l_count
        );

    elsif l_count > l_instalments.count() then
        -- Delete old records if it is the acceleration with decreasing count of instalments
        l_count := l_instalments.count();

        delete from dpp_instalment
         where dpp_id            = i_dpp_id
           and split_hash        = l_dpp.split_hash
           and macros_id is null
           and instalment_number > l_last_number + l_count;

        trc_log_pkg.debug(
            i_text       => 'accelerate_dpp(): [' || nvl(sql%rowcount, 0)|| '] instalments were deleted'
        );
    end if;

    select sum(instalment_amount)
      into l_new_amount
      from dpp_instalment
     where decode(macros_id, null, dpp_id, null) = i_dpp_id;

    update dpp_payment_plan p
       set instalment_total = (select count(*)
                                 from dpp_instalment i
                                where i.dpp_id = p.id)
     where p.id = l_dpp.dpp_id;

    if l_dpp.status = dpp_api_const_pkg.DPP_OPERATION_PAID then
        -- Full early repayment
        update dpp_payment_plan
           set status     = l_dpp.status
         where id         = i_dpp_id
           and split_hash = l_dpp.split_hash
           and status     = dpp_api_const_pkg.DPP_OPERATION_ACTIVE;

        trc_log_pkg.debug(
            i_text       => 'accelerate_dpp(): FULL early repayment, DPP was marked as [#1]'
          , i_env_param1 => l_dpp.status
        );
    end if;

    l_account := acc_api_account_pkg.get_account(
                     i_account_id  => l_dpp.account_id
                   , i_mask_error  => com_api_const_pkg.FALSE
                 );

    if l_dpp.accel_fee_id is not null then
        select fee_type
          into l_fee_type
          from fcl_fee
         where id = l_dpp.accel_fee_id;

        l_fee_amount :=
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id         => l_dpp.accel_fee_id
              , i_base_amount    => nvl(i_payment_amount, l_instalments(1).amount - l_instalments(1).interest)
              , io_base_currency => l_dpp.dpp_currency
              , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id      => l_dpp.account_id
              , i_eff_date       => l_eff_date
              , i_split_hash     => l_dpp.split_hash
            );

        -- It is not needed to register a fee with zero amount, because it leads to registration
        -- of operation with zero amount and its processing with error status "Processed without
        -- entries". As a result entire procedure accelerate_dpp() fails.
        if l_fee_amount > 0 then
            opr_api_create_pkg.create_operation(
                io_oper_id          => l_fee_oper_id
              , i_is_reversal       => com_api_const_pkg.FALSE
              , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
              , i_oper_reason       => l_fee_type
              , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
              , i_status_reason     => null
              , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL
              , i_oper_count        => 1
              , i_oper_amount       => l_fee_amount
              , i_oper_currency     => l_dpp.dpp_currency
              , i_oper_date         => l_eff_date
              , i_host_date         => l_eff_date
            );

            opr_api_create_pkg.add_participant(
                i_oper_id           => l_fee_oper_id
              , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
              , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
              , i_host_date         => l_eff_date
              , i_inst_id           => l_dpp.inst_id
              , i_card_id           => l_dpp.card_id
              , i_customer_id       => l_account.customer_id
              , i_account_id        => l_dpp.account_id
              , i_account_number    => l_account.account_number
              , i_split_hash        => l_dpp.split_hash
              , i_without_checks    => com_api_const_pkg.TRUE
            );
        end if;
    end if;

    rul_api_shared_data_pkg.load_account_params(
        i_account_id    => l_dpp.account_id
      , io_params       => l_params
    );

    rul_api_shared_data_pkg.load_card_params(
        i_card_id       => l_dpp.card_id
      , io_params       => l_params
    );

    rul_api_shared_data_pkg.load_customer_params(
        i_customer_id   => l_account.customer_id
      , io_params       => l_params
    );

    evt_api_event_pkg.register_event(
        i_event_type    => dpp_api_const_pkg.EVENT_TYPE_ACCELERATE_PLAN
      , i_eff_date      => l_eff_date
      , i_entity_type   => dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN
      , i_object_id     => l_dpp.dpp_id
      , i_inst_id       => l_dpp.inst_id
      , i_split_hash    => l_dpp.split_hash
      , i_param_tab     => l_params
    );

    l_dpp_rec.id            := i_dpp_id;
    l_dpp_rec.reg_oper_id   := l_dpp.reg_oper_id;
    l_dpp_rec.dpp_currency  := l_dpp.dpp_currency;
    l_dpp_rec.account_id    := l_dpp.account_id;
    l_dpp_rec.split_hash    := l_dpp.split_hash;

    dpp_cst_payment_plan_pkg.accelerate_dpp_postprocess(
        i_dpp       => l_dpp_rec
      , i_eff_date  => l_eff_date
    );

    -- If DPP is registered not by GUI a transaction shouldn't be commited
    -- to provide possibility to rollback changes
    if l_fee_oper_id is not null then
        process_operation(
            i_oper_id          => l_fee_oper_id
          , i_action           => 'acceleration'
        );
    end if;

    trc_log_pkg.clear_object;
end accelerate_dpp;

/*
 * DPP acceleration (repayment) with check absent indebtedness by credit,
 * DPP is searched for operation with using external_auth_id field.
 */
procedure accelerate_dpp(
    i_external_auth_id        in     com_api_type_pkg.t_attr_name
  , i_new_count               in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount          in     com_api_type_pkg.t_money      default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
  , i_check_mad_aging_unpaid  in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_mask_error              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.accelerate_dpp: ';
    l_operation                      opr_api_type_pkg.t_oper_rec;
    l_dpp_rec                        dpp_api_type_pkg.t_dpp;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Start with params - external_auth_id [#1], new_instalment_count [#2], payment_amount [#3], acceleration_type [#4], check_mad_aging_unpaid [#5], mask_error [#6]'
      , i_env_param1 => i_external_auth_id
      , i_env_param2 => i_new_count
      , i_env_param3 => i_payment_amount
      , i_env_param4 => i_acceleration_type
      , i_env_param5 => i_check_mad_aging_unpaid
      , i_env_param6 => i_mask_error
    );

    l_operation := opr_api_operation_pkg.get_operation(i_external_auth_id => i_external_auth_id);

    if l_operation.id is null or l_operation.is_reversal = com_api_const_pkg.TRUE then
        com_api_error_pkg.raise_error(
            i_error      => 'REQUIRED_OPERATION_NOT_FOUND'
          , i_env_param1 => i_external_auth_id
          , i_env_param2 => com_api_const_pkg.FALSE
        );
    end if;

    l_dpp_rec := get_dpp(i_oper_id  => l_operation.id);

    if l_dpp_rec.status <> dpp_api_const_pkg.DPP_OPERATION_ACTIVE then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_FOR_OPERATION_NOT_FOUND'
          , i_env_param1 => l_operation.id
          , i_env_param2 => i_external_auth_id
          , i_env_param3 => dpp_api_const_pkg.DPP_OPERATION_ACTIVE
        );
    end if;

    if nvl(i_check_mad_aging_unpaid, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        crd_overdue_pkg.check_mad_aging_indebtedness(
            i_account_id => l_dpp_rec.account_id
        );
    end if;

    accelerate_dpp(
        i_dpp_id            => l_dpp_rec.id
      , i_new_count         => i_new_count
      , i_payment_amount    => i_payment_amount
      , i_acceleration_type => i_acceleration_type
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Finish success with params - external_auth_id [#1], new_instalment_count [#2], payment_amount [#3], acceleration_type [#4], check_mad_aging_unpaid [#5], mask_error [#6]'
      , i_env_param1 => i_external_auth_id
      , i_env_param2 => i_new_count
      , i_env_param3 => i_payment_amount
      , i_env_param4 => i_acceleration_type
      , i_env_param5 => i_check_mad_aging_unpaid
      , i_env_param6 => i_mask_error
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - external_auth_id [#1], new_instalment_count [#2], payment_amount [#3], acceleration_type [#4], check_mad_aging_unpaid [#5], mask_error [#6]'
          , i_env_param1 => i_external_auth_id
          , i_env_param2 => i_new_count
          , i_env_param3 => i_payment_amount
          , i_env_param4 => i_acceleration_type
          , i_env_param5 => i_check_mad_aging_unpaid
          , i_env_param6 => i_mask_error
        );
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end accelerate_dpp;

/*
 * Accelerating active DPPs for a specified account from oldest to newest ones by spending incoming amount.
 */
procedure accelerate_dpps(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_payment_amount          in     com_api_type_pkg.t_money
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value    default null
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.accelerate_dpps() ';
    l_payment_amount                 com_api_type_pkg.t_money;
    l_dpp_tab                        dpp_api_type_pkg.t_dpp_tab;
    l_index                          binary_integer;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_account_id [#1], i_payment_amount [#2], i_acceleration_type [#3]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_payment_amount
      , i_env_param3 => i_acceleration_type
    );

    l_dpp_tab := get_dpp(i_account_id => i_account_id);

    l_payment_amount := i_payment_amount;

    -- Use all amount <l_payment_amount> for full or partial advanced repayment DPPs for the account
    l_index := l_dpp_tab.first(); -- 1st DPP by date of creation
    while l_payment_amount > 0 and l_index <= l_dpp_tab.last() loop
        accelerate_dpp(
            i_dpp_id            => l_dpp_tab(l_index).id
          , i_new_count         => null
          , i_payment_amount    => least(l_payment_amount, l_dpp_tab(l_index).dpp_amount)
          , i_acceleration_type => nvl(i_acceleration_type, dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_AMT)
        );
        l_payment_amount := l_payment_amount - l_dpp_tab(l_index).dpp_amount;
        l_index          := l_dpp_tab.next(l_index);
    end loop;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> #1 DPPs were processed of #2 in total for the account'
                                   || ', the rest of i_payment_amount is [#3]'
      , i_env_param1 => nvl(l_index - 1, 0)
      , i_env_param2 => l_dpp_tab.count()
      , i_env_param3 => l_payment_amount
    );
end accelerate_dpps;

procedure check_advanced_repayment(
    io_dpp                    in out nocopy dpp_api_type_pkg.t_dpp_program
  , i_amount                  in     com_api_type_pkg.t_money
  , i_eff_date                in     date
) is
    l_count                          com_api_type_pkg.t_short_id;
    l_fee_amount                     com_api_type_pkg.t_money;
    l_next_payment_amount            com_api_type_pkg.t_money;
    l_eff_date                       date;
begin
    l_next_payment_amount := i_amount;

    if l_next_payment_amount is null then
        select min(payment_amount) keep (dense_rank first order by instalment_date)
          into l_next_payment_amount
          from dpp_instalment
         where decode(macros_id, null, dpp_id, null) = io_dpp.dpp_id;
    end if;

    if io_dpp.min_early_repayment is not null then
        l_fee_amount :=
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id         => io_dpp.min_early_repayment
              , i_base_amount    => l_next_payment_amount
              , io_base_currency => io_dpp.dpp_currency
              , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id      => io_dpp.account_id
              , i_eff_date       => l_eff_date
              , i_split_hash     => io_dpp.split_hash
            );
    else
        l_fee_amount := 0;
    end if;

    select count(*)
      into l_count
      from dpp_instalment d
     where d.dpp_id  = io_dpp.dpp_id
       and macros_id is not null;

    if l_count       < io_dpp.fixed_instalment
    or io_dpp.status     != dpp_api_const_pkg.DPP_OPERATION_ACTIVE
    or l_fee_amount  > nvl(i_amount, 0)
    then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_ADV_REPAYMENT_DPP'
          , i_env_param1 => io_dpp.dpp_id
          , i_env_param2 => io_dpp.fixed_instalment
          , i_env_param3 => l_count
          , i_env_param4 => io_dpp.status
          , i_env_param5 => l_fee_amount
          , i_env_param6 => i_amount
        );
    end if;
end check_advanced_repayment;

/*
 * Cancelling a DPP.
 */
procedure cancel_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
) is
    l_rest_amount                    com_api_type_pkg.t_money;
    l_dpp                            dpp_api_type_pkg.t_dpp;
    l_macros_id                      com_api_type_pkg.t_long_id;
    l_macros_intr_id                 com_api_type_pkg.t_long_id;
    l_params                         com_api_type_pkg.t_param_tab;
    l_cancelation_fee_id             com_api_type_pkg.t_short_id;
    l_fee_amount                     com_api_type_pkg.t_money;
    l_oper_id                        com_api_type_pkg.t_long_id;
    l_eff_date                       date;
    l_last_bill_date                 date;
    l_customer_id                    com_api_type_pkg.t_medium_id;
    l_fee_type                       com_api_type_pkg.t_dict_value;
    l_account_rec                    acc_api_type_pkg.t_account_rec;
    l_credit_bunch_type_id           com_api_type_pkg.t_tiny_id;
    l_intr_bunch_type_id             com_api_type_pkg.t_tiny_id;
    l_over_bunch_type_id             com_api_type_pkg.t_tiny_id;
    l_interest_amount                com_api_type_pkg.t_money;
    l_instalment_id                  com_api_type_pkg.t_long_id;
    l_instalment_number              com_api_type_pkg.t_tiny_id;
    l_dpp_program                    dpp_api_type_pkg.t_dpp_program;
begin
    trc_log_pkg.debug(
        i_text => 'cancel_dpp() << i_dpp_id [' || i_dpp_id || ']'
    );

    l_dpp_program := get_dpp_program(i_dpp_id);

    select sum(decode(i.macros_id, null
                    , i.instalment_amount - i.interest_amount
                      +
                      case
                          when i.acceleration_type is not null then nvl(i.payment_amount, 0)
                                                               else 0
                      end
                    , 0)
           ) as rest_amount
         , max(case when i.macros_id is null then p.posting_date else i.instalment_date end) last_bill_date
         , p.oper_currency
         , p.dpp_currency
         , p.account_id
         , p.inst_id
         , p.split_hash
         , p.dpp_amount
         , p.card_id
         , p.reg_oper_id
         , p.oper_id
         , p.posting_date
         , p.status
         , a.customer_id
         , a.account_number
         , a.account_type
         , a.currency
         , a.agent_id
      into l_rest_amount
         , l_last_bill_date
         , l_dpp.oper_currency
         , l_dpp.dpp_currency
         , l_dpp.account_id
         , l_dpp.inst_id
         , l_dpp.split_hash
         , l_dpp.dpp_amount
         , l_dpp.card_id
         , l_dpp.reg_oper_id
         , l_dpp.oper_id
         , l_dpp.posting_date
         , l_dpp.status
         , l_account_rec.customer_id
         , l_account_rec.account_number
         , l_account_rec.account_type
         , l_account_rec.currency
         , l_account_rec.agent_id
      from dpp_instalment i
         , dpp_payment_plan p
         , acc_account a
     where i.dpp_id     = p.id
       and p.id         = i_dpp_id
       and i.split_hash = p.split_hash
       and a.id         = p.account_id
       and a.split_hash = p.split_hash
     group by
           p.oper_currency
         , p.dpp_currency
         , p.account_id
         , p.inst_id
         , p.split_hash
         , p.dpp_amount
         , p.card_id
         , p.reg_oper_id
         , p.oper_id
         , p.posting_date
         , p.status
         , a.customer_id
         , a.account_number
         , a.account_type
         , a.currency
         , a.agent_id;

    trc_log_pkg.set_object(
        i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => l_dpp.reg_oper_id
    );

    if l_dpp.status != dpp_api_const_pkg.DPP_OPERATION_ACTIVE then
        com_api_error_pkg.raise_error(
            i_error         => 'WRONG_DPP_STATUS'
          , i_env_param1    => l_dpp.status
        );
    end if;

    l_account_rec.inst_id       := l_dpp.inst_id;
    l_account_rec.split_hash    := l_dpp.split_hash;
    l_account_rec.account_id    := l_dpp.account_id;
    l_dpp.id    := i_dpp_id;
    l_eff_date  := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_dpp.inst_id);

    check_usury_rate(
        io_dpp       => l_dpp_program
      , i_eff_date   => l_eff_date
    );

    get_amount_to_cancel(
        i_dpp_id           => l_dpp.id
      , i_inst_id          => l_dpp.inst_id
      , i_eff_date         => l_eff_date
      , i_rest_amount      => l_rest_amount
      , i_fee_id           => l_dpp_program.fee_id
      , i_last_bill_date   => l_last_bill_date
      , o_amount           => l_rest_amount
      , o_interest_amount  => l_interest_amount
    );

    if l_rest_amount > 0 then
        dpp_cst_payment_plan_pkg.get_dpp_credit_bunch_types(
            i_dpp                        => l_dpp
          , o_credit_bunch_type_id       => l_credit_bunch_type_id
          , o_intr_bunch_type_id         => l_intr_bunch_type_id
          , o_over_bunch_type_id         => l_over_bunch_type_id
        );

        put_instalment_macros(
            i_oper_id                    => l_dpp.reg_oper_id
          , i_reg_oper_id                => l_dpp.oper_id
          , i_amount                     => l_rest_amount
          , i_interest_amount            => l_interest_amount
          , i_currency                   => l_dpp.dpp_currency
          , i_account_rec                => l_account_rec
          , i_card_id                    => l_dpp.card_id
          , i_credit_bunch_type_id       => l_credit_bunch_type_id
          , i_intr_bunch_type_id         => l_intr_bunch_type_id
          , i_over_bunch_type_id         => l_over_bunch_type_id
          , i_posting_date               => l_dpp.posting_date
          , i_eff_date                   => l_eff_date
          , i_macros_type_id             => nvl(l_dpp_program.cancel_m_type_id,      l_dpp_program.macros_type_id)
          , i_macros_intr_type_id        => nvl(l_dpp_program.cancel_m_intr_type_id, l_dpp_program.macros_intr_type_id)
          , i_credit_macros_type_id      => l_dpp_program.cancel_credit_m_type
          , i_credit_macros_intr_type_id => l_dpp_program.cancel_intr_credit_m_type
          , o_macros_id                  => l_macros_id
          , o_macros_intr_id             => l_macros_intr_id
        );

        delete from dpp_instalment
         where decode(macros_id, null, dpp_id, null) = i_dpp_id
           and split_hash = l_dpp.split_hash;

        select nvl(max(instalment_number), 0) + 1
          into l_instalment_number
          from dpp_instalment
         where dpp_id = i_dpp_id;

        dpp_api_instalment_pkg.add_instalment(
            o_id                    => l_instalment_id
          , i_dpp_id                => i_dpp_id
          , i_instalment_number     => l_instalment_number
          , i_instalment_date       => l_eff_date
          , i_instalment_amount     => l_rest_amount
          , i_payment_amount        => null
          , i_interest_amount       => l_interest_amount
          , i_macros_id             => l_macros_id
          , i_macros_intr_id        => l_macros_intr_id
          , i_acceleration_type     => null
          , i_split_hash            => l_dpp.split_hash
        );

        update dpp_payment_plan
           set status     = dpp_api_const_pkg.DPP_OPERATION_CANCELED
         where id         = i_dpp_id
           and split_hash = l_dpp.split_hash;

        get_saved_attribute_value(
            i_attr_name  => dpp_api_const_pkg.ATTR_CANCEL_FEE_ID
          , i_dpp_id     => i_dpp_id
          , o_value      => l_cancelation_fee_id
        );

        trc_log_pkg.debug(
            i_text       => 'l_cancelation_fee_id [' || l_cancelation_fee_id || ']'
        );

        if l_cancelation_fee_id is not null then
            l_fee_amount :=
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id         => l_cancelation_fee_id
                  , i_base_amount    => l_rest_amount
                  , io_base_currency => l_dpp.dpp_currency
                  , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id      => l_dpp.account_id
                  , i_eff_date       => l_eff_date
                  , i_split_hash     => l_dpp.split_hash
                );

            if l_fee_amount > 0 then
                select fee_type
                  into l_fee_type
                  from fcl_fee
                 where id = l_cancelation_fee_id;

                opr_api_create_pkg.create_operation(
                    io_oper_id          => l_oper_id
                  , i_is_reversal       => com_api_const_pkg.FALSE
                  , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                  , i_oper_reason       => l_fee_type
                  , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                  , i_status_reason     => null
                  , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
                  , i_oper_count        => 1
                  , i_oper_amount       => l_fee_amount
                  , i_oper_currency     => l_dpp.dpp_currency
                  , i_oper_date         => l_eff_date
                  , i_host_date         => l_eff_date
                );

                opr_api_create_pkg.add_participant(
                    i_oper_id           => l_oper_id
                  , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                  , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                  , i_host_date         => l_eff_date
                  , i_inst_id           => l_dpp.inst_id
                  , i_customer_id       => l_customer_id
                  , i_card_id           => l_dpp.card_id
                  , i_account_id        => l_dpp.account_id
                  , i_account_number    => l_account_rec.account_number
                  , i_split_hash        => l_dpp.split_hash
                  , i_without_checks    => com_api_const_pkg.TRUE
                );
            end if;
        end if;

        rul_api_shared_data_pkg.load_account_params(
            i_account_id    => l_dpp.account_id
          , io_params       => l_params
        );

        rul_api_shared_data_pkg.load_card_params(
            i_card_id       => l_dpp.card_id
          , io_params       => l_params
        );

        rul_api_shared_data_pkg.load_customer_params(
            i_customer_id   => l_account_rec.customer_id
          , io_params       => l_params
        );

        evt_api_event_pkg.register_event(
            i_event_type    => dpp_api_const_pkg.EVENT_TYPE_CANCEL_PLAN
          , i_eff_date      => l_eff_date
          , i_entity_type   => dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN
          , i_object_id     => l_dpp.id
          , i_inst_id       => l_dpp.inst_id
          , i_split_hash    => l_dpp.split_hash
          , i_param_tab     => l_params
        );
    end if;

    acc_api_entry_pkg.flush_job;

    dpp_cst_payment_plan_pkg.cancel_dpp_postprocess(
        i_dpp               => l_dpp
      , i_eff_date          => l_eff_date
    );

    -- If DPP is registered not by GUI a transaction shouldn't be commited
    -- to provide possibility to rollback changes
    if l_oper_id is not null then
        process_operation(
            i_oper_id          => l_oper_id
          , i_action           => 'cancellation'
        );
    end if;

    trc_log_pkg.clear_object;

    trc_log_pkg.debug(
        i_text => 'cancel_dpp() >> number of last unpaid instalment [' || l_instalment_number || ']'
    );
end cancel_dpp;

procedure add_payment_plan(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_reg_oper_id             in     com_api_type_pkg.t_long_id
  , i_account_id              in     com_api_type_pkg.t_account_id
  , i_card_id                 in     com_api_type_pkg.t_medium_id
  , i_product_id              in     com_api_type_pkg.t_short_id
  , i_oper_date               in     date
  , i_oper_amount             in     com_api_type_pkg.t_money
  , i_oper_currency           in     com_api_type_pkg.t_curr_code
  , i_dpp_amount              in     com_api_type_pkg.t_money
  , i_dpp_currency            in     com_api_type_pkg.t_curr_code
  , i_interest_amount         in     com_api_type_pkg.t_money
  , i_status                  in     com_api_type_pkg.t_dict_value
  , i_instalment_amount       in     com_api_type_pkg.t_money
  , i_instalment_total        in     com_api_type_pkg.t_tiny_id
  , i_instalment_billed       in     com_api_type_pkg.t_tiny_id
  , i_next_instalment_date    in     date
  , i_debt_balance            in     com_api_type_pkg.t_money
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_split_hash              in     com_api_type_pkg.t_tiny_id
  , i_posting_date            in     date
  , i_oper_type               in     com_api_type_pkg.t_dict_value
) is
begin
    insert into dpp_payment_plan_vw(
        id
      , oper_id
      , reg_oper_id
      , account_id
      , card_id
      , product_id
      , oper_date
      , oper_amount
      , oper_currency
      , dpp_amount
      , dpp_currency
      , interest_amount
      , status
      , instalment_amount
      , instalment_total
      , instalment_billed
      , next_instalment_date
      , debt_balance
      , inst_id
      , split_hash
      , posting_date
      , oper_type
    ) values (
        i_id
      , i_oper_id
      , i_reg_oper_id
      , i_account_id
      , i_card_id
      , i_product_id
      , i_oper_date
      , i_oper_amount
      , i_oper_currency
      , i_dpp_amount
      , i_dpp_currency
      , i_interest_amount
      , i_status
      , i_instalment_amount
      , i_instalment_total
      , i_instalment_billed
      , i_next_instalment_date
      , i_debt_balance
      , i_inst_id
      , i_split_hash
      , i_posting_date
      , i_oper_type
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error             => 'DPP_ALREADY_EXISTS'
          , i_env_param1        => i_id
          , i_env_param2        => i_reg_oper_id
        );
end add_payment_plan;

procedure get_dpp_amount(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , o_dpp_amount                 out com_api_type_pkg.t_money
  , o_dpp_currency               out com_api_type_pkg.t_curr_code
) is
    l_eff_date                       date;
    l_account                        acc_api_type_pkg.t_account_rec;
    l_service_id                     com_api_type_pkg.t_short_id;
    l_param_tab                      com_api_type_pkg.t_param_tab;
    l_product_id                     com_api_type_pkg.t_short_id;
    l_alg_calc_intr                  com_api_type_pkg.t_dict_value;
    l_dpp_amount                     com_api_type_pkg.t_money;
begin
    l_account    := acc_api_account_pkg.get_account(
                        i_account_id  => i_account_id
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );
    l_eff_date   := com_api_sttl_day_pkg.get_calc_date(
                        i_inst_id     => l_account.inst_id
                    );
    l_service_id := crd_api_service_pkg.get_active_service(
                        i_account_id  => i_account_id
                      , i_eff_date    => l_eff_date
                      , i_split_hash  => l_account.split_hash
                      , i_mask_error  => com_api_const_pkg.TRUE
                    );

    l_dpp_amount := 0;

    if l_service_id is null then
        select sum(e.balance_impact * e.amount)
          into l_dpp_amount
          from acc_entry e
         where e.macros_id  = i_macros_id
           and e.account_id = i_account_id
           and e.split_hash = l_account.split_hash
           and e.status     = acc_api_const_pkg.ENTRY_STATUS_POSTED;
    else
        select sum(db.amount)
          into l_dpp_amount
          from crd_debt_balance db
         where db.split_hash = l_account.split_hash
           and db.debt_id    = i_macros_id;

        crd_debt_pkg.load_debt_param(
            i_debt_id           => i_macros_id
          , io_param_tab        => l_param_tab
          , i_split_hash        => l_account.split_hash
          , o_product_id        => l_product_id
        );

        -- Get algorithm ACIL
        begin
            l_alg_calc_intr :=
                nvl(
                    prd_api_product_pkg.get_attr_value_char(
                        i_product_id    => l_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
                      , i_split_hash    => l_account.split_hash
                      , i_service_id    => l_service_id
                      , i_params        => l_param_tab
                      , i_eff_date      => l_eff_date
                    )
                  , crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value [CRD_ALGORITHM_CALC_INTEREST] not defined. Set algorithm = ACIL0001');
                    l_alg_calc_intr := crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD;
                else
                    raise;
                end if;
        end;

        l_dpp_amount := l_dpp_amount
                      + nvl(
                            crd_api_report_pkg.calculate_interest(
                                i_account_id    => i_account_id
                              , i_debt_id       => i_macros_id
                              , i_eff_date      => l_eff_date
                              , i_split_hash    => l_account.split_hash
                              , i_service_id    => l_service_id
                              , i_product_id    => l_product_id
                              , i_alg_calc_intr => l_alg_calc_intr
                            )
                          , 0
                        );
    end if;

    dpp_cst_payment_plan_pkg.dpp_amount_postprocess(
        i_account_id    => i_account_id
      , i_macros_id     => i_macros_id
      , io_dpp_amount   => l_dpp_amount
      , io_dpp_currency => l_account.currency
    );

    o_dpp_amount    := l_dpp_amount;
    o_dpp_currency  := l_account.currency;
end get_dpp_amount;

function get_dpp_amount_only(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_macros_id               in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_money
is
    l_dpp_amount                     com_api_type_pkg.t_money;
    l_dpp_currency                   com_api_type_pkg.t_curr_code;
begin
    get_dpp_amount(
        i_account_id   => i_account_id
      , i_macros_id    => i_macros_id
      , o_dpp_amount   => l_dpp_amount
      , o_dpp_currency => l_dpp_currency
    );
    return l_dpp_amount;
end;

/*
 * Creating macroses with bunches on processing an instalment.
 * @i_is_credit_account           - if this flag is NULL, it is necessary to check all parameters <i_credit*>
                                    for compatibility because some combinations are impossible;
 * @i_credit_account_rec          - credit account for the case when there are 2 accounts: instalment and credit ones;
 * @i_credit_macros_type_id       - macros type for principal amount for the case of a separate credit account;
 * @i_credit_macros_intr_type_id  - macros type for interest amount for the case of a separate credit account;
 * @i_credit_repay_macros_type_id - macros type for early repayment amount for the case of a separate credit account;
 */
procedure put_instalment_macros(
    i_oper_id                       in     com_api_type_pkg.t_long_id
  , i_reg_oper_id                   in     com_api_type_pkg.t_long_id
  , i_amount                        in     com_api_type_pkg.t_money
  , i_interest_amount               in     com_api_type_pkg.t_money
  , i_repayment_amount              in     com_api_type_pkg.t_money       default null
  , i_currency                      in     com_api_type_pkg.t_curr_code
  , i_account_rec                   in     acc_api_type_pkg.t_account_rec
  , i_card_id                       in     com_api_type_pkg.t_medium_id
  , i_credit_bunch_type_id          in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_intr_bunch_type_id            in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_over_bunch_type_id            in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERLIMIT_REGSTR
  , i_lending_bunch_type_id         in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_CREDIT_LENDING
  , i_posting_date                  in     date
  , i_eff_date                      in     date
  , i_macros_type_id                in     com_api_type_pkg.t_tiny_id
  , i_macros_intr_type_id           in     com_api_type_pkg.t_tiny_id
  , i_repay_macros_type_id          in     com_api_type_pkg.t_tiny_id     default null
  , i_is_credit_account             in     com_api_type_pkg.t_boolean     default null
  , i_credit_account_rec            in     acc_api_type_pkg.t_account_rec default null
  , i_credit_macros_type_id         in     com_api_type_pkg.t_tiny_id     default null
  , i_credit_macros_intr_type_id    in     com_api_type_pkg.t_tiny_id     default null
  , i_credit_repay_macros_type_id   in     com_api_type_pkg.t_tiny_id     default null
  , o_macros_id                        out com_api_type_pkg.t_long_id
  , o_macros_intr_id                   out com_api_type_pkg.t_long_id
) is
    LOG_PREFIX                    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.put_instalment_macros';
    l_credit_account                       acc_api_type_pkg.t_account_rec;
    l_is_credit_account                    com_api_type_pkg.t_boolean;
    l_service_id                           com_api_type_pkg.t_short_id;
    l_principal_amount                     com_api_type_pkg.t_money;
    l_repayment_macros_id                  com_api_type_pkg.t_long_id;

    procedure put_macros(
        o_macros_id                        out com_api_type_pkg.t_long_id
      , i_oper_id                       in     com_api_type_pkg.t_long_id
      , i_reg_oper_id                   in     com_api_type_pkg.t_long_id
      , i_account                       in     acc_api_type_pkg.t_account_rec
      , i_card_id                       in     com_api_type_pkg.t_medium_id
      , i_eff_date                      in     date
      , i_posting_date                  in     date
      , i_amount                        in     com_api_type_pkg.t_money
      , i_currency                      in     com_api_type_pkg.t_curr_code
      , i_credit_bunch_type_id          in     com_api_type_pkg.t_tiny_id
      , i_over_bunch_type_id            in     com_api_type_pkg.t_tiny_id
      , i_lending_bunch_type_id         in     com_api_type_pkg.t_tiny_id
      , i_macros_type_id                in     com_api_type_pkg.t_tiny_id
      , i_is_credit_account             in     com_api_type_pkg.t_boolean
      , i_credit_account                in     acc_api_type_pkg.t_account_rec
      , i_credit_macros_type_id         in     com_api_type_pkg.t_tiny_id
    ) is
        l_bunch_id                             com_api_type_pkg.t_long_id;
        l_param_tab                            com_api_type_pkg.t_param_tab;
        l_operation                            opr_api_type_pkg.t_oper_rec;
        l_over_amount                          com_api_type_pkg.t_money;
        l_credit_amount                        com_api_type_pkg.t_money;
    begin
        acc_api_entry_pkg.put_macros(
            o_macros_id       => o_macros_id
          , o_bunch_id        => l_bunch_id
          , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id       => i_reg_oper_id
          , i_macros_type_id  => i_macros_type_id
          , i_amount          => i_amount
          , i_currency        => i_currency
          , i_account_type    => i_account.account_type
          , i_account_id      => i_account.account_id
          , i_posting_date    => i_eff_date
          , i_param_tab       => l_param_tab
        );

        if i_is_credit_account = com_api_const_pkg.TRUE and o_macros_id is not null then
            if i_credit_macros_type_id is not null then
                acc_api_entry_pkg.put_macros(
                    o_macros_id         => o_macros_id
                  , o_bunch_id          => l_bunch_id
                  , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id         => i_reg_oper_id
                  , i_macros_type_id    => i_credit_macros_type_id
                  , i_amount            => i_amount
                  , i_currency          => i_currency
                  , i_account_type      => i_credit_account.account_type
                  , i_account_id        => i_credit_account.account_id
                  , i_posting_date      => i_eff_date
                  , i_param_tab         => l_param_tab
                );
            end if;

            l_operation.id           := i_reg_oper_id;
            l_operation.oper_type    := dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER;
            l_operation.sttl_type    := opr_api_const_pkg.SETTLEMENT_INTERNAL;
            l_operation.is_reversal  := com_api_const_pkg.FALSE;
            l_operation.original_id  := i_oper_id;
            l_operation.oper_date    := i_posting_date;
            l_operation.oper_amount  := i_amount;

            crd_debt_pkg.credit_clearance(
                i_account                     => coalesce(i_credit_account, i_account)
              , i_operation                   => l_operation
              , i_macros_type_id              => nvl(i_credit_macros_type_id, i_macros_type_id)
              , i_credit_bunch_type_id        => i_credit_bunch_type_id
              , i_over_bunch_type_id          => i_over_bunch_type_id
              , i_card_id                     => i_card_id
              , i_card_type_id                => null
              , i_service_id                  => null
              , o_over_amount                 => l_over_amount
              , o_credit_amount               => l_credit_amount
            );

            if i_lending_bunch_type_id is not null then
                crd_debt_pkg.lending_clearance(
                    i_account         => coalesce(i_credit_account, i_account)
                  , i_operation       => l_operation
                  , i_macros_type_id  => nvl(i_credit_macros_type_id, i_macros_type_id)
                  , i_bunch_type_id   => i_lending_bunch_type_id
                  , i_service_id      => null
                );
            end if;
        end if;
    end put_macros;

begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' << i_oper_id ['      || i_oper_id
               || '], i_reg_oper_id ['                 || i_reg_oper_id
               || '], i_amount ['                      || i_amount
               || '], i_interest_amount ['             || i_interest_amount
               || '], i_repayment_amount ['            || i_repayment_amount
               || '], i_currency ['                    || i_currency
               || '], i_account_rec ['                 || i_account_rec.account_id || '|' || i_account_rec.account_type
               || '], i_card_id ['                     || i_card_id
               || '], i_credit_bunch_type_id ['        || i_credit_bunch_type_id
               || '], i_intr_bunch_type_id ['          || i_intr_bunch_type_id
               || '], i_over_bunch_type_id ['          || i_over_bunch_type_id
               || '], i_lending_bunch_type_id ['       || i_lending_bunch_type_id
               || '], i_posting_date ['                || to_char(i_posting_date, com_api_const_pkg.LOG_DATE_FORMAT)
               || '], i_eff_date ['                    || to_char(i_eff_date,     com_api_const_pkg.LOG_DATE_FORMAT)
               || '], i_macros_type_id ['              || i_macros_type_id
               || '], i_macros_intr_type_id ['         || i_macros_intr_type_id
               || '], i_repay_macros_type_id ['        || i_repay_macros_type_id
               || '], i_is_credit_account ['              || i_is_credit_account
               || '], i_credit_account_rec ['          || i_credit_account_rec.account_id || '|' || i_credit_account_rec.account_type
               || '], i_credit_macros_type_id ['       || i_credit_macros_type_id
               || '], i_credit_macros_intr_type_id ['  || i_credit_macros_intr_type_id
               || '], i_credit_repay_macros_type_id [' || i_credit_repay_macros_type_id
               || ']'
    );

    if i_is_credit_account is not null then
        l_is_credit_account := i_is_credit_account;
        l_credit_account    := i_credit_account_rec;
    else
        l_service_id :=
            crd_api_service_pkg.get_active_service(
                i_account_id  => i_account_rec.account_id
              , i_split_hash  => i_account_rec.split_hash
              , i_eff_date    => i_eff_date
              , i_mask_error  => com_api_const_pkg.TRUE
            );

        l_is_credit_account := com_api_type_pkg.to_bool(l_service_id is not null);

        -- It is the case of 2 accounts, DPP account <i_account_rec> and Credit account <i_credit_account_rec>
        if     i_credit_macros_type_id         is not null
            or i_credit_macros_intr_type_id    is not null
            or i_credit_repay_macros_type_id   is not null
            or i_credit_account_rec.account_id is not null
        then
            if l_is_credit_account = com_api_const_pkg.TRUE then
                -- DPP account <i_account_rec> can't have Credit service
                com_api_error_pkg.raise_error(
                    i_error      => 'DPP_ACCOUNT_CONTAINS_INSTALMENT_AND_CREDIT_SERVICES'
                );
            end if;

            if i_credit_account_rec.account_id is not null then
                l_service_id :=
                    crd_api_service_pkg.get_active_service(
                        i_account_id  => i_credit_account_rec.account_id
                      , i_split_hash  => i_credit_account_rec.split_hash
                      , i_eff_date    => i_eff_date
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );
                l_credit_account := i_credit_account_rec;
            else
                l_credit_account := get_separate_credit_account(i_account => i_account_rec);
            end if;

            l_is_credit_account := com_api_const_pkg.TRUE;
        end if;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': l_credit_account.account_id [#1]'
      , i_env_param1 => l_credit_account.account_id
    );

    if i_repay_macros_type_id is null then
        l_principal_amount := i_amount - i_interest_amount + nvl(i_repayment_amount, 0);
    else
        l_principal_amount := i_amount - i_interest_amount;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': l_is_credit_account [#1], l_principal_amount [#2]'
      , i_env_param1 => l_is_credit_account
      , i_env_param2 => l_principal_amount
    );

    put_macros(
        o_macros_id              => o_macros_id
      , i_oper_id                => i_oper_id
      , i_reg_oper_id            => i_reg_oper_id
      , i_account                => i_account_rec
      , i_card_id                => i_card_id
      , i_eff_date               => i_eff_date
      , i_posting_date           => i_posting_date
      , i_amount                 => l_principal_amount
      , i_currency               => i_currency
      , i_credit_bunch_type_id   => i_credit_bunch_type_id
      , i_over_bunch_type_id     => i_over_bunch_type_id
      , i_lending_bunch_type_id  => i_lending_bunch_type_id
      , i_macros_type_id         => i_macros_type_id
      , i_is_credit_account      => l_is_credit_account
      , i_credit_account         => l_credit_account
      , i_credit_macros_type_id  => i_credit_macros_type_id
    );

    put_macros(
        o_macros_id              => o_macros_intr_id
      , i_oper_id                => i_oper_id
      , i_reg_oper_id            => i_reg_oper_id
      , i_account                => i_account_rec
      , i_card_id                => i_card_id
      , i_eff_date               => i_eff_date
      , i_posting_date           => i_posting_date
      , i_amount                 => i_interest_amount
      , i_currency               => i_currency
      , i_credit_bunch_type_id   => i_credit_bunch_type_id
      , i_over_bunch_type_id     => i_over_bunch_type_id
      , i_lending_bunch_type_id  => i_lending_bunch_type_id
      , i_macros_type_id         => i_macros_intr_type_id
      , i_is_credit_account      => l_is_credit_account
      , i_credit_account         => l_credit_account
      , i_credit_macros_type_id  => i_credit_macros_intr_type_id
    );

    if      i_repay_macros_type_id is not null
        and i_repayment_amount     is not null
    then
        put_macros(
            o_macros_id              => l_repayment_macros_id
          , i_oper_id                => i_oper_id
          , i_reg_oper_id            => i_reg_oper_id
          , i_account                => i_account_rec
          , i_card_id                => i_card_id
          , i_eff_date               => i_eff_date
          , i_posting_date           => i_posting_date
          , i_amount                 => i_repayment_amount
          , i_currency               => i_currency
          , i_credit_bunch_type_id   => i_credit_bunch_type_id
          , i_over_bunch_type_id     => i_over_bunch_type_id
          , i_lending_bunch_type_id  => i_lending_bunch_type_id
          , i_macros_type_id         => i_repay_macros_type_id
          , i_is_credit_account      => l_is_credit_account
          , i_credit_account         => l_credit_account
          , i_credit_macros_type_id  => i_credit_repay_macros_type_id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_macros_id [#1], o_macros_intr_id [#2]'
      , i_env_param1 => o_macros_id
      , i_env_param2 => o_macros_intr_id
    );
end put_instalment_macros;

procedure get_dpp_info(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , o_original_oper_type         out com_api_type_pkg.t_dict_value
  , o_inst_id                    out com_api_type_pkg.t_inst_id
  , o_dpp_amount                 out com_api_type_pkg.t_money
  , o_instalments_count          out pls_integer
  , o_paid_instalments_count     out pls_integer
  , o_rest_amount                out com_api_type_pkg.t_money
  , o_last_bill_date             out date
) is
    l_id                             com_api_type_pkg.t_long_id;
begin
    select min(p.id)
         , min(o.oper_type)
         , min(p.inst_id)
         , min(p.dpp_amount)
         , count(*)
         , count(macros_id)
         , sum(decode(i.macros_id, null, i.instalment_amount - i.interest_amount, 0)) rest_amount
         , max(case when i.macros_id is null then p.posting_date else i.instalment_date end) last_bill_date
      into l_id
         , o_original_oper_type
         , o_inst_id
         , o_dpp_amount
         , o_instalments_count
         , o_paid_instalments_count
         , o_rest_amount
         , o_last_bill_date
      from dpp_payment_plan p
         , dpp_instalment   i
         , opr_operation    o
     where i.dpp_id     = p.id
       and i.split_hash = p.split_hash
       and o.id         = p.oper_id
       and p.id         = i_dpp_id;

    if l_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_IS_NOT_FOUND'
          , i_env_param1 => i_dpp_id
        );
    end if;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => 'get_dpp_info(i_dpp_id => #1) >> ' || sqlerrm
          , i_env_param1 => i_dpp_id
        );
        raise;
end get_dpp_info;

procedure get_amount_to_cancel(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id  default null
  , i_eff_date                in     date                        default null
  , i_rest_amount             in     com_api_type_pkg.t_money    default null
  , i_fee_id                  in     com_api_type_pkg.t_short_id default null
  , i_last_bill_date          in     date                        default null
  , o_amount                     out com_api_type_pkg.t_money
  , o_interest_amount            out com_api_type_pkg.t_money
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_amount_to_cancel';
    l_eff_date                       date;
    l_fee_id                         com_api_type_pkg.t_short_id;
    l_rest_amount                    com_api_type_pkg.t_money;
    l_last_bill_date                 date;
    l_inst_id                        com_api_type_pkg.t_inst_id;
    l_original_oper_type             com_api_type_pkg.t_dict_value;
    l_dpp_amount                     com_api_type_pkg.t_money;
    l_instalments_count              pls_integer;
    l_paid_instalments_count         pls_integer;
    l_is_interest_since_last_bill    com_api_type_pkg.t_boolean;

    function calc_interest_since_last_bill(
        i_dpp_id                  in     com_api_type_pkg.t_long_id
      , i_eff_date                in     date
      , i_oper_type               in     com_api_type_pkg.t_dict_value
      , i_dpp_amount              in     com_api_type_pkg.t_money
      , i_total_instalments       in     com_api_type_pkg.t_count
      , i_paid_instalments        in     com_api_type_pkg.t_count
    ) return com_api_type_pkg.t_boolean
    is
        l_params                         com_api_type_pkg.t_param_tab;
        l_service_id                     com_api_type_pkg.t_short_id;
        l_dpp                            dpp_api_type_pkg.t_dpp;
        l_result                         com_api_type_pkg.t_boolean;
    begin
        rul_api_param_pkg.set_param(
            i_name    => 'OPER_TYPE'
          , i_value   => i_oper_type
          , io_params => l_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'DPP_AMOUNT'
          , i_value   => i_dpp_amount
          , io_params => l_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'INSTALMENT_COUNT'
          , i_value   => i_total_instalments
          , io_params => l_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PAID_INSTALMENT_COUNT'
          , i_value   => i_paid_instalments
          , io_params => l_params
        );

        l_dpp := get_dpp(i_dpp_id => i_dpp_id);

        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id           => l_dpp.account_id
              , i_attr_name           => null
              , i_service_type_id     => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
              , i_split_hash          => l_dpp.split_hash
              , i_eff_date            => i_eff_date
              , i_inst_id             => l_dpp.inst_id
            );

        begin
            l_result := prd_api_product_pkg.get_attr_value_number(
                            i_product_id   => l_dpp.product_id
                          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id    => l_dpp.account_id
                          , i_attr_name    => dpp_api_const_pkg.ATTR_INTEREST_SINCE_LAST_BILL
                          , i_params       => l_params
                          , i_service_id   => l_service_id
                          , i_eff_date     => i_eff_date
                          , i_split_hash   => l_dpp.split_hash
                          , i_inst_id      => l_dpp.inst_id
                          , i_mask_error   => com_api_const_pkg.TRUE
                        );
        exception
            when com_api_error_pkg.e_application_error then
                l_result := null;
        end;

        return l_result;
    end calc_interest_since_last_bill;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_dpp_id [' || i_dpp_id
                     || '], i_inst_id [' || i_inst_id
                     || '], i_fee_id [' || i_fee_id
                     || '], i_rest_amount [' || i_rest_amount
                     || '], i_eff_date [#1], i_last_bill_date [#2]'
      , i_env_param1 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param2 => to_char(i_last_bill_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    get_dpp_info(
        i_dpp_id                  => i_dpp_id
      , o_original_oper_type      => l_original_oper_type
      , o_inst_id                 => l_inst_id
      , o_dpp_amount              => l_dpp_amount
      , o_instalments_count       => l_instalments_count
      , o_paid_instalments_count  => l_paid_instalments_count
      , o_rest_amount             => l_rest_amount
      , o_last_bill_date          => l_last_bill_date
    );

    -- Values of incoming parameters are primary
    l_inst_id        := nvl(i_inst_id, l_inst_id);
    l_rest_amount    := nvl(i_rest_amount, l_rest_amount);
    l_last_bill_date := nvl(i_last_bill_date, l_last_bill_date);

    if i_eff_date is null then
        l_eff_date  := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);
    else
        l_eff_date  := i_eff_date;
    end if;

    if i_fee_id is null then
        get_saved_attribute_value(
            i_attr_name  => dpp_api_const_pkg.ATTR_FEE_ID
          , i_dpp_id     => i_dpp_id
          , o_value      => l_fee_id
        );
    else
        l_fee_id := i_fee_id;
    end if;

    l_is_interest_since_last_bill :=
        calc_interest_since_last_bill(
            i_dpp_id             => i_dpp_id
          , i_eff_date           => l_eff_date
          , i_oper_type          => l_original_oper_type
          , i_dpp_amount         => l_rest_amount
          , i_total_instalments  => l_instalments_count
          , i_paid_instalments   => l_paid_instalments_count
        );

    if l_is_interest_since_last_bill = com_api_const_pkg.FALSE then
        o_interest_amount := 0;
    else
        -- Not billed amount without interests + interests from the last bill date till today
        o_interest_amount := round(l_rest_amount * (get_year_percent_in_fraction(l_fee_id) / get_days_in_year)
                                                 * (trunc(l_eff_date) - trunc(l_last_bill_date)));
    end if;

    trc_log_pkg.debug(
        i_text       =>  LOG_PREFIX ||  ': l_last_bill_date [#1'
                     || '], l_instalments_count [' || l_instalments_count
                     || '], l_paid_instalments_count [' || l_paid_instalments_count
                     || '], l_fee_id [' || l_fee_id
                     || '], l_rest_amount [' || l_rest_amount
                     || '], o_interest_amount [' || o_interest_amount
                     || '], l_is_interest_since_last_bill [' || l_is_interest_since_last_bill || ']'
      , i_env_param1 => to_char(l_last_bill_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    o_amount := round(l_rest_amount) + o_interest_amount;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_amount [' || o_amount || '], o_interest_amount [' || o_interest_amount || ']'
    );
end get_amount_to_cancel;

function check_balances_exist(
    i_account_id              in    com_api_type_pkg.t_account_id
  , i_mask_error              in    com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean
is
    l_balances                      com_api_type_pkg.t_amount_by_name_tab;
    l_result                        com_api_type_pkg.t_boolean;
begin
    acc_api_balance_pkg.get_account_balances(
        i_account_id            => i_account_id
      , o_balances              => l_balances
      , i_lock_balances         => com_api_const_pkg.FALSE
    );
    if      l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED)
        and l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT)
    then
        l_result := com_api_const_pkg.TRUE;
    else
        begin
            com_api_error_pkg.raise_error(
                i_error      => 'DPP_INSTALMENT_ACCOUNT_BALANCE_TYPE_NOT_FOUND'
              , i_env_param1 =>
                    case
                        when not l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED) then
                            crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                        when not l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT) then
                            crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT
                    end
              , i_mask_error => i_mask_error
            );
        exception
            when com_api_error_pkg.e_application_error then
                if i_mask_error = com_api_const_pkg.TRUE then
                    l_result := com_api_const_pkg.FALSE;
                else
                    raise;
                end if;
        end;
    end if;

    return l_result;
end check_balances_exist;

/*
 * Bulk registering a new DPP via XML file (CLOB).
 * @i_xml          - incoming XML file
 * @i_inst_id      - institution ID
 * @i_sess_file_id - session file ID
 * @o_result       - response XML file with the same structure (CLOB)
 */
procedure register_dpp(
    i_xml                     in     clob
  , i_inst_id                 in     com_api_type_pkg.t_inst_id default null
  , i_sess_file_id            in     com_api_type_pkg.t_long_id default null
  , o_result                     out clob
) is
    l_xml                            xmltype;
begin
    register_dpp(
        i_xml          => XMLType(i_xml)
      , i_inst_id      => i_inst_id
      , i_sess_file_id => i_sess_file_id
      , o_result       => l_xml
    );

    select XMLSerialize(document l_xml as clob indent )
      into o_result
      from dual;
end;

function get_dpp(
    i_reg_oper_id             in      com_api_type_pkg.t_long_id
  , i_mask_error              in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return dpp_api_type_pkg.t_dpp
is
    l_dpp_rec                         dpp_api_type_pkg.t_dpp;
begin
    begin
        select dp.id
             , dp.oper_id
             , dp.account_id
             , dp.card_id
             , dp.product_id
             , dp.oper_date
             , dp.oper_amount
             , dp.oper_currency
             , dp.dpp_amount
             , dp.dpp_currency
             , dp.interest_amount
             , dp.status
             , dp.instalment_amount
             , dp.instalment_total
             , dp.instalment_billed
             , dp.next_instalment_date
             , dp.debt_balance
             , dp.inst_id
             , dp.split_hash
             , dp.reg_oper_id
             , dp.posting_date
             , dp.oper_type
             , (select v.value
                  from dpp_attribute_value v
                     , prd_attribute a
                 where a.attr_name = 'DPP_ALGORITHM'
                   and a.id        = v.attr_id
                   and v.dpp_id    = dp.id
                ) dpp_algorithm
          into l_dpp_rec
          from dpp_payment_plan dp
         where dp.reg_oper_id = i_reg_oper_id
        ;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'DPP_FOR_OPERATION_NOT_FOUND'
                  , i_env_param1 => i_reg_oper_id
                );
            end if;
    end;
    return l_dpp_rec;
end get_dpp;

/*
 * Function returns a separate credit account (different compared to <i_account>) of the same customer.
 */
function get_separate_credit_account(
    i_account                 in     acc_api_type_pkg.t_account_rec
) return acc_api_type_pkg.t_account_rec
is
    l_credit_accounts                acc_api_type_pkg.t_account_tab;
begin
    l_credit_accounts :=
        crd_utl_pkg.get_credit_accounts(
            i_customer_id           => i_account.customer_id
          , i_inst_id               => i_account.inst_id
          , i_split_hash            => i_account.split_hash
          , i_excluded_account_id   => i_account.account_id -- not the same account is required
        );

    if l_credit_accounts.count() > 1 then
        com_api_error_pkg.raise_error(
            i_error      => 'DPP_TWO_OR_MORE_ACCOUNTS_FOUND'
          , i_env_param1 => i_account.customer_id
        );
    end if;

    return l_credit_accounts(1);
end get_separate_credit_account;

end;
/
