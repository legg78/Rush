create or replace package bgn_qo_pkg as

procedure process_string(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , o_is_invalid           out          com_api_type_pkg.t_boolean
);

procedure export_line(
    io_line             in out nocopy   com_api_type_pkg.t_raw_data
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_host_inst_id      in              com_api_type_pkg.t_inst_id
  , i_is_file_trail     in              com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

end bgn_qo_pkg;
/
 