create or replace package cst_tie_api_fin_pkg is

-- Purpose : TIETO Financial message API
  
function get_msg_impact(
    i_tran_type      in cst_tie_api_type_pkg.t_tran_type
) return com_api_type_pkg.t_sign;

procedure create_from_auth (
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
  , i_oper_rec              in opr_api_type_pkg.t_oper_rec
--  , i_iss_part_rec          in opr_api_type_pkg.t_oper_part_rec
);
/*
procedure create_incoming_first_pres (
    i_mes_fin_rec         in tie_api_type_pkg.t_mes_fin_rec
  , i_mes_chip_rec        in tie_api_type_pkg.t_mes_fin_add_chip_rec
  , i_mes_acq_rec         in tie_api_type_pkg.t_mes_fin_acq_ref_rec
  , i_file_id             in com_api_type_pkg.t_long_id
  , i_network_id          in com_api_type_pkg.t_tiny_id
  , i_host_id             in com_api_type_pkg.t_tiny_id
  , i_standard_id         in com_api_type_pkg.t_tiny_id
);
*/
function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_start_date            in date default null
  , i_end_date              in date default null
  , i_card_network_id       in com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_count;

procedure enum_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_start_date            in date default null
  , i_end_date              in date default null
  , i_card_network_id       in com_api_type_pkg.t_tiny_id default null
  , o_fin_cur              out cst_tie_api_type_pkg.t_fin_cur
);

procedure create_tie_fin_message;

end cst_tie_api_fin_pkg;
/
