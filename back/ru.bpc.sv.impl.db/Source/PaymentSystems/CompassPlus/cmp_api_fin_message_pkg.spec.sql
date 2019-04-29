create or replace package cmp_api_fin_message_pkg as

function put_message (
    i_fin_rec               in cmp_api_type_pkg.t_cmp_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure create_operation (
    i_oper                  in opr_api_type_pkg.t_oper_rec
    , i_iss_part            in opr_api_type_pkg.t_oper_part_rec
    , i_acq_part            in opr_api_type_pkg.t_oper_part_rec
);

procedure create_operation (
    i_fin_rec               in cmp_api_type_pkg.t_cmp_fin_mes_rec
    , i_standard_id         in com_api_type_pkg.t_tiny_id
);

procedure process_auth (
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
    , i_inst_id             in com_api_type_pkg.t_inst_id default null
    , i_network_id          in com_api_type_pkg.t_tiny_id default null
    , i_collect_only        in com_api_type_pkg.t_boolean default null
    , i_status              in com_api_type_pkg.t_dict_value default null
    , io_fin_mess_id        in out com_api_type_pkg.t_long_id
);

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_collect_only        in com_api_type_pkg.t_dict_value
) return number;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_collect_only        in com_api_type_pkg.t_dict_value
);

end;
/
