create or replace package body prc_api_process_report_pkg is
/*********************************************************************
 * The API for process report <br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 22.12.2011 <br />
 * Last changed by $Author: khougaev $ <br />
 * $LastChangedDate:: 2011-09-22 12:50:29 +0400#$ <br />
 * Revision: $LastChangedRevision: 12555 $ <br />
 * Module: PRC_API_PROCESS_REPORT_PKG <br />
 * @headcom
 ********************************************************************/
procedure run_report (
    o_xml                    out clob
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_end_time            in     date
) is
    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_session_id            com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'Run process report result log'
      , i_env_param1    => i_end_time
    );

    if i_entity_type <> prc_api_const_pkg.ENTITY_TYPE_PROCESS then
        com_api_error_pkg.raise_error (
            i_error        => 'ENTITY_TYPE_NOT_SUPPORTED'
            , i_env_param1 => i_entity_type
        );
    end if;

    -- header
    select
        xmlelement( "process_stat"
            , xmlelement( "process_name", get_text ('prc_process', 'name', p.id, nvl(i_lang, get_def_lang)) )
            , xmlelement( "process_description", get_text ('prc_process', 'description', p.id, nvl(i_lang, get_def_lang)) )
                
            , xmlelement( "process_start_time", to_char(s.start_time, 'mm/dd/yyyy hh24:mi:ss:ff6') )
            , xmlelement( "process_end_time", to_char(s.end_time, 'mm/dd/yyyy hh24:mi:ss:ff6') )
                
            , xmlelement( "process_result_code", com_api_dictionary_pkg.get_article_text(s.result_code) )

            , xmlelement( "processed", s.processed )
            , xmlelement( "rejected", s.rejected )
            , xmlelement( "excepted", s.excepted )
        ) xml
        , s.id session_id
    into
        l_header
        , l_session_id
    from
        prc_session_vw s
        , prc_process_vw p
    where
        p.id = i_object_id
        and s.process_id = p.id
        and s.inst_id = i_inst_id
        and trunc(s.end_time, 'mi') = trunc(i_end_time, 'mi');

    select
        xmlelement( "process_logs", xmlagg(t.xml) )
    into
        l_detail
    from (
        select nvl(
                   xmlagg(
                       xmlelement("process_log"
                         , xmlelement("log_group", 'Error') 
                         , xmlelement("trace_timestamp", null)
                         , xmlelement("trace_level", l.trace_level) 
                         , xmlelement("trace_text", l.trace_text)
                         , xmlelement("trace_count", count(*))
                         , xmlelement("thread_number", null)
                       )
                   )
                 , xmlelement("process_log")
               ) xml
          from trc_log l
         where l.session_id  = l_session_id
           and l.trace_level = trc_config_pkg.g_codes(trc_config_pkg.ERROR)
         group by
               l.trace_level
             , l.trace_text
        union all
        select
            *
        from (
            select xmlelement("process_log"
                     , xmlelement("log_group", 'Log') 
                     , xmlelement("trace_timestamp", to_char(l.trace_timestamp, 'mm/dd/yyyy hh24:mi:ss:ff6'))
                     , xmlelement("trace_level", l.trace_level) 
                     , xmlelement("trace_text", l.trace_text)
                     , xmlelement("trace_count", null)
                     , xmlelement("thread_number", l.thread_number)
                   )
            from trc_log l
           where l.session_id = l_session_id
           order by l.thread_number, l.trace_timestamp
        )
    ) t;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;
        
    o_xml := l_result.getclobval();
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error        => 'SESSION_NOT_FOUND'
            , i_env_param1 => i_object_id
        );
end;

end;
/
