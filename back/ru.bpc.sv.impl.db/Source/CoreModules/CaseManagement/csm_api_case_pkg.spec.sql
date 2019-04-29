create or replace package csm_api_case_pkg as
/*********************************************************
 *  Case management API  <br />
 *  Renamed csm_api_dispute_pkg (Created by Kondratyev A.(kondratyev@bpcbt.com)  at 29.11.2016 <br />)
 *  Module: csm_api_case_pkg <br />
 *  @headcom
 **********************************************************/

procedure add_case(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_seqnum                  in     com_api_type_pkg.t_seqnum
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_merchant_name           in     com_api_type_pkg.t_name
  , i_customer_number         in     com_api_type_pkg.t_name
  , i_dispute_reason          in     com_api_type_pkg.t_dict_value
  , i_oper_date               in     date
  , i_oper_amount             in     com_api_type_pkg.t_money
  , i_oper_currency           in     com_api_type_pkg.t_curr_code
  , i_dispute_id              in     com_api_type_pkg.t_long_id
  , i_dispute_progress        in     com_api_type_pkg.t_dict_value
  , i_write_off_amount        in     com_api_type_pkg.t_money
  , i_write_off_currency      in     com_api_type_pkg.t_curr_code
  , i_due_date                in     date
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_disputed_amount         in     com_api_type_pkg.t_money
  , i_disputed_currency       in     com_api_type_pkg.t_curr_code
  , i_created_date            in     date
  , i_created_by_user_id      in     com_api_type_pkg.t_short_id
  , i_arn                     in     com_api_type_pkg.t_card_number
  , i_claim_id                in     com_api_type_pkg.t_long_id       default null
  , i_auth_code               in     com_api_type_pkg.t_auth_code
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_acquirer_inst_bin       in     com_api_type_pkg.t_cmid
  , i_transaction_code        in     com_api_type_pkg.t_cmid
  , i_case_source             in     com_api_type_pkg.t_dict_value
  , i_sttl_amount             in     com_api_type_pkg.t_money
  , i_sttl_currency           in     com_api_type_pkg.t_curr_code
  , i_base_amount             in     com_api_type_pkg.t_money
  , i_base_currency           in     com_api_type_pkg.t_curr_code
  , i_hide_date               in     date
  , i_unhide_date             in     date
  , i_team_id                 in     com_api_type_pkg.t_tiny_id
  , i_card_number             in     com_api_type_pkg.t_card_number
  , i_original_id             in     com_api_type_pkg.t_long_id
  , i_network_id              in     com_api_type_pkg.t_network_id    default null
  , i_ext_claim_id            in     com_api_type_pkg.t_attr_name     default null
  , i_ext_clearing_trans_id   in     com_api_type_pkg.t_name          default null
  , i_ext_auth_trans_id       in     com_api_type_pkg.t_name          default null
);

-- Add case
procedure add (
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_card_number             in     com_api_type_pkg.t_card_number     
  , i_merchant_number         in     com_api_type_pkg.t_merchant_number 
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_original_id             in     com_api_type_pkg.t_long_id
  , i_dispute_id              in     com_api_type_pkg.t_long_id
  , i_dispute_amount          in     com_api_type_pkg.t_money         default null
  , i_dispute_currency        in     com_api_type_pkg.t_curr_code     default null
);

function get_flow_id(
    i_sttl_type     in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_tiny_id;

function get_flow_id(
    i_operation_id  in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id;

function get_card_category(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_tiny_id;  -- Return 1 - Visa, 2 - MasterCard, 3 - Maestro, else return null.

function check_due_date(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value    default null
  , i_is_manual               in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return date;

function get_reason_lov_id(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_case_progress           in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_tiny_id;

procedure get_case_by_operation(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_case_source             in     com_api_type_pkg.t_dict_value    default null
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , o_case_id                    out com_api_type_pkg.t_long_id
  , o_seqnum                     out com_api_type_pkg.t_tiny_id
);

procedure change_case_status(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , i_reason_code             in     com_api_type_pkg.t_dict_value
);

procedure set_due_date(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_due_date                in     date
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
);

procedure get_case(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , o_case_rec                   out csm_api_type_pkg.t_csm_case_rec
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure get_case(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , o_case_rec                   out csm_api_type_pkg.t_csm_case_rec
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure change_case_progress(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure change_case_progress(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

function get_progress_lov_id(
    i_case_id                 in     com_api_type_pkg.t_long_id       default null
  , i_flow_id                 in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_tiny_id;

procedure add_history(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_action                  in     com_api_type_pkg.t_name
  , i_event_type              in     com_api_type_pkg.t_dict_value   default null
  , i_new_appl_status         in     com_api_type_pkg.t_dict_value
  , i_old_appl_status         in     com_api_type_pkg.t_dict_value
  , i_new_reject_code         in     com_api_type_pkg.t_dict_value
  , i_old_reject_code         in     com_api_type_pkg.t_dict_value
  , i_env_param1              in     com_api_type_pkg.t_name         default null
  , i_env_param2              in     com_api_type_pkg.t_name         default null
  , i_env_param3              in     com_api_type_pkg.t_name         default null
  , i_env_param4              in     com_api_type_pkg.t_name         default null
  , i_mask_error              in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
);

end csm_api_case_pkg;
/
