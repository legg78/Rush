create or replace package body rpt_prc_run_pkg as
/*********************************************************
*  API for run reports from processes <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 05.04.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: rpt_prc_run_pkg <br />
*  @headcom
**********************************************************/
    
BULK_LIMIT                  constant com_api_type_pkg.t_tiny_id := 1000;
UNIVERSAL_REPORT_FORMAT_ID  constant com_api_type_pkg.t_tiny_id := 1312;
    
procedure run_report is
    l_process_id         com_api_type_pkg.t_short_id;
    l_session_id         com_api_type_pkg.t_long_id;
    l_parent_sess_id     com_api_type_pkg.t_long_id;
    l_report_id          com_api_type_pkg.t_short_id;
    l_template_id        com_api_type_pkg.t_short_id;
    l_report             clob;
    l_params             com_api_type_pkg.t_param_tab;
    l_data_source        clob;
    l_cur                sys_refcursor;
    l_sess_file_id       com_api_type_pkg.t_long_id;
    l_source_type        com_api_type_pkg.t_dict_value;
    l_container_id       com_api_type_pkg.t_short_id;
    l_process_param_tab  com_param_map_tpt;
begin
    l_process_id        := prc_api_session_pkg.get_process_id;
    l_session_id        := prc_api_session_pkg.get_session_id;
    l_parent_sess_id    := prc_api_session_pkg.get_parent_session_id;
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_process_param_tab := prc_ui_run_pkg.get_param_tab;
    
    trc_log_pkg.debug(
        i_text          => 'process_id [#1], session_id [#2], parent_sess_id [#3], l_container_id [#4]'
      , i_env_param1    => l_process_id
      , i_env_param2    => l_session_id
      , i_env_param3    => l_parent_sess_id
      , i_env_param4    => l_container_id
    );
    
    prc_api_stat_pkg.log_start;

    prc_api_stat_pkg.log_estimation(i_estimated_count => 1);
    
    select a.report_id
         , a.report_template_id
         , r.source_type
         , r.data_source
      into l_report_id
         , l_template_id
         , l_source_type
         , l_data_source
      from prc_file_attribute a
         , prc_file f
         , rpt_report r
     where a.container_id = l_container_id
       and f.id           = a.file_id
       and r.id           = a.report_id;

    trc_log_pkg.debug(
        i_text => 'report_id [#1], template_id [#2], source_type [#3]'
      , i_env_param1   => l_report_id
      , i_env_param2   => l_template_id
      , i_env_param3   => l_source_type
    );

    for rec in (
        select p.id as param_id
             , p.param_name
             , p.data_type
             , coalesce(
                   case p.data_type
                       when com_api_const_pkg.DATA_TYPE_CHAR
                       then d.char_value
                       when com_api_const_pkg.DATA_TYPE_NUMBER
                       then to_char(d.number_value, com_api_const_pkg.NUMBER_FORMAT)
                       when com_api_const_pkg.DATA_TYPE_DATE
                       then to_char(d.date_value,   com_api_const_pkg.DATE_FORMAT)
                   end
                 , v.param_value
                 , p.default_value
               ) as param_value
          from rpt_parameter p
             , prc_parameter_value v 
             , table(cast(l_process_param_tab as com_param_map_tpt)) d
         where p.report_id       = l_report_id
           and v.param_id(+)     = p.id
           and v.container_id(+) = l_container_id
           and d.name(+)         = p.param_name
    ) loop
        case rec.data_type
            when com_api_const_pkg.DATA_TYPE_CHAR   then 
                rul_api_param_pkg.set_param(
                    i_name    => rec.param_name
                  , i_value   => rec.param_value  
                  , io_params => l_params
                );
            when com_api_const_pkg.DATA_TYPE_NUMBER then 
                rul_api_param_pkg.set_param(
                    i_name    => rec.param_name
                  , i_value   => to_number(rec.param_value, get_number_format)  
                  , io_params => l_params
                );
            when com_api_const_pkg.DATA_TYPE_DATE then 
                rul_api_param_pkg.set_param(
                    i_name    => rec.param_name
                  , i_value   => to_date(rec.param_value, get_date_format)  
                  , io_params => l_params
                );
        end case;

        -- save param
        trc_log_pkg.debug(
            i_text         => 'Param_id [#1], Param_name [#2], Param_value [#3]'
          , i_env_param1   => rec.param_id
          , i_env_param2   => rec.param_name
          , i_env_param3   => rec.param_value
        );

        prc_api_process_history_pkg.add(
            i_session_id  => l_session_id
          , i_param_id    => rec.param_id
          , i_param_value => trim(both '''' from rec.param_value)
        );
    end loop;

    rul_api_param_pkg.set_param(
        i_name    => 'REPORT_ID'
      , i_value   => l_report_id 
      , io_params => l_params
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id   => l_sess_file_id
        , io_params      => l_params
    );

    rpt_api_run_pkg.process_report(
        i_report_id     => l_report_id
      , i_template_id   => l_template_id
      , i_parameters    => l_params 
      , i_source_type   => l_source_type
      , io_data_source  => l_data_source
      , o_resultset     => l_cur
      , o_xml           => l_report
    );

    if nvl(length(l_report),0) = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'REPORT_RETURNS_EMPTY_RESULT'
          , i_env_param1 => l_report_id
        );
    end if;

    prc_api_file_pkg.put_file(
        i_sess_file_id  => l_sess_file_id
      , i_clob_content  => l_report
      , i_add_to        => com_api_type_pkg.FALSE
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id => l_sess_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_current(
        i_current_count  => 1
      , i_excepted_count => 0
    );

    prc_api_stat_pkg.log_end(
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end run_report;

function get_format_name(
    i_report_id         in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id is
    l_format_id         com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug('rpt_prc_run_pkg.get_report_name. Report_id = ' || i_report_id);

    select name_format_id
      into l_format_id   
      from rpt_report
    where id = i_report_id;
    
    if l_format_id is null then 
        select id
          into l_format_id
          from rul_name_format
         where id          = UNIVERSAL_REPORT_FORMAT_ID
           and inst_id     = ost_api_const_pkg.DEFAULT_INST
           and entity_type = com_api_const_pkg.ENTITY_TYPE_REPORT;
    end if;
    
    trc_log_pkg.debug('Found format_id = ' || l_format_id || ', Report_id = ' || i_report_id);
    
    return l_format_id;
exception 
    when no_data_found then
        com_api_error_pkg.raise_fatal_error (
            i_error      => 'RUL_NAME_FORMAT_NOT_FOUND'
          , i_env_param1 => i_report_id
        );
end get_format_name;

procedure run_multiple_reports(
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_report_id             in     com_api_type_pkg.t_short_id
  , i_template_id           in     com_api_type_pkg.t_short_id     default null
  , i_lang                  in     com_api_type_pkg.t_dict_value   default null
  , i_ignore_empty_reports  in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_make_notification     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_subscriber_name       in     com_api_type_pkg.t_name         default null
) is
    DEFAULT_PROCEDURE_NAME         constant com_api_type_pkg.t_name := 'RPT_PRC_RUN_PKG.RUN_MULTIPLE_REPORTS';

    l_subscriber_name   com_api_type_pkg.t_name       := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_make_notification com_api_type_pkg.t_boolean    := nvl(i_make_notification, com_api_type_pkg.FALSE);
    l_lang              com_api_type_pkg.t_dict_value;
    l_template_id       com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_estimated_count   com_api_type_pkg.t_short_id   := 0;
    l_processed_count   com_api_type_pkg.t_short_id   := 0;
    l_excepted_count    com_api_type_pkg.t_short_id   := 0;
    l_count             com_api_type_pkg.t_short_id   := 0;
    l_sess_file_id      com_api_type_pkg.t_long_id;
    l_data_source       clob;
    l_source_type       com_api_type_pkg.t_dict_value;
    l_cur               sys_refcursor;
    l_report            clob;
    
    l_format_id         com_api_type_pkg.t_inst_id;
    l_name_params       com_api_type_pkg.t_param_tab;
    l_file_name         com_api_type_pkg.t_name; 
    l_is_deterministic  com_api_type_pkg.t_boolean;
    l_container_id      com_api_type_pkg.t_long_id;
    l_save_path         com_api_type_pkg.t_full_desc; 
    l_document_type     com_api_type_pkg.t_dict_value;
    l_document_id       com_api_type_pkg.t_long_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
    l_file_format       com_api_type_pkg.t_dict_value;

    l_event_tab         rpt_api_type_pkg.t_event_tab;
    l_notif_count       com_api_type_pkg.t_short_id;

    cursor cur_events is
        select e.event_type
             , o.entity_type
             , o.object_id
             , o.split_hash
             , o.eff_date 
             , o.id event_object_id
             , o.inst_id
             , d.id              as document_id
             , d.document_number as document_number
             , d.document_type   as document_type
             , d.entity_type     as document_entity_type
             , d.object_id       as document_object_id
             , d.start_date      as document_start_date
             , d.end_date        as document_end_date
             , d.status          as document_status
          from evt_event e
             , evt_event_object o
             , rpt_document d
         where e.id          = o.event_id
           and e.event_type  = i_event_type
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and (o.container_id is null or o.container_id = l_container_id)
           and o.entity_type = rpt_api_const_pkg.ENTITY_TYPE_DOCUMENT
           and o.object_id   = d.id(+);

begin
    savepoint read_events_start;

    trc_log_pkg.debug('run_several_reports Start');
    trc_log_pkg.debug(
        i_text       => 'Input parameters: i_event_type [#1], i_report_id [#2], i_template_id [#3], i_lang [#4], i_ignore_empty_reports [#5], i_make_notification [#6]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_report_id
      , i_env_param3 => i_template_id
      , i_env_param4 => i_lang
      , i_env_param5 => i_ignore_empty_reports
      , i_env_param6 => i_make_notification
    );

    l_container_id := prc_api_session_pkg.get_container_id;
    l_lang         := nvl(i_lang, get_user_lang);

    prc_api_stat_pkg.log_start;
    
    begin
        select source_type
             , data_source
             , is_deterministic
             , document_type
          into l_source_type    
             , l_data_source
             , l_is_deterministic
             , l_document_type
          from rpt_report
         where id = i_report_id;
    exception
        when no_data_found then     
            com_api_error_pkg.raise_error(
                i_error      => 'REPORT_NOT_FOUND'
              , i_env_param1 => i_report_id
            );
    end;
    trc_log_pkg.debug('Report source_type = ' || l_source_type || ', l_container_id = ' || l_container_id);
    
    select max(id)
         , count(1)
      into l_template_id
         , l_count
      from rpt_template
     where report_id = i_report_id 
       and id        = nvl(i_template_id, id)
       and lang      = l_lang;
    
    if l_count = 0 then
        begin
            select id, report_format 
              into l_template_id, l_file_format
              from rpt_template
             where report_id = i_report_id
               and id        = nvl(i_template_id, id)
               and rownum    = 1;
        
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'REPORT_TEMPLATE_NOT_FOUND'
                  , i_env_param1 => i_report_id
                  , i_env_param2 => i_template_id
                );
        end;     
    end if;      
    trc_log_pkg.debug('Report template = '||l_template_id);

    select count(1)
      into l_estimated_count  
      from evt_event e
         , evt_event_object o
         , rpt_document d
     where e.event_type  = i_event_type
       and e.id          = o.event_id
       and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
       and (o.container_id is null or o.container_id = l_container_id)
       and o.entity_type = rpt_api_const_pkg.ENTITY_TYPE_DOCUMENT
       and o.object_id   = d.id(+);
         
    trc_log_pkg.debug('l_estimated_count = '||l_estimated_count);

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );        

    begin 
        select a.name_format_id
          into l_format_id
          from prc_file_attribute a
         where a.container_id  = l_container_id;
    exception
        when no_data_found then 
            null;               
    end;
    
    if l_format_id is null then
        l_format_id := get_format_name(
                           i_report_id => i_report_id
                       );
    end if;
    
    trc_log_pkg.debug('l_format_id = ' || l_format_id);

    open    cur_events;
    trc_log_pkg.debug(
        i_text          => 'cursor opened'
    );

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching '||BULK_LIMIT||' events'
        );

        fetch cur_events bulk collect into l_event_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 events fetched'
          , i_env_param1    => l_event_tab.count
        );

        for i in 1 .. l_event_tab.count loop
            savepoint run_report_start;

            begin
                -- set report params
                trc_log_pkg.debug(
                    i_text          => 'Set report params.'
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_EVENT_TYPE'
                  , i_value   => l_event_tab(i).event_type
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_ENTITY_TYPE'
                  , i_value   => l_event_tab(i).entity_type
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_OBJECT_ID'
                  , i_value   => l_event_tab(i).object_id
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_SPLIT_HASH'
                  , i_value   => l_event_tab(i).split_hash
                  , io_params => l_params
                );
                
                rul_api_param_pkg.set_param(
                    i_name    => 'I_EFF_DATE'
                  , i_value   => l_event_tab(i).eff_date
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_INST_ID'
                  , i_value   => l_event_tab(i).inst_id
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'DOCUMENT_ID'
                  , i_value   => l_event_tab(i).document_id
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'DOCUMENT_NUMBER'
                  , i_value   => l_event_tab(i).document_number
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_DOCUMENT_TYPE'
                  , i_value   => l_event_tab(i).document_type
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_START_DATE'
                  , i_value   => l_event_tab(i).document_start_date
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_END_DATE'
                  , i_value   => l_event_tab(i).document_end_date
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'DOCUMENT_STATUS'
                  , i_value   => l_event_tab(i).document_status
                  , io_params => l_params
                );

                -- set file name params
                rul_api_param_pkg.set_param(
                    i_name    => 'EFF_DATE'
                  , i_value   => l_event_tab(i).eff_date
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'REPORT_ID'
                  , i_value   => i_report_id
                  , io_params => l_name_params
                );
                
                rul_api_param_pkg.set_param(
                    i_name    => 'EVENT_TYPE'
                  , i_value   => l_event_tab(i).event_type
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'ENTITY_TYPE'
                  , i_value   => l_event_tab(i).entity_type
                  , io_params => l_name_params
                );
                
                rul_api_param_pkg.set_param(
                    i_name    => 'OBJECT_ID'
                  , i_value   => l_event_tab(i).object_id
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'LANG'
                  , i_value   => l_lang
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'INVOICE_ID'
                  , i_value   => l_event_tab(i).object_id
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'INST_ID'
                  , i_value   => l_event_tab(i).inst_id
                  , io_params => l_name_params
                );
                
                rul_api_param_pkg.set_param(
                    i_name    => 'INDEX'
                  , i_value   => 1
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param (
                    i_name     => 'SYS_DATE'
                  , i_value    => com_api_sttl_day_pkg.get_sysdate
                  , io_params  => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'EVENT_OBJECT_ID'
                  , i_value   => l_event_tab(i).event_object_id
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'SESSION_ID'
                  , i_value   => prc_api_session_pkg.get_session_id
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'TEMPLATE_ID'
                  , i_value   => l_template_id
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'REPORT_FORMAT'
                  , i_value   => l_file_format
                  , io_params => l_params
                );

                if l_event_tab(i).document_status = rpt_api_const_pkg.DOCUMENT_STATUS_PREPARATION or l_event_tab(i).document_id is null then
                    rpt_api_run_pkg.process_report(
                        i_report_id     => i_report_id
                      , i_template_id   => l_template_id
                      , i_parameters    => l_params
                      , i_source_type   => l_source_type
                      , io_data_source  => l_data_source
                      , o_resultset     => l_cur
                      , o_xml           => l_report
                    );
                    trc_log_pkg.debug('process_report ok');
                else
                    rpt_api_document_pkg.get_content(
                        o_xml          => l_report
                      , i_document_id  => l_event_tab(i).document_id
                      , i_content_type => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
                    );
                    trc_log_pkg.debug('get_content ok');
                end if;

                 if nvl(length(l_report),0) = 0 then
                     com_api_error_pkg.raise_error(
                         i_error      => 'REPORT_RETURNS_EMPTY_RESULT'
                       , i_env_param1 => i_report_id
                     );
                 end if;

                -- generate file name
                l_file_name := rul_api_name_pkg.get_name(
                    i_format_id  => l_format_id
                  , i_param_tab  => l_name_params
                );
                trc_log_pkg.debug('Generated l_file_name - '|| l_file_name);
                                
                prc_api_file_pkg.open_file(
                    o_sess_file_id   => l_sess_file_id
                    , i_file_name    => l_file_name
                    , i_object_id    => l_event_tab(i).object_id
                    , i_entity_type  => l_event_tab(i).entity_type
                );
                trc_log_pkg.debug('Open file = '||l_sess_file_id);

                prc_api_file_pkg.put_file(
                    i_sess_file_id  => l_sess_file_id
                  , i_clob_content  => l_report
                  , i_add_to        => com_api_type_pkg.FALSE
                );
                trc_log_pkg.debug('put_file ok');

                prc_api_file_pkg.close_file(
                    i_sess_file_id => l_sess_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
                trc_log_pkg.debug('Close file = ' || l_sess_file_id);

                --generate document
                if l_is_deterministic = com_api_type_pkg.TRUE then

                    select directory_path
                      into l_save_path 
                      from prc_file_attribute a
                         , prc_directory d 
                     where a.container_id = l_container_id
                       and a.location_id = d.id;

                    l_document_id := null;
                    l_seqnum      := null;

                    -- the process is subscribed directly to the entity of the report (old behaviour)
                    if l_event_tab(i).document_id is null then
                        rpt_api_document_pkg.add_document(
                            io_document_id          => l_document_id
                          , o_seqnum                => l_seqnum
                          , i_content_type          => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
                          , i_document_type         => nvl(l_document_type, rpt_api_const_pkg.DOCUMENT_TYPE_CREDIT)
                          , i_entity_type           => l_event_tab(i).entity_type
                          , i_object_id             => l_event_tab(i).object_id
                          , i_report_id             => i_report_id
                          , i_template_id           => l_template_id
                          , i_file_name             => l_file_name
                          , i_mime_type             => rpt_api_const_pkg.MIME_TYPE_PDF
                          , i_save_path             => l_save_path
                          , i_document_date         => l_event_tab(i).eff_date
                          , i_document_number       => null
                          , i_inst_id               => l_event_tab(i).inst_id
                          , i_start_date            => l_event_tab(i).document_start_date
                          , i_end_date              => l_event_tab(i).document_end_date
                          , i_status                => rpt_api_const_pkg.DOCUMENT_STATUS_CREATED
                          , i_xml                   => l_report
                        );

                        trc_log_pkg.debug('registered document id=[' || l_document_id || '], seqnum=['||l_seqnum||']');

                    -- the process is subscribed to the document in "Preparation" status. The record about the report is made and forming and saving report body are needed
                    elsif l_event_tab(i).document_status = rpt_api_const_pkg.DOCUMENT_STATUS_PREPARATION then
                        rpt_api_document_pkg.modify_document(
                            i_document_id           => l_event_tab(i).document_id
                          , io_seqnum               => l_seqnum
                          , i_content_type          => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
                          , i_report_id             => i_report_id
                          , i_template_id           => l_template_id
                          , i_file_name             => l_file_name
                          , i_mime_type             => rpt_api_const_pkg.MIME_TYPE_PDF
                          , i_save_path             => l_save_path
                          , i_document_date         => l_event_tab(i).eff_date
                          , i_document_number       => null
                          , i_document_type         => nvl(l_document_type, rpt_api_const_pkg.DOCUMENT_TYPE_CREDIT)
                          , i_start_date            => l_event_tab(i).document_start_date
                          , i_end_date              => l_event_tab(i).document_end_date
                          , i_status                => rpt_api_const_pkg.DOCUMENT_STATUS_CREATED
                          , i_content               => l_report
                        );

                        trc_log_pkg.debug('modified document id=[' || l_event_tab(i).document_id || '], seqnum=['||l_seqnum||']');

                    -- the process is subscribed to the document in other status, resending
                    elsif l_event_tab(i).document_id is not null then
                        trc_log_pkg.debug(
                            i_text                  => 'The document exists with ID [#1] and has status [#2]'
                          , i_env_param1            => l_event_tab(i).document_id
                          , i_env_param2            => l_event_tab(i).document_status
                        );
                    end if;

                end if;

                if l_make_notification = com_api_type_pkg.TRUE then
                    -- create notifucation
                    ntf_api_notification_pkg.make_notification_param(
                        i_inst_id                   => l_event_tab(i).inst_id
                      , i_event_type                => l_event_tab(i).event_type
                      , i_entity_type               => l_event_tab(i).document_entity_type
                      , i_object_id                 => l_event_tab(i).document_object_id
                      , i_eff_date                  => l_event_tab(i).eff_date
                      , i_param_tab                 => l_params
                      , io_processed_count          => l_notif_count
                    );
                end if;

                --update event_object
                evt_api_event_pkg.process_event_object(
                    i_event_object_id    => l_event_tab(i).event_object_id
                );

                trc_log_pkg.debug('process event_object ' || l_event_tab(i).event_object_id || ' - ok');

            exception
                when others then
                    rollback to savepoint run_report_start;

                    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                        raise;
                    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                        if not (i_ignore_empty_reports = com_api_const_pkg.TRUE
                           and com_api_error_pkg.get_last_error() = 'REPORT_RETURNS_EMPTY_RESULT') then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            evt_api_event_pkg.process_event_object(
                                i_event_object_id    => l_event_tab(i).event_object_id
                            );
                        end if;
                    else
                        trc_log_pkg.error(
                            i_text          => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );
                        l_excepted_count := l_excepted_count + 1;
                    end if;
            end;

            l_processed_count := l_processed_count + 1;

            prc_api_stat_pkg.log_current(
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );

        end loop;

        if l_event_tab.count = 0 then
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );
        end if;

        exit when cur_events%notfound;
    end loop;
    close cur_events;

    prc_api_stat_pkg.log_end(
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    
    trc_log_pkg.debug('run_several_reports End');

exception
    when others then
        rollback to savepoint read_events_start;
                
        if cur_events%isopen then
            close   cur_events;
        end if;
        
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
     
end run_multiple_reports;

procedure multiple_run_and_notif(
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_report_id             in     com_api_type_pkg.t_short_id
  , i_template_id           in     com_api_type_pkg.t_short_id     default null
  , i_lang                  in     com_api_type_pkg.t_dict_value   default null
  , i_ignore_empty_reports  in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) is
begin
    rpt_prc_run_pkg.run_multiple_reports(
        i_event_type            => i_event_type
      , i_report_id             => i_report_id
      , i_template_id           => i_template_id
      , i_lang                  => i_lang
      , i_ignore_empty_reports  => i_ignore_empty_reports
      , i_make_notification     => com_api_type_pkg.TRUE
      , i_subscriber_name       => 'RPT_PRC_RUN_PKG.MULTIPLE_RUN_AND_NOTIF'
    );
end multiple_run_and_notif;

end rpt_prc_run_pkg;
/
