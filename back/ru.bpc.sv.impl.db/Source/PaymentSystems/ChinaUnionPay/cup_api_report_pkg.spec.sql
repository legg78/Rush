create or replace package cup_api_report_pkg as

procedure audit_trailer_data_matching(
    o_xml                     out  clob
  , i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_lang                     in  com_api_type_pkg.t_dict_value   default null
  , i_audit_trailer_file_id    in  com_api_type_pkg.t_long_id      default null
  , i_start_date               in  date                            default null
  , i_end_date                 in  date                            default null
  , i_match_status             in  com_api_type_pkg.t_dict_value
);

end cup_api_report_pkg;
/
