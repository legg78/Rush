create or replace package bgn_eo_pkg as

procedure process_string(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , o_is_invalid           out          com_api_type_pkg.t_boolean
);

end bgn_eo_pkg;
/
 