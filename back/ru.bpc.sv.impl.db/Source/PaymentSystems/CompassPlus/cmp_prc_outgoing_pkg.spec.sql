create or replace package cmp_prc_outgoing_pkg as

procedure process (
    i_network_id             in com_api_type_pkg.t_tiny_id default null
    , i_inst_id              in com_api_type_pkg.t_inst_id default null
    , i_host_inst_id         in com_api_type_pkg.t_inst_id default null
    , i_action_code          in varchar2 default null
    , i_collect_only_upload_type in com_api_type_pkg.t_dict_value default null
);

end;
/
