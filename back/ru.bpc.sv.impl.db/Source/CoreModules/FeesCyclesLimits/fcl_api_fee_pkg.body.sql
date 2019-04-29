create or replace package body fcl_api_fee_pkg as

procedure get_period_coeff(
    i_calc_period           in      com_api_type_pkg.t_tiny_id
  , i_start_date            in      date
  , i_end_date              in      date
  , i_eff_date              in      date
  , i_length_type           in      com_api_type_pkg.t_dict_value
  , i_length_type_algorithm in      com_api_type_pkg.t_dict_value
  , o_period_coeff              out number
  , o_period_coeff1             out number
) is
begin
    if i_calc_period is not null or (i_start_date is not null and i_end_date is not null) then
        if i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_YEAR then

            --high priority
            if i_start_date is not null and i_end_date is not null then
                if i_length_type_algorithm is null or i_length_type_algorithm = fcl_api_const_pkg.ALG_NUMBER_DAYS_OF_YEAR_FACT then

                    if trunc(i_start_date, 'YEAR') < trunc(i_end_date, 'YEAR') then

                        o_period_coeff  := ((to_date('3112' || to_char(i_start_date, 'yyyy'), 'ddmmyyyy')  + 1 - com_api_const_pkg.ONE_SECOND) - i_start_date)/(add_months(trunc(i_start_date, 'YYYY'), 12) - trunc(i_start_date, 'YYYY'));
                        o_period_coeff1 := (i_end_date - trunc(i_end_date, 'YEAR'))/(add_months(trunc(i_end_date, 'YYYY'), 12) - trunc(i_end_date, 'YYYY'));

                    else
                        o_period_coeff := (i_end_date - i_start_date)/(add_months(trunc(i_start_date, 'YYYY'), 12) - trunc(i_start_date, 'YYYY'));
                    end if;

                elsif i_length_type_algorithm = fcl_api_const_pkg.ALG_NUMBER_DAYS_OF_YEAR_360 then
                    o_period_coeff := (i_end_date - i_start_date)/360;

                elsif i_length_type_algorithm = fcl_api_const_pkg.ALG_NUMBER_DAYS_OF_YEAR_365 then
                    o_period_coeff := (i_end_date - i_start_date)/365;
                end if;

            else
                --default
                if i_length_type_algorithm is null or i_length_type_algorithm = fcl_api_const_pkg.ALG_NUMBER_DAYS_OF_YEAR_FACT then
                    o_period_coeff := i_calc_period / (add_months(trunc(i_eff_date, 'YYYY'), 12) - trunc(i_eff_date, 'YYYY'));

                elsif i_length_type_algorithm = fcl_api_const_pkg.ALG_NUMBER_DAYS_OF_YEAR_360 then
                    o_period_coeff := i_calc_period / 360;

                elsif i_length_type_algorithm = fcl_api_const_pkg.ALG_NUMBER_DAYS_OF_YEAR_365 then
                    o_period_coeff := i_calc_period / 365;
                end if;
            end if;

        elsif i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_MONTH then

            if i_start_date is not null and i_end_date is not null then

                if trunc(i_start_date, 'MONTH') < trunc(i_end_date, 'MONTH') then

                    o_period_coeff  := (last_day(trunc(i_start_date, 'MONTH')) + 1 - com_api_const_pkg.ONE_SECOND - i_start_date)/to_number(to_char(last_day(i_start_date), 'dd'));
                    o_period_coeff1 := (i_end_date - trunc(i_end_date, 'MONTH'))/to_number(to_char(last_day(i_end_date), 'dd'));
                else
                    o_period_coeff := (i_end_date - i_start_date)/to_number(to_char(last_day(i_start_date), 'dd'));
                end if;
            else
                o_period_coeff := i_calc_period / (add_months(i_eff_date, 1) - i_eff_date);
            end if;
        else
            -- others length type
            if i_start_date is not null and i_end_date is not null then
                o_period_coeff :=
                    case when i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_WEEK  then (i_end_date - i_start_date) / 7
                         when i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_DAY   then (i_end_date - i_start_date)
                         when i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_HOUR  then (i_end_date - i_start_date) * 24
                         else 1
                    end;
            else
                o_period_coeff :=
                    case when i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_WEEK  then i_calc_period / 7
                         when i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_DAY   then i_calc_period
                         when i_length_type = fcl_api_const_pkg.CYCLE_LENGTH_HOUR  then i_calc_period * 24
                         else 1
                    end;
            end if;
        end if;
    else
        o_period_coeff := 1;
    end if;

end;

function get_fee_amount(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id          default 1
  , io_base_currency    in out  com_api_type_pkg.t_curr_code
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date                                default null
  , i_calc_period       in      com_api_type_pkg.t_tiny_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_fee_included      in      com_api_type_pkg.t_boolean          default null
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_tier_amount       in      com_api_type_pkg.t_money            default null
  , i_tier_count        in      com_api_type_pkg.t_long_id          default null
) return com_api_type_pkg.t_money is
    l_fee_amount        com_api_type_pkg.t_money;
begin
    get_fee_amount(
        i_fee_id            => i_fee_id
      , i_base_amount       => i_base_amount
      , i_base_count        => i_base_count
      , i_base_currency     => io_base_currency
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_eff_date          => i_eff_date
      , i_calc_period       => i_calc_period
      , i_split_hash        => i_split_hash
      , io_fee_currency     => io_base_currency
      , o_fee_amount        => l_fee_amount
      , i_fee_included      => i_fee_included
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_tier_amount       => i_tier_amount
      , i_tier_count        => i_tier_count
    );

    return l_fee_amount;
end;

procedure get_fee_amount(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id          default 1
  , i_base_currency     in      com_api_type_pkg.t_curr_code
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date                                default null
  , i_calc_period       in      com_api_type_pkg.t_tiny_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_fee_included      in      com_api_type_pkg.t_boolean          default null
  , io_fee_currency     in out  com_api_type_pkg.t_curr_code
  , o_fee_amount           out  com_api_type_pkg.t_money
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_tier_amount       in      com_api_type_pkg.t_money            default null
  , i_tier_count        in      com_api_type_pkg.t_long_id          default null
  , i_oper_date         in      date                                default null
) is

    cu_fee_rates        sys_refcursor;

    l_amount_for_tier   com_api_type_pkg.t_money;
    l_count_for_tier    com_api_type_pkg.t_long_id;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_currency          com_api_type_pkg.t_curr_code;
    l_fee_rate_calc     com_api_type_pkg.t_dict_value;
    l_fee_base_calc     com_api_type_pkg.t_dict_value;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_sum_curr          com_api_type_pkg.t_money                    := 0;
    l_count_curr        com_api_type_pkg.t_long_id                  := 0;
    l_sum_limit         com_api_type_pkg.t_money                    := 0;
    l_count_limit       com_api_type_pkg.t_long_id                  := 0;
    l_fixed_rate        com_api_type_pkg.t_money                    := 0;
    l_percent_rate      com_api_type_pkg.t_money                    := 0;
    l_fixed_amount      com_api_type_pkg.t_money                    := 0;
    l_percent_amount    com_api_type_pkg.t_money                    := 0;
    l_min_value         com_api_type_pkg.t_money                    := 0;
    l_max_value         com_api_type_pkg.t_money                    := 0;
    l_min_value_last    com_api_type_pkg.t_money                    := 0;
    l_max_value_last    com_api_type_pkg.t_money                    := 0;
    l_length_type       com_api_type_pkg.t_dict_value;
    l_count_lower       com_api_type_pkg.t_long_id                  := 0;
    l_count_upper       com_api_type_pkg.t_long_id                  := 0;
    l_sum_lower         com_api_type_pkg.t_money                    := 0;
    l_sum_upper         com_api_type_pkg.t_money                    := 0;
    l_conv_base_amount  com_api_type_pkg.t_money                    := 0;
    l_base_amount       com_api_type_pkg.t_money                    := 0;
    l_base_count        com_api_type_pkg.t_long_id                  := 0;
    l_fee_amount        com_api_type_pkg.t_money                    := 0;
    l_period_coeff      number                                      := 1;
    l_period_coeff1     number;
    l_eff_date          date;
    l_limit_eff_date    date;
    l_last_reset_date   date;
    l_prev_date         date;
    l_next_date         date;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_rate_type         com_api_type_pkg.t_dict_value;

    l_tier_count        com_api_type_pkg.t_tiny_id                  := 0;
    l_length_type_algorithm  com_api_type_pkg.t_dict_value;

    l_sql_source        com_api_type_pkg.t_full_desc                :=
        'select fixed_rate '                           ||
             ', percent_rate '                         ||
             ', min_value '                            ||
             ', max_value '                            ||
             ', length_type  '                         ||
             ', length_type_algorithm  '               ||
             ', nvl(count_threshold, 0) count_lower '  ||
             ', nvl(min(count_threshold) over(order by count_threshold range between 1 following and unbounded following) - 1, 9999999999999999) count_upper ' ||
             ', nvl(sum_threshold, 0) sum_lower '      ||
             ', nvl(min(sum_threshold) over(order by sum_threshold range between 1 following and unbounded following) - 1, 999999999999999999.9999) sum_upper ' ||
          'from fcl_fee_tier   '             ||
         'where fee_id = :i_fee_id '||
         'order by sum_lower, count_lower ';
begin
    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    begin
        select f.fee_type
             , f.currency
             , f.fee_rate_calc
             , f.fee_base_calc
             , t.limit_type
             , f.limit_id
             , f.inst_id
          into l_fee_type
             , l_currency
             , l_fee_rate_calc
             , l_fee_base_calc
             , l_limit_type
             , l_limit_id
             , l_inst_id
          from fcl_fee f
             , fcl_fee_type t
         where f.id = i_fee_id
           and f.fee_type = t.fee_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'FEE_NOT_FOUND'
              , i_env_param1    => i_fee_id
            );
    end;

    io_fee_currency := nvl(io_fee_currency, l_currency);

    -- Check simple algorithms to prevent currency conversion
    if io_fee_currency = i_base_currency and
       l_fee_rate_calc in (fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE, fcl_api_const_pkg.FEE_RATE_FIXED_VALUE) and
       l_fee_base_calc =  fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT and
       nvl(i_fee_included, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
    then
        for r in (
            select fixed_rate
                 , percent_rate
                 , min_value
                 , max_value
                 , length_type
                 , length_type_algorithm
                 , sum_threshold
                 , count_threshold
                 , count(1) over() tier_count
              from fcl_fee_tier
             where fee_id = i_fee_id
        ) loop
            -- if simple percentage algorith and incoming currency equal to outqoing
            -- implement simple calculation without currency conversion
            if r.tier_count = 1 and r.sum_threshold = 0 and r.count_threshold = 0 and
               nvl(r.max_value, 0) = 0 and
               nvl(r.min_value, 0) = 0
            then
                if l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE then
                    get_period_coeff(
                        i_calc_period           => i_calc_period
                      , i_start_date            => i_start_date
                      , i_end_date              => i_end_date
                      , i_eff_date              => l_eff_date
                      , i_length_type           => r.length_type
                      , i_length_type_algorithm => r.length_type_algorithm
                      , o_period_coeff          => l_period_coeff
                      , o_period_coeff1         => l_period_coeff1
                    );

                    o_fee_amount := round(r.percent_rate * i_base_amount * l_period_coeff / 100, 4);

                    if l_period_coeff1 is not null then
                        o_fee_amount := o_fee_amount +
                            round(r.percent_rate * i_base_amount * l_period_coeff1 / 100, 4);
                    end if;

                elsif l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FIXED_VALUE and r.fixed_rate = 0 then
                    o_fee_amount := 0;
                end if;
            end if;
            exit;
        end loop;

        if o_fee_amount is not null then
            return;
        end if;
    end if;

    if io_fee_currency != l_currency or (i_base_currency is not null and i_base_currency != l_currency) then
        begin
            select r.rate_type
              into l_rate_type
              from fcl_fee_rate r
             where r.inst_id = l_inst_id
               and r.fee_type = l_fee_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'FEE_RATE_TYPE_NOT_FOUND'
                  , i_env_param1    => l_fee_type
                  , i_env_param2    => l_inst_id
                );
        end;
    end if;

    trc_log_pkg.debug('get_fee_amount: i_base_currency='||i_base_currency||' l_currency='||l_currency);
    if i_base_currency is not null and i_base_currency != l_currency then
        l_conv_base_amount :=
            com_api_rate_pkg.convert_amount(
                i_src_amount        => i_base_amount
              , i_src_currency      => i_base_currency
              , i_dst_currency      => l_currency
              , i_rate_type         => l_rate_type
              , i_inst_id           => l_inst_id
              , i_eff_date          => l_eff_date
            );

        if i_tier_amount is not null then
            l_amount_for_tier   :=
                com_api_rate_pkg.convert_amount(
                    i_src_amount        => i_tier_amount
                  , i_src_currency      => i_base_currency
                  , i_dst_currency      => l_currency
                  , i_rate_type         => l_rate_type
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => l_eff_date
                );
        else
            l_amount_for_tier   := l_conv_base_amount;
        end if;
    else
        l_conv_base_amount := i_base_amount;
        l_amount_for_tier  := nvl(i_tier_amount, i_base_amount);
    end if;
    trc_log_pkg.debug('get_fee_amount: i_base_amount='||i_base_amount||' l_conv_base_amount='||l_conv_base_amount);

    if l_limit_id is not null and i_entity_type is not null and i_object_id is not null then

        begin
            select b.cycle_type
              into l_cycle_type
              from fcl_limit a
                 , fcl_limit_type b
             where a.id         = l_limit_id
               and a.limit_type = b.limit_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'LIMIT_NOT_FOUND'
                  , i_env_param1    => l_limit_id
                );
        end;

        if l_cycle_type is not null then

            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type        => l_cycle_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_split_hash        => i_split_hash
              , o_prev_date         => l_prev_date
              , o_next_date         => l_next_date
            );

            if l_next_date <= l_eff_date
                and (i_oper_date is null
                    or l_next_date <= i_oper_date
                    )
            then
                fcl_api_limit_pkg.zero_limit_counter(
                    i_limit_type        => l_limit_type
                  , i_entity_type       => i_entity_type
                  , i_object_id         => i_object_id
                  , i_eff_date          => l_next_date
                  , i_split_hash        => i_split_hash
                );

                fcl_api_cycle_pkg.switch_cycle(
                    i_cycle_type        => l_cycle_type
                  , i_product_id        => prd_api_product_pkg.get_product_id(
                                               i_entity_type  => i_entity_type
                                             , i_object_id    => i_object_id
                                             , i_eff_date     => null
                                             , i_inst_id      => null
                                           )
                  , i_entity_type       => i_entity_type
                  , i_object_id         => i_object_id
                  , i_params            => opr_api_shared_data_pkg.g_params
                  , i_eff_date          => l_eff_date
                  , i_split_hash        => i_split_hash
                  , o_new_finish_date   => l_next_date
                );
            elsif l_next_date <= l_eff_date
                and l_next_date > i_oper_date
            then
                l_eff_date := i_oper_date;
            end if;
        end if;

        if l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER then
            l_limit_eff_date := nvl(l_prev_date - com_api_const_pkg.ONE_SECOND, l_eff_date);
        else
            l_limit_eff_date := l_eff_date;
        end if;

        begin

            fcl_api_limit_pkg.get_limit_counter(
                i_limit_type        => l_limit_type
              , i_product_id        => prd_api_product_pkg.get_product_id(
                                            i_entity_type => i_entity_type
                                          , i_object_id   => i_object_id
                                          , i_eff_date    => l_eff_date)
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_params            => opr_api_shared_data_pkg.g_params
              , io_currency         => io_fee_currency
              , i_eff_date          => l_limit_eff_date
              , i_split_hash        => i_split_hash
              , o_last_reset_date   => l_last_reset_date
              , o_count_curr        => l_count_curr
              , o_count_limit       => l_count_limit
              , o_sum_limit         => l_sum_limit
              , o_sum_curr          => l_sum_curr
            );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'LIMIT_COUNTER_NOT_FOUND' then
                    l_sum_curr       := 0;
                    l_count_curr     := 0;
                else
                    raise;
                end if;
        end;
    end if;

    l_count_for_tier    := nvl(i_tier_count, i_base_count);

    begin
        trc_log_pkg.debug('find fee tier: '||l_sql_source);

        open cu_fee_rates for l_sql_source
            using i_fee_id;

        loop
            fetch cu_fee_rates into
                l_fixed_rate
              , l_percent_rate
              , l_min_value_last
              , l_max_value_last
              , l_length_type
              , l_length_type_algorithm
              , l_count_lower
              , l_count_upper
              , l_sum_lower
              , l_sum_upper;

            exit when cu_fee_rates%notfound;

            if (
                l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_TIRED_BASIS
                and
                (l_sum_curr + l_amount_for_tier)  >= l_sum_lower
                and
                (l_count_curr + l_count_for_tier) >= l_count_lower
               )
               or
               (
                l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER
                and
                l_sum_curr between l_sum_lower and l_sum_upper
                and
                l_count_curr between l_count_lower and l_count_upper
               )
               or
               (
                l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_THRESHOLD_AMOUNT
                and
                (l_sum_curr <= l_sum_lower or l_sum_curr < l_sum_upper)
                and
                (l_count_curr <= l_count_lower or l_count_curr < l_count_upper)
               )
               or
               (
                l_fee_base_calc != fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER
                and
                (l_sum_curr + l_amount_for_tier)  between l_sum_lower   and l_sum_upper
                and
                (l_count_curr + l_count_for_tier) between l_count_lower and l_count_upper
               )
            then
                l_min_value := l_min_value_last;
                l_max_value := l_max_value_last;

                get_period_coeff(
                    i_calc_period           => i_calc_period
                  , i_start_date            => i_start_date
                  , i_end_date              => i_end_date
                  , i_eff_date              => l_eff_date
                  , i_length_type           => l_length_type
                  , i_length_type_algorithm => l_length_type_algorithm
                  , o_period_coeff          => l_period_coeff
                  , o_period_coeff1         => l_period_coeff1
                );
                if l_fee_base_calc in (fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT, fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER) then
                    l_base_amount := l_conv_base_amount;

                elsif l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_DIFF_THRESHOLD and l_sum_curr > l_sum_lower then
                    l_base_amount := l_conv_base_amount;

                elsif l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_DIFF_THRESHOLD then
                    l_base_amount := (l_conv_base_amount + l_sum_curr) - l_sum_lower;

                elsif l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_THRESHOLD then
                    l_base_amount := l_sum_lower;

                elsif l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_TIRED_BASIS and (l_conv_base_amount + l_sum_curr) < l_sum_upper then
                    l_base_amount := (l_conv_base_amount + l_sum_curr) - l_sum_lower;

                elsif l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_TIRED_BASIS and (l_conv_base_amount + l_sum_curr) >= l_sum_upper then
                    l_base_amount := l_sum_upper - l_sum_lower;

                elsif l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_THRESHOLD_AMOUNT
                then
                     l_base_amount := least(l_sum_upper, l_conv_base_amount + l_sum_curr)  - greatest(l_sum_lower, l_sum_curr);
                     l_base_amount := greatest(l_base_amount, 0);
                end if;

                if l_sum_lower > 0 and l_fee_base_calc not in (fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
                                                             , fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER) then
                    l_base_amount := l_base_amount + 1;
                end if;

                l_base_count :=
                    case when l_fee_base_calc in (fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT, fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER)
                         then i_base_count

                         when l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_DIFF_THRESHOLD and l_count_curr > l_count_lower
                         then i_base_count

                         when l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_DIFF_THRESHOLD
                         then (i_base_count + l_count_curr) - l_count_lower

                         when l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_THRESHOLD
                         then l_count_lower

                         when l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_TIRED_BASIS and (i_base_count + l_count_curr) < l_count_upper
                         then (i_base_count + l_count_curr) - l_count_lower

                         when l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_TIRED_BASIS and (i_base_count + l_count_curr) >= l_count_upper
                         then l_count_upper - l_count_lower
                    end;

                if l_count_lower > 0 and l_fee_base_calc not in (fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT, fcl_api_const_pkg.FEE_BASE_PREV_TURNOVER) then
                    l_base_count := l_base_count + 1;
                end if;

                l_fixed_amount := l_fixed_amount +
                    (l_fixed_rate * l_base_count * l_period_coeff);

                if l_period_coeff1 is not null then
                    l_fixed_amount := l_fixed_amount + (l_fixed_rate * l_base_count * l_period_coeff1);

                end if;

                if nvl(i_fee_included, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE and
                   l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE and
                   l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
                then
                    l_percent_amount :=
                        l_base_amount/(l_percent_rate * l_period_coeff + 100) * (l_percent_rate * l_period_coeff);

                    if l_period_coeff1 is not null then
                        l_percent_amount := l_percent_amount +
                            (l_base_amount/(l_percent_rate * l_period_coeff1 + 100) * (l_percent_rate * l_period_coeff1));
                    end if;

                else
                    l_percent_amount := l_percent_amount +
                        (l_percent_rate * l_base_amount * l_period_coeff / 100);

                    if l_period_coeff1 is not null then
                        l_percent_amount := l_percent_amount +
                            (l_percent_rate * l_base_amount * l_period_coeff1 / 100);
                    end if;
                end if;

                l_tier_count := l_tier_count + 1;

                if l_tier_count > 1 and l_fee_base_calc not in (fcl_api_const_pkg.FEE_BASE_TIRED_BASIS
                                                              , fcl_api_const_pkg.FEE_BASE_THRESHOLD_AMOUNT)
                then
                    com_api_error_pkg.raise_error(
                        i_error             => 'TOO_MANY_FEE_RATES_FOUND'
                      , i_env_param1        => i_fee_id
                      , i_env_param2        => l_conv_base_amount
                      , i_env_param3        => l_count_curr
                      , i_env_param4        => l_sum_curr
                      , i_entity_type       => i_entity_type
                      , i_object_id         => i_object_id
                    );
                end if;

            end if;
        end loop;

        close cu_fee_rates;

    exception
        when others then
            if cu_fee_rates%isopen then
                close cu_fee_rates;
            end if;

            raise;
    end;

    if l_tier_count = 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_RATE_NOT_FOUND'
          , i_env_param1        => i_fee_id
          , i_env_param2        => l_conv_base_amount
          , i_env_param3        => l_count_curr
          , i_env_param4        => l_sum_curr
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
        );
    end if;

    l_fee_amount := l_fee_amount +
        case when l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
             then l_percent_amount

             when l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FIXED_VALUE
             then l_fixed_amount

             when l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_MIN_FIXED_PERCENT
             then least(l_fixed_amount, l_percent_amount)

             when l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_MAX_FIXED_PERCENT
             then greatest(l_fixed_amount, l_percent_amount)

             when l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_SUM_FIXED_PERCENT
             then (l_fixed_amount + l_percent_amount)

             else 0
        end;

    if nvl(l_min_value, 0) != 0 and l_min_value > l_fee_amount then
        l_fee_amount := l_min_value;
    end if;

    if nvl(l_max_value, 0) != 0 and l_max_value < l_fee_amount then
        l_fee_amount := l_max_value;
    end if;

    if io_fee_currency != l_currency then
        o_fee_amount := round(
            com_api_rate_pkg.convert_amount(
                i_src_amount        => l_fee_amount
              , i_src_currency      => l_currency
              , i_dst_currency      => io_fee_currency
              , i_rate_type         => l_rate_type
              , i_inst_id           => l_inst_id
              , i_eff_date          => l_eff_date
            ), 4);
    else
        o_fee_amount := round(l_fee_amount, 4);
    end if;

    -- if simple percentage algorith and incoming currency equal to outqoing
    -- implement simple calculation without currency conversion
    if io_fee_currency = i_base_currency and
       i_base_currency != l_currency and
       l_tier_count = 1 and l_sum_lower = 0 and l_count_lower = 0 and
       l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE and
       l_fee_base_calc = fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT and
       nvl(l_max_value, 0) = 0 and
       nvl(l_min_value, 0) = 0
    then
        if nvl(i_fee_included, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            o_fee_amount := round(l_percent_rate * i_base_amount * l_period_coeff / 100, 4);
        else
            o_fee_amount := round(i_base_amount / (l_percent_rate * l_period_coeff + 100) * (l_percent_rate * l_period_coeff), 4);
        end if;
    end if;
end;

procedure start_counter(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_result            pls_integer;
begin

    select 1
      into l_result
      from fcl_fee_counter
     where fee_type    = i_fee_type
       and entity_type = i_entity_type
       and object_id   = i_object_id
       and nvl2(end_date, 1, 0) = com_api_const_pkg.FALSE;

exception
    when no_data_found then
        insert into fcl_fee_counter(
            id
          , fee_type
          , entity_type
          , object_id
          , start_date
          , end_date
          , split_hash
          , inst_id
        ) values (
            fcl_fee_counter_seq.nextval
          , i_fee_type
          , i_entity_type
          , i_object_id
          , nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
          , i_end_date
          , case
          when i_split_hash is null
          then com_api_hash_pkg.get_split_hash(
                   i_entity_type => i_entity_type
                 , i_object_id   => i_object_id
               )
          else i_split_hash
          end
          , i_inst_id
        );
end;

procedure stop_counter(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_end_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
) is
    l_fee_counter_id    com_api_type_pkg.t_long_id;
begin

    select id
      into l_fee_counter_id
      from fcl_fee_counter
     where fee_type    = i_fee_type
       and entity_type = i_entity_type
       and object_id   = i_object_id
       and (end_date is null or end_date > i_end_date);

    update fcl_fee_counter
       set end_date = nvl(i_end_date, com_api_sttl_day_pkg.get_sysdate)
     where id       = l_fee_counter_id;

exception
    when no_data_found then
        null;
end;

function select_fee(
    i_fee          in  fcl_api_type_pkg.t_fee
  , i_fee_tier     in  fcl_api_type_pkg.t_fee_tier_tab
  , i_fees         in  com_api_type_pkg.t_varchar2_tab
) return com_api_type_pkg.t_param_value as
    l_result     com_api_type_pkg.t_param_value;
    l_fee        fcl_api_type_pkg.t_fee;
begin
    for i in 1 .. i_fees.count loop
        begin
            select id
                 , fee_type
                 , fee_rate_calc
                 , fee_base_calc
                 , currency
                 , inst_id
                 , cycle_id
                 , limit_id
              into l_fee
              from fcl_fee f
             where f.id = to_number(i_fees(i), com_api_const_pkg.NUMBER_FORMAT);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'FEE_NOT_FOUND'
                  , i_env_param1    => i_fees(i)
                );
        end;

        if      i_fee.fee_type      = l_fee.fee_type
            and i_fee.fee_rate_calc = l_fee.fee_rate_calc
            and i_fee.fee_base_calc = l_fee.fee_base_calc
            and i_fee.currency      = l_fee.currency      then
            for r in (
                select t.fixed_rate
                     , t.percent_rate
                     , t.min_value
                     , t.max_value
                     , t.length_type
                     , t.sum_threshold
                     , t.count_threshold
                     , t.length_type_algorithm
                  from fcl_fee_tier t
                 where t.fee_id = l_fee.id
            )
            loop
                for j in 1 .. i_fee_tier.count loop
                    if    r.fixed_rate      = i_fee_tier(j).fixed_rate
                      and r.percent_rate    = i_fee_tier(j).percent_rate
                      and r.min_value       = i_fee_tier(j).min_value
                      and r.max_value       = i_fee_tier(j).max_value
                      and r.length_type     = i_fee_tier(j).length_type
                      and r.sum_threshold   = i_fee_tier(j).sum_threshold
                      and r.count_threshold = i_fee_tier(j).count_threshold then
                        return i_fees(i);
                    end if;
                end loop;
            end loop;
        end if;
    end loop;

    return null;
end;

procedure save_fee(
    io_fee_id       in out          com_api_type_pkg.t_short_id
  , i_entity_type   in              com_api_type_pkg.t_dict_value
  , i_object_id     in              com_api_type_pkg.t_long_id
  , i_attr_name     in              com_api_type_pkg.t_name
  , i_percent_rate  in              com_api_type_pkg.t_money
  , i_product_id    in              com_api_type_pkg.t_short_id
  , i_service_id    in              com_api_type_pkg.t_short_id
  , i_eff_date      in              date
  , i_fee_currency  in              com_api_type_pkg.t_curr_code
  , i_fee_type      in              com_api_type_pkg.t_dict_value
  , i_fee_rate_calc in              com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
  , i_fee_base_calc in              com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
  , i_length_type   in              com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.CYCLE_LENGTH_YEAR
  , i_inst_id       in              com_api_type_pkg.t_inst_id      default null
  , i_split_hash    in              com_api_type_pkg.t_tiny_id      default null
  , i_search_fee    in              com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
    l_fee                           fcl_api_type_pkg.t_fee;
    l_fee_tier                      fcl_api_type_pkg.t_fee_tier_tab;
    l_fee_tier_id                   com_api_type_pkg.t_short_id;
    l_seqnum                        com_api_type_pkg.t_seqnum;
    l_attr_value_id                 com_api_type_pkg.t_medium_id;
    l_eff_date                      date                            := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
begin
    trc_log_pkg.debug(
        'Incoming fee_id [' || io_fee_id ||
        '], percent rate from auth_tag [' || i_percent_rate ||
        '], i_fee_type [' || i_fee_type ||
        '], i_fee_rate_calc [' || i_fee_rate_calc ||
        '], i_fee_base_calc [' || i_fee_base_calc ||
        '], i_fee_currency [' || i_fee_currency ||
        ']'
    );

    l_fee.fee_type      := i_fee_type;
    l_fee.fee_rate_calc := i_fee_rate_calc;
    l_fee.fee_base_calc := i_fee_base_calc;
    l_fee.currency      := i_fee_currency;

    if i_percent_rate is not null then
        l_fee_tier(1).fixed_rate      := 0;
        l_fee_tier(1).percent_rate    := i_percent_rate;
        l_fee_tier(1).min_value       := 0;
        l_fee_tier(1).max_value       := 0;
        l_fee_tier(1).length_type     := i_length_type;
        l_fee_tier(1).sum_threshold   := 0;
        l_fee_tier(1).count_threshold := 0;

        -- check if such fee is already registred
        if i_search_fee = com_api_const_pkg.TRUE then
            begin
                io_fee_id :=
                    prd_api_product_pkg.get_fee_id(
                        i_product_id   => i_product_id
                      , i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                      , i_fee_type     => i_fee_type
                      , i_params       => io_params
                      , i_fee          => l_fee
                      , i_fee_tier     => l_fee_tier
                      , i_service_id   => i_service_id
                      , i_eff_date     => l_eff_date
                      , i_split_hash   => i_split_hash
                      , i_inst_id      => i_inst_id
                      , i_mask_error   => com_api_const_pkg.TRUE
                    );
            exception
                when com_api_error_pkg.e_application_error then
                    io_fee_id := null;
            end;
        end if;

        -- if it doesn't exist - add new one
        if io_fee_id is null then
            fcl_ui_fee_pkg.add_fee(
                i_fee_type      => l_fee.fee_type
              , i_currency      => l_fee.currency
              , i_fee_rate_calc => l_fee.fee_rate_calc
              , i_fee_base_calc => l_fee.fee_base_calc
              , i_inst_id       => i_inst_id
              , o_fee_id        => io_fee_id
              , o_seqnum        => l_seqnum
            );

            fcl_ui_fee_pkg.add_fee_tier(
                i_fee_id                => io_fee_id
              , i_fixed_rate            => l_fee_tier(1).fixed_rate
              , i_percent_rate          => l_fee_tier(1).percent_rate
              , i_min_value             => l_fee_tier(1).min_value
              , i_max_value             => l_fee_tier(1).max_value
              , i_length_type           => l_fee_tier(1).length_type
              , i_sum_threshold         => l_fee_tier(1).sum_threshold
              , i_count_threshold       => l_fee_tier(1).count_threshold
              , i_length_type_algorithm => null
              , o_fee_tier_id           => l_fee_tier_id
              , o_seqnum                => l_seqnum
            );

            prd_api_attribute_value_pkg.set_attr_value_fee(
                io_attr_value_id    => l_attr_value_id
              , i_service_id        => i_service_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_attr_name         => i_attr_name
              , i_mod_id            => null
              , i_start_date        => l_eff_date
              , i_end_date          => l_eff_date
              , i_fee_id            => io_fee_id
              , i_check_start_date  => com_api_const_pkg.FALSE
              , i_inst_id           => i_inst_id
            );

            trc_log_pkg.debug(
                i_text => 'new fee added; fee_id = ' || io_fee_id
            );
        else
            trc_log_pkg.debug(
                i_text => 'Fee already exist; fee_id =  ' || io_fee_id
            );
        end if;
    end if;

    if io_fee_id is null then
        io_fee_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_product_id   => i_product_id
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_attr_name    => i_attr_name
              , i_params       => io_params
              , i_service_id   => i_service_id
              , i_eff_date     => l_eff_date
              , i_split_hash   => i_split_hash
              , i_inst_id      => i_inst_id
            );
    end if;
end save_fee;

end;
/
