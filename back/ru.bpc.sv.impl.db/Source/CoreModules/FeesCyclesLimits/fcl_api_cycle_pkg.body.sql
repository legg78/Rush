create or replace package body fcl_api_cycle_pkg as
/************************************************************
 * The API for cycles <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010 <br />
 * Module: FCL_API_CYCLE_PKG <br />
 * @headcom
 ************************************************************/

procedure get_cycle_date(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_add_counter       in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , o_prev_date            out  date
  , o_next_date            out  date
) is
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    select next_date
         , prev_date
      into o_next_date
         , o_prev_date
      from fcl_cycle_counter
     where cycle_type  = i_cycle_type
       and object_id   = i_object_id
       and entity_type = i_entity_type
       and split_hash  = l_split_hash;

exception
    when no_data_found then
        if i_add_counter = com_api_type_pkg.TRUE then
            add_cycle_counter(
                i_cycle_type  => i_cycle_type
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_split_hash  => l_split_hash
              , i_inst_id     => ost_api_institution_pkg.get_object_inst_id(i_entity_type, i_object_id)
            );
            select next_date
                 , prev_date
              into o_next_date
                 , o_prev_date
              from fcl_cycle_counter
             where cycle_type  = i_cycle_type
               and object_id   = i_object_id
               and entity_type = i_entity_type
               and split_hash  = l_split_hash;
        else
            o_prev_date := null;
            o_next_date := null;
        end if;
end;

procedure calc_next_date(
    i_cycle_id             in     com_api_type_pkg.t_short_id
  , i_start_date           in     date                            default null
  , i_forward              in     com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , o_next_date               out date
  , i_cycle_calc_date_type in     com_api_type_pkg.t_dict_value   default null
  , i_object_params        in     com_api_type_pkg.t_param_tab    default cast(null as com_api_type_pkg.t_param_tab)
) is
    l_start_date        date;
    l_length_type       com_api_type_pkg.t_dict_value;
    l_cycle_length      com_api_type_pkg.t_tiny_id;
    l_trunc_type        com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_workdays_only     com_api_type_pkg.t_boolean;

    function get_next_workday(
        i_start_date           in      date
      , i_forward              in      com_api_type_pkg.t_boolean
      , i_inst_id              in      com_api_type_pkg.t_inst_id
      , i_cycle_length         in      com_api_type_pkg.t_tiny_id
      , i_cycle_calc_date_type in      com_api_type_pkg.t_dict_value
    ) return date is
        l_next_date        date;
    begin
        if i_cycle_calc_date_type = fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE then
            if i_forward = com_api_type_pkg.TRUE then
                return l_start_date + 1;
            else
                return l_start_date - 1;
            end if;
        end if;

        if i_forward = com_api_type_pkg.TRUE then
            select period_day
              into l_next_date
              from (
                    select p.period_day
                         , rownum rn
                      from (
                            select d.period_day
                              from (
                                    select trunc(l_start_date) + rownum period_day
                                      from dual
                                   connect by rownum <= (trunc(l_start_date) + 365 - trunc(l_start_date))
                              ) d
                             where d.period_day not in (
                                       select h.holiday_date
                                         from com_holiday h
                                        where h.holiday_date between trunc(l_start_date) and trunc(l_start_date) + 365
                                          and h.inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                                   )
                          order by d.period_day
                      ) p
                   )
             where rn = l_cycle_length;
        else
            select period_day
              into l_next_date
              from (
                    select p.period_day
                         , rownum rn
                      from (
                            select d.period_day
                              from (
                                    select trunc(l_start_date) - rownum period_day
                                      from dual
                                    connect by rownum <= (trunc(l_start_date) + 365 - trunc(l_start_date))
                              ) d
                             where d.period_day not in (
                                       select h.holiday_date
                                         from com_holiday h
                                        where h.holiday_date between trunc(l_start_date) - 365 and trunc(l_start_date)
                                          and h.inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                                   )
                          order by d.period_day desc
                      ) p
                   )
             where rn = l_cycle_length;
        end if;

        return l_next_date;
    end get_next_workday;

    procedure process_cycle(
        i_inst_id              in     com_api_type_pkg.t_inst_id
      , i_cycle_id             in     com_api_type_pkg.t_short_id
      , i_start_date           in     date
      , i_forward              in     com_api_type_pkg.t_boolean
      , i_length_type          in     com_api_type_pkg.t_dict_value
      , i_cycle_length         in     com_api_type_pkg.t_tiny_id
      , i_cycle_calc_date_type in     com_api_type_pkg.t_dict_value
      , i_trunc_type           in     com_api_type_pkg.t_dict_value
      , i_workdays_only        in     com_api_type_pkg.t_boolean
      , o_next_date               out date
    ) is
        l_sign                        com_api_type_pkg.t_sign;
        l_start_date                  date;
        l_next_date_wo_shifts         date; -- next date WithOut applied any shifts
        l_days_count                  com_api_type_pkg.t_count := 0;

        function add_cycle_length(
            i_start_date           in     date
          , i_inst_id              in     com_api_type_pkg.t_inst_id
          , i_length_type          in     com_api_type_pkg.t_dict_value
          , i_cycle_length         in     com_api_type_pkg.t_tiny_id
          , i_forward              in     com_api_type_pkg.t_boolean
          , i_cycle_calc_date_type in     com_api_type_pkg.t_dict_value
          , i_workdays_only        in     com_api_type_pkg.t_boolean
        ) return date is
            l_sign                        pls_integer;
        begin
            l_sign:= case when i_forward = com_api_type_pkg.TRUE then 1 else -1 end;

            return
                case i_length_type
                    when fcl_api_const_pkg.CYCLE_LENGTH_MONTH   then
                        add_months(i_start_date, l_sign * i_cycle_length)
                    when fcl_api_const_pkg.CYCLE_LENGTH_YEAR    then
                        add_months(i_start_date, l_sign * i_cycle_length * 12)
                    when fcl_api_const_pkg.CYCLE_LENGTH_DAY     then
                        case
                            when i_workdays_only = com_api_type_pkg.TRUE then
                                get_next_workday(
                                    i_start_date           => i_start_date
                                  , i_forward              => i_forward
                                  , i_inst_id              => i_inst_id
                                  , i_cycle_length         => i_cycle_length
                                  , i_cycle_calc_date_type => i_cycle_calc_date_type
                                )
                            else
                                i_start_date + l_sign * i_cycle_length
                        end
                    when fcl_api_const_pkg.CYCLE_LENGTH_WEEK    then
                        i_start_date + l_sign * (i_cycle_length * 7)
                    when fcl_api_const_pkg.CYCLE_LENGTH_HOUR    then
                        i_start_date + l_sign * (i_cycle_length * 1/24)
                    when fcl_api_const_pkg.CYCLE_LENGTH_MINUTE  then
                        i_start_date + l_sign * (i_cycle_length * 1/24/60)
                    when fcl_api_const_pkg.CYCLE_LENGTH_SECOND  then
                        i_start_date + l_sign * (i_cycle_length * 1/24/60/60)
                end;
        end add_cycle_length;

    begin
        l_sign:= case when i_forward = com_api_type_pkg.TRUE then 1 else -1 end;

        l_start_date := nvl(case i_trunc_type
                                when fcl_api_const_pkg.CYCLE_LENGTH_HOUR   then trunc(i_start_date, 'HH')
                                when fcl_api_const_pkg.CYCLE_LENGTH_DAY    then trunc(i_start_date)
                                when fcl_api_const_pkg.CYCLE_LENGTH_WEEK   then trunc(i_start_date, 'IW')
                                when fcl_api_const_pkg.CYCLE_LENGTH_MONTH  then trunc(i_start_date, 'MM')
                                when fcl_api_const_pkg.CYCLE_LENGTH_YEAR   then trunc(i_start_date, 'YYYY')
                                when fcl_api_const_pkg.CYCLE_LENGTH_MINUTE then trunc(i_start_date, 'MI')
                                when fcl_api_const_pkg.CYCLE_LENGTH_SECOND then null
                            end
                          , i_start_date);
        trc_log_pkg.debug(
            i_text       => 'fcl_api_cycle_pkg.calc_next_date->process_cycle, start: i_cycle_id [#1], ' ||
                            'i_forward [#6], i_trunc_type [#2], i_length_type [#3], i_cycle_length [#4], i_start_date [#5]'
          , i_env_param1 => i_cycle_id
          , i_env_param2 => i_trunc_type
          , i_env_param3 => i_length_type
          , i_env_param4 => i_cycle_length
          , i_env_param5 => i_start_date
          , i_env_param6 => i_forward
        );

        l_next_date_wo_shifts := l_start_date;

        loop
            l_next_date_wo_shifts := add_cycle_length(
                                         i_start_date           => l_next_date_wo_shifts
                                       , i_inst_id              => i_inst_id
                                       , i_length_type          => i_length_type
                                       , i_cycle_length         => i_cycle_length
                                       , i_forward              => i_forward
                                       , i_cycle_calc_date_type => i_cycle_calc_date_type
                                       , i_workdays_only        => i_workdays_only
                                     );
            o_next_date := l_next_date_wo_shifts;

            -- applying all defined shifts for the current cycle
            for r in (select * from fcl_cycle_shift where cycle_id = i_cycle_id order by priority) loop
                case r.shift_type
                    when fcl_api_const_pkg.CYCLE_SHIFT_WEEK_DAY then
                        loop
                            exit when trunc(o_next_date) - trunc(o_next_date, 'IW') + 1 = r.shift_length;
                            o_next_date := o_next_date + l_sign * r.shift_sign;
                        end loop;

                    when fcl_api_const_pkg.CYCLE_SHIFT_WORK_DAY then
                        l_days_count := 0;
                        loop
                            if com_api_holiday_pkg.is_holiday(o_next_date, l_inst_id) = com_api_type_pkg.FALSE then
                                l_days_count := l_days_count + 1;
                            end if;

                            exit when l_days_count >= r.shift_length;

                            o_next_date := trunc(o_next_date) + l_sign * r.shift_sign;
                        end loop;

                    when fcl_api_const_pkg.CYCLE_SHIFT_MONTH_DAY then
                        loop
                            exit when to_number(to_char(o_next_date, 'dd')) = r.shift_length;
                            o_next_date := o_next_date + l_sign * r.shift_sign;
                        end loop;

                    when fcl_api_const_pkg.CYCLE_SHIFT_PERIOD then
                        o_next_date :=
                            case r.length_type
                                when fcl_api_const_pkg.CYCLE_LENGTH_DAY then
                                    o_next_date + l_sign * (r.shift_sign * r.shift_length)

                                when fcl_api_const_pkg.CYCLE_LENGTH_WEEK then
                                    o_next_date + l_sign * (r.shift_sign * r.shift_length * 7)

                                when fcl_api_const_pkg.CYCLE_LENGTH_HOUR then
                                    o_next_date + l_sign * (r.shift_sign * r.shift_length * 1/24)

                                when fcl_api_const_pkg.CYCLE_LENGTH_MINUTE then
                                    o_next_date + l_sign * (r.shift_sign * r.shift_length * 1/24/60)

                                when fcl_api_const_pkg.CYCLE_LENGTH_SECOND then
                                    o_next_date + l_sign * (r.shift_sign * r.shift_length * 1/24/60/60)

                                when fcl_api_const_pkg.CYCLE_LENGTH_MONTH then
                                    add_months(o_next_date, l_sign * r.shift_sign * r.shift_length)

                                when fcl_api_const_pkg.CYCLE_LENGTH_YEAR then
                                    add_months(o_next_date, l_sign * r.shift_sign * r.shift_length * 12)
                            end;

                    when fcl_api_const_pkg.CYCLE_SHIFT_END_MONTH then
                        o_next_date := add_months(trunc(o_next_date, 'MM'), 1) - com_api_const_pkg.ONE_SECOND;

                    when fcl_api_const_pkg.CYCLE_SHIFT_CERTAIN_YEAR then
                        begin
                            o_next_date := to_date('01.01.' || lpad(to_char(r.shift_length), 4, '0'), 'DD.MM.YYYY');
                        exception
                            when com_api_error_pkg.e_invalid_year then
                                com_api_error_pkg.raise_error(
                                    i_error      => 'CYCLE_SHIFT_INCORRECT_LENGTH'
                                  , i_env_param1 => r.shift_type
                                  , i_env_param2 => r.shift_length
                                );
                        end;

                    else -- for an undefined cycle shift's type a custom processing (hook) should be called
                        trc_log_pkg.info(
                            i_text       => 'custom processing for cycle''s shift [#1] with type [#2] is applying; ' ||
                                            'r.shift_sign [#3], r.length_type [#4], r.shift_length [#5], i_forward [#6]'
                          , i_env_param1 => r.id
                          , i_env_param2 => r.shift_type
                          , i_env_param3 => r.shift_sign
                          , i_env_param4 => r.length_type
                          , i_env_param5 => r.shift_length
                          , i_env_param6 => i_forward
                        );

                        o_next_date := fcl_cst_cycle_ver2_pkg.shift_date(
                                           i_date         => o_next_date
                                         , i_shift_type   => r.shift_type
                                         , i_shift_sign   => r.shift_sign
                                         , i_length_type  => r.length_type
                                         , i_shift_length => r.shift_length
                                         , i_forward      => i_forward
                                         , i_start_date   => i_start_date
                                         , i_object_params => i_object_params
                                       );

                        if o_next_date is null then
                            com_api_error_pkg.raise_error(
                                i_error      => 'CUSTOM_PROCESSING_FOR_CYCLE_SHIFT_IS_NOT_DEFINED'
                              , i_env_param1 => i_cycle_id
                              , i_env_param2 => r.shift_type
                            );
                        end if;
                end case;
            end loop;

            trc_log_pkg.debug(
                i_text       => 'fcl_api_cycle_pkg.calc_next_date->process_cycle [#1], loop: ' ||
                                'l_start_date [#2], l_next_date_wo_shifts [#3], o_next_date [#4]'
              , i_env_param1 => i_cycle_id
              , i_env_param2 => to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss')
              , i_env_param3 => to_char(l_next_date_wo_shifts, 'dd.mm.yyyy hh24:mi:ss')
              , i_env_param4 => to_char(o_next_date, 'dd.mm.yyyy hh24:mi:ss')
            );

            exit when o_next_date > l_start_date and i_forward = com_api_const_pkg.TRUE
                   or o_next_date < l_start_date and i_forward = com_api_const_pkg.FALSE
                   or i_cycle_length = 0;

        end loop;

        if o_next_date = l_start_date then
            trc_log_pkg.warn(
                i_text          => 'start date and next date are equal; cycle_id [#1]'
              , i_env_param1    => i_cycle_id
            );
        end if;

    end process_cycle;

begin
    l_start_date := nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate);

    begin
        select c.length_type
             , c.cycle_length
             , c.trunc_type
             , c.inst_id
             , nvl(c.workdays_only, 0)
          into l_length_type
             , l_cycle_length
             , l_trunc_type
             , l_inst_id
             , l_workdays_only
          from fcl_cycle_vw c
         where c.id = i_cycle_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'CYCLE_NOT_FOUND'
              , i_env_param1    => i_cycle_id
            );
    end;

    if nvl(l_cycle_length, -1) < 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'CYCLE_LENGTH_NOT_DEFINED'
          , i_env_param1 => l_cycle_length
        );
    end if;

    process_cycle(
        i_cycle_id             => i_cycle_id
      , i_inst_id              => l_inst_id
      , i_start_date           => l_start_date
      , i_forward              => i_forward
      , i_length_type          => l_length_type
      , i_cycle_length         => l_cycle_length
      , i_cycle_calc_date_type => i_cycle_calc_date_type
      , i_trunc_type           => l_trunc_type
      , i_workdays_only        => l_workdays_only
      , o_next_date            => o_next_date
    );
end;

procedure switch_cycle(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_start_date        in      date                            default null
  , i_eff_date          in      date                            default null
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , o_new_finish_date      out  date
  , i_test_mode         in      com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , i_forward           in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_cycle_id          in      com_api_type_pkg.t_short_id     default null
) is
    l_cycle_id                  com_api_type_pkg.t_short_id;
    l_eff_date                  date;
    l_start_date                date;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_cycle_calc_start_date     com_api_type_pkg.t_dict_value;
    l_cycle_calc_date_type      com_api_type_pkg.t_dict_value;
begin

    if i_test_mode not in (
           fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
         , fcl_api_const_pkg.ATTR_MISS_IGNORE
       )
    then
        com_api_error_pkg.raise_error(
            i_error     =>  'WRONG_TEST_MODE'
        );
    end if;

    begin
        select cycle_calc_start_date
             , cycle_calc_date_type
          into l_cycle_calc_start_date
             , l_cycle_calc_date_type
          from fcl_cycle_type
         where cycle_type = i_cycle_type;
    exception
        when no_data_found then
            l_cycle_calc_start_date := null;
            l_cycle_calc_date_type  := null;
    end;

    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(i_entity_type, i_object_id);
    else
        l_inst_id := i_inst_id;
    end if;

    begin
        select next_date
          into o_new_finish_date
          from fcl_cycle_counter
         where cycle_type  = i_cycle_type
           and object_id   = i_object_id
           and entity_type = i_entity_type
           and split_hash  = l_split_hash;
    exception
        when others then
            add_cycle_counter(
                i_cycle_type  => i_cycle_type
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_split_hash  => l_split_hash
              , i_inst_id     => l_inst_id
            );
    end;

    if l_cycle_calc_date_type = fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE then
        -- if calculation date type is Bank settlement date
        l_start_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => l_inst_id);
    else
        -- if calculation date type is System date
        l_start_date := nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate);
        --l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    end if;

    if l_cycle_calc_start_date = fcl_api_const_pkg.START_DATE_PREV_END_DATE and o_new_finish_date is not null then
        -- if calculation start date is Previous period end date
        l_start_date := o_new_finish_date;

    elsif l_cycle_calc_start_date = fcl_api_const_pkg.START_DATE_CURRENT_DATE then
        null;
    else
        l_start_date := nvl(o_new_finish_date, l_start_date);
    end if;

    if o_new_finish_date is null or o_new_finish_date <= l_start_date then
        if i_cycle_id is null then
            begin
                l_cycle_id :=
                    prd_api_product_pkg.get_cycle_id(
                        i_product_id      => i_product_id
                      , i_entity_type     => i_entity_type
                      , i_object_id       => i_object_id
                      , i_cycle_type      => i_cycle_type
                      , i_params          => i_params
                      , i_service_id      => i_service_id
                      , i_split_hash      => l_split_hash
                      , i_eff_date        => l_eff_date
                      , i_inst_id         => l_inst_id
                    );
            exception
                when com_api_error_pkg.e_application_error or no_data_found then
                    -- Parameter <i_test_mode> should be only used for NDF exception or CYCLE_NOT_DEFINED error
                    if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
                        and
                        com_api_error_pkg.get_last_error() != 'CYCLE_NOT_DEFINED'
                    then
                        raise;
                    elsif i_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                        com_api_error_pkg.raise_error(
                            i_error     => 'ATTRIBUTE_NOT_FOUND'
                        );
                    elsif i_test_mode = fcl_api_const_pkg.ATTR_MISS_IGNORE then
                        o_new_finish_date := null;
                        return;
                    end if;
            end;
        else
            l_cycle_id := i_cycle_id;
        end if;

        calc_next_date(
            i_cycle_id             => l_cycle_id
          , i_start_date           => l_start_date
          , i_forward              => i_forward
          , o_next_date            => o_new_finish_date
          , i_cycle_calc_date_type => l_cycle_calc_date_type
        );

        update fcl_cycle_counter
           set prev_date     = nvl(next_date, l_start_date)
             , next_date     = o_new_finish_date
             , period_number = nvl(period_number, 0) + 1
         where cycle_type    = i_cycle_type
           and object_id     = i_object_id
           and entity_type   = i_entity_type
           and split_hash    = l_split_hash;
    end if;
end;

function calc_next_date(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_start_date        in      date                            default null
  , i_forward           in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_raise_error       in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return date is
    l_result            date;
begin
    if i_cycle_id is null then
        return null;
    end if;

    calc_next_date(
        i_cycle_id          => i_cycle_id
      , i_start_date        => i_start_date
      , i_forward           => i_forward
      , o_next_date         => l_result
    );

    return l_result;
exception
    when com_api_error_pkg.e_application_error then
        if i_raise_error  = com_api_type_pkg.TRUE then
            raise;
        else
            return null;
        end if;
end;

function calc_next_date(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_start_date        in      date                            default null
  , i_eff_date          in      date                            default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_forward           in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_raise_error       in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_product_id        in      com_api_type_pkg.t_short_id     default null
) return date is
    l_cycle_id                  com_api_type_pkg.t_short_id;
    l_params                    com_api_type_pkg.t_param_tab;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_product_id                com_api_type_pkg.t_short_id;
    l_cycle_calc_start_date     com_api_type_pkg.t_dict_value;
    l_cycle_calc_date_type      com_api_type_pkg.t_dict_value;
    l_next_date                 date;
    l_eff_date                  date;
    l_start_date                date;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(i_entity_type, i_object_id);
    else
        l_inst_id := i_inst_id;
    end if;

    if i_product_id is null then
        l_product_id := prd_api_product_pkg.get_product_id(
                            i_entity_type   => i_entity_type
                          , i_object_id     => i_object_id
                        );
    else
        l_product_id := i_product_id;
    end if;

    l_eff_date := coalesce(i_eff_date, i_start_date, com_api_sttl_day_pkg.get_sysdate);

    begin
        select cycle_calc_start_date
             , cycle_calc_date_type
          into l_cycle_calc_start_date
             , l_cycle_calc_date_type
          from fcl_cycle_type
         where cycle_type = i_cycle_type ;
    exception
        when no_data_found then
            l_cycle_calc_start_date := null;
            l_cycle_calc_date_type  := null;
    end;

    if l_cycle_calc_date_type = fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE then
        -- if calculation date type is Bank settlement date
        l_start_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => l_inst_id);
    else
        -- if calculation date type is System date
        --l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
        l_start_date := nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate);
    end if;

    if l_cycle_calc_start_date = fcl_api_const_pkg.START_DATE_PREV_END_DATE and i_start_date is not null then
        -- if calculation start date is Previous period end date
        l_start_date := i_start_date;

    elsif l_cycle_calc_start_date = fcl_api_const_pkg.START_DATE_CURRENT_DATE then
        null;
    else
        l_start_date := nvl(i_start_date, l_eff_date);
    end if;

    rul_api_shared_data_pkg.load_params(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , io_params      => l_params
      , i_full_set     => com_api_const_pkg.TRUE
    );

    begin
        l_cycle_id :=
            prd_api_product_pkg.get_cycle_id(
                i_product_id    => l_product_id
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_cycle_type    => i_cycle_type
              , i_split_hash    => l_split_hash
              , i_params        => l_params
              , i_eff_date      => l_eff_date
              , i_inst_id       => l_inst_id
              , i_mask_error    => com_api_type_pkg.boolean_not(i_raise_error)
            );

        if l_cycle_id is not null then
            calc_next_date(
                i_cycle_id             => l_cycle_id
              , i_start_date           => l_start_date
              , i_forward              => i_forward
              , o_next_date            => l_next_date
              , i_cycle_calc_date_type => l_cycle_calc_date_type
              , i_object_params        => l_params
            );
        end if;

    exception
        when com_api_error_pkg.e_application_error then
            if i_raise_error = com_api_const_pkg.TRUE then
                raise;
            end if;
    end;

    return l_next_date;
end calc_next_date;

procedure add_cycle_counter(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_next_date         in      date                            default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_count             com_api_type_pkg.t_count    := 0;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    select count(1)
      into l_count
      from fcl_cycle_counter
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and cycle_type  = i_cycle_type
       and split_hash  = l_split_hash;

    if l_count = 0 then
        insert into fcl_cycle_counter(
            id
          , entity_type
          , object_id
          , cycle_type
          , next_date
          , split_hash
          , inst_id
        ) values (
            fcl_cycle_counter_seq.nextval
          , i_entity_type
          , i_object_id
          , i_cycle_type
          , i_next_date
          , l_split_hash
          , i_inst_id
        );
    elsif i_next_date is not null then
        update fcl_cycle_counter
           set next_date     = i_next_date
         where i_entity_type = entity_type
           and i_object_id   = object_id
           and i_cycle_type  = cycle_type
           and l_split_hash  = split_hash;
    end if;
end;

procedure remove_cycle_counter(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
) is
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    delete fcl_cycle_counter
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and (cycle_type = i_cycle_type or i_cycle_type is null)
       and split_hash  = l_split_hash;
end;

/**********************************************************
 * Reset cycle counter - set next date into null
 *********************************************************/
procedure reset_cycle_counter(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
) is
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    update fcl_cycle_counter
       set next_date   = null
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and cycle_type  = i_cycle_type
       and split_hash  = l_split_hash;

end reset_cycle_counter;

end fcl_api_cycle_pkg;
/
