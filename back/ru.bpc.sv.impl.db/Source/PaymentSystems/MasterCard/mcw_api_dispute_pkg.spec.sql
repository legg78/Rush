create or replace package mcw_api_dispute_pkg is
/********************************************************* 
 *  MasterCard dispute API  <br /> 
 *  Created by Kopachev (kopachev@bpcbt.com)  at 11.04.2013 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2015-10-20 18:05:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 59935 $ <br /> 
 *  Module: mcw_api_dispute_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

e_need_original_record exception;

function get_fin_id(
    i_original_id       in      com_api_type_pkg.t_long_id
  , i_mti               in      mcw_api_type_pkg.t_mti        default null
  , i_de024             in      mcw_api_type_pkg.t_de024      default null
  , i_is_incoming       in      com_api_type_pkg.t_boolean    default null
  , i_is_reversal       in      com_api_type_pkg.t_boolean    default null
  , i_mask_error        in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;
    
procedure check_dispute_status(
    i_id                in      com_api_type_pkg.t_long_id
);
    
procedure update_oper_amount(
    i_id                in      com_api_type_pkg.t_long_id
  , i_oper_amount       in      com_api_type_pkg.t_money
  , i_oper_currency     in      com_api_type_pkg.t_curr_code
  , i_raise_error       in      com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
);
    
procedure gen_member_fee (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_network_id        in     com_api_type_pkg.t_tiny_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de003             in     mcw_api_type_pkg.t_de003
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
  , i_de093             in     mcw_api_type_pkg.t_de093
  , i_de094             in     mcw_api_type_pkg.t_de094
  , i_de002             in     mcw_api_type_pkg.t_de002
  , i_original_fin_id   in     com_api_type_pkg.t_long_id        default null
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);

procedure gen_retrieval_fee (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004          default null
  , i_de030_1           in     mcw_api_type_pkg.t_de030s         default null
  , i_de049             in     mcw_api_type_pkg.t_de049          default null
  , i_de072             in     mcw_api_type_pkg.t_de072          default null
  , i_p0149_1           in     mcw_api_type_pkg.t_p0149_1        default null
  , i_p0149_2           in     mcw_api_type_pkg.t_p0149_2        default null
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);

procedure gen_retrieval_request (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0228             in     mcw_api_type_pkg.t_p0228
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);

procedure update_dispute_id (
    i_id                in     com_api_type_pkg.t_long_id
  , i_dispute_id        in     com_api_type_pkg.t_long_id
);

procedure fetch_dispute_id (
    i_fin_cur           in     sys_refcursor
  , o_fin_rec              out mcw_api_type_pkg.t_fin_rec
);

procedure sync_dispute_id (
    io_fin_rec          in out nocopy mcw_api_type_pkg.t_fin_rec
  , o_dispute_id           out        com_api_type_pkg.t_long_id
  , o_dispute_rn           out        com_api_type_pkg.t_long_id
);

procedure assign_dispute_id (
    io_fin_rec          in out nocopy mcw_api_type_pkg.t_fin_rec
  , o_auth                 out        aut_api_type_pkg.t_auth_rec
  , i_need_repeat       in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
);

procedure assign_dispute_id (
    io_fin_rec          in out nocopy mcw_api_type_pkg.t_fin_rec
);

procedure gen_chargeback_fee (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
  , o_fin_id               out com_api_type_pkg.t_long_id
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id    default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id  default null
);

procedure gen_second_presentment_fee (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
  , o_fin_id               out com_api_type_pkg.t_long_id
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id    default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id  default null
);

procedure gen_fee_return (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
  , o_fin_id               out com_api_type_pkg.t_long_id
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null

);

procedure gen_fee_resubmition (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
  , o_fin_id               out com_api_type_pkg.t_long_id
 	, i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id    default null
 	, i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id  default null
);

procedure gen_fee_second_return (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
  , o_fin_id               out com_api_type_pkg.t_long_id
 	, i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id    default null
 	, i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id  default null
);

procedure gen_fraud(
    i_original_fin_id  in     com_api_type_pkg.t_long_id
  , i_c01              in     com_api_type_pkg.t_dict_value     default null
  , i_c02              in     com_api_type_pkg.t_name           default null
  , i_c04              in     com_api_type_pkg.t_name           default null
  , i_c14              in     com_api_type_pkg.t_name           default null
  , i_c15              in     com_api_type_pkg.t_name           default null
  , i_c28              in     com_api_type_pkg.t_dict_value     default null
  , i_c29              in     com_api_type_pkg.t_dict_value     default null
  , i_c30              in     com_api_type_pkg.t_dict_value     default null
  , i_c31              in     com_api_type_pkg.t_dict_value     default null
  , i_c44              in     com_api_type_pkg.t_dict_value     default null
  , i_ext_claim_id     in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id   in     mcw_api_type_pkg.t_ext_message_id default null
);

procedure load_auth (
    i_id                in            com_api_type_pkg.t_long_id
  , io_auth             in out nocopy aut_api_type_pkg.t_auth_rec
);

procedure gen_retrieval_request_acknowl (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);

/*
 * Try to calculate dispute due date by the reference table DSP_DUE_DATE_LIMIT
 * and set value of application element DUE_DATE and a new cycle counter (for notification).
 */
procedure update_due_date(
    i_fin_rec           in     mcw_api_type_pkg.t_fin_rec
  , i_standard_id       in     com_api_type_pkg.t_tiny_id
  , i_msg_type          in     com_api_type_pkg.t_dict_value
  , i_is_incoming       in     com_api_type_pkg.t_boolean
  , i_create_disp_case  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

function has_dispute_msg(
    i_id                in     com_api_type_pkg.t_long_id
  , i_mti               in     mcw_api_type_pkg.t_mti
  , i_de024_1           in     mcw_api_type_pkg.t_de024
  , i_de024_2           in     mcw_api_type_pkg.t_de024         default null
  , i_reversal          in     com_api_type_pkg.t_boolean       default null
  , i_is_uploaded       in     com_api_type_pkg.t_boolean       default null
) return com_api_type_pkg.t_boolean;
    
procedure change_case_status(
    i_dispute_id        in     com_api_type_pkg.t_long_id
  , i_mti               in     mcw_api_type_pkg.t_mti
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_is_reversal       in     com_api_type_pkg.t_boolean
  , i_reason_code       in     com_api_type_pkg.t_dict_value
  , i_msg_status        in     com_api_type_pkg.t_dict_value
  , i_msg_type          in     com_api_type_pkg.t_dict_value
);

procedure modify_member_fee(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_network_id        in     com_api_type_pkg.t_network_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de003             in     mcw_api_type_pkg.t_de003
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
  , i_de093             in     mcw_api_type_pkg.t_de093
  , i_de094             in     mcw_api_type_pkg.t_de094
  , i_de002             in     mcw_api_type_pkg.t_de002
);

procedure modify_retrieval_fee(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
);

procedure modify_retrieval_request(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0228             in     mcw_api_type_pkg.t_p0228
);

procedure modify_first_pres_reversal(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
);

procedure modify_chargeback_fee(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
);

procedure modify_second_presentment_fee(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
);

procedure modify_fee_return(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
);

procedure modify_fee_resubmition (
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
);

procedure modify_fee_second_return (
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_de073             in     mcw_api_type_pkg.t_de073
);

procedure modify_fraud(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_c01               in     com_api_type_pkg.t_dict_value
  , i_c02               in     com_api_type_pkg.t_medium_id
  , i_c04               in     com_api_type_pkg.t_medium_id
  , i_c14               in     mcw_api_type_pkg.t_de004
  , i_c15               in     mcw_api_type_pkg.t_de049
  , i_c28               in     com_api_type_pkg.t_dict_value
  , i_c29               in     com_api_type_pkg.t_dict_value
  , i_c30               in     com_api_type_pkg.t_dict_value
  , i_c31               in     com_api_type_pkg.t_dict_value
  , i_c44               in     com_api_type_pkg.t_dict_value
);

end mcw_api_dispute_pkg;
/
