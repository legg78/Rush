create or replace package cmp_prc_incoming_pkg as

procedure process (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_action_code         in com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id default null
);

end;
/
 