create or replace package body rpt_ui_tag_pkg as
/*******************************************************************
*  UI for report tags <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 16.12.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: rpt_ui_tag_pkg <br />
*  @headcom
******************************************************************/

procedure add_tag(
    o_id              out com_api_type_pkg.t_tiny_id
  , o_seqnum          out com_api_type_pkg.t_seqnum
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_label        in     com_api_type_pkg.t_name
  , i_description  in     com_api_type_pkg.t_text
  , i_lang         in     com_api_type_pkg.t_dict_value
) is
begin
    o_id := rpt_tag_seq.nextval;
    o_seqnum := 1;

    insert into rpt_tag_vw(
        id
      , seqnum
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rpt_tag'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name  => 'rpt_tag'
      , i_column_name => 'description'
      , i_object_id   => o_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

end add_tag;

procedure modify_tag(
    i_id           in     com_api_type_pkg.t_tiny_id
  , io_seqnum      in out com_api_type_pkg.t_seqnum
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_label        in     com_api_type_pkg.t_name
  , i_description  in     com_api_type_pkg.t_text
  , i_lang         in     com_api_type_pkg.t_dict_value
) is
begin
    update rpt_tag_vw a
       set a.inst_id = i_inst_id
         , a.seqnum  = io_seqnum
     where a.id      = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rpt_tag'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rpt_tag'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;

procedure remove_tag(
    i_id      in     com_api_type_pkg.t_tiny_id
  , i_seqnum  in     com_api_type_pkg.t_seqnum
) is
    l_report_id   com_api_type_pkg.t_short_id;
begin
    select min(report_id)
      into l_report_id
      from rpt_report_tag_vw
     where tag_id = i_id;
     
    if l_report_id is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'REPORT_TAG_ALREADY_USED'
          , i_env_param1 => i_id
          , i_env_param2 => l_report_id
        );
    end if;

    update rpt_tag_vw a
       set a.seqnum = i_seqnum
     where a.id     = i_id;

    delete rpt_tag_vw a
     where a.id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'rpt_tag'
      , i_object_id  => i_id
    );
end;

procedure add_report_tag(
    i_tag_id              in     com_api_type_pkg.t_tiny_id
  , i_report_id           in     com_api_type_pkg.t_short_id
) is
begin
    insert into rpt_report_tag_vw(
        report_id
      , tag_id
    ) values (
        i_report_id
      , i_tag_id
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'REPORT_TAG_ALREADY_EXIST'
          , i_env_param1 => i_report_id
          , i_env_param2 => i_tag_id
        );
end;

procedure remove_report_tag(
    i_tag_id              in     com_api_type_pkg.t_tiny_id
  , i_report_id           in     com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select tag_id
             , report_id
          from rpt_report_tag_vw a
         where a.report_id = i_report_id
           and a.tag_id    = i_tag_id
    ) loop
        delete rpt_report_tag_vw a
         where a.report_id = rec.report_id
           and a.tag_id    = rec.tag_id;
    end loop;
end;

end;
/
