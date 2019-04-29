create or replace package cst_ui_nbrt_bin_range_pkg as

procedure add_nbrt_bin_range(
    o_nbrt_bin_range_id    out  com_api_type_pkg.t_short_id
  , i_pan_low           in      com_api_type_pkg.t_bin
  , i_pan_high          in      com_api_type_pkg.t_bin
  , i_pan_length        in      com_api_type_pkg.t_tiny_id
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_country           in      com_api_type_pkg.t_country_code
  , i_iss_network_id    in      com_api_type_pkg.t_network_id
  , i_label             in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
);

procedure modify_nbrt_bin_range(
    i_nbrt_bin_range_id in      com_api_type_pkg.t_short_id
  , i_label             in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_pan_low           in      com_api_type_pkg.t_bin
  , i_pan_high          in      com_api_type_pkg.t_bin
  , i_pan_length        in      com_api_type_pkg.t_tiny_id
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_country           in      com_api_type_pkg.t_country_code
  , i_iss_network_id    in      com_api_type_pkg.t_network_id
);

procedure remove_nbrt_bin_range(
    i_nbrt_bin_range_id in      com_api_type_pkg.t_short_id
);

end;
/
