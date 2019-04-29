create or replace package amx_prc_outgoing_pkg as

procedure process (
    i_network_id            in     com_api_type_pkg.t_tiny_id    default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_collection_only       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_amx_action_code       in     com_api_type_pkg.t_curr_code  default null 
  , i_start_date            in     date                          default null
  , i_end_date              in     date                          default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_apn                   in     com_api_type_pkg.t_cmid       default null
);

procedure process_ack (
    i_network_id            in     com_api_type_pkg.t_tiny_id    default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_amx_action_code       in     com_api_type_pkg.t_curr_code  default null 
);

end;
/

