create or replace package body com_prc_mcc_export_pkg is

g_session_file_id       com_api_type_pkg.t_long_id;
g_file_type             com_api_type_pkg.t_dict_value;

function get_file_type
  return com_api_type_pkg.t_dict_value
is
begin
    return g_file_type;
end get_file_type;

function get_session_file_id
  return com_api_type_pkg.t_long_id
is
begin
    return g_session_file_id;
end get_session_file_id;

procedure process(
    i_dict_version         in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value default null
)
is
    CRLF           constant       com_api_type_pkg.t_name       := chr(13) || chr(10);
    l_file                        clob;
    l_total_count                 com_api_type_pkg.t_count      := 0;
    l_counter                     com_api_type_pkg.t_count      := 0;
    l_fetched_count               com_api_type_pkg.t_count      := 0;
    l_container_id                com_api_type_pkg.t_long_id;    
    l_params                      com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text       => 'com_prc_mcc_export_pkg.process: START with i_dict_version [#1], i_lang [#2]'
      , i_env_param1 => i_dict_version
      , i_env_param2 => i_lang
    );
    
    l_container_id := prc_api_session_pkg.get_container_id;

    select min(f.file_type)
      into g_file_type
      from prc_file_attribute a
         , prc_file f
     where a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT
       and a.container_id = l_container_id;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;
    
    savepoint sp_prc_mcc_export;
    
    trc_log_pkg.debug('Creating a new XML file...');
            
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
      , i_file_type     => g_file_type
      , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
      , io_params       => l_params
    );

    l_fetched_count := com_itf_dict_pkg.execute_mcc_query(
                           i_dict_version => i_dict_version
                         , i_lang         => i_lang
                         , o_xml          => l_file
                         , i_entry_point  => com_api_const_pkg.ENTRYPOINT_EXPORT
                       );
    
    prc_api_stat_pkg.log_estimation(i_estimated_count => l_fetched_count);
            
    l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

    prc_api_file_pkg.put_file(
        i_sess_file_id  => g_session_file_id
      , i_clob_content  => l_file
      , i_add_to        => com_api_const_pkg.FALSE
    );

    l_counter     := l_counter + 1;
    trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

    l_total_count := l_total_count + l_fetched_count;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug('com_prc_mcc_export_pkg.process: FINISH');

exception
    when others then
        rollback to sp_prc_mcc_export;
        prc_api_stat_pkg.log_end(i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED);

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

end com_prc_mcc_export_pkg;
/
