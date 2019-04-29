create or replace package cst_icc_api_report_pkg as

procedure cup_audit_trailer_unmatched(
    o_xml                     out  clob
  , i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_lang                     in  com_api_type_pkg.t_dict_value   default null
  , i_audit_trailer_file_id    in  com_api_type_pkg.t_long_id      default null
  , i_start_date               in  date                            default null
  , i_end_date                 in  date                            default null
);

end cst_icc_api_report_pkg;
/
