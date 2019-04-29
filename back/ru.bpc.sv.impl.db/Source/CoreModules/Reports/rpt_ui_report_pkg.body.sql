create or replace package body rpt_ui_report_pkg as
/*********************************************************
 *  Interface for reports definition  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com) at 18.05.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RPT_UI_REPORT_PKG <br /> 
 *  @headcom 
 **********************************************************/

procedure add_report(
    o_report_id           out  com_api_type_pkg.t_short_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_report_name      in      com_api_type_pkg.t_name
  , i_report_desc      in      com_api_type_pkg.t_short_desc
  , i_source           in      clob
  , i_source_type      in      com_api_type_pkg.t_attr_name
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_lang             in      com_api_type_pkg.t_name
  , i_is_deterministic in      com_api_type_pkg.t_boolean
  , i_name_format_id   in      com_api_type_pkg.t_tiny_id
  , i_is_notification  in      com_api_type_pkg.t_boolean    default null
  , i_document_type    in      com_api_type_pkg.t_dict_value default null
) is
    l_count          com_api_type_pkg.t_count := 0;
begin

    if i_source_type = rpt_api_const_pkg.REPORT_SOURCE_XML then
        select count(distinct a.argument_name)
          into l_count
          from user_procedures p
             , user_arguments a
         where p.object_type = 'PACKAGE'
           and p.object_name||'.'||p.procedure_name = upper(dbms_lob.substr(i_source, 1000))
           and p.subprogram_id > 0
           and a.object_id = p.object_id
           and a.argument_name in ('O_XML','I_LANG');

         if l_count != 2 then
             com_api_error_pkg.raise_error(
                 i_error      => 'BAD_XML_SOURCE'
               , i_env_param1 => i_report_name
               , i_env_param2 => dbms_lob.substr(i_source, 1000)
             );
         end if;
    end if;

    o_report_id := rpt_report_seq.nextval;
    o_seqnum    := 1;

    insert into rpt_report_vw(
        id
      , seqnum
      , inst_id
      , data_source
      , source_type
      , is_deterministic
      , name_format_id
      , document_type
      , is_notification
    ) values(
        o_report_id
      , o_seqnum
      , i_inst_id
      , i_source
      , i_source_type
      , i_is_deterministic
      , i_name_format_id
      , i_document_type
      , nvl(i_is_notification, 0)
    );

    com_api_i18n_pkg.add_text(
        i_table_name   =>  'RPT_REPORT'
      , i_column_name  =>  'LABEL'
      , i_object_id    =>  o_report_id
      , i_text         =>  i_report_name
      , i_lang         =>  i_lang
      , i_check_unique =>  com_api_type_pkg.FALSE
    );

    select count(1)
      into l_count
      from com_i18n_vw i
         , rpt_report_vw r
     where i.table_name  = upper('RPT_REPORT')
       and i.column_name = upper('LABEL')
       and i.text        = i_report_name
       and i.object_id  != o_report_id
       and r.id          = i.object_id
       and r.inst_id     = i_inst_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_DESCRIPTION'
          , i_env_param1  => upper('rpt_report')
          , i_env_param2  => upper('name')
          , i_env_param3  => i_report_name
        );
    end if;


    com_api_i18n_pkg.add_text(
        i_table_name   =>  'RPT_REPORT'
      , i_column_name  =>  'DESCRIPTION'
      , i_object_id    =>  o_report_id
      , i_text         =>  i_report_desc
      , i_lang         =>  i_lang
    );

    rpt_ui_parameter_pkg.sync_parameters(
        i_report_id   =>  o_report_id
    );
end;

procedure modify_report(
    i_report_id        in     com_api_type_pkg.t_short_id
  , io_seqnum          in out com_api_type_pkg.t_seqnum
  , i_report_name      in     com_api_type_pkg.t_name
  , i_report_desc      in     com_api_type_pkg.t_short_desc
  , i_source           in     clob
  , i_source_type      in     com_api_type_pkg.t_attr_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_lang             in     com_api_type_pkg.t_name
  , i_is_deterministic in     com_api_type_pkg.t_boolean
  , i_name_format_id   in     com_api_type_pkg.t_tiny_id
  , i_is_notification  in     com_api_type_pkg.t_boolean    default null
  , i_document_type    in     com_api_type_pkg.t_dict_value default null
) is
    l_count    com_api_type_pkg.t_count := 0;
begin

    update rpt_report_vw
    set data_source      = i_source
      , source_type      = i_source_type
      , inst_id          = i_inst_id
      , seqnum           = io_seqnum
      , is_deterministic = i_is_deterministic
      , name_format_id   = i_name_format_id
      , is_notification  = coalesce(i_is_notification, is_notification, 0)
      , document_type    = i_document_type
    where id = i_report_id;
    
    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name   =>  'RPT_REPORT'
      , i_column_name  =>  'LABEL'
      , i_object_id    =>  i_report_id
      , i_text         =>  i_report_name
      , i_lang         =>  i_lang
--      , i_check_unique =>  com_api_type_pkg.FALSE
    );
    
    select count(1)
      into l_count
      from com_i18n_vw i
         , rpt_report_vw r
     where i.table_name  = upper('RPT_REPORT')
       and i.column_name = upper('LABEL')
       and i.text        = i_report_name
       and i.object_id  != i_report_id
       and r.id          = i.object_id
       and r.inst_id     = i_inst_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_DESCRIPTION'
          , i_env_param1  => upper('rpt_report')
          , i_env_param2  => upper('name')
          , i_env_param3  => i_report_name
        );
    end if;

    com_api_i18n_pkg.add_text(
        i_table_name   =>  'RPT_REPORT'
      , i_column_name  =>  'DESCRIPTION'
      , i_object_id    =>  i_report_id
      , i_text         =>  i_report_desc
      , i_lang         =>  i_lang
    );

  /*  rpt_ui_parameter_pkg.sync_parameters(
        i_report_id    =>  i_report_id
    );*/
end;

procedure remove_report(
    i_report_id  in      com_api_type_pkg.t_short_id
  , i_seqnum     in      com_api_type_pkg.t_seqnum
) is
--l_count  com_api_type_pkg.t_short_id;
begin

    update rpt_report_vw
    set seqnum = i_seqnum
    where id = i_report_id;

    delete from rpt_report_vw
    where id = i_report_id;

    com_api_i18n_pkg.remove_text(
        i_table_name  =>  'RPT_REPORT'
      , i_object_id   =>  i_report_id
    );
    
    for rec in (
         select id from rpt_parameter where report_id = i_report_id
    ) loop
        rpt_ui_parameter_pkg.remove_parameter(rec.id);
    end loop;

    for rec in (
         select id, seqnum from rpt_template where report_id = i_report_id
    ) loop
        rpt_ui_template_pkg.remove_template(rec.id, rec.seqnum);
    end loop;
    
    for rec in (
         select tag_id from rpt_report_tag where report_id = i_report_id
    ) loop
        rpt_ui_tag_pkg.remove_report_tag(rec.tag_id, i_report_id);
    end loop;
    
    for rec in (
         select id from acm_role_report_vw where object_id = i_report_id
    ) loop
        acm_ui_role_pkg.remove_role_rpt(rec.id);
    end loop;    
    
end;

function get_report_tag(
    i_report_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name is
begin
    for rec in (
        select
            stragg(get_text(
                       i_table_name  => 'rpt_tag'
                     , i_column_name => 'label'
                     , i_object_id   => a.tag_id
                     , i_lang        => get_user_lang
            ) ) as tags
        from
            rpt_report_tag a
        where
            a.report_id = i_report_id)
    loop
        return rec.tags;
    end loop;

    return '';

end;

procedure add_report_object(
    o_report_object_id    out  com_api_type_pkg.t_short_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_report_id        in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_type      in      com_api_type_pkg.t_dict_value
) is
begin

    o_report_object_id := rpt_report_object_seq.nextval;
    o_seqnum    := 1;

    insert into rpt_report_object_vw(
        id
      , seqnum
      , report_id
      , entity_type
      , object_type
    ) values(
        o_report_object_id
      , o_seqnum
      , i_report_id
      , i_entity_type
      , i_object_type
    );

end;

procedure modify_report_object(
    i_report_object_id in     com_api_type_pkg.t_short_id
  , io_seqnum          in out com_api_type_pkg.t_seqnum
  , i_report_id        in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_type      in      com_api_type_pkg.t_dict_value
) is
begin

    update rpt_report_object_vw
    set report_id        = i_report_id
      , entity_type      = i_entity_type
      , object_type      = i_object_type
      , seqnum           = io_seqnum
    where id = i_report_object_id;
    
    io_seqnum := io_seqnum + 1;

end;

procedure remove_report_object(
    i_report_object_id in      com_api_type_pkg.t_short_id
  , i_seqnum           in      com_api_type_pkg.t_seqnum
) is
begin

    update rpt_report_object_vw
       set seqnum = i_seqnum
     where id = i_report_object_id;

    delete from rpt_report_object_vw
     where id = i_report_object_id;

end;

end;
/
