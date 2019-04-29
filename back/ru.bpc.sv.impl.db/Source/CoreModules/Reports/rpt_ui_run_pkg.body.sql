create or replace package body rpt_ui_run_pkg as
/*********************************************************
 *  User interface for reports running  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.09.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate:: 2010-09-27 11:31:00 +0400#$ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RPT_UI_RUN_PKG <br />
 *  @headcom
 **********************************************************/

procedure check_params(
    io_param_tab        in out  com_api_type_pkg.t_param_tab
  , i_parameters        in      com_param_map_tpt
  , i_report_id         in      com_api_type_pkg.t_short_id
) is
    l_value             com_api_type_pkg.t_full_desc;
begin

    io_param_tab.delete;
    
    for rec in (
        select p.id
             , p.param_name
             , p.data_type
             , p.is_mandatory
             , p.default_value
             , x.name
             , x.char_value
             , x.number_value
             , x.date_value
          from rpt_parameter p
             , table(cast(i_parameters as com_param_map_tpt)) x
         where p.report_id         = i_report_id
           and upper(p.param_name) = upper(x.name(+))
         order by param_name
    ) loop
        if rec.id is not null
          and rec.is_mandatory = com_api_const_pkg.TRUE
          and (  (rec.data_type = com_api_const_pkg.DATA_TYPE_CHAR   and rec.char_value   is null)
              or (rec.data_type = com_api_const_pkg.DATA_TYPE_NUMBER and rec.number_value is null)
              or (rec.data_type = com_api_const_pkg.DATA_TYPE_DATE   and rec.date_value   is null)
              )
        then
            com_api_error_pkg.raise_error(
                i_error       =>  'MANDATORY_PARAM_VALUE_NOT_PRESENT'
              , i_env_param1  =>  nvl(rec.name, rec.param_name)
              , i_env_param2  =>  i_report_id
            );
        else
            if rec.is_mandatory = com_api_const_pkg.FALSE
              and (  (rec.data_type = com_api_const_pkg.DATA_TYPE_CHAR    and rec.char_value   is null)
                  or (rec.data_type = com_api_const_pkg.DATA_TYPE_NUMBER  and rec.number_value is null)
                  or (rec.data_type = com_api_const_pkg.DATA_TYPE_DATE    and rec.date_value   is null)
                  )
            then
                l_value := rec.default_value;
            else
                l_value :=
                    case rec.data_type
                    when com_api_const_pkg.DATA_TYPE_CHAR
                        then rec.char_value
                    when com_api_const_pkg.DATA_TYPE_NUMBER
                        then to_char(rec.number_value, com_api_const_pkg.NUMBER_FORMAT)
                    when com_api_const_pkg.DATA_TYPE_DATE
                        then to_char(rec.date_value, com_api_const_pkg.DATE_FORMAT)
                    end;
            end if;

            io_param_tab(rec.param_name) := l_value;
        end if;
    end loop;
    
end;

procedure report_start(
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_parameters        in      com_param_map_tpt
  , i_template_id       in      com_api_type_pkg.t_short_id
  , i_document_id       in      com_api_type_pkg.t_long_id      default null
  , i_content_type      in      com_api_type_pkg.t_dict_value   default null
  , o_run_id               out  com_api_type_pkg.t_long_id
  , o_is_deterministic     out  com_api_type_pkg.t_boolean
  , o_is_first_run         out  com_api_type_pkg.t_boolean
  , o_file_name            out  com_api_type_pkg.t_name
  , o_save_path            out  com_api_type_pkg.t_name
  , o_resultset            out  sys_refcursor
  , o_xml                  out  clob
) is
    l_count             pls_integer;
    l_run_hash          com_api_type_pkg.t_name;
    l_name_format_id    com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_data_source       clob := empty_clob();
    l_source_type       com_api_type_pkg.t_dict_value;
    l_xml_data          XMLType;
    l_document_id       com_api_type_pkg.t_long_id      := i_document_id;
    l_first_run_id      com_api_type_pkg.t_long_id;
    l_file_format       com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.set_object(
        i_entity_type  => rpt_api_const_pkg.ENTITY_TYPE_REPORT
      , i_object_id    => i_report_id
    );

    select count(1)
      into l_count
      from acm_cu_report_vw
     where rpt_id = i_report_id;
     
    if l_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'RPT_NOT_ENOUGH_RIGHTS'
          , i_env_param1 => i_report_id
        );
    end if; 

    begin

        select source_type
             , is_deterministic
             , name_format_id
             , inst_id
             , data_source
          into l_source_type
             , o_is_deterministic
             , l_name_format_id
             , l_inst_id
             , l_data_source
          from rpt_report
         where id = i_report_id
           and data_source is not null;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       =>  'REPORT_NOT_FOUND'
              , i_env_param1  =>  i_report_id
            );
    end;
    
    if l_document_id is null then
    
        check_params(
            io_param_tab    => l_param_tab
          , i_parameters    => i_parameters
          , i_report_id     => i_report_id
        );    

        if o_is_deterministic = com_api_const_pkg.TRUE then
            rpt_api_run_pkg.get_document_data(
                i_report_id         => i_report_id
              , i_param_tab         => l_param_tab
              , i_name_format_id    => l_name_format_id
              , i_inst_id           => l_inst_id
              , o_file_name         => o_file_name
              , o_save_path         => o_save_path
              , o_run_hash          => l_run_hash
              , o_first_run_id      => l_first_run_id
              , io_document_id      => l_document_id
              , i_content_type      => i_content_type
            );
        
        elsif l_name_format_id is not null then

            begin
                select report_format 
                  into l_file_format
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

            rul_api_param_pkg.set_param(
                i_name    => 'INST_ID'
              , i_value   => l_inst_id
              , io_params => l_param_tab
            );        

            rul_api_param_pkg.set_param(
                i_name    => 'SYS_DATE'
              , i_value   => get_sysdate
              , io_params => l_param_tab
            );        

            rul_api_param_pkg.set_param(
                i_name    => 'SESSION_ID'
              , i_value   => prc_api_session_pkg.get_session_id
              , io_params => l_param_tab
            );        
            
            rul_api_param_pkg.set_param(
                i_name    => 'USER_NAME'
              , i_value   => com_ui_user_env_pkg.get_user_name 
              , io_params => l_param_tab
            ); 

            rul_api_param_pkg.set_param(
                i_name    => 'REPORT_ID'
              , i_value   => i_report_id 
              , io_params => l_param_tab
            ); 

            rul_api_param_pkg.set_param(
                i_name    => 'EFF_DATE'
              , i_value   => i_report_id 
              , io_params => l_param_tab
            );

            rul_api_param_pkg.set_param(
                i_name    => 'REPORT_FORMAT'
              , i_value   => l_file_format
              , io_params => l_param_tab
            );

            o_file_name :=
                        rul_api_name_pkg.get_name (
                            i_format_id           => l_name_format_id
                          , i_param_tab           => l_param_tab
                          , i_double_check_value  => null
                        );                   
        end if;
    end if;
    
    rpt_api_run_pkg.register_report_run(
        o_run_id            => o_run_id
      , i_report_id         => i_report_id
      , i_param_tab         => l_param_tab
      , i_run_hash          => case when l_first_run_id is null then l_run_hash else null end
      , i_document_id       => l_document_id
    );

    if l_document_id is not null then
        begin
            select xmlelement("report",
                       xmlelement("datasource", 
                            xmlparse(document b.document_content)
                       )
                     , xmlelement("template", XMLCData(nvl(c.base64, c.text)))
                   )
              into l_xml_data
              from rpt_document_content b
                 , rpt_template c
             where b.document_id = l_document_id
               and b.content_type = i_content_type
               and b.template_id = c.id;
                   
             o_xml := com_api_const_pkg.XML_HEADER || l_xml_data.getclobval();
                
            update rpt_run
               set first_run_id = (select min(id) from rpt_run where document_id = l_document_id)
             where id = o_run_id;
            
        exception                 
            when no_data_found then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'REPORT_DOCUMENT_NOT_FOUND'
                  , i_env_param1    => l_document_id
                );
        end;
    elsif l_first_run_id is not null then
        update rpt_run
           set first_run_id = l_first_run_id
         where id = o_run_id;
         
    else            
        begin
            rpt_api_run_pkg.process_report(
                i_report_id         => i_report_id
              , i_template_id       => i_template_id
              , i_parameters        => l_param_tab
              , i_source_type       => l_source_type
              , io_data_source      => l_data_source
              , o_resultset         => o_resultset
              , o_xml               => o_xml
            );
        exception
            when others then
                set_report_status(
                    i_run_id => o_run_id
                  , i_status => rpt_api_const_pkg.REPORT_STATUS_FAILED
                );
                trc_log_pkg.debug('rpt_api_run_pkg.process_report: '||sqlerrm);

                if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                    raise;
                elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                    raise;
                else
                    com_api_error_pkg.raise_fatal_error(
                        i_error         => 'UNHANDLED_EXCEPTION'
                      , i_env_param1    => SQLERRM
                    );
                end if;
        end;
    end if;
    
    trc_log_pkg.debug ('rpt_ui_run_pkg.report_start - ok');

end;

procedure set_report_status(
    i_run_id            in      com_api_type_pkg.t_long_id
  , i_status            in      com_api_type_pkg.t_dict_value
) is
begin
    if i_status not in (rpt_api_const_pkg.REPORT_STATUS_RUNNING
                      , rpt_api_const_pkg.REPORT_STATUS_FAILED
                      , rpt_api_const_pkg.REPORT_STATUS_GENERATED)
    then
        com_api_error_pkg.raise_error(
            i_error       =>  'BAD_REPORT_STATUS'
          , i_env_param1  =>  i_status
        );
    end if;

    update rpt_run
       set status       = i_status
         , finish_date  = get_sysdate()
         , document_id  = decode(i_status, rpt_api_const_pkg.REPORT_STATUS_FAILED, null, document_id)
         , run_hash     = decode(i_status, rpt_api_const_pkg.REPORT_STATUS_FAILED, null, run_hash)
     where id           = i_run_id;
     
    if sql%rowcount = 0 then
        com_api_error_pkg.raise_error(
            i_error       =>  'REPORT_RUN_NOT_FOUND'
          , i_env_param1  =>  i_run_id
        );
    end if;
end;

end;
/
