create or replace package cst_bmed_csc_incoming_pkg as

procedure process (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id default null
);

end;
/