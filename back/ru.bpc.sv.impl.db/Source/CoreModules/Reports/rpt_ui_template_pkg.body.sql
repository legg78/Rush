create or replace package body rpt_ui_template_pkg as

procedure add_template(
    o_id                   out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_report_id         in      com_api_type_pkg.t_short_id
  , i_template_lang     in      com_api_type_pkg.t_dict_value
  , i_text              in      clob
  , i_base64            in      clob
  , i_report_processor  in      com_api_type_pkg.t_dict_value
  , i_report_format     in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) is
begin
    select rpt_template_seq.nextval
         , 1
    into   o_id
         , o_seqnum
    from dual;

    insert into rpt_template_vw(
        id
      , seqnum
      , report_id
      , lang
      , text
      , base64
      , report_processor
      , report_format
    ) values(
        o_id
      , o_seqnum
      , i_report_id
      , i_template_lang
      , i_text
      , i_base64
      , i_report_processor
      , i_report_format
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_TEMPLATE'
      , i_column_name  => 'LABEL'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_TEMPLATE'
      , i_column_name  => 'DESCRIPTION'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );

end;

procedure modify_template(
    i_id                in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_report_id         in      com_api_type_pkg.t_short_id
  , i_template_lang     in      com_api_type_pkg.t_dict_value
  , i_text              in      clob
  , i_base64            in      clob
  , i_report_processor  in      com_api_type_pkg.t_dict_value
  , i_report_format     in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update rpt_template_vw
    set    seqnum           = io_seqnum
         , report_id        = i_report_id
         , lang    = i_template_lang
         , text             = i_text
         , base64           = i_base64
         , report_processor = i_report_processor
         , report_format    = i_report_format
    where  id = i_id;

    io_seqnum := io_seqnum + 1;

     com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_TEMPLATE'
      , i_column_name  => 'LABEL'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_TEMPLATE'
      , i_column_name  => 'DESCRIPTION'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;

procedure remove_template(
    i_id      in     com_api_type_pkg.t_short_id
  , i_seqnum  in     com_api_type_pkg.t_tiny_id
) is
begin
    update rpt_template_vw
       set seqnum  = i_seqnum
     where id      = i_id;

    delete rpt_template_vw
     where id      = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name  => 'RPT_TEMPLATE'
      , i_object_id   => i_id
    );

end;

end;
/
