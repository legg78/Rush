create or replace package body app_prc_response_pkg as

/*
 * Process for unloading application responses for those applications that were uploaded earlier
 * (created via GUI applications aren't processed by this process).
 * @param i_export_clear_pan  – if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 */
procedure event_upload_app_response(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_count               in     com_api_type_pkg.t_medium_id  default null
)
is
    LOG_PREFIX             constant com_api_type_pkg.t_name  :=
                                lower($$PLSQL_UNIT) || '.event_upload_app_response';

    CRLF         constant com_api_type_pkg.t_tag        := chr(13) || chr(10);
    SAVE_LIMIT   constant com_api_type_pkg.t_tiny_id    := 1000;
    l_sess_file_id        com_api_type_pkg.t_long_id;
    l_xml_content         clob;
    l_params              com_api_type_pkg.t_param_tab;
    l_record_count        com_api_type_pkg.t_medium_id  := 0;
    l_sysdate             date;

    -- Selection of all applications are ready for processing and split by session_file_id
    cursor l_cur_applications(
        p_inst_id in com_api_type_pkg.t_inst_id
    ) is
    select a.session_file_id
         --, a.resp_session_file_id
         , sf.file_name
         , o.object_id as appl_id
         , o.id
         , o.event_timestamp
         , row_number() over (partition by a.session_file_id order by o.event_timestamp, o.id) as row_num
         , count(*)     over (partition by a.session_file_id) as cnt
         , row_number() over (order by a.session_file_id, o.event_timestamp, o.id) as row_num_all
         , count(*)     over () as cnt_all
      from evt_event_object o
      join app_application a      on a.id  = o.object_id
      join prc_session_file sf    on sf.id = a.session_file_id
     where o.entity_type    = app_api_const_pkg.ENTITY_TYPE_APPLICATION
       and decode(o.status, 'EVST0001', o.procedure_name, null) = 'APP_PRC_RESPONSE_PKG.EVENT_UPLOAD_APP_RESPONSE' -- using index
       and o.eff_date      <= l_sysdate
       and (p_inst_id = ost_api_const_pkg.DEFAULT_INST or o.inst_id = p_inst_id)
     order by
           a.session_file_id
         , o.event_timestamp
         , o.id
    for update skip locked;

    procedure close_file(
        i_appl_id       in  com_api_type_pkg.t_long_id
    )
    is
    begin
        prc_api_file_pkg.put_file(
            i_sess_file_id => l_sess_file_id
          , i_clob_content => l_xml_content || CRLF 
                           || '</applications>'
          , i_add_to       => com_api_type_pkg.TRUE
        );
        prc_api_file_pkg.close_file(
            i_sess_file_id => l_sess_file_id
          , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count => l_record_count
        );
            
        update app_application
           set resp_session_file_id = l_sess_file_id
         where id = i_appl_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': Close_file l_sess_file_id [#1], i_record_count [#2]'
          , i_env_param1 => l_sess_file_id
          , i_env_param2 => l_record_count
        );

        l_record_count := 0;
    end;

begin
    savepoint upload_app_response;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX ||': Start. inst_id [#1]'
      , i_env_param1 => i_inst_id
    );

    prc_api_stat_pkg.log_start;

    l_params  := evt_api_shared_data_pkg.g_params;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    for rec in l_cur_applications(p_inst_id => i_inst_id) loop
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': rec {session_file_id [#1], appl_id [#2], row_num [#3]'
                                      || ', cnt [#4], row_num_all [#5], cnt_all [#6]}'
          , i_env_param1 => rec.session_file_id
          , i_env_param2 => rec.appl_id
          , i_env_param3 => rec.row_num
          , i_env_param4 => rec.cnt
          , i_env_param5 => rec.row_num_all
          , i_env_param6 => rec.cnt_all
        );

        -- Applications' count in all files
        if rec.row_num_all = 1 then
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => rec.cnt_all
              , i_measure         => app_api_const_pkg.ENTITY_TYPE_APPLICATION
            );
        end if;

        -- For the first application within file session_file_id it's necessary to open a new output file  
        if rec.row_num = 1
           or mod(rec.row_num, i_count) = 1
        then
            if rec.row_num != 1
               and mod(rec.row_num, i_count) = 1
            then
                close_file(
                    i_appl_id      => rec.appl_id
                );
            end if;

            rul_api_param_pkg.set_param (
                i_name    => 'INST_ID'
              , i_value   => i_inst_id
              , io_params => l_params
            );
            rul_api_param_pkg.set_param(
                i_name    => 'TIMESTAMP'
              , i_value   => to_char(rec.event_timestamp, 'ffff')
              , io_params => l_params
            );
            rul_api_param_pkg.set_param(
                i_name    => 'ORIGINAL_FILE_NAME'
              , i_value   => rec.file_name
              , io_params => l_params
            );
            prc_api_file_pkg.open_file(
                o_sess_file_id => l_sess_file_id
              , i_file_type    => app_api_const_pkg.FILE_TYPE_APP_RESPONSE
              , io_params      => l_params
            );
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': Open_file l_sess_file_id [#1], row_num [#2]'
              , i_env_param1 => l_sess_file_id
              , i_env_param2 => rec.row_num
            );
            l_xml_content := com_api_const_pkg.XML_HEADER || CRLF 
                             || '<applications xmlns="' || app_api_const_pkg.APPL_XMLNS || '">' || CRLF;
        end if;

        l_xml_content := l_xml_content
                      || app_api_application_pkg.get_xml(
                             i_appl_id          => rec.appl_id
                           , i_add_header       => com_api_const_pkg.FALSE
                           , i_export_clear_pan => i_export_clear_pan
                           , i_add_xmlns        => com_api_const_pkg.FALSE
                         ); 

        l_record_count := l_record_count + 1;

        -- The output file should be filled and closed only after processing the last application of input file
        if rec.row_num = rec.cnt then
            close_file(
                i_appl_id      => rec.appl_id
            );

        elsif mod(rec.row_num, SAVE_LIMIT) = 0 then
            prc_api_file_pkg.put_file(
                i_sess_file_id => l_sess_file_id
              , i_clob_content => l_xml_content || CRLF 
              , i_add_to       => com_api_type_pkg.TRUE
            );
            l_xml_content := empty_clob();

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': Put_file l_sess_file_id [#1], row_num [#2]'
              , i_env_param1 => l_sess_file_id
              , i_env_param2 => rec.row_num
            );

        end if;

        -- All event objects are marked as processed instead of its deleting 
        evt_api_event_pkg.process_event_object(
            i_event_object_id => rec.id
        );
        
        prc_api_stat_pkg.increase_current(
            i_current_count  => 1  -- one application extracted
          , i_excepted_count => 0
        );

        -- After processing the last application in the last file total progress should be logged 
        if rec.row_num_all = rec.cnt_all then
            prc_api_stat_pkg.log_end(
                i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
              , i_processed_total => rec.cnt_all
            );
        end if;
    end loop;

    -- Store statistics in the case when there are no applications to process
    if l_sess_file_id is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
          , i_measure         => app_api_const_pkg.ENTITY_TYPE_APPLICATION
        );
        prc_api_stat_pkg.log_end(
            i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX ||': Finish'
      , i_env_param1 => i_inst_id
    );

exception
    when others then
        rollback to upload_app_response;

        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id => l_sess_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

        raise;
end event_upload_app_response;

end;
/
