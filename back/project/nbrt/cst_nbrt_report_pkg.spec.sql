create or replace package cst_nbrt_report_pkg as

procedure monthly_report(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_start_date        in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

procedure detailed_report(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_start_date        in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

end;
/
