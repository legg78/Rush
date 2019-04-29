create or replace package rpt_ui_report_constructor_pkg is

procedure create_constructor (
    o_id              out com_api_type_pkg.t_short_id
  , i_report_name  in     com_api_type_pkg.t_full_desc
  , i_description  in     com_api_type_pkg.t_full_desc default null
  , i_xml_template in     clob
);

procedure update_constructor (
    i_id           in     com_api_type_pkg.t_short_id
  , i_report_name  in     com_api_type_pkg.t_full_desc
  , i_description  in     com_api_type_pkg.t_full_desc default null
  , i_xml_template in     clob
);

procedure delete_constructor (
    i_id           in     com_api_type_pkg.t_short_id
);

end rpt_ui_report_constructor_pkg;
/
