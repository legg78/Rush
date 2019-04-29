create or replace package evt_api_rule_proc_pkg is
/*********************************************************
 *  API for event rule processing <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 26.08.2011 <br />
 *  Module: EVT_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure calculate_fee;

procedure calculate_fee_turnover;

procedure init_limit_counter;

procedure reset_limit_counter;

procedure switch_limit_counter;

procedure get_limit_counter;

procedure switch_cycle;

procedure create_operation;

procedure write_trace;

procedure check_sttl_day_holiday;

procedure check_sttl_day_exist;

procedure find_untreated_entry;

procedure check_process;

procedure check_rate;

procedure send_notification;

procedure send_user_notification;

procedure set_host_status;

procedure remove_cycle_counter;

procedure change_object_status;

procedure close_service;

procedure change_prev_instance_status;

procedure get_account_balance_amount;

procedure deactive_delivery_address;

procedure close_account;

procedure reset_cycle_counter;

procedure add_transmission_data;

procedure change_card_delivery_status;

procedure switch_cycle_birthday;

procedure change_statmnt_delivery_status;

procedure split_terminal_revenue_cycled;

procedure gen_acq_min_amount_event;

procedure calculate_facilitator_fee;

procedure fill_flexible_mcc_list;

procedure get_available_balance_amount;

procedure get_absolute_amount;

procedure change_customer_account_status;

procedure select_amount;

procedure check_amount_positive;

-- Obsolete. Do not use
procedure send_credit_due_notification;

procedure add_oper_stage;

procedure check_amount_not_positive;

procedure change_dependent_object_status;

procedure subtract_amount;

procedure close_dependent_objects;

procedure add_amount;

procedure close_card;

procedure close_contract;

procedure check_modifier;

end evt_api_rule_proc_pkg;
/
