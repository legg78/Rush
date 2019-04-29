create or replace package body rpt_ui_report_constructor_pkg is

procedure create_constructor (
    o_id              out com_api_type_pkg.t_short_id
  , i_report_name  in     com_api_type_pkg.t_full_desc
  , i_description  in     com_api_type_pkg.t_full_desc default null
  , i_xml_template in     clob
) is
begin
    trc_log_pkg.debug(i_text => 'Going to create Report Constructor [' || i_report_name || ']');

    o_id := rpt_report_constructor_seq.nextval;

    insert into rpt_report_constructor_vw (
        id
      , report_name
      , description
      , xml_template)
    values (
        o_id
      , i_report_name
      , i_description
      , i_xml_template
    );

    trc_log_pkg.debug(i_text => 'Report Constructor created with id [' || o_id || ']');
end create_constructor;

procedure update_constructor (
    i_id           in     com_api_type_pkg.t_short_id
  , i_report_name  in     com_api_type_pkg.t_full_desc
  , i_description  in     com_api_type_pkg.t_full_desc default null
  , i_xml_template in     clob
) is
begin
    trc_log_pkg.debug(i_text => 'Going to update Report Constructor [' || i_report_name || ']');

    update rpt_report_constructor_vw
       set report_name  = i_report_name,
           description  = nvl(i_description, description),
           xml_template = i_xml_template
     where id = i_id;

    trc_log_pkg.debug(i_text => 'Report Constructor updated with id [' || i_id || ']');
end update_constructor;

procedure delete_constructor (
    i_id           in     com_api_type_pkg.t_short_id
) is
begin
    trc_log_pkg.debug(i_text => 'Going to delete Report Constructor');

    delete from rpt_report_constructor_vw where id = i_id;

    trc_log_pkg.debug(i_text => 'Report Constructor deleted with id [' || i_id || ']');
end delete_constructor;

end rpt_ui_report_constructor_pkg;
/
