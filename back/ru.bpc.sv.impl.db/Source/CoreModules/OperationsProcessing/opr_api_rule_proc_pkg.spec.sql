create or replace package opr_api_rule_proc_pkg is
/*********************************************************
 *  API for operation rules processing <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 13.09.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::              $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: OPR_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

-- refactored
procedure post_macros;

procedure post_macros_two_account;

procedure get_account_balance;

procedure check_account_balance;

procedure get_account_balance_amount;

procedure load_transaction_data;

procedure load_operation_amount;

procedure load_operation_accounts;

procedure calculate_fee_reversal;

procedure register_oper_in_order;

-- not refactored

procedure check_balance_positive;

procedure check_amount_positive;

procedure conditional_fee_calculation;

procedure calculate_fee;

procedure reset_limit_counter;

procedure switch_limit_counter;

procedure get_limit_remainder;

procedure switch_cycle;

procedure add_amount;

procedure subtract_amount;

procedure assign_amount;

procedure select_object_account;

procedure select_auth_account;

procedure select_amount_to_post_account;

procedure convert_amount;

procedure set_amount;

procedure calculate_cycle_date;

procedure write_trace;

procedure load_customer_data;

procedure load_payment_order_data;

procedure get_object_account_balance;

procedure check_object_account_balance;

procedure set_account_balance_amount;

procedure calculate_oper_actual_amount;

procedure cancel_processing;

procedure select_operation_account;

procedure select_merchant_account;

procedure unhold_auth;

procedure unhold_macros;

procedure unhold_auth_partial;

procedure insurance_payment;

procedure completion_check;
-- from auth
procedure activate_card;

procedure deactivate_card;

procedure count_wrong_pin_attempt;

procedure set_payment_order_status;

procedure select_participant_contract;

procedure add_aggregator_participant;

procedure register_event;

procedure make_notification;

/**************************************************
 * Obsolete. Do not use.
 **************************************************/
procedure make_notification_by_account;

procedure add_notification;

procedure remove_notification;

procedure change_object_status;

procedure set_limit_object;

procedure load_object_data;

procedure collect_p2p_tags;

procedure get_provider_account;

procedure rollback_limit_counter;

procedure proportional_amount;

procedure create_collection_only;

procedure get_bin_currency;

procedure check_reversal_amount;

/*
 * This rule is used to save some amount to amounts of found operation's authorization.
 */
procedure save_amount_to_auth_amounts;

procedure calculate_unhold_date;

procedure add_institution_participant;

procedure calculate_fee_turnover;

procedure pin_activation;

procedure set_fee_object;

procedure register_card_token;

procedure split_terminal_revenue;

procedure create_tie_fin_message;

procedure register_pin_offset;

procedure select_inst_gl_account;

procedure attach_mobile_service;

procedure detach_mobile_service;

procedure remove_cycle_counter;

procedure union_shared_param_tables;

procedure change_account_status;

procedure select_merchant_account_by_pan;

procedure change_dependent_object_status;

procedure get_own_merchant;

procedure update_card_token;

procedure update_token_pan;

procedure check_object_status;

procedure select_rate_type;

procedure prepare_document;

end opr_api_rule_proc_pkg;
/
