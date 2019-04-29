create or replace package cst_cfc_rule_proc_pkg as
/*********************************************************
*  CFC custom API of the operation rules <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 14.11.2017 <br />
*  Module: CST_CFC_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure save_additional_auth_tags;

procedure process_revised_bucket;

procedure get_remaining_payment_amount;

procedure get_spent_own_funds;

procedure get_oper_debt_amount;

procedure set_absolute_amount;

procedure get_account_balance_amount;

procedure add_amount;

/*
 * Rule changes repayment priorities of new (uninvoiced) debts using priorities configurated for balance Overdue.
 */
procedure change_repay_priority;

procedure calc_accrued_interest_amount;

function get_cus_account_status
return com_api_type_pkg.t_dict_value;

function check_card_activation
return com_api_type_pkg.t_count;

procedure credit_balance_payment;

end cst_cfc_rule_proc_pkg;
/
