create or replace package body prc_api_report_pkg is
/*********************************************************************
 * The API for reports <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 04.02.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_REPORT_PKG <br />
 * @headcom
 ********************************************************************/
procedure run_report (
    o_xml                  out  clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
) is
    l_header                xmltype;
    l_errors                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_subject               xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'Run process report result log'
    );
        
    -- header
    select
        xmlelement("process_stat"
            , xmlelement("process_name", get_text ('prc_process', 'name', p.id, i_lang))
            , xmlelement("process_desc", get_text('prc_process', 'description', p.id, i_lang))
                
            , xmlelement("start_time", to_char(s.start_time, 'mm/dd/yyyy hh24:mi:ss:ff6'))
            , xmlelement("end_time", to_char(s.end_time, 'mm/dd/yyyy hh24:mi:ss:ff6'))
                
            , xmlelement("result_code", s.result_code)

            , xmlelement("processed", s.processed)
            , xmlelement("rejected", s.rejected)
            , xmlelement("excepted", s.excepted)
        ) xml
        , xmlelement("subject", get_text ('prc_process', 'name', p.id, i_lang)) subject
    into
         l_header
       , l_subject
    from
        prc_session_vw s
        , prc_process_vw p
    where
        s.id = i_object_id
        and s.process_id = p.id;
      
       select
            xmlelement("process_errors", 
                xmlagg(
                    xmlelement("error_message" 
                      , xmlelement("error_text", l.text)
                      , xmlelement("error_count", count(*))
                    )
                )
            ) xml
        into l_errors
        from trc_log t
           , com_ui_label_vw l
       where t.session_id  = i_object_id
         and t.trace_level = 'ERROR'
         and t.label_id    = l.id
         and l.lang        = i_lang
       group by l.text;
        
        select
                xmlelement("process_logs", 
                    xmlagg(
                    xmlelement("log_message" 
                    , xmlelement("trace_timestamp", to_char(l.trace_timestamp, 'mm/dd/yyyy hh24:mi:ss:ff6'))
                    , xmlelement("trace_level", l.trace_level) 
                    , xmlelement("trace_text", case when length (l.trace_text) > 200 then l.trace_text
                                                    else trc_log_pkg.get_text (l.label_id, l.trace_text)
                                               end)
                 )
                ))
          into l_detail
          from trc_log l
         where l.session_id   = i_object_id
           and l.trace_level != 'DEBUG'
         order by l.trace_timestamp;

    select
        xmlelement (
            "report"
            , l_subject
            , l_header
            , l_errors
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
            i_error         => 'SESSION_NOT_FOUND'
          , i_env_param1    => i_object_id
        );
end;  

procedure file_password_event (
    o_xml               out     clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
)is
    l_result            xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'Run process report file_password_event'
    );

   select
        xmlelement("report"
            , xmlelement("file_type", get_article_text(f.file_type, i_lang))
            , xmlelement("file_name", f.file_name)
            , xmlelement("file_date", to_char(f.file_date, 'dd.mm.yyyy'))
            , xmlelement("password", prc_api_file_pkg.get_file_password)
        )
    into l_result    
    from prc_session_file f
   where f.id = i_object_id;
           
    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text          => 'End file_password_event'
    );
      
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error      => 'SESSION_FILE_NOT_FOUND'
          , i_env_param1 => i_object_id
        );
    
end;

end;
/
