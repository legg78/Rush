create or replace package cst_mpu_prc_outgoing_pkg as

procedure unload_clearing(
    i_network_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id  default null
);

end cst_mpu_prc_outgoing_pkg;
/
