create or replace package body app_prc_application_pkg as
/*********************************************************
 *  API for processes of application files <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_PRC_APPLICATION_PKG  <br />
 *  @headcom
 **********************************************************/

BULK_LIMIT         constant com_api_type_pkg.t_count := 100; -- T. Kyte recommends always to use 100 (anyway, <= 1000)

procedure process(
    i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id            in      com_api_type_pkg.t_short_id     default null
  , i_session_files_only  in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , i_execution_mode      in      com_api_type_pkg.t_dict_value   default null
  , i_validate_xml_file   in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) is
    l_estimated_count             com_api_type_pkg.t_count      := 0;
    l_record_count                com_api_type_pkg.t_count      := 0;
    l_excepted_count              com_api_type_pkg.t_count      := 0;
    l_appl_id_tab                 com_api_type_pkg.t_number_tab;
    l_appl_status                 com_api_type_pkg.t_dict_value;
    l_sysdate                     date;
    l_exist_savepoint             com_api_type_pkg.t_boolean    := com_api_const_pkg.TRUE;
    l_session_id                  com_api_type_pkg.t_long_id;

    cursor cu_appls_count is
        select count(a.id)
          from app_application a
         where decode(a.appl_status, 'APST0006', 'APST0006', null) = 'APST0006'
           and (
                   i_session_files_only = com_api_const_pkg.FALSE
                   or
                   a.session_file_id in (select f.id from prc_session_file f where f.session_id = l_session_id)
               )
           and (
                   a.inst_id = i_inst_id
                   or
                   i_inst_id is null
                   or
                   i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                   a.agent_id = i_agent_id
                   or
                   i_agent_id is null
               )
           and (
                   a.execution_mode = i_execution_mode
                   or
                   i_execution_mode is null
               )
           and (
                   (
                       i_execution_mode = prc_api_const_pkg.EXECUTION_MODE_USER_INST
                       and
                       a.appl_type in (app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
                                     , app_api_const_pkg.APPL_TYPE_INSTITUTION)
                   )
                   or
                   a.appl_type not in (app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
                                     , app_api_const_pkg.APPL_TYPE_INSTITUTION)
               );

    cursor cu_appls is
        select a.id
          from app_application a
         where decode(a.appl_status, 'APST0006', 'APST0006', null) = 'APST0006'
           and (
                   i_session_files_only = com_api_const_pkg.FALSE
                   or
                   a.session_file_id in (select f.id from prc_session_file f where f.session_id = l_session_id)
               )
           and (
                   a.inst_id = i_inst_id
                   or
                   i_inst_id is null
                   or
                   i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                   a.agent_id = i_agent_id
                   or
                   i_agent_id is null
               )
           and (
                   a.execution_mode = i_execution_mode
                   or
                   i_execution_mode is null
               )
           and (
                   (
                       i_execution_mode = prc_api_const_pkg.EXECUTION_MODE_USER_INST
                       and
                       a.appl_type in (app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
                                     , app_api_const_pkg.APPL_TYPE_INSTITUTION)
                   )
                   or
                   a.appl_type not in (app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
                                     , app_api_const_pkg.APPL_TYPE_INSTITUTION)
               )
         order by a.id       
         for update nowait;

begin
    savepoint sp_app_process;

    prc_api_stat_pkg.log_start;

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_session_id    := prc_api_session_pkg.get_session_id;

    trc_log_pkg.debug('Start application processing: sysdate=['||l_sysdate||'] inst_id=['||i_inst_id||'] agent_id=['||i_agent_id||']');

    open cu_appls_count;
    fetch cu_appls_count into l_estimated_count;
    close cu_appls_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
      , i_measure         => app_api_const_pkg.ENTITY_TYPE_APPLICATION
    );

    open cu_appls;

    loop
        fetch cu_appls
            bulk collect
            into l_appl_id_tab
           limit BULK_LIMIT;

        for i in 1..l_appl_id_tab.count loop

            begin
                app_api_application_pkg.set_appl_id(l_appl_id_tab(i));

                app_process_pkg.processing(
                    i_appl_id     => l_appl_id_tab(i)
                  , o_appl_status => l_appl_status
                  , i_run_mode    => 1                -- Process "Applications processing"
                );
                
                app_api_application_pkg.set_appl_id(null);

                select count(id) + l_excepted_count
                  into l_excepted_count
                  from app_application
                 where id          = l_appl_id_tab(i)
                   and appl_status = app_api_const_pkg.APPL_STATUS_PROC_FAILED;

            exception
                when com_api_error_pkg.e_application_error then
                    l_excepted_count := l_excepted_count + 1;
            end;

        end loop;

        l_record_count := l_record_count + l_appl_id_tab.count;

        prc_api_stat_pkg.log_current(
            i_current_count     => l_record_count
          , i_excepted_count    => l_excepted_count
        );

        exit when cu_appls%notfound;

    end loop;

    close cu_appls;

    if i_execution_mode = prc_api_const_pkg.EXECUTION_MODE_USER_INST
       and l_record_count > 0
    then
        -- Method "refresh_mview" contains commit
        acm_api_user_pkg.refresh_mview;

        l_exist_savepoint := com_api_const_pkg.FALSE;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then

        if l_exist_savepoint = com_api_const_pkg.TRUE then
            rollback to sp_app_process;
        end if;
        
        app_api_application_pkg.set_appl_id(null);

        if cu_appls_count%isopen then
            close cu_appls_count;
        end if;

        if cu_appls%isopen then
            close cu_appls;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => SQLERRM
            );
        end if;
end process;

procedure parallel_process(
    i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id            in      com_api_type_pkg.t_short_id     default null
  , i_session_files_only  in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , i_validate_xml_file   in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) is
    l_estimated_count             com_api_type_pkg.t_count      := 0;
    l_record_count                com_api_type_pkg.t_count      := 0;
    l_excepted_count              com_api_type_pkg.t_count      := 0;
    l_appl_id_tab                 com_api_type_pkg.t_number_tab;
    l_appl_status                 com_api_type_pkg.t_dict_value;
    l_sysdate                     date;
    l_thread_number               com_api_type_pkg.t_tiny_id;
    l_session_id                  com_api_type_pkg.t_long_id;

    cursor cu_appls_count is
        select count(a.id)
          from app_application a
         where decode(a.appl_status, 'APST0006', 'APST0006', null) = 'APST0006'
           and a.split_hash in (select sm.split_hash from com_split_map sm where sm.thread_number = l_thread_number)
           and a.execution_mode = prc_api_const_pkg.EXECUTION_MODE_PARALLEL
           and (
                   i_session_files_only = com_api_const_pkg.FALSE
                   or
                   a.session_file_id in (select f.id from prc_session_file f where f.session_id = l_session_id)
               )
           and (
                   a.inst_id = i_inst_id
                   or
                   i_inst_id is null
                   or
                   i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                   a.agent_id = i_agent_id
                   or
                   i_agent_id is null
               );

    cursor cu_appls is
        select a.id
          from app_application a
         where decode(a.appl_status, 'APST0006', 'APST0006', null) = 'APST0006'
           and a.split_hash in (select sm.split_hash from com_split_map sm where sm.thread_number = l_thread_number)
           and a.execution_mode = prc_api_const_pkg.EXECUTION_MODE_PARALLEL
           and (
                   i_session_files_only = com_api_const_pkg.FALSE
                   or
                   a.session_file_id in (select f.id from prc_session_file f where f.session_id = l_session_id)
               )
           and (
                   a.inst_id = i_inst_id
                   or
                   i_inst_id is null
                   or
                   i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                   a.agent_id = i_agent_id
                   or
                   i_agent_id is null
               )
         order by a.id       
         for update nowait;

begin
    savepoint sp_app_process;

    prc_api_stat_pkg.log_start;

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_session_id    := prc_api_session_pkg.get_session_id;
    l_thread_number := prc_api_session_pkg.get_thread_number;

    if l_thread_number = prc_api_const_pkg.DEFAULT_THREAD then
        com_api_error_pkg.raise_error(
            i_error    => 'NEED_MULTI_THREAD_MODE'
        );
    end if;

    trc_log_pkg.debug('Start application processing: sysdate=['||l_sysdate||'] inst_id=['||i_inst_id||'] agent_id=['||i_agent_id||']');

    open cu_appls_count;
    fetch cu_appls_count into l_estimated_count;
    close cu_appls_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
      , i_measure         => app_api_const_pkg.ENTITY_TYPE_APPLICATION
    );

    open cu_appls;

    loop
        fetch cu_appls
            bulk collect
            into l_appl_id_tab
           limit BULK_LIMIT;

        for i in 1..l_appl_id_tab.count loop

            begin
                app_api_application_pkg.set_appl_id(l_appl_id_tab(i));

                app_process_pkg.processing(
                    i_appl_id     => l_appl_id_tab(i)
                  , o_appl_status => l_appl_status
                  , i_run_mode    => 1                -- Process "Applications processing"
                );
                
                app_api_application_pkg.set_appl_id(null);

                select count(id) + l_excepted_count
                  into l_excepted_count
                  from app_application
                 where id          = l_appl_id_tab(i)
                   and appl_status = app_api_const_pkg.APPL_STATUS_PROC_FAILED;

            exception
                when com_api_error_pkg.e_application_error then
                    l_excepted_count := l_excepted_count + 1;
            end;

        end loop;

        l_record_count := l_record_count + l_appl_id_tab.count;

        prc_api_stat_pkg.log_current(
            i_current_count     => l_record_count
          , i_excepted_count    => l_excepted_count
        );

        exit when cu_appls%notfound;

    end loop;

    close cu_appls;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_app_process;
        
        app_api_application_pkg.set_appl_id(null);

        if cu_appls_count%isopen then
            close cu_appls_count;
        end if;

        if cu_appls%isopen then
            close cu_appls;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => SQLERRM
            );
        end if;
end parallel_process;

/*
 * Process for processing applications during migration.
 * @i_count - it allows to launch migrating in few steps with gathering Oracle statistics
              between launches (e.g., 1 000 000 applications can be processed in 3 steps:
              10 000 on 1st step, then 100 000 on 2nd step, and last 890 000 on 3rd step)
 */
procedure process_migrate(
    i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id            in      com_api_type_pkg.t_short_id     default null
  , i_count               in      com_api_type_pkg.t_short_id     default 0
  , i_application_type    in      com_api_type_pkg.t_dict_value   default null
  , i_validate_xml_file   in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) is
    CURSOR_LIMIT         constant com_api_type_pkg.t_count := 5000;

    l_record_count                com_api_type_pkg.t_count := 0;
    l_processed_count             com_api_type_pkg.t_count := 0; -- total processed at some moment
    l_excepted_count              com_api_type_pkg.t_count := 0; -- total failed at some moment
    l_cursor_limit                com_api_type_pkg.t_count := 0;
    l_appl_id_tab                 com_api_type_pkg.t_number_tab;
    l_appl_status                 com_api_type_pkg.t_dict_value;
    l_session_id                  com_api_type_pkg.t_long_id;

    cursor cu_appls(
        i_limit    in    com_api_type_pkg.t_count
    ) is
        select a.id
          from app_application a
         where decode(a.appl_status, 'APST0006', 'APST0006', null) = 'APST0006'
           and a.split_hash in (select split_hash from com_api_split_map_vw)
           and a.agent_id    = nvl(i_agent_id, a.agent_id)
           and (
                   a.inst_id = nvl(i_inst_id, a.inst_id)
                   or
                   i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                   a.appl_type = i_application_type
                   or
                   (i_application_type is null and a.appl_type != app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT)
               )
           and rownum <= i_limit;

    cursor cu_appl_count is -- count of applications by files of current session
        select a.session_file_id
             , f.file_name
             , count(a.id) as cnt
          from app_application a
          join prc_session_file f on f.id = a.session_file_id
         where f.session_id  = l_session_id
           and decode(a.appl_status, 'APST0006', 'APST0006', null) = 'APST0006'
           and a.split_hash in (select split_hash from com_api_split_map_vw)
           and a.agent_id    = nvl(i_agent_id, a.agent_id)
           and (
                   a.inst_id = nvl(i_inst_id, a.inst_id)
                   or
                   i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                   a.appl_type = i_application_type
                   or
                   (i_application_type is null and a.appl_type != app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT)
               )
      group by a.session_file_id
             , f.file_name;

    type t_appl_count_tab is table of cu_appl_count%rowtype index by pls_integer;

    l_appl_count_tab              t_appl_count_tab;

begin
    savepoint sp_app_process;

    prc_api_stat_pkg.log_start;

    l_session_id    := prc_api_session_pkg.get_session_id;

    trc_log_pkg.debug(
        i_text       => 'START application processing (migrate): '
                     || 'sysdate [#1], i_inst_id [#2], i_agent_id [#3], i_count [#4]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(get_sysdate())
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_agent_id
      , i_env_param4 => i_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => i_count
      , i_measure         => app_api_const_pkg.ENTITY_TYPE_APPLICATION
    );

    if i_count = 0 then
        -- Don't process applications, just logging information about uploaded ones (by files) in current session
        open cu_appl_count;

        loop
            fetch cu_appl_count bulk collect into l_appl_count_tab limit BULK_LIMIT;
            exit when l_appl_count_tab.count() = 0;

            for i in l_appl_count_tab.first .. l_appl_count_tab.last loop
                trc_log_pkg.info(
                    i_text       => '#2 applications uploaded successfully from file [#1], session_file_id [#3]'
                  , i_env_param1 => l_appl_count_tab(i).file_name
                  , i_env_param2 => l_appl_count_tab(i).cnt
                  , i_env_param3 => l_appl_count_tab(i).session_file_id
                );
                l_record_count := l_record_count + l_appl_count_tab(i).cnt;
            end loop;
        end loop;

        close cu_appl_count;

        trc_log_pkg.info(
            i_text       => 'Total applications successfully uploaded: #1'
          , i_env_param1 => l_record_count
        );
    else
        -- Otherwise process applications
        loop
            -- Reopen cursor on each iteration and fetch limited count of unprocessed applications
            -- at a time to avoid exception ORA-01555 during continous reading from APP_APPLICATION
            l_cursor_limit := least(CURSOR_LIMIT, i_count - l_processed_count);

            trc_log_pkg.debug('open cursor cu_appls(i_limit => ' || l_cursor_limit || ')');

            open cu_appls(i_limit => l_cursor_limit);
            fetch cu_appls bulk collect into l_appl_id_tab;
            close cu_appls;

            trc_log_pkg.debug(l_appl_id_tab.count() || ' applications'' IDs were fetched');

            exit when l_appl_id_tab.count() = 0;

            for i in l_appl_id_tab.first .. l_appl_id_tab.last loop
                begin
                    app_api_application_pkg.set_appl_id(
                        i_appl_id     => l_appl_id_tab(i)
                    );
                    app_process_pkg.processing(
                        i_appl_id     => l_appl_id_tab(i)
                      , o_appl_status => l_appl_status
                      , i_run_mode    => 2                -- Process "Migrating applications processing"
                    );

                    if l_appl_status = app_api_const_pkg.APPL_STATUS_PROC_FAILED then
                        l_excepted_count := l_excepted_count + 1;
                    end if;
                exception
                    when com_api_error_pkg.e_application_error then
                        l_excepted_count := l_excepted_count + 1;
                end;

                l_processed_count := l_processed_count + 1;

                -- Commit every BULK_LIMIT processed applications + after processing the last application
                if mod(i, BULK_LIMIT) = 0 or i = l_appl_id_tab.last then
                    trc_log_pkg.debug(
                        i_text           => i || ' applications were processed from the cursor, failed/total = #1/#2'
                      , i_env_param1     => l_excepted_count
                      , i_env_param2     => l_processed_count
                    );
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_processed_count
                      , i_excepted_count => l_excepted_count
                    );

                    if i_application_type = app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
                       and l_processed_count > 0
                    then
                        -- Method "refresh_mview" contains commit
                        acm_api_user_pkg.refresh_mview;
                    end if;

                    commit;

                    -- New savepoint after commit
                    savepoint sp_app_process;
                end if;
            end loop;
        end loop;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_processed_count
          , i_measure         => app_api_const_pkg.ENTITY_TYPE_APPLICATION
        );

        if i_application_type = app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
           and l_processed_count > 0
        then
            acm_api_user_pkg.refresh_mview;
        end if;

    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
    );

exception
    when others then
        rollback to sp_app_process;

        if cu_appl_count%isopen then
            close cu_appl_count;
        end if;

        if cu_appls%isopen then
            close cu_appls;
        end if;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_processed_count
          , i_measure           => app_api_const_pkg.ENTITY_TYPE_APPLICATION
        );

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
          , i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process_migrate;

end app_prc_application_pkg;
/
