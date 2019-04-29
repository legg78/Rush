create or replace package cst_bof_gim_prc_outgoing_pkg as

procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_host_inst_id          in com_api_type_pkg.t_inst_id
  , i_start_date            in date
  , i_end_date              in date
  , i_include_affiliate     in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_charset               in com_api_type_pkg.t_oracle_name   default null
);

end;
/
