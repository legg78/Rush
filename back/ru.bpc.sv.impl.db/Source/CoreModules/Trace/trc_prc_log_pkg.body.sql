create or replace package body trc_prc_log_pkg as

procedure process(
    i_entity_type         in      com_api_type_pkg.t_dict_value
    , i_object_id         in      com_api_type_pkg.t_long_id
    , i_start_date        in      timestamp
    , i_end_date          in      timestamp
)is
    l_type                        com_api_type_pkg.t_dict_value;
    l_obj_id                      com_api_type_pkg.t_long_id;

    l_record                      com_api_type_pkg.t_raw_tab;
    l_record_number               com_api_type_pkg.t_integer_tab;
    l_record_count                pls_integer := 0;
    l_session_file_id             com_api_type_pkg.t_long_id;

    l_trace_timestamp             com_api_type_pkg.t_timestamp_tab;
    l_trace_text                  com_api_type_pkg.t_varchar2_tab;
    l_user_id                     com_api_type_pkg.t_oracle_name_tab;
    l_session_id                  com_api_type_pkg.t_long_tab;
    l_entity_type                 com_api_type_pkg.t_dict_tab;
    l_object_id                   com_api_type_pkg.t_long_tab;
    l_who_called                  com_api_type_pkg.t_name_tab;
    l_trace_level                 com_api_type_pkg.t_dict_tab;
    l_thread_number               com_api_type_pkg.t_tiny_tab;
    l_inst_id                     com_api_type_pkg.t_tiny_tab;
    l_header                      com_api_type_pkg.t_raw_data;

    cursor cur is
        select t.trace_timestamp
             , t.trace_level
             , t.who_called
             , case when t.trace_level = 'DEBUG' then t.trace_text
                    else
                        case
                          when length (t.trace_text) > 200 then t.trace_text
                          else trc_log_pkg.get_text (t.label_id, t.trace_text)
                        end
               end
                 trace_text
             , t.user_id
             , t.session_id
             , t.thread_number
             , t.entity_type
             , t.object_id
             , t.inst_id
          from trc_log t
         where (l_type = '0' or t.entity_type = l_type)
           and (l_obj_id = 0 or t.object_id = l_obj_id)
           and (i_start_date is null or t.trace_timestamp >= i_start_date)
           and (i_end_date is null or t.trace_timestamp <= i_end_date);

    cursor cur_count is
        select count(1)
          from trc_log t
         where (l_type = '0' or t.entity_type = l_type)
           and (l_obj_id = 0 or t.object_id = l_obj_id)
           and (i_start_date is null or t.trace_timestamp >= i_start_date)
           and (i_end_date is null or t.trace_timestamp <= i_end_date);

begin

    prc_api_stat_pkg.log_start;

    l_type := nvl(i_entity_type, '0');
    l_obj_id := nvl(i_object_id, 0);

    if (i_entity_type is not null and i_object_id is not null)
        or
        (i_start_date is not null and i_end_date is not null)
        then

        open cur_count;
        fetch cur_count into l_record_count;
        close cur_count;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count     => l_record_count
        );

        if l_record_count > 0 then

            l_record_count := 0;

            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_session_file_id
            );

            l_record_count := l_record_count + 1;

            prc_api_file_pkg.put_line(
                i_sess_file_id  => l_session_file_id
              , i_raw_data      => 'PARAMETERS: '                                                                        || ' ' ||
                                   'I_ENTITY_TYPE: ' || lpad(l_type, 8, ' ')                                             || ' ' ||
                                   'I_OBJECT_ID: '   || lpad(l_obj_id, 16, 0)                                            || ' ' ||
                                   'I_START_DATE: '  || lpad(nvl(to_char(i_start_date, 'YYYYMMDDHH24MISS'), ' '), 14)    || ' ' ||
                                   'I_END_DATE: '    || lpad(nvl(to_char(i_end_date, 'YYYYMMDDHH24MISS'), ' '), 14)
            );

            l_record_count := l_record_count + 1;

            l_header := rpad('TIME', 14, ' ')            || ' ' ||
                        rpad('LEVEL', 8, ' ')            || ' ' ||
                        rpad('WHO_CALLED', 35, ' ')      || ' ' ||
                        rpad('TRACE_TEXT', 200, ' ')     || ' ' ||
                        rpad('USER_ID', 30, ' ')         || ' ' ||
                        rpad('SESSION_ID', 16, ' ')      || ' ' ||
                        rpad('THR', 4, ' ')              || ' ' ||
                        rpad('ENTTP', 8, ' ')            || ' ' ||
                        rpad('OBJECT_ID', 16, ' ')       || ' ' ||
                        rpad('INST', 4, ' ');

            prc_api_file_pkg.put_line(
                i_sess_file_id  => l_session_file_id
              , i_raw_data      => l_header
            );

            open cur;

            loop
                fetch cur bulk collect into
                    l_trace_timestamp
                    , l_trace_level
                    , l_who_called
                    , l_trace_text
                    , l_user_id
                    , l_session_id
                    , l_thread_number
                    , l_entity_type
                    , l_object_id
                    , l_inst_id
                limit 1000;

                l_record.delete;
                l_record_number.delete;

                for i in 1..l_trace_timestamp.count loop
                    l_record(i) :=
                        lpad(nvl(to_char(l_trace_timestamp(i), 'YYYYMMDDHH24MISS'), ' '), 14)   || ' ' ||
                        rpad(nvl(l_trace_level(i), ' '), 8, ' ')                                || ' ' ||
                        rpad(nvl(l_who_called(i), ' '), 35, ' ')                                || ' ' ||
                        rpad(nvl(l_trace_text(i), ' '), 200, ' ')                               || ' ' ||
                        rpad(nvl(l_user_id(i), ' '), 30, ' ')                                   || ' ' ||
                        rpad(nvl(l_session_id(i), 0), 16, '0')                                  || ' ' ||
                        rpad(nvl(l_thread_number(i), 0), 4, '0')                                || ' ' ||
                        rpad(nvl(l_entity_type(i), ' '), 8, ' ')                                || ' ' ||
                        rpad(nvl(l_object_id(i), 0), 16, '0')                                   || ' ' ||
                        rpad(nvl(l_inst_id(i), 0), 4, '0');

                    l_record_count     := l_record_count + 1;
                    l_record_number(i) := l_record_count;

                end loop;

                prc_api_file_pkg.put_bulk(
                    i_sess_file_id  => l_session_file_id
                  , i_raw_tab       => l_record
                  , i_num_tab       => l_record_number
                );

                prc_api_stat_pkg.increase_current (
                    i_current_count       => l_trace_timestamp.count
                  , i_excepted_count      => 0
                );

                exit when cur%notfound;
            end loop;

            close cur;

            prc_api_file_pkg.close_file(
                i_sess_file_id      => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'NO_ONE_GROUP_PARAM_EXISTS'
          , i_env_param1 => 'i_entity_type, i_object_id'
          , i_env_param2 => 'i_start_date, i_end_date'
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cur%isopen then
            close cur;
        end if;

        if cur_count%isopen then
            close cur_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure unload_audit_log(
    i_start_date          in      timestamp
    , i_end_date          in      timestamp
    , i_session_id        in      com_api_type_pkg.t_long_id   
    , i_user_id           in      com_api_type_pkg.t_short_id
)is
    l_ref_cur           com_api_type_pkg.t_ref_cur;

    l_count             com_api_type_pkg.t_short_id;
    l_record            com_api_type_pkg.t_raw_tab;
    l_record_number     com_api_type_pkg.t_integer_tab;
    l_proc_count        pls_integer := 0;
    l_session_file_id   com_api_type_pkg.t_long_id;

    l_id                com_api_type_pkg.t_long_tab;
    l_entity_type       com_api_type_pkg.t_dict_tab;
    l_object_id         com_api_type_pkg.t_long_tab;
    l_action_type       com_api_type_pkg.t_dict_tab;
    l_action_time       com_api_type_pkg.t_timestamp_tab;
    l_user_id           com_api_type_pkg.t_name_tab;
    l_session_id        com_api_type_pkg.t_long_tab;
    l_privileges        com_api_type_pkg.t_name_tab;
    l_header            com_api_type_pkg.t_raw_data;
    l_params            com_api_type_pkg.t_raw_data;
    l_result            com_api_type_pkg.t_name_tab;

    BULK_LIMIT          constant com_api_type_pkg.t_tiny_id := 1000;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select t.id'                                                                                              ||
             ', t.entity_type'                                                                                     ||
             ', t.object_id'                                                                                       ||    
             ', t.action_type'                                                                                     ||
             ', t.action_time'                                                                                     ||
             ', t.user_id || '' - '' || acm_api_user_pkg.get_user_name(t.user_id, com_api_type_pkg.FALSE) user_id'              ||
             ', t.session_id'                                                                                      ||
             ', get_text (''acm_privilege'', ''label'', t.priv_id , com_ui_user_env_pkg.get_user_lang) priv_name ' ||
             ', get_article_text(t.status, com_ui_user_env_pkg.get_user_lang) result '
             ;
            
    l_ref_source                com_api_type_pkg.t_text :=
        'from adt_trail t' ||
        ', (select :p_start_date p_start_date' ||
                ', :p_end_date p_end_date'     ||                   
                ', :p_session_id p_session_id' ||                   
                ', :p_user_id p_user_id '      || 
                ' from dual) x '               ||
        ' where 1 = 1';

    l_count_source                com_api_type_pkg.t_text := 'select count(1) ';

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.info(
         i_text =>'unload_trc_log, start_date=[#1], end_date=[#2], session_id=[#3], user_id=[#4]'
       , i_env_param1 => i_start_date
       , i_env_param2 => i_end_date
       , i_env_param3 => i_session_id
       , i_env_param4 => i_user_id
     );

    if i_start_date is null and i_end_date is null and i_session_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'NO_ONE_PARAM_EXISTS'
          , i_env_param1 => 'i_start_date, i_end_date, i_session_id'
        );    
    end if;
    
    if i_start_date is not null then
        l_ref_source := l_ref_source || ' and t.action_time >= x.p_start_date'; 
    end if;

    if i_end_date is not null then
        l_ref_source := l_ref_source || ' and t.action_time <= x.p_end_date'; 
    end if;
    
    if i_session_id is not null then
        l_ref_source := l_ref_source || ' and t.session_id = x.p_session_id'; 
    end if;

    if i_user_id is not null then
        l_ref_source := l_ref_source || ' and t.user_id = p_user_id'; 
    end if;
    
    l_count_source := l_count_source || l_ref_source;

    trc_log_pkg.debug('l_count_source : ' || l_count_source);

    execute immediate l_count_source
        into l_count
        using i_start_date
            , i_end_date
            , i_session_id
            , i_user_id;  
    trc_log_pkg.debug('l_count : ' || l_count);

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_count
    );
    
    if l_count > 0 then  
    
        l_ref_source := COLUMN_LIST || l_ref_source || ' order by t.id';
        trc_log_pkg.debug('l_ref_source : ' || l_ref_source);

        open l_ref_cur for l_ref_source 
        using i_start_date
            , i_end_date
            , i_session_id
            , i_user_id;            

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );
        trc_log_pkg.debug('Open file. session_file_id : ' || l_session_file_id);

        l_params := 'PARAMETERS: ' ||
                        case when i_start_date is not null then 'START_DATE:' || to_char(i_start_date, 'YYYYMMDDHH24MISS') else '' end  || ', ' || 
                        case when i_end_date is not null then 'END_DATE:'     || to_char(i_end_date, 'YYYYMMDDHH24MISS') else '' end    || ', ' || 
                        case when i_session_id is not null then 'SESSION_ID:' || i_session_id else '' end                               || ', ' || 
                        case when i_user_id is not null then 'USER_ID:'       || i_user_id else '' end; 

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => l_params
        );

        l_header := rpad('ID', 16, ' ')              || '|' ||
                    rpad('ENTITY_TYPE', 11, ' ')     || '|' ||
                    rpad('OBJECT_ID', 16, ' ')       || '|' ||
                    rpad('ACTION_TYPE', 11, ' ')     || '|' ||
                    rpad('TIMESTAMP ', 20, ' ')      || '|' ||
                    rpad('USER_ID', 30, ' ')         || '|' ||
                    rpad('SESSION_ID', 16, ' ')      || '|' ||
                    rpad('RESULT', 20, ' ')          || '|' ||
                    rpad('PRIVILEGES', 200, ' ');

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => l_header
        );
        
        l_proc_count       := l_proc_count + 2;
            
        loop
            fetch l_ref_cur bulk collect into
                l_id
                , l_entity_type 
                , l_object_id   
                , l_action_type
                , l_action_time
                , l_user_id    
                , l_session_id 
                , l_privileges 
                , l_result
            limit BULK_LIMIT;

            l_record.delete;

            for i in 1..l_action_time.count loop
                l_record(i) :=
                    rpad(nvl(l_id(i), 0), 16, ' ')                                                       || '|' ||
                    rpad(nvl(l_entity_type(i), 'n/a'), 11, ' ')                                          || '|' ||
                    rpad(nvl(to_char(l_object_id(i)), 'n/a'), 16, ' ')                                   || '|' ||
                    rpad(nvl(l_action_type(i), 'n/a'), 11, ' ')                                          || '|' ||
                    rpad(nvl(to_char(l_action_time(i), 'DD.MM.YYYY HH24:MI:SS'), ' '), 20)               || '|' ||
                    rpad(nvl(to_char(l_user_id(i)), 'n/a'), 30, ' ')                                     || '|' ||
                    rpad(nvl(l_session_id(i), 0), 16, ' ')                                               || '|' ||
                    rpad(nvl(l_result(i), 'n/a'), 20, ' ')                                               || '|' ||
                    rpad(nvl(l_privileges(i), 'n/a'), 200, ' ');

                l_proc_count       := l_proc_count + 1;
                l_record_number(i) := l_proc_count;

                trc_log_pkg.debug('l_record(i) : ' || l_record(i));

            end loop;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_record
              , i_num_tab       => l_record_number              
            );

            prc_api_stat_pkg.log_current (
                i_current_count     => l_proc_count
                , i_excepted_count  => 0
            );

            exit when l_ref_cur%notfound;
        end loop;      
                      
        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        close l_ref_cur;   
        
        prc_api_stat_pkg.log_end(
            i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            , i_processed_total  => l_proc_count
        );
          
    end if;        

    trc_log_pkg.debug('unload_audit_log End.');

exception 
    when others then
        if l_ref_cur%isopen then
            close l_ref_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        trc_log_pkg.debug('sqlerrm : ' || sqlerrm);

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

end;
/
