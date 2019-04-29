create or replace package nbc_prc_outgoing_pkg as

procedure process_rf (
    i_network_id             in com_api_type_pkg.t_tiny_id default null
    , i_inst_id              in com_api_type_pkg.t_inst_id default null
);

procedure process_df (
    i_network_id             in com_api_type_pkg.t_tiny_id default null
    , i_inst_id              in com_api_type_pkg.t_inst_id default null
);

end;
/
