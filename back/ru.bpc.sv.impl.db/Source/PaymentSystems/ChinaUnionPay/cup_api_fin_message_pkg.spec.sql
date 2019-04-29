create or replace package cup_api_fin_message_pkg as

function put_message (
    i_fin_rec               in     cup_api_type_pkg.t_cup_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure create_operation (
    i_oper                  in     opr_api_type_pkg.t_oper_rec
    , i_iss_part            in     opr_api_type_pkg.t_oper_part_rec
    , i_acq_part            in     opr_api_type_pkg.t_oper_part_rec
);

procedure process_auth (
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
    , i_inst_id             in     com_api_type_pkg.t_inst_id default null
    , i_network_id          in     com_api_type_pkg.t_tiny_id default null
    , i_status              in     com_api_type_pkg.t_dict_value default null
    , io_fin_mess_id        in out com_api_type_pkg.t_long_id
);

function estimate_messages_for_upload (
    i_network_id            in     com_api_type_pkg.t_tiny_id
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_host_inst_id        in     com_api_type_pkg.t_inst_id
) return number;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in     com_api_type_pkg.t_tiny_id
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_host_inst_id        in     com_api_type_pkg.t_inst_id
);

procedure put_fee (
    i_fee_rec               in     cup_api_type_pkg.t_cup_fee_rec
);

procedure put_audit_trailer (
    i_cup_audit_rec         in     cup_api_type_pkg.t_cup_audit_rec
);

procedure create_fee_oper_stage(
    i_match_status          in     com_api_type_pkg.t_dict_value
  , i_fin_msg_id            in     com_api_type_pkg.t_long_id
  , i_fee_type              in     com_api_type_pkg.t_dict_value
);

function is_cup(
    i_id                    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function get_original_id(
    i_fin_rec               in     cup_api_type_pkg.t_cup_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure get_fin_mes(
    i_id                    in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out cup_api_type_pkg.t_cup_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

end cup_api_fin_message_pkg;
/
