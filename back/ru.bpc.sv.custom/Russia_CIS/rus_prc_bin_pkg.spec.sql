create or replace package rus_prc_bin_pkg is

procedure load_bin(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_priority            in     com_api_type_pkg.t_tiny_id
  , i_card_network_id     in     com_api_type_pkg.t_tiny_id
  , i_found_bin_priority  in     com_api_type_pkg.t_tiny_id
);

end rus_prc_bin_pkg;
/
