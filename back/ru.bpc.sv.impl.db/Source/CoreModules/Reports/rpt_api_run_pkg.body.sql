create or replace package body rpt_api_run_pkg as
/*********************************************************
 *  API for reports running <br />
 *  Created by Fomichev A.(fomichev@bpc.ru)  at 21.09.2010 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2010-09-27 11:31:00 +0400#$ <br />
 *  Module: rpt_api_run_pkg <br />
 *  @headcom
 **********************************************************/
g_report_id com_api_type_pkg.t_short_id;

function get_g_report_id 
    return com_api_type_pkg.t_short_id is
begin
    return g_report_id;    
end get_g_report_id;

procedure set_g_report_id (i_g_report_id in com_api_type_pkg.t_short_id
) is
begin	
	g_report_id := i_g_report_id;
end set_g_report_id;	
  
function format_parameters (
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_parameters        in      com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_text is
    l_result            com_api_type_pkg.t_text;
    l_param_name        com_api_type_pkg.t_name;
    l_param_value       com_api_type_pkg.t_param_value;
begin
    for parameter in (
        select param_name
          from rpt_parameter
         where is_mandatory = com_api_type_pkg.TRUE
           and report_id = i_report_id
    ) loop
        if not i_parameters.exists(parameter.param_name) then
            com_api_error_pkg.raise_error(
                i_error       => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
              , i_env_param1  => parameter.param_name
              , i_env_param2  => i_report_id
            );
        end if;
    end loop;

    l_result := l_result || '(o_xml => :o_xml, i_lang => :i_lang ';

    if i_parameters.count > 0 then
        l_param_name := i_parameters.first;
        loop
            exit when l_param_name is null;

            for parameter in (
                select data_type
                  from rpt_parameter_vw
                 where report_id = i_report_id
                   and upper(param_name) = upper(l_param_name)
            ) loop
                l_param_value := null;
                
                case parameter.data_type
                when com_api_const_pkg.DATA_TYPE_CHAR then
                    if i_parameters(l_param_name) is null then
                        l_param_value := 'NULL';
                    else
                        l_param_value := '''' || replace(i_parameters(l_param_name), '''', '"') || '''';
                    end if;

                when com_api_const_pkg.DATA_TYPE_DATE   then
                    if i_parameters(l_param_name) is null then
                        l_param_value := 'NULL';
                    else
                        l_param_value := 'to_date(''' || i_parameters(l_param_name) || ''',''' || com_api_const_pkg.DATE_FORMAT ||''')';
                    end if;

                when com_api_const_pkg.DATA_TYPE_NUMBER then
                    if i_parameters(l_param_name) is null then
                        l_param_value := 'NULL';
                    else
                        l_param_value := 'to_number(''' || i_parameters(l_param_name)||''',''' || com_api_const_pkg.NUMBER_FORMAT ||''')';
                    end if;
                else
                     l_param_value := nvl(i_parameters(l_param_name), 'NULL');
                end case;

                l_result := l_result || ', ' || upper(l_param_name) || ' => ' || l_param_value;
                trc_log_pkg.debug (
                    i_text          => 'Param [#1] set to [#2]'
                    , i_env_param1  => l_param_name
                    , i_env_param2  => l_param_value
                );
            end loop;

            l_param_name := i_parameters.next(l_param_name);
        end loop;
    end if;
    
    l_result := l_result || ');';
    
    return l_result;
end;
    
procedure process_report(
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_template_id       in      com_api_type_pkg.t_short_id
  , i_parameters        in      com_api_type_pkg.t_param_tab
  , i_source_type       in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , io_data_source      in out nocopy clob
  , o_resultset            out  sys_refcursor
  , o_xml                  out  clob
) is
    l_run_sql           com_api_type_pkg.t_lob_data;
    l_old_source        clob := empty_clob();
    l_source_clob       clob := empty_clob();
   
    l_param_name        com_api_type_pkg.t_name;
    l_param_value       com_api_type_pkg.t_param_value;

    l_template          clob := empty_clob();
    l_result            clob := empty_clob();
    l_lang              com_api_type_pkg.t_dict_value;
   
begin
    trc_log_pkg.debug (
        i_text          => 'process_report: id[#1] source_type[#2]'
        , i_env_param1  => i_report_id
        , i_env_param2  => i_source_type
    );

    case i_source_type 
    when rpt_api_const_pkg.REPORT_SOURCE_SIMPLE then
        trc_log_pkg.debug('source simple report');

        for rec in (
            select param_name
              from rpt_parameter_vw
             where is_mandatory = com_api_type_pkg.TRUE
               and report_id = i_report_id
        ) loop
            if not i_parameters.exists(rec.param_name) then
                com_api_error_pkg.raise_error(
                    i_error       => 'MANDATORY_PARAM_VALUE_NOT_PRESENT'
                  , i_env_param1  =>  rec.param_name
                  , i_env_param2  =>  i_report_id
                );
            end if;
        end loop;

        if i_parameters.count > 0 then
            l_param_name := i_parameters.first;
            loop
                exit when l_param_name is null;
                    
                for parameter in (
                    select data_type
                      from rpt_parameter_vw
                     where report_id  = i_report_id
                       and upper(param_name) = upper(l_param_name)
                ) loop
                    
                    l_param_value :=
                        case parameter.data_type
                        when com_api_const_pkg.DATA_TYPE_CHAR   then ''''||i_parameters(l_param_name)||''''
                        when com_api_const_pkg.DATA_TYPE_DATE   then
                              'to_date('''||i_parameters(l_param_name)||''','''||com_api_const_pkg.DATE_FORMAT ||''')'
                        when com_api_const_pkg.DATA_TYPE_NUMBER then
                              'to_number('''||i_parameters(l_param_name)||''','''||com_api_const_pkg.NUMBER_FORMAT ||''')'
                        else i_parameters(l_param_name)
                        end;

                    l_old_source  := io_data_source;

                    io_data_source := replace(io_data_source, ':'||upper(l_param_name), l_param_value);

                    if l_old_source = io_data_source then
                        com_api_error_pkg.raise_error(
                            i_error      => 'REPORT_PARAM_NOT_FOUND'
                          , i_env_param1 => l_param_name
                          , i_env_param2 => i_report_id
                        );
                    end if;
                end loop;

                l_param_name := i_parameters.next(l_param_name);
            end loop;
        end if;

        trc_log_pkg.debug('rpt_api_run_pkg.process_report: l_source='||l_source_clob);

        open o_resultset for io_data_source;
        
    when rpt_api_const_pkg.REPORT_SOURCE_XML then

        trc_log_pkg.debug (
            i_text          => 'template_id[#1], parameters count[#2]'
            , i_env_param1  => i_template_id
            , i_env_param2  => i_parameters.count
        );
        trc_log_pkg.debug('source_char['||substr(to_char(io_data_source), 1, 2000)||']');

        if i_template_id is not null then
            begin
                select nvl(base64, text)
                     , lang
                  into l_template
                     , l_lang
                  from rpt_template_vw
                 where id = i_template_id;
            exception
                when no_data_found then
                    null;
            end;
        else
            l_lang := i_lang;
        end if;

        l_run_sql := format_parameters (
            i_report_id     => i_report_id
            , i_parameters  => i_parameters
        );
            
        l_run_sql := 'begin '||to_char(io_data_source) || l_run_sql || ' end;';
        
        trc_log_pkg.debug (
            i_text          => 'Run code: [#1]'
            , i_env_param1  => l_run_sql
        );
        set_g_report_id(i_g_report_id => i_report_id);
        execute immediate l_run_sql
        using out l_result, in l_lang;

        o_xml := com_api_const_pkg.XML_HEADER
               ||'<report><datasource>'||l_result||'</datasource>'
               ||case when l_template is not null and l_template <> empty_clob()
                      then '<template><![CDATA['||l_template||']]></template>'
                      else empty_clob()
                 end
               ||'</report>';
    else
        null;
    end case;
end;

procedure get_document_data(
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_name_format_id    in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_file_name            out  com_api_type_pkg.t_name
  , o_save_path            out  com_api_type_pkg.t_name
  , o_run_hash             out  com_api_type_pkg.t_name
  , o_first_run_id         out  com_api_type_pkg.t_long_id
  , io_document_id      in out  com_api_type_pkg.t_long_id
  , i_content_type      in      com_api_type_pkg.t_dict_value
) is
    l_file_name_param_tab   com_api_type_pkg.t_param_tab;
    l_hash_base             com_api_type_pkg.t_text;
begin
        rul_api_param_pkg.set_param('REPORT_ID', i_report_id, l_file_name_param_tab);
        l_hash_base := l_file_name_param_tab('REPORT_ID');
        if io_document_id is not null then
            rul_api_param_pkg.set_param('DOCUMENT_ID', io_document_id, l_file_name_param_tab);
            l_hash_base := l_hash_base || l_file_name_param_tab('DOCUMENT_ID');
        end if;
    
        for r in (
            select param_name
              from rpt_parameter
             where report_id = i_report_id
             order by param_name 
        ) loop
            trc_log_pkg.debug('report parameter found: param_name='||r.param_name); 
            if i_param_tab.exists(r.param_name) then
                l_hash_base := l_hash_base || i_param_tab(r.param_name);
                trc_log_pkg.debug('report parameter value added to hash: param_name='||i_param_tab(r.param_name)); 
                -- Cut prefix 'I_' of parameter names 
                l_file_name_param_tab(substr(r.param_name, 3)) := i_param_tab(r.param_name);
            end if;
        end loop;
        
        o_run_hash := rawtohex(dbms_crypto.hash(utl_raw.cast_to_raw(l_hash_base), dbms_crypto.HASH_MD5));
        
        trc_log_pkg.debug('Calculated hash: run_hash='||o_run_hash); 

        begin
            select d.file_name
                 , a.id
                 , d.save_path 
                 , a.document_id
              into o_file_name
                 , o_first_run_id
                 , o_save_path
                 , io_document_id
              from rpt_run a
                 , rpt_document_content d
             where a.report_id = i_report_id
               and a.run_hash  = o_run_hash
               and d.document_id(+) = a.document_id
               and d.content_type(+) = nvl(i_content_type, rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM);
               
            if o_save_path is null then 
                if i_name_format_id is not null then
                    o_file_name := 
                        rul_api_name_pkg.get_name (
                            i_format_id           => i_name_format_id
                          , i_param_tab           => l_file_name_param_tab
                          , i_double_check_value  => null
                        );
                end if;
                
                o_save_path := 
                    set_ui_value_pkg.get_inst_param_v(
                        i_param_name        => 'REPORTS_SAVE_PATH'
                      , i_inst_id           => i_inst_id
                    );
                
                if substr(o_save_path, -1) != '/' then
                    o_save_path := o_save_path || '/';
                end if;
                    
                o_save_path := o_save_path || o_run_hash;

            end if;
               
            trc_log_pkg.debug('Found first run: first_run_id='||o_first_run_id); 
        exception
            when no_data_found then
                trc_log_pkg.debug('Not found first run'); 

                if i_name_format_id is not null then
                    o_file_name := 
                        rul_api_name_pkg.get_name (
                            i_format_id           => i_name_format_id
                          , i_param_tab           => l_file_name_param_tab
                          , i_double_check_value  => null
                        );
                end if;
                
                o_save_path := 
                    set_ui_value_pkg.get_inst_param_v(
                        i_param_name        => 'REPORTS_SAVE_PATH'
                      , i_inst_id           => i_inst_id
                    );
                
                trc_log_pkg.debug('Find path: Save path='||o_save_path); 
                        
                if substr(o_save_path, -1) != '/' then
                    o_save_path := o_save_path || '/';
                end if;
                    
                o_save_path := o_save_path || o_run_hash;
        end;
        
end;

procedure register_report_run(
    o_run_id               out  com_api_type_pkg.t_long_id
  , i_report_id         in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_run_hash          in      com_api_type_pkg.t_name         default null
  , i_document_id       in      com_api_type_pkg.t_long_id      default null
  , i_status            in      com_api_type_pkg.t_dict_value   default null
) is
    pragma autonomous_transaction;
    l_param_name        com_api_type_pkg.t_name;
begin

    o_run_id := com_api_id_pkg.get_id(rpt_run_seq.nextval, com_api_sttl_day_pkg.get_sysdate);

    l_param_name := i_param_tab.first;
    
    loop

        exit when l_param_name is null;

        insert into rpt_run_parameter(
            id
          , run_id
          , param_id
          , param_value
        ) select com_api_id_pkg.get_id(rpt_run_parameter_seq.nextval, com_api_sttl_day_pkg.get_sysdate)
               , o_run_id
               , id
               , i_param_tab(l_param_name)
            from rpt_parameter
           where param_name = l_param_name
             and report_id  = i_report_id;
            
        l_param_name := i_param_tab.next(l_param_name);

    end loop;

    merge into
        rpt_run dst
    using (
        select
            o_run_id run_id
            , i_report_id report_id
            , get_sysdate() as start_date
            , null finish_date
            , get_user_id user_id
            , nvl(i_status, rpt_api_const_pkg.REPORT_STATUS_RUNNING) status
            , com_ui_user_env_pkg.get_user_inst inst_id
            , i_document_id document_id
            , i_run_hash run_hash
        from dual
    ) src
    on (
        src.run_hash = dst.run_hash and i_document_id is not null 
    )
    when matched then
        update
        set
            dst.start_date = src.start_date
            , dst.finish_date = src.finish_date
            , dst.user_id = src.user_id
            , dst.status = src.status
            , dst.document_id = src.document_id
            , dst.report_id = src.report_id
    when not matched then
        insert (
            dst.id
            , dst.report_id
            , dst.start_date
            , dst.finish_date
            , dst.user_id
            , dst.status
            , dst.inst_id
            , dst.document_id
            , dst.run_hash
        ) values (
            src.run_id
            , src.report_id
            , src.start_date
            , src.finish_date
            , src.user_id
            , src.status
            , src.inst_id
            , src.document_id
            , src.run_hash
        );

    commit;

    trc_log_pkg.debug(
            i_text          => 'Report run registred'
    );

end;

end;
/
