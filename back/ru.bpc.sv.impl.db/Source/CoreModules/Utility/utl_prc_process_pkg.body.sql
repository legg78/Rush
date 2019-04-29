create or replace package body utl_prc_process_pkg is

    procedure process_card (
        i_inst_id                   in com_api_type_pkg.t_inst_id
    ) is
        BULK_LIMIT                  number := 400;
        
        l_sysdate                   date;
        l_thread_number             com_api_type_pkg.t_tiny_id;
        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;

        l_ok_event_id               com_api_type_pkg.t_number_tab;
        l_event_id                  com_api_type_pkg.t_number_tab;
        l_event_type                com_api_type_pkg.t_dict_tab;
        l_entity_type               com_api_type_pkg.t_dict_tab;
        l_object_id                 com_api_type_pkg.t_number_tab;
        l_eff_date                  com_api_type_pkg.t_date_tab;
        
        cursor l_events_count is
            select
                count(*)
            from
                evt_event_object_vw o
                , evt_event_vw e
                , evt_subscriber_vw s
            where
                o.procedure_name = 'UTL_PRC_PROCESS_PKG.PROCESS_CARD'
                and o.eff_date <= l_sysdate
                and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                )
                and e.id = o.event_id
                and e.event_type = s.event_type
                and o.procedure_name = s.procedure_name;

        cursor l_events is
            select
                o.id
                , e.event_type
                , o.entity_type
                , o.object_id
                , o.eff_date
            from
                evt_event_object_vw o
                , evt_event_vw e
                , evt_subscriber_vw s
            where
                o.procedure_name = 'UTL_PRC_PROCESS_PKG.PROCESS_CARD'
                and o.eff_date <= l_sysdate
                and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                )
                and e.id = o.event_id
                and e.event_type = s.event_type
                and o.procedure_name = s.procedure_name
            order by
                o.eff_date, s.priority;
    begin
        l_thread_number := get_thread_number;
        l_sysdate := com_api_sttl_day_pkg.get_sysdate;
        
        prc_api_stat_pkg.log_start;
        
        trc_log_pkg.debug (
            i_text          => 'Process. inst_id [#1] sysdate [#2]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss') 
        );

        open l_events_count;
        fetch l_events_count into l_estimated_count;
        close l_events_count;
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            open l_events;
            loop
                fetch l_events
                bulk collect into
                l_event_id
                , l_event_type
                , l_entity_type
                , l_object_id
                , l_eff_date
                limit BULK_LIMIT;
                
                for i in 1..l_event_id.count loop
                    begin
                        trc_log_pkg.debug (
                            i_text          => 'Process event_type [#1] for object_id [#2]'
                            , i_env_param1  => l_event_type(i)
                            , i_env_param2  => l_object_id(i)
                        );

                        -- register ok upload
                        l_ok_event_id(l_ok_event_id.count + 1) := l_event_id(i);

                    exception
                        when com_api_error_pkg.e_application_error then
                            l_excepted_count := l_excepted_count + 1;
                        when com_api_error_pkg.e_fatal_error then
                            raise;        
                        when others then
                            com_api_error_pkg.raise_fatal_error (
                                i_error       => 'UNHANDLED_EXCEPTION'
                              , i_env_param1  => sqlerrm
                            );
                    end;
                end loop;
                
                -- delete ok
                forall i in 1..l_ok_event_id.count
                    delete from
                        evt_event_object
                    where
                        id = l_ok_event_id(i);

                -- clear ok
                l_ok_event_id.delete;
                
                l_processed_count := l_processed_count + l_event_id.count;

                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => l_excepted_count
                );
                
                exit when l_events%notfound;  
            end loop;
            close l_events;
        end if;
        
        trc_log_pkg.debug (
            i_text  => 'Process finished ...'
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_events%isopen then
                close l_events;
            end if;
            
            if l_events_count%isopen then
                close l_events_count;
            end if;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;    
            raise;
    end;
    
    procedure process_account (
        i_inst_id                   in com_api_type_pkg.t_inst_id
    ) is
        BULK_LIMIT                  number := 400;
        
        l_sysdate                   date;
        l_thread_number             com_api_type_pkg.t_tiny_id;
        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;

        l_ok_event_id               com_api_type_pkg.t_number_tab;
        l_event_id                  com_api_type_pkg.t_number_tab;
        l_event_type                com_api_type_pkg.t_dict_tab;
        l_entity_type               com_api_type_pkg.t_dict_tab;
        l_object_id                 com_api_type_pkg.t_number_tab;
        l_eff_date                  com_api_type_pkg.t_date_tab;
        
        cursor l_events_count is
            select
                count(*)
            from
                evt_event_object_vw o
                , evt_event_vw e
                , evt_subscriber_vw s
            where
                o.procedure_name = 'UTL_PRC_PROCESS_PKG.PROCESS_ACCOUNT'
                and o.eff_date <= l_sysdate
                and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                )
                and e.id = o.event_id
                and e.event_type = s.event_type
                and o.procedure_name = s.procedure_name;

        cursor l_events is
            select
                o.id
                , e.event_type
                , o.entity_type
                , o.object_id
                , o.eff_date
            from
                evt_event_object_vw o
                , evt_event_vw e
                , evt_subscriber_vw s
            where
                o.procedure_name = 'UTL_PRC_PROCESS_PKG.PROCESS_ACCOUNT'
                and o.eff_date <= l_sysdate
                and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                )
                and e.id = o.event_id
                and e.event_type = s.event_type
                and o.procedure_name = s.procedure_name
            order by
                o.eff_date, s.priority;
    begin
        l_thread_number := get_thread_number;
        l_sysdate := com_api_sttl_day_pkg.get_sysdate;
        
        prc_api_stat_pkg.log_start;
        
        trc_log_pkg.debug (
            i_text          => 'Process. inst_id [#1] sysdate [#2]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss') 
        );

        open l_events_count;
        fetch l_events_count into l_estimated_count;
        close l_events_count;
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            open l_events;
            loop
                fetch l_events
                bulk collect into
                l_event_id
                , l_event_type
                , l_entity_type
                , l_object_id
                , l_eff_date
                limit BULK_LIMIT;
                
                for i in 1..l_event_id.count loop
                    begin
                        trc_log_pkg.debug (
                            i_text          => 'Process event_type [#1] for object_id [#2]'
                            , i_env_param1  => l_event_type(i)
                            , i_env_param2  => l_object_id(i)
                        );

                        -- register ok upload
                        l_ok_event_id(l_ok_event_id.count + 1) := l_event_id(i);

                    exception
                        when com_api_error_pkg.e_application_error then
                            l_excepted_count := l_excepted_count + 1;
                        when com_api_error_pkg.e_fatal_error then
                            raise;        
                        when others then
                            com_api_error_pkg.raise_fatal_error (
                                i_error       => 'UNHANDLED_EXCEPTION'
                              , i_env_param1  => sqlerrm
                            );
                    end;
                end loop;
                
                -- delete ok
                forall i in 1..l_ok_event_id.count
                    delete from
                        evt_event_object
                    where
                        id = l_ok_event_id(i);

                -- clear ok
                l_ok_event_id.delete;
                
                l_processed_count := l_processed_count + l_event_id.count;

                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => l_excepted_count
                );
                
                exit when l_events%notfound;  
            end loop;
            close l_events;
        end if;
        
        trc_log_pkg.debug (
            i_text  => 'Process finished ...'
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_events%isopen then
                close l_events;
            end if;
            
            if l_events_count%isopen then
                close l_events_count;
            end if;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;    
            raise;
    end;
    
    procedure process_application (
        i_inst_id                   in com_api_type_pkg.t_inst_id
    ) is
        BULK_LIMIT                  number := 400;
        
        l_sysdate                   date;
        l_thread_number             com_api_type_pkg.t_tiny_id;
        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;

        l_ok_event_id               com_api_type_pkg.t_number_tab;
        l_event_id                  com_api_type_pkg.t_number_tab;
        l_event_type                com_api_type_pkg.t_dict_tab;
        l_entity_type               com_api_type_pkg.t_dict_tab;
        l_object_id                 com_api_type_pkg.t_number_tab;
        l_eff_date                  com_api_type_pkg.t_date_tab;
        
        cursor l_events_count is
            select
                count(*)
            from
                evt_event_object_vw o
                , evt_event_vw e
                , evt_subscriber_vw s
            where
                o.procedure_name = 'UTL_PRC_PROCESS_PKG.PROCESS_APPLICATION'
                and o.eff_date <= l_sysdate
                and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                )
                and e.id = o.event_id
                and e.event_type = s.event_type
                and o.procedure_name = s.procedure_name;

        cursor l_events is
            select
                o.id
                , e.event_type
                , o.entity_type
                , o.object_id
                , o.eff_date
            from
                evt_event_object_vw o
                , evt_event_vw e
                , evt_subscriber_vw s
            where
                o.procedure_name = 'UTL_PRC_PROCESS_PKG.PROCESS_APPLICATION'
                and o.eff_date <= l_sysdate
                and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                )
                and e.id = o.event_id
                and e.event_type = s.event_type
                and o.procedure_name = s.procedure_name
            order by
                o.eff_date, s.priority;
    begin
        l_thread_number := get_thread_number;
        l_sysdate := com_api_sttl_day_pkg.get_sysdate;
        
        prc_api_stat_pkg.log_start;
        
        trc_log_pkg.debug (
            i_text          => 'Process. inst_id [#1] sysdate [#2]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss') 
        );

        open l_events_count;
        fetch l_events_count into l_estimated_count;
        close l_events_count;
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            open l_events;
            loop
                fetch l_events
                bulk collect into
                l_event_id
                , l_event_type
                , l_entity_type
                , l_object_id
                , l_eff_date
                limit BULK_LIMIT;
                
                for i in 1..l_event_id.count loop
                    begin
                        trc_log_pkg.debug (
                            i_text          => 'Process event_type [#1] for object_id [#2]'
                            , i_env_param1  => l_event_type(i)
                            , i_env_param2  => l_object_id(i)
                        );

                        -- register ok upload
                        l_ok_event_id(l_ok_event_id.count + 1) := l_event_id(i);

                    exception
                        when com_api_error_pkg.e_application_error then
                            l_excepted_count := l_excepted_count + 1;
                        when com_api_error_pkg.e_fatal_error then
                            raise;        
                        when others then
                            com_api_error_pkg.raise_fatal_error (
                                i_error       => 'UNHANDLED_EXCEPTION'
                              , i_env_param1  => sqlerrm
                            );
                    end;
                end loop;
                
                -- delete ok
                forall i in 1..l_ok_event_id.count
                    delete from
                        evt_event_object
                    where
                        id = l_ok_event_id(i);

                -- clear ok
                l_ok_event_id.delete;
                
                l_processed_count := l_processed_count + l_event_id.count;

                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => l_excepted_count
                );
                
                exit when l_events%notfound;  
            end loop;
            close l_events;
        end if;
        
        trc_log_pkg.debug (
            i_text  => 'Process finished ...'
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_events%isopen then
                close l_events;
            end if;
            
            if l_events_count%isopen then
                close l_events_count;
            end if;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;    
            raise;
    end;
    
end;
/
