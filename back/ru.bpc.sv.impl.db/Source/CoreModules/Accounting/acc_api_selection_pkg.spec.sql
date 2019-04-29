create or replace package acc_api_selection_pkg is

procedure get_account(
    o_account_id               out com_api_type_pkg.t_medium_id
  , o_account_number           out com_api_type_pkg.t_account_number
  , o_inst_id                  out com_api_type_pkg.t_inst_id
  , o_agent_id                 out com_api_type_pkg.t_agent_id
  , o_currency                 out com_api_type_pkg.t_curr_code 
  , o_account_type             out com_api_type_pkg.t_dict_value
  , o_status                   out com_api_type_pkg.t_dict_value 
  , o_contract_id              out com_api_type_pkg.t_medium_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
  , o_scheme_id                out com_api_type_pkg.t_tiny_id
  , o_split_hash               out com_api_type_pkg.t_tiny_id
  , i_selection_id              in com_api_type_pkg.t_tiny_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_account_number            in com_api_type_pkg.t_account_number
  , i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_iso_type                  in com_api_type_pkg.t_dict_value
  , i_oper_currency             in com_api_type_pkg.t_curr_code
  , i_sttl_currency             in com_api_type_pkg.t_curr_code
  , i_bin_currency              in com_api_type_pkg.t_curr_code
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_is_forced_processing      in com_api_type_pkg.t_boolean        default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value     default null
  , i_oper_amount               in com_api_type_pkg.t_long_id        default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value     default null
  , i_params                    in com_api_type_pkg.t_param_tab
);

procedure get_account(
    o_account_id               out com_api_type_pkg.t_medium_id
  , o_account_number           out com_api_type_pkg.t_account_number
  , o_inst_id                  out com_api_type_pkg.t_inst_id
  , o_agent_id                 out com_api_type_pkg.t_agent_id
  , o_currency                 out com_api_type_pkg.t_curr_code 
  , o_account_type             out com_api_type_pkg.t_dict_value
  , o_contract_id              out com_api_type_pkg.t_medium_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
  , o_scheme_id                out com_api_type_pkg.t_tiny_id
  , o_split_hash               out com_api_type_pkg.t_tiny_id
  , i_selection_id              in com_api_type_pkg.t_tiny_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_account_number            in com_api_type_pkg.t_account_number
  , i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_iso_type                  in com_api_type_pkg.t_dict_value
  , i_oper_currency             in com_api_type_pkg.t_curr_code
  , i_sttl_currency             in com_api_type_pkg.t_curr_code
  , i_bin_currency              in com_api_type_pkg.t_curr_code
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_is_forced_processing      in com_api_type_pkg.t_boolean        default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value     default null
  , i_oper_amount               in com_api_type_pkg.t_long_id        default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value     default null
  , i_params                    in com_api_type_pkg.t_param_tab
);

/**************************************************
* @param    i_show_friendly_numbers
*     Defines if will be filled field <friendly_number> with "friendly" account number.
*     For example, instead of account's number "9856576812346708" a "friendly" one 
*     may contain something like this: "SAV X1234 RUB".
*     Customizing of such representation is implemented by
*     function <cst_api_name_pkg.get_friendly_account_number>.
* @return   A collection with account information records.
***************************************************/
procedure get_accounts(
    i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_oper_type                 in com_api_type_pkg.t_dict_value     default null
  , i_account_type              in com_api_type_pkg.t_dict_value     default null
  , i_selection_id              in com_api_type_pkg.t_tiny_id        default null
  , i_party_type                in com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
  , i_msg_type                  in com_api_type_pkg.t_dict_value     default null
  , i_show_friendly_numbers     in com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , o_accounts                 out acc_api_type_pkg.t_account_tab
  , i_is_forced_processing      in com_api_type_pkg.t_boolean        default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value     default null
  , i_oper_amount               in com_api_type_pkg.t_long_id        default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value     default null
);

function check_account_restricted(
    i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_inst_id                   in com_api_type_pkg.t_inst_id
  , i_account_type              in com_api_type_pkg.t_dict_value
  , i_account_status            in com_api_type_pkg.t_dict_value
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_is_forced_processing      in com_api_type_pkg.t_boolean        default null
) return com_api_type_pkg.t_boolean;

end acc_api_selection_pkg;
/
