create or replace package opr_ui_operation_pkg as

procedure modify_status(
    i_oper_id           in      com_api_type_pkg.t_long_id
  , i_oper_status       in      com_api_type_pkg.t_dict_value
  , i_forced_processing in      com_api_type_pkg.t_boolean      default null
);

procedure modify_statuses(
    i_session_id          in    com_api_type_pkg.t_long_id      default null
  , i_incom_sess_file_id  in    com_api_type_pkg.t_long_id      default null
  , i_host_date_from      in    date                            default null
  , i_host_date_to        in    date                            default null
  , i_msg_type            in    com_api_type_pkg.t_dict_value   default null
  , i_sttl_type           in    com_api_type_pkg.t_dict_value   default null    
  , i_is_reversal         in    com_api_type_pkg.t_boolean      default null  
  , i_oper_currency       in    com_api_type_pkg.t_curr_code    default null
  , i_oper_type           in    com_api_type_pkg.t_dict_value   default null
  , i_oper_status         in    com_api_type_pkg.t_dict_value   
  , i_new_status          in    com_api_type_pkg.t_dict_value   
  , i_oper_id             in    com_api_type_pkg.t_long_id      default null
  , i_oper_reason         in    com_api_type_pkg.t_dict_value   default null
);

procedure match_operations(
    i_orig_oper_id         in      com_api_type_pkg.t_long_id
  , i_pres_oper_id         in      com_api_type_pkg.t_long_id
);

procedure match_operation_reversal(
    i_orig_oper_id         in      com_api_type_pkg.t_long_id
  , i_reversal_oper_id     in      com_api_type_pkg.t_long_id
);

/*
 * Procedure searches an operation's participant and performs checks that could modify some its data.
 */
procedure perform_checks(
    i_oper_id               in     com_api_type_pkg.t_long_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value
  , o_network_id               out com_api_type_pkg.t_tiny_id
  , o_inst_id                  out com_api_type_pkg.t_inst_id
  , o_card_inst_id             out com_api_type_pkg.t_inst_id
  , o_card_network_id          out com_api_type_pkg.t_network_id
  , o_card_type_id             out com_api_type_pkg.t_tiny_id
  , o_card_mask                out com_api_type_pkg.t_card_number
  , o_card_hash                out com_api_type_pkg.t_medium_id
  , o_card_seq_number          out com_api_type_pkg.t_tiny_id
  , o_card_expir_date          out date
  , o_card_service_code        out com_api_type_pkg.t_country_code
  , o_card_country             out com_api_type_pkg.t_country_code
  , o_account_id               out com_api_type_pkg.t_medium_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
  , o_merchant_id              out com_api_type_pkg.t_short_id
  , o_terminal_id              out com_api_type_pkg.t_short_id
  , o_card_id                  out com_api_type_pkg.t_medium_id
  , o_card_instance_id         out com_api_type_pkg.t_medium_id
  , o_split_hash               out com_api_type_pkg.t_tiny_id
  -- Parameters that could be changed indirectly
  , o_customer_name            out com_api_type_pkg.t_text
  , o_inst_name                out com_api_type_pkg.t_text
  , o_card_inst_name           out com_api_type_pkg.t_text
  , o_network_name             out com_api_type_pkg.t_text
  , o_card_network_name        out com_api_type_pkg.t_text
  , o_card_type_name           out com_api_type_pkg.t_text
  -- Additional parameters
  , o_client_id_type           out com_api_type_pkg.t_dict_value
  , o_client_id_value          out com_api_type_pkg.t_name
  , o_account_type             out com_api_type_pkg.t_dict_value
  , o_account_amount           out com_api_type_pkg.t_money
  , o_account_currency         out com_api_type_pkg.t_curr_code
  , o_auth_code                out com_api_type_pkg.t_auth_code
  , o_card_number              out com_api_type_pkg.t_card_number
);

/*
 * Procedure searches participant by PK i_participant.oper_id & i_participant.participant_type and updates all its fields.
 */
procedure update_participant(
    i_oper_id               in     com_api_type_pkg.t_long_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_card_inst_id          in     com_api_type_pkg.t_inst_id
  , i_card_network_id       in     com_api_type_pkg.t_network_id
  , i_card_id               in     com_api_type_pkg.t_medium_id
  , i_card_instance_id      in     com_api_type_pkg.t_medium_id
  , i_card_type_id          in     com_api_type_pkg.t_tiny_id
  , i_card_mask             in     com_api_type_pkg.t_card_number
  , i_card_hash             in     com_api_type_pkg.t_medium_id
  , i_card_seq_number       in     com_api_type_pkg.t_tiny_id
  , i_card_expir_date       in     date
  , i_card_service_code     in     com_api_type_pkg.t_country_code
  , i_card_country          in     com_api_type_pkg.t_country_code
  , i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_account_id            in     com_api_type_pkg.t_medium_id
  , i_merchant_id           in     com_api_type_pkg.t_short_id
  , i_terminal_id           in     com_api_type_pkg.t_short_id
  , i_client_id_type        in     com_api_type_pkg.t_dict_value        default null
  , i_client_id_value       in     com_api_type_pkg.t_name              default null
  , i_account_type          in     com_api_type_pkg.t_dict_value        default null
  , i_account_number        in     com_api_type_pkg.t_account_number    default null
  , i_account_amount        in     com_api_type_pkg.t_money             default null
  , i_account_currency      in     com_api_type_pkg.t_curr_code         default null
  , i_auth_code             in     com_api_type_pkg.t_auth_code         default null
  , i_card_number           in     com_api_type_pkg.t_card_number       default null
);

procedure modify_sttl_type(
    i_oper_id               in     com_api_type_pkg.t_long_id
  , i_sttl_type             in     com_api_type_pkg.t_dict_value
);

end;
/