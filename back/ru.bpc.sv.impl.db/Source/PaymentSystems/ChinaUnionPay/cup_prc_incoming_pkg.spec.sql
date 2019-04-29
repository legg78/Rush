create or replace package cup_prc_incoming_pkg as

procedure load_clearing(
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
);

procedure load_interchange_fee(
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
);

procedure load_dispute(
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
  , i_create_operation      in     com_api_type_pkg.t_boolean   default null
);

procedure load_audit_trailer(
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
);

procedure load_fee_collection(
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
  , i_create_operation      in     com_api_type_pkg.t_boolean   default null
);

/*
procedure process(
    i_cup_load_type in com_api_type_pkg.t_dict_value
  , i_issuer in com_api_type_pkg.t_boolean
  , i_timeout in com_api_type_pkg.t_long_id
);
*/

end;
/
