create or replace package trc_session_pkg as

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_text              in      com_api_type_pkg.t_text
);

end;
/
