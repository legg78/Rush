create or replace package body fcl_prc_cycle_counter_pkg is

    procedure process (
        i_cycle_type        in      com_api_type_pkg.t_dict_value   default null
        , i_cycle_date_type in      com_api_type_pkg.t_dict_value
        , i_inst_id         in      com_api_type_pkg.t_short_id
    ) is
        BULK_LIMIT                  number := 500;

        l_id                        com_api_type_pkg.t_number_tab;
        l_entity_type               com_api_type_pkg.t_dict_tab;
        l_object_id                 com_api_type_pkg.t_number_tab;
        l_cycle_type                com_api_type_pkg.t_dict_tab;
        l_next_date                 com_api_type_pkg.t_date_tab;
        l_split_hash                com_api_type_pkg.t_number_tab;
        l_inst_id                   com_api_type_pkg.t_number_tab;
        l_is_repeating              com_api_type_pkg.t_boolean_tab;
        l_param_tab                 com_api_type_pkg.t_param_tab;
        l_eff_date                  date;
        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;

        cursor cu_cycles is
            select
                c.id
                , c.entity_type
                , c.object_id
                , c.cycle_type
                , c.next_date
                , c.split_hash
                , c.inst_id
                , t.is_repeating
            from fcl_cycle_counter c
               , fcl_cycle_type t
           where c.split_hash in (select split_hash from com_api_split_map_vw)
             and c.cycle_type = t.cycle_type
             and c.next_date <= l_eff_date
             and not exists (select null from fcl_limit_type l where l.cycle_type = t.cycle_type)
             and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or c.inst_id = i_inst_id)
             and (
                  (t.is_standard = 1 and i_cycle_type is null)
                  or
                  c.cycle_type = i_cycle_type
                 );

        cursor cu_cycles_count is
          select count(1)
            from fcl_cycle_counter c
               , fcl_cycle_type t
           where c.split_hash in (select split_hash from com_api_split_map_vw)
             and c.cycle_type = t.cycle_type
             and c.next_date <= l_eff_date
             and not exists (select null from fcl_limit_type l where l.cycle_type = t.cycle_type)
             and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or c.inst_id = i_inst_id)
             and (
                  (t.is_standard = 1 and i_cycle_type is null)
                  or
                  c.cycle_type = i_cycle_type
                 );

    begin
        savepoint process_cycle_counter;

        prc_api_stat_pkg.log_start;

        if i_cycle_date_type = fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE then
            l_eff_date := com_api_sttl_day_pkg.get_sysdate;
            trc_log_pkg.debug (
                i_text          => 'Date type is system date. effective date [#1]'
                , i_env_param1  => to_char(l_eff_date, com_api_const_pkg.DATE_FORMAT)
            );

        elsif i_cycle_date_type = fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE then
            l_eff_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id);
            trc_log_pkg.debug (
                i_text          => 'Date type is settelment date. effective date [#1]'
                , i_env_param1  => to_char(l_eff_date, com_api_const_pkg.DATE_FORMAT)
            );
        end if;

        trc_log_pkg.debug (
            i_text          => 'Process cycle counter. effective date [#1] cycle type [#2] inst_id [#3]'
            , i_env_param1  => to_char(l_eff_date, com_api_const_pkg.DATE_FORMAT)
            , i_env_param2  => i_cycle_type
            , i_env_param3  => i_inst_id
        );

        open cu_cycles_count;
        fetch cu_cycles_count into l_estimated_count;
        close cu_cycles_count;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        if l_estimated_count > 0 then

            open cu_cycles;

            loop
                fetch cu_cycles
                bulk collect into
                    l_id
                  , l_entity_type
                  , l_object_id
                  , l_cycle_type
                  , l_next_date
                  , l_split_hash
                  , l_inst_id
                  , l_is_repeating
                limit BULK_LIMIT;

                for i in 1 .. l_id.count loop
                    begin
                        savepoint process_cycle_counter;

                        evt_api_event_pkg.register_event (
                            i_event_type     => l_cycle_type(i)
                            , i_eff_date     => l_next_date(i)
                            , i_entity_type  => l_entity_type(i)
                            , i_object_id    => l_object_id(i)
                            , i_inst_id      => l_inst_id(i)
                            , i_split_hash   => l_split_hash(i)
                            , i_param_tab    => l_param_tab
                        );

                        if l_is_repeating(i) = com_api_type_pkg.FALSE then
                            -- update next date
                            l_next_date(i) := null;

                        else
                            l_next_date(i) :=
                                fcl_api_cycle_pkg.calc_next_date (
                                    i_cycle_type         => l_cycle_type(i)
                                    , i_entity_type      => l_entity_type(i)
                                    , i_object_id        => l_object_id(i)
                                    , i_inst_id          => l_inst_id(i)
                                    , i_split_hash       => l_split_hash(i)
                                    , i_start_date       => l_next_date(i)
                                    , i_eff_date         => l_eff_date
                                );

                        end if;
                    exception
                        when com_api_error_pkg.e_stop_cycle_repetition then
                            l_next_date(i) := null;
                            rollback to savepoint process_cycle_counter;

                        when com_api_error_pkg.e_application_error then
                            l_excepted_count := l_excepted_count + 1;
                            rollback to savepoint process_cycle_counter;

                            fcl_cst_cycle_pkg.on_application_error(
                                i_event_type    => l_cycle_type(i)
                              , i_entity_type   => l_entity_type(i)
                              , i_object_id     => l_object_id(i)
                              , i_inst_id       => l_inst_id(i)
                              , i_split_hash    => l_split_hash(i)
                              , io_next_date    => l_next_date(i)
                            );

                        when com_api_error_pkg.e_fatal_error then
                            raise;

                        when others then
                            rollback to savepoint process_cycle_counter;

                            com_api_error_pkg.raise_fatal_error(
                                i_error         => 'UNHANDLED_EXCEPTION'
                              , i_env_param1    => sqlerrm
                            );
                    end;
                end loop;

                forall i in 1..l_cycle_type.count
                    update fcl_cycle_counter
                       set prev_date     = next_date
                         , next_date     = l_next_date(i)
                         , period_number = nvl(period_number, 0) + 1
                     where cycle_type    = l_cycle_type(i)
                       and object_id     = l_object_id(i)
                       and entity_type   = l_entity_type(i)
                       and split_hash    = l_split_hash(i);

                l_processed_count := l_processed_count + l_id.count;

                prc_api_stat_pkg.log_current (
                    i_current_count    => l_processed_count
                    , i_excepted_count => l_excepted_count
                );

                exit when cu_cycles%notfound;
            end loop;
            close cu_cycles;
            evt_api_event_pkg.flush_events;

        end if;

        trc_log_pkg.debug (
            i_text      => 'Process cycle counter finished ...'
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint process_cycle_counter;

            if cu_cycles_count%isopen then
                close cu_cycles_count;
            end if;

            if cu_cycles%isopen then
                close cu_cycles;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => sqlerrm
                );
            end if;

            raise;
    end;
end;
/
