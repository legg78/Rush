create or replace package cup_prc_outgoing_pkg as

procedure unload_clearing(
    i_network_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id  default null
  , i_host_inst_id         in     com_api_type_pkg.t_inst_id  default null
  , i_action_code          in     varchar2                    default null
  , i_include_affiliate    in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
);

end;
/
