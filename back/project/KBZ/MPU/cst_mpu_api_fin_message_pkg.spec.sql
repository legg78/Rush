create or replace package cst_mpu_api_fin_message_pkg as

function put_message (
    i_fin_rec        in     cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure create_operation (
    i_oper           in     opr_api_type_pkg.t_oper_rec
  , i_iss_part       in     opr_api_type_pkg.t_oper_part_rec
  , i_acq_part       in     opr_api_type_pkg.t_oper_part_rec
);

procedure process_auth (
    i_auth_rec       in     aut_api_type_pkg.t_auth_rec
  , i_inst_id        in     com_api_type_pkg.t_inst_id default null
  , i_network_id     in     com_api_type_pkg.t_tiny_id default null
  , i_status         in     com_api_type_pkg.t_dict_value default null
  , io_fin_mess_id   in out com_api_type_pkg.t_long_id
);

function estimate_messages_for_upload (
    i_network_id     in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
) return number;

procedure enum_messages_for_upload (
    o_fin_cur        in out sys_refcursor
  , i_network_id     in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
);

procedure load_auth(
    i_id             in            com_api_type_pkg.t_long_id
  , io_auth          in out nocopy aut_api_type_pkg.t_auth_rec
);

procedure put_fund_stat(
    i_fund_stat      in     cst_mpu_api_type_pkg.t_mpu_fund_sttl_rec
);

procedure put_volume_stat(
    i_volume_stat    in      cst_mpu_api_type_pkg.t_mpu_volume_stat_rec
);
    
procedure put_merchant_settlement(
    i_merchant_sttl  in      cst_mpu_api_type_pkg.t_mpu_mrch_settlement_rec
);

end cst_mpu_api_fin_message_pkg;
/
