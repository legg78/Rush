create or replace package body itf_omn_prc_product_export_pkg is
/*********************************************************
 *  Product export process <br />
 *  Created by Fomichev Andrey (fomichev@bpcbt.com) at 03.08.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-08-03 13:34:00 +0400#$ <br />
 *  Module: itf_omn_prc_product_export_pkg <br />
 *  @headcom
 **********************************************************/
 
-- entry point, interface
procedure process(
    i_lang             in     com_api_type_pkg.t_dict_value default null
  , i_omni_iss_version in     com_api_type_pkg.t_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id    default null
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.export_cards: ';
    l_file               clob;
    l_count              com_api_type_pkg.t_long_id;
    l_sess_file_id       com_api_type_pkg.t_long_id;
begin

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START'
    );
    prc_api_stat_pkg.log_start;

    savepoint sp_omn_product_export;
    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_sess_file_id
      , i_file_type     => itf_api_const_pkg.FILE_TYPE_PRODUCT
      , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
    );

    l_count := 
        itf_omn_product_pkg.execute_product_query(
            i_inst_id          => i_inst_id
          , i_lang             => i_lang
          , i_omni_iss_version => i_omni_iss_version
          , o_xml              => l_file
          , i_session_file_id  => l_sess_file_id
        );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_count
    );

    if l_file is not null then
        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_count
        );
                    
        trc_log_pkg.debug('file saved, cnt=' || l_count || ', length=' || length(l_file));
         
        prc_api_stat_pkg.log_current (
            i_current_count   => l_count
          , i_excepted_count  => 0
        );
    else
        prc_api_file_pkg.remove_file(
            i_sess_file_id => l_sess_file_id
          , i_file_type    => itf_api_const_pkg.FILE_TYPE_PRODUCT
          , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
        );
        trc_log_pkg.debug('empty result - file not created');
    end if;
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END' 
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );


exception
    when others then
        rollback to savepoint sp_omn_product_export;
        
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        select count(1)
          into l_count
          from prc_session_file f
         where f.id = l_sess_file_id;
        
        if l_sess_file_id is not null and l_count > 0 then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
        
end process;

end itf_omn_prc_product_export_pkg;
/
