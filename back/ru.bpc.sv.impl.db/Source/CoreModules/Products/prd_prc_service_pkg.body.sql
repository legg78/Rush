create or replace package body prd_prc_service_pkg is

    BULK_LIMIT                  constant number := 400;

    function enum_service (
        i_status                    in com_api_type_pkg.t_dict_value
        , i_thread_number           in com_api_type_pkg.t_tiny_id
        , i_is_ordered              in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt               com_api_type_pkg.t_text :=
'select
    o.id
    , o.entity_type
    , o.object_id
    , s.inst_id
    , t.enable_event_type
    , t.disable_event_type
from
    prd_service_object_vw o
    , prd_service_vw s
    , prd_service_type_vw t
    , ( select
            :status status
            , :thread_number thread_number
            , :sys_dt sys_dt
        from
            dual
    ) x
where
    s.id = o.service_id
    and t.id = s.service_type_id
    and o.status = x.status
    ';
    begin
        if i_thread_number > 0 then
            l_cursor_stmt := l_cursor_stmt || ' and o.split_hash in (select m.split_hash from com_split_map m where m.thread_number = x.thread_number)';
        end if;

        if i_status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE then
            l_cursor_stmt := l_cursor_stmt || ' and o.start_date <= x.sys_dt';
            if i_is_ordered = com_api_type_pkg.TRUE then
                l_cursor_stmt := l_cursor_stmt || ' order by'
                           || ' decode(o.entity_type, ''ENTTCARD'', 1, ''ENTTTRMN'', 1, ''ENTTMRCH'', 1, ''ENTTACCT'', 2, ''ENTTCNTR'', 3, 4)'
                           || ', o.entity_type, t.is_initial desc';
            end if;
        else
            l_cursor_stmt := l_cursor_stmt || ' and nvl(o.end_date, x.sys_dt) < x.sys_dt';
            if i_is_ordered = com_api_type_pkg.TRUE then
                l_cursor_stmt := l_cursor_stmt || ' order by'
                           || ' decode(o.entity_type, ''ENTTCARD'', 1, ''ENTTTRMN'', 1, ''ENTTMRCH'', 1, ''ENTTACCT'', 2, ''ENTTCNTR'', 3, 4)'
                           || ', o.entity_type, t.is_initial';
            end if;
        end if;
        
        return l_cursor_stmt;
    end;

    function estimate_service (
        i_sysdate                   in date
        , i_thread_number           in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_long_id is
        l_disable_stmt              com_api_type_pkg.t_text;
        l_enable_stmt               com_api_type_pkg.t_text;
        l_estimated_count           com_api_type_pkg.t_long_id;
    begin
        l_enable_stmt := enum_service (
            i_status           => prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE
            , i_thread_number  => i_thread_number
            , i_is_ordered     => com_api_type_pkg.FALSE
        );
        l_disable_stmt := enum_service (
            i_status           => prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
            , i_thread_number  => i_thread_number
            , i_is_ordered     => com_api_type_pkg.FALSE
        );
        
        execute immediate 'select count(1) from (' || l_enable_stmt || ' union all ' || l_disable_stmt || ')'
        into l_estimated_count
        using prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE, i_thread_number, i_sysdate
              , prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE, i_thread_number, i_sysdate;
              
        return l_estimated_count;
    end;
    
    procedure process_services (
        i_status                    in com_api_type_pkg.t_dict_value
        , i_sysdate                 in date
        , i_thread_number           in com_api_type_pkg.t_tiny_id
        , io_excepted_count         in out com_api_type_pkg.t_long_id
        , io_processed_count        in out com_api_type_pkg.t_long_id
    ) is
        l_id                        com_api_type_pkg.t_number_tab;
        l_entity_type               com_api_type_pkg.t_dict_tab;
        l_object_id                 com_api_type_pkg.t_number_tab;
        l_inst_id                   com_api_type_pkg.t_number_tab;
        l_enable_event_type         com_api_type_pkg.t_dict_tab;
        l_disable_event_type        com_api_type_pkg.t_dict_tab;
        l_params                    com_api_type_pkg.t_param_tab;

        l_services_cur              sys_refcursor;
        l_cursor_stmt               com_api_type_pkg.t_text;
    begin
        trc_log_pkg.debug (
            i_text          => 'Request to set status [#1] for service object'
            , i_env_param1  => i_status
        );

        l_cursor_stmt := enum_service (
            i_status           => i_status
            , i_thread_number  => i_thread_number
        );
        open l_services_cur for l_cursor_stmt
        using i_status, i_thread_number, i_sysdate;
        loop
            fetch l_services_cur
            bulk collect into
            l_id
            , l_entity_type
            , l_object_id
            , l_inst_id
            , l_enable_event_type
            , l_disable_event_type
            limit BULK_LIMIT;

            for i in 1 .. l_id.count loop
                begin
                    savepoint proc_new_service;
                    
                    prd_api_service_pkg.change_service_status (
                        i_id                    => l_id(i)
                        , i_sysdate             => i_sysdate
                        , i_entity_type         => l_entity_type(i)
                        , i_object_id           => l_object_id(i)
                        , i_inst_id             => l_inst_id(i)
                        , i_enable_event_type   => l_enable_event_type(i)
                        , i_disable_event_type  => l_disable_event_type(i)
                        , i_forced              => com_api_type_pkg.FALSE
                        , i_params              => l_params
                    );
                exception
                    when others then
                        rollback to savepoint proc_new_service;
                                
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            io_excepted_count := io_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;
                    
                io_processed_count := io_processed_count + 1;
            end loop;

            prc_api_stat_pkg.log_current (
                i_current_count     => io_processed_count
                , i_excepted_count  => io_excepted_count
            );

            exit when l_services_cur%notfound;
        end loop;
        close l_services_cur;

        trc_log_pkg.debug (
            i_text          => 'Total records updated [#1]'
            , i_env_param1  => io_processed_count
        );
    exception
        when others then
          dbms_output.put_line(sqlerrm);
          if l_services_cur%isopen then
              close l_services_cur;
          end if;
          raise;
    end;
    
    procedure switch_service_status
    is
        l_sysdate                   date;
        l_thread_number             com_api_type_pkg.t_tiny_id;
        l_estimated_count           com_api_type_pkg.t_long_id;
        l_excepted_count            com_api_type_pkg.t_long_id;
        l_processed_count           com_api_type_pkg.t_long_id;
    begin
        savepoint service_process_start;
        
        prc_api_stat_pkg.log_start;

        l_sysdate := com_api_sttl_day_pkg.get_sysdate;
        l_thread_number := 0;--get_thread_number;
        
        l_excepted_count := 0;
        l_processed_count := 0;

        -- get estimated count
        l_estimated_count := estimate_service (
            i_sysdate          => l_sysdate
            , i_thread_number  => l_thread_number
        );

        trc_log_pkg.debug (
            i_text          => 'Estimated count: [#1]'
            , i_env_param1  => l_estimated_count
        );

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            -- activation service
            process_services (
                i_status              => prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE
                , i_sysdate           => l_sysdate
                , i_thread_number     => l_thread_number
                , io_excepted_count   => l_excepted_count
                , io_processed_count  => l_processed_count
            );
            -- closing service
            process_services (
                i_status              => prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
                , i_sysdate           => l_sysdate
                , i_thread_number     => l_thread_number
                , io_excepted_count   => l_excepted_count
                , io_processed_count  => l_processed_count
            );
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    exception
        when others then
            rollback to savepoint service_process_start;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;

end;
/
