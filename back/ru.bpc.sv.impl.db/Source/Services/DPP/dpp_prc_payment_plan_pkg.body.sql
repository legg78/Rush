create or replace package body dpp_prc_payment_plan_pkg as
/*********************************************************
*  API for DPP payment plan process <br />
*  Created by A.Fomichev (fomichev@bpcbt.com)  at 06.09.2018 <br />
*  Module: DPP_PRC_PAYMENT_PLAN_PKG <br />
*  @headcom
**********************************************************/

procedure process(
    i_inst_id                in     com_api_type_pkg.t_inst_id
) is
    l_estimated_count               com_api_type_pkg.t_long_id;
    l_excepted_count                com_api_type_pkg.t_long_id  := 0;
    l_processed_count               com_api_type_pkg.t_long_id  := 0;
    BULK_LIMIT             constant com_api_type_pkg.t_short_id := 100;
    l_xml                           xmltype;
    l_sess_file_id                  com_api_type_pkg.t_long_id;
    l_file_record_count             com_api_type_pkg.t_long_id;
    l_clob                          clob;
begin 
    savepoint sp_dpp_process;

    prc_api_stat_pkg.log_start;
    
    for rec in (
        select s.file_xml_contents as xml_content
             , s.file_name
             , s.id as session_file_id
             , row_number() over(order by s.id) rn
             , count(1) over() cnt
          from prc_session_file s
             , prc_file_attribute_vw a
             , prc_file_vw f
         where s.session_id   = get_session_id
           and s.file_attr_id = a.id
           and f.id           = a.file_id
           order by s.id
    ) loop

        if rec.rn=1 then
            l_estimated_count := rec.cnt;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
        end if;

        dpp_api_payment_plan_pkg.register_dpp(
            i_xml          => rec.xml_content
          , i_inst_id      => i_inst_id
          , i_sess_file_id => rec.session_file_id
          , o_result       => l_xml
        );
        if l_xml is not null then
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_sess_file_id
              , i_file_type     => dpp_api_const_pkg.FILE_TYPE_DPP_REGISTRATION
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
            );

            select xmlquery('count($doc/dpps/dpp/dpp_id)'
                            passing l_xml as "doc"
                            returning content
                   ).getNumberVal()
              into l_file_record_count
              from dual; 

            select XMLQuery('copy $i := $p1 modify
                              ((for $j in $i/dpps/file_id
                             return replace value of node $j with $file_id)
                             )
                             return $i'
                             PASSING l_xml AS "p1",
                             to_char(l_sess_file_id, com_api_const_pkg.XML_NUMBER_FORMAT) AS "file_id"
                            RETURNING CONTENT
                   )
              into l_xml
              from dual;
            trc_log_pkg.debug(
                i_text       =>  'l_count =#1, l_sess_file_id=#2'
              , i_env_param1 => l_file_record_count
              , i_env_param2 => l_sess_file_id
            );
              
            select XMLSerialize(document l_xml as clob indent ) 
              into l_clob
              from dual;

            prc_api_file_pkg.put_file(
                i_sess_file_id => l_sess_file_id
              , i_clob_content => com_api_const_pkg.XML_HEADER || chr(13) || chr(10) || l_clob
              , i_add_to       => com_api_const_pkg.FALSE
            );

            prc_api_file_pkg.close_file(
                i_sess_file_id => l_sess_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count => l_file_record_count
            );
        else
            trc_log_pkg.debug('empty result file not saved.');
        end if;            

        l_processed_count := l_processed_count + 1;

        if mod(l_processed_count, BULK_LIMIT) = 0 then
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );
        end if;
    end loop;

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_dpp_process;
        prc_api_stat_pkg.log_end (
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process;

end dpp_prc_payment_plan_pkg;
/
