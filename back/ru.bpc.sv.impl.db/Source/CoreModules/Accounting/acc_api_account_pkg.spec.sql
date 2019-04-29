create or replace package acc_api_account_pkg is
/*********************************************************
*  Accounting API  <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 06.08.2009 <br />
*  Module: ACC_API_ACCOUNT_PKG <br />
**********************************************************/

procedure create_account(
    o_id                     out com_api_type_pkg.t_account_id
  , io_split_hash         in out com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , io_account_number     in out com_api_type_pkg.t_account_number
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_contract_id         in     com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_customer_number     in     com_api_type_pkg.t_name
);

procedure remove_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id             default null
);

procedure create_accounts(
    io_account_tab        in out nocopy acc_api_type_pkg.t_account_tab
);

procedure create_accounts(
    io_id_tab             in out nocopy com_api_type_pkg.t_number_tab
  , io_split_hash_tab     in out com_api_type_pkg.t_number_tab
  , i_account_type_tab    in     com_api_type_pkg.t_dict_tab
  , io_account_num_tab    in out com_api_type_pkg.t_account_number_tab
  , i_currency_tab        in     com_api_type_pkg.t_curr_code_tab
  , i_inst_tab            in     com_api_type_pkg.t_inst_id_tab
  , i_agent_tab           in     com_api_type_pkg.t_agent_id_tab
  , i_status              in     com_api_type_pkg.t_dict_tab
  , i_contract_id         in     com_api_type_pkg.t_number_tab
  , i_customer_id         in     com_api_type_pkg.t_number_tab
  , i_customer_number     in     com_api_type_pkg.t_name_tab
);

procedure add_account_object(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_usage_order         in     com_api_type_pkg.t_tiny_id             default null
  , i_is_pos_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_currency     in     com_api_type_pkg.t_boolean             default null
  , i_is_pos_currency     in     com_api_type_pkg.t_boolean             default null
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number  default null
  , o_account_object_id      out com_api_type_pkg.t_long_id
);

/*
 * Procedure checks incoming account sequential number and returns it if it is not used for incoming entity object;
 * otherwise, it either raises an error or ignores incoming value and returns next correct value.
 */
procedure get_seq_number(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
  , o_account_seq_number     out acc_api_type_pkg.t_account_seq_number
);

procedure copy_account_object(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_source_object_id    in     com_api_type_pkg.t_long_id
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_is_pos_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_default      in     com_api_type_pkg.t_boolean             default null
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number  default null
);

procedure remove_account_object(
    i_account_object_id   in     com_api_type_pkg.t_long_id
);

function account_object_exists(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

procedure create_gl_accounts(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
);

procedure create_gl_account(
    o_id                     out com_api_type_pkg.t_medium_id
  , io_account_number     in out com_api_type_pkg.t_account_number
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
  , i_refresh_mvw         in     com_api_type_pkg.t_boolean             default com_api_type_pkg.TRUE
);

procedure get_account_info(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_curr_code           in     com_api_type_pkg.t_curr_code           default null
  , o_account_number         out com_api_type_pkg.t_account_number
  , o_inst_id                out com_api_type_pkg.t_inst_id
);

procedure get_account_info(
    i_account_id          in     com_api_type_pkg.t_medium_id
  , o_account_number         out com_api_type_pkg.t_account_number
  , o_entity_type            out com_api_type_pkg.t_dict_value
  , o_inst_id                out com_api_type_pkg.t_inst_id
);

procedure get_account_info(
    i_account_id          in     com_api_type_pkg.t_medium_id
  , o_account_rec            out acc_api_type_pkg.t_account_rec
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_type_pkg.TRUE
);

function get_accounts(
    i_contract_id         in     com_api_type_pkg.t_medium_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
) return acc_api_type_pkg.t_account_tab;

procedure set_account_status(
    i_account_id          in      com_api_type_pkg.t_medium_id
  , i_status              in      com_api_type_pkg.t_dict_value
  , i_reason              in      com_api_type_pkg.t_dict_value         default null
);

procedure close_account(
    i_account_id          in     com_api_type_pkg.t_medium_id
);

procedure close_balance(
    i_account_id          in     com_api_type_pkg.t_medium_id
);

procedure find_account(
    i_account_number      in     com_api_type_pkg.t_account_number
    , i_oper_type         in     com_api_type_pkg.t_dict_value
    , i_party_type        in     com_api_type_pkg.t_dict_value
    , i_msg_type          in     com_api_type_pkg.t_dict_value          default null
    , i_inst_id           in     com_api_type_pkg.t_inst_id             default null
    , o_account_id           out com_api_type_pkg.t_medium_id
    , o_customer_id          out com_api_type_pkg.t_medium_id
    , o_split_hash           out com_api_type_pkg.t_tiny_id
    , o_inst_id              out com_api_type_pkg.t_inst_id
    , o_iss_network_id       out com_api_type_pkg.t_network_id
    , o_resp_code            out com_api_type_pkg.t_dict_value
);

procedure find_account(
    i_account_number      in     com_api_type_pkg.t_account_number
  , i_oper_type           in     com_api_type_pkg.t_dict_value
  , i_party_type          in     com_api_type_pkg.t_dict_value
  , i_msg_type            in     com_api_type_pkg.t_dict_value          default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id             default null
  , o_account_id             out com_api_type_pkg.t_medium_id
  , o_currency               out com_api_type_pkg.t_curr_code
  , o_status                 out com_api_type_pkg.t_dict_value
  , o_customer_id            out com_api_type_pkg.t_medium_id
  , o_split_hash             out com_api_type_pkg.t_tiny_id
  , o_inst_id                out com_api_type_pkg.t_inst_id
  , o_iss_network_id         out com_api_type_pkg.t_network_id
  , o_resp_code              out com_api_type_pkg.t_dict_value
);

procedure find_account(
    i_account_number      in     com_api_type_pkg.t_account_number
  , i_oper_type           in     com_api_type_pkg.t_dict_value
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_party_type          in     com_api_type_pkg.t_dict_value
  , i_msg_type            in     com_api_type_pkg.t_dict_value          default null
  , o_account_id             out com_api_type_pkg.t_medium_id
  , o_resp_code              out com_api_type_pkg.t_dict_value
);

procedure find_account(
    i_customer_id         in     com_api_type_pkg.t_account_number
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , io_currency           in out com_api_type_pkg.t_curr_code
  , o_account_id             out com_api_type_pkg.t_medium_id
  , o_account_number         out com_api_type_pkg.t_account_number
);

/*
 * Invalidating cached account record, it should be called any change of account.
 */
procedure clear_cache;

procedure get_account_info(
    i_account_number      in     com_api_type_pkg.t_account_number
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_rate_type           in     com_api_type_pkg.t_dict_value
  , o_accounts               out sys_refcursor
);

function next_customer_account(
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_account_type        in     com_api_type_pkg.t_dict_value          default null
) return com_api_type_pkg.t_sign;

function check_account_number_unique(
    i_account_number      in     com_api_type_pkg.t_account_number
  , i_inst_id             in     com_api_type_pkg.t_inst_id
) return number;

function get_account_id(
    i_account_number      in     com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_account_id;

procedure modify_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_new_agent_id        in     com_api_type_pkg.t_agent_id
);

/*
 * Function searches and returns an account record by <i_account_id> if it isn't NULL
 * (<i_account_number> and <i_inst_id> are ignored in this case),
 * otherwise it uses <i_account_number> with <i_inst_id> to locate an account.
 * If <i_inst_id> is NULL then first account will be returned.
 * Exceptions ACCOUNT_NOT_FOUND and ACCOUNT_NUMBER_NOT_UNIQUE are raised when searching is failed and <i_mask_error> is FALSE.
 */
function get_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_account_number      in     com_api_type_pkg.t_account_number      default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id             default null
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_const_pkg.TRUE
) return acc_api_type_pkg.t_account_rec;

function get_account(
    i_customer_id         in     com_api_type_pkg.t_account_number
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code           default null
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_const_pkg.TRUE
) return acc_api_type_pkg.t_account_rec;

function get_account(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code           default null
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_const_pkg.TRUE
) return acc_api_type_pkg.t_account_rec;

procedure add_unlink_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_usage_order         in     com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_is_pos_default      in     com_api_type_pkg.t_boolean
  , i_is_atm_default      in     com_api_type_pkg.t_boolean
  , i_is_atm_currency     in     com_api_type_pkg.t_boolean
  , i_is_pos_currency     in     com_api_type_pkg.t_boolean
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number
  , o_unlink_account_id      out com_api_type_pkg.t_long_id
);

procedure add_account_link(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_description         in     com_api_type_pkg.t_name
  , i_is_active           in     com_api_type_pkg.t_boolean             default com_api_const_pkg.TRUE
  , o_account_link_id        out com_api_type_pkg.t_medium_id
);

function get_account_reg_date(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
) return date;

function get_account_number(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_account_number;

function check_active_account(
    i_card_id             in     com_api_type_pkg.t_medium_id
  , i_curr_code           in     com_api_type_pkg.t_curr_code           default null
) return com_api_type_pkg.t_boolean;

procedure reconnect_account(
    i_account_id          in     com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_contract_id         in     com_api_type_pkg.t_long_id
);

function get_default_accounts(
    i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_use_atm_default     in     com_api_type_pkg.t_boolean
  , i_use_pos_default     in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_text;

procedure set_object_default_account(
    i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_account_id          in     com_api_type_pkg.t_account_id
  , i_is_pos_default      in     com_api_type_pkg.t_boolean
  , i_is_atm_default      in     com_api_type_pkg.t_boolean
);

end acc_api_account_pkg;
/
