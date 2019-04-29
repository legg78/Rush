create or replace package bgn_api_fin_pkg as

function put_message (
    i_fin_rec       in              bgn_api_type_pkg.t_bgn_fin_rec
) return com_api_type_pkg.t_long_id;

procedure put_file_rec (
    i_file_rec      in              bgn_api_type_pkg.t_bgn_file_rec             
);

procedure put_package_rec (
    io_package_rec  in out nocopy   bgn_api_type_pkg.t_bgn_package_rec
);

procedure put_retrieval_rec (
    io_retrieval_rec in out nocopy  bgn_api_type_pkg.t_bgn_retrieval_rec
); 

function get_original_file_id (
    i_retrieval_rec in              bgn_api_type_pkg.t_bgn_retrieval_rec
  , i_file_type     in              com_api_type_pkg.t_dict_value  
  , i_mask_error    in              com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

function get_original_fin_id (
    i_retrieval_rec in              bgn_api_type_pkg.t_bgn_retrieval_rec
  , i_mask_error    in              com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

procedure find_original_id (
    io_retrieval_rec    in out nocopy   bgn_api_type_pkg.t_bgn_retrieval_rec
  , i_mask_error        in              com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE  
); 

procedure get_fin (
    i_id            in com_api_type_pkg.t_long_id
  , i_oper_id       in com_api_type_pkg.t_long_id := null
  , i_is_incoming   in com_api_type_pkg.t_boolean
  , o_fin_rec       out bgn_api_type_pkg.t_bgn_fin_rec
  , i_mask_error    in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
);

procedure fin_to_oper(
    io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
  , io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_file_code         in              com_api_type_pkg.t_dict_value
);

function get_original_for_reversal(
    io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , i_refnum            in  com_api_type_pkg.t_rrn  
  , i_card_number       in  com_api_type_pkg.t_card_number  
  , i_mask_error        in  com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

procedure match_usonus(
    io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
);

procedure create_from_oper (
    i_oper_rec          in opr_api_type_pkg.t_oper_rec
  , i_iss_rec           in opr_api_type_pkg.t_oper_part_rec
  , i_asq_rec           in opr_api_type_pkg.t_oper_part_rec  
  , i_id                in com_api_type_pkg.t_long_id
  , i_inst_id           in com_api_type_pkg.t_inst_id := null
  , i_network_id        in com_api_type_pkg.t_tiny_id := null
);

procedure create_operation (
    i_oper                  in opr_api_type_pkg.t_oper_rec
    , i_iss_part            in opr_api_type_pkg.t_oper_part_rec
    , i_acq_part            in opr_api_type_pkg.t_oper_part_rec
);

procedure enum_messages_for_upload (
    o_fin_cur                  out  sys_refcursor
  , i_network_id            in      com_api_type_pkg.t_network_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_host_inst_id          in      com_api_type_pkg.t_inst_id
);

function estimate_messages_for_upload (
    i_network_id            in      com_api_type_pkg.t_network_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_host_inst_id          in      com_api_type_pkg.t_inst_id
) return number; 

function get_borica_code (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_network_id            in      com_api_type_pkg.t_network_id  default bgn_api_const_pkg.BORICA_NETWORK_ID
) return com_api_type_pkg.t_dict_value;

end bgn_api_fin_pkg;
/
 