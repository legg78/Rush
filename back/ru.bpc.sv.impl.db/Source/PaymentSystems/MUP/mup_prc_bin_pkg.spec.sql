create or replace package mup_prc_bin_pkg is

procedure load_bin(
    i_inst_id         in    com_api_type_pkg.t_inst_id
  , i_network_id      in    com_api_type_pkg.t_tiny_id
  , i_priority        in    com_api_type_pkg.t_tiny_id
  , i_cleanup_bins    in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

end;
/
