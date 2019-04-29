CREATE OR REPLACE package trc_dbms_output_pkg as

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_section           in      com_api_type_pkg.t_full_desc
  , i_user              in      com_api_type_pkg.t_oracle_name
  , i_text              in      com_api_type_pkg.t_text
);

end;
/
