create or replace package csm_ui_dispute_pkg as
/**************************************************
 *  Case dispute application UI API <br />
 *  Created by Truschelev O.(truschelev@bpcbt.com) at 10.03.2017 <br />
 *  Module: CSM_UI_DISPUTE_PKG <br />
 *  @headcom
 ***************************************************/

procedure get_default_manual_application(
    o_appl_id                         out com_api_type_pkg.t_long_id
  , o_created_date                    out date
  , o_created_by_user_id              out com_api_type_pkg.t_short_id
  , o_case_owner                      out com_api_type_pkg.t_short_id
  , o_case_id                         out com_api_type_pkg.t_long_id
  , o_claim_id                        out com_api_type_pkg.t_long_id
  , o_reject_code                     out com_api_type_pkg.t_dict_value
  , o_appl_status                     out com_api_type_pkg.t_dict_value
  , o_is_visible                      out com_api_type_pkg.t_boolean
  , o_team_id                         out com_api_type_pkg.t_tiny_id
);

/*
 * Procedure creates a dispute application (case) for a dispute operation;
 * operation's participant type defines if it will be an issuing dispute case or an acquring one.
 */
procedure create_manual_application(
    io_appl_id                     in out com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_seqnum
  , i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_merchant_name                in     com_api_type_pkg.t_name
  , i_customer_number              in     com_api_type_pkg.t_name
  , i_dispute_reason               in     com_api_type_pkg.t_dict_value
  , i_oper_date                    in     date
  , i_oper_amount                  in     com_api_type_pkg.t_money
  , i_oper_currency                in     com_api_type_pkg.t_curr_code
  , i_dispute_id                   in     com_api_type_pkg.t_long_id
  , i_dispute_progress             in     com_api_type_pkg.t_dict_value
  , i_write_off_amount             in     com_api_type_pkg.t_money
  , i_write_off_currency           in     com_api_type_pkg.t_curr_code
  , i_due_date                     in     date
  , i_reason_code                  in     com_api_type_pkg.t_dict_value
  , i_disputed_amount              in     com_api_type_pkg.t_money
  , i_disputed_currency            in     com_api_type_pkg.t_curr_code
  , i_created_date                 in     date
  , i_created_by_user_id           in     com_api_type_pkg.t_short_id
  , i_arn                          in     com_api_type_pkg.t_card_number
  , i_claim_id                     in     com_api_type_pkg.t_long_id       default null
  , i_auth_code                    in     com_api_type_pkg.t_auth_code
  , i_case_progress                in     com_api_type_pkg.t_dict_value
  , i_acquirer_inst_bin            in     com_api_type_pkg.t_cmid
  , i_transaction_code             in     com_api_type_pkg.t_cmid
  , i_case_source                  in     com_api_type_pkg.t_dict_value
  , i_sttl_amount                  in     com_api_type_pkg.t_money
  , i_sttl_currency                in     com_api_type_pkg.t_curr_code
  , i_base_amount                  in     com_api_type_pkg.t_money
  , i_base_currency                in     com_api_type_pkg.t_curr_code
  , i_hide_date                    in     date
  , i_unhide_date                  in     date
  , i_team_id                      in     com_api_type_pkg.t_tiny_id
  , i_card_number                  in     com_api_type_pkg.t_card_number
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id
  , i_agent_id                     in     com_api_type_pkg.t_short_id
  , i_duplicated_from_case_id      in     com_api_type_pkg.t_long_id       default null
);

/*
 * Procedure creates a dispute application (case) for a dispute operation;
 * operation's participant type defines if it will be an issuing dispute case or an acquring one.
 */
procedure create_application(
    i_oper_id                      in     com_api_type_pkg.t_long_id
  , i_participant_type             in     com_api_type_pkg.t_dict_value
  , o_appl_id                         out com_api_type_pkg.t_long_id
  , i_unpaired_oper_id             in     com_api_type_pkg.t_long_id       := null
  , i_dispute_reason               in     com_api_type_pkg.t_dict_value    := null
  , i_claim_id                     in     com_api_type_pkg.t_long_id       := null
);

procedure refuse_application_owner(
    i_appl_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
);

procedure get_case(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , o_case_cur                        out sys_refcursor
);

procedure check_available_actions(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , o_new_case_enable                 out com_api_type_pkg.t_boolean
  , o_take_enable                     out com_api_type_pkg.t_boolean
  , o_refuse_enable                   out com_api_type_pkg.t_boolean
  , o_hide_enable                     out com_api_type_pkg.t_boolean
  , o_unhide_enable                   out com_api_type_pkg.t_boolean
  , o_close_enable                    out com_api_type_pkg.t_boolean
  , o_reopen_enable                   out com_api_type_pkg.t_boolean
  , o_duplicate_enable                out com_api_type_pkg.t_boolean
  , o_comment_enable                  out com_api_type_pkg.t_boolean
  , o_status_enable                   out com_api_type_pkg.t_boolean
  , o_resolution_enable               out com_api_type_pkg.t_boolean
  , o_team_enable                     out com_api_type_pkg.t_boolean
  , o_reassign_enable                 out com_api_type_pkg.t_boolean
  , o_letter_enable                   out com_api_type_pkg.t_boolean
  , o_progress_enable                 out com_api_type_pkg.t_boolean
  , o_reason_enable                   out com_api_type_pkg.t_boolean
  , o_check_due_enable                out com_api_type_pkg.t_boolean
  , o_set_due_enable                  out com_api_type_pkg.t_boolean
);

function is_check_due_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_card_category                in     com_api_type_pkg.t_tiny_id       default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_set_due_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_case_progress                in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function get_due_date_lov(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_tiny_id;

function is_take_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_refuse_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

procedure set_application_team(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
  , i_team_id                      in     com_api_type_pkg.t_short_id
);

function is_progress_enable(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_card_category                in     com_api_type_pkg.t_tiny_id       default null
  , i_case_progress                in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_reason_enable(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_card_category                in     com_api_type_pkg.t_tiny_id       default null
  , i_case_progress                in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean;

function count_link_operations(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_array_exclude_oper_status    in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_short_id;

function is_close_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_reopen_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean;

function is_status_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_resolution_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

procedure change_case_status(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_appl_status                  in     com_api_type_pkg.t_dict_value
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null    
);

function is_duplicate_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_case_source                  in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

procedure set_hide_unhide_date(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
  , i_hide_date                    in     date
  , i_unhide_date                  in     date
);

procedure change_case_visibility(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
  , i_is_visible                   in     com_api_type_pkg.t_boolean
  , i_start_date                   in     date                       default null
  , i_end_date                     in     date                       default null
);

function is_hide_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_is_visible                   in     com_api_type_pkg.t_boolean       default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_unhide_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_is_visible                   in     com_api_type_pkg.t_boolean       default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean;

procedure add_history(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_action                       in     com_api_type_pkg.t_name
  , i_event_type                   in     com_api_type_pkg.t_dict_value    default null
  , i_new_appl_status              in     com_api_type_pkg.t_dict_value
  , i_old_appl_status              in     com_api_type_pkg.t_dict_value
  , i_new_reject_code              in     com_api_type_pkg.t_dict_value
  , i_old_reject_code              in     com_api_type_pkg.t_dict_value
  , i_env_param1                   in     com_api_type_pkg.t_name          default null
  , i_env_param2                   in     com_api_type_pkg.t_name          default null
  , i_env_param3                   in     com_api_type_pkg.t_name          default null
  , i_env_param4                   in     com_api_type_pkg.t_name          default null
  , i_mask_error                   in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure set_due_date(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_due_date                     in     date
  , io_seqnum                      in out com_api_type_pkg.t_seqnum
);

procedure modify_case(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_seqnum
  , i_oper_date                    in     date
  , i_oper_amount                  in     com_api_type_pkg.t_money
  , i_oper_currency                in     com_api_type_pkg.t_curr_code
  , i_dispute_reason               in     com_api_type_pkg.t_dict_value
  , i_due_date                     in     date
  , i_reason_code                  in     com_api_type_pkg.t_dict_value
  , i_disputed_amount              in     com_api_type_pkg.t_money
  , i_disputed_currency            in     com_api_type_pkg.t_curr_code
  , i_arn                          in     com_api_type_pkg.t_card_number
  , i_claim_id                     in     com_api_type_pkg.t_long_id       default null
  , i_auth_code                    in     com_api_type_pkg.t_auth_code
  , i_merchant_name                in     com_api_type_pkg.t_name
  , i_transaction_code             in     com_api_type_pkg.t_cmid
  , i_agent_id                     in     com_api_type_pkg.t_short_id      default null
  , i_card_number                  in     com_api_type_pkg.t_card_number   default null
);

procedure remove_claim(
    i_claim_id                     in     com_api_type_pkg.t_long_id
  , i_seqnum                       in     com_api_type_pkg.t_seqnum
);

procedure set_application_user(
    i_case_id                in      com_api_type_pkg.t_long_id
  , io_seqnum                in out  com_api_type_pkg.t_tiny_id
  , i_user_id                in      com_api_type_pkg.t_short_id      default null
);

function is_comment_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_team_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_reassign_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_letter_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

procedure case_close_wo_inv(
    i_case_id                      in     com_api_type_pkg.t_long_id
);

procedure case_reopen_wo_inv(
    i_case_id                      in     com_api_type_pkg.t_long_id
);

end csm_ui_dispute_pkg;
/
