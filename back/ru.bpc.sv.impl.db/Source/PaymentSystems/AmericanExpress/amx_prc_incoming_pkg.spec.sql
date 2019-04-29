create or replace package amx_prc_incoming_pkg as

procedure process (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_amx_action_code       in     com_api_type_pkg.t_curr_code  default null -- possible value 'TEST' for test processing
  , i_create_operation      in     com_api_type_pkg.t_boolean    := null
);

function get_message_impact(   
    i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_func_code             in     com_api_type_pkg.t_curr_code
  , i_proc_code             in     com_api_type_pkg.t_auth_code 
  , i_incoming              in     com_api_type_pkg.t_boolean
  , i_raise_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_sign;

end;
/
