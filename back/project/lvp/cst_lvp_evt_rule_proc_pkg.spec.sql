create or replace package cst_lvp_evt_rule_proc_pkg is
/*********************************************************
 *  API for event rule processing for Lienviet bank <br />
 *  Created by ChauHuynh(huynh@bpcbt.com) at 26.09.2017 <br />
 *  Module: CST_LVP_EVT_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/
procedure change_card_status;

procedure set_debt_aging_level;

procedure get_abs_acct_balance_amount;

procedure get_available_balance_amount;

procedure get_original_debt_level;

procedure get_total_debt_amount;

procedure get_invoice_interest_amount;

procedure check_direct_debit_paid;

procedure set_acc_debt_level;

procedure incr_acc_debt_level;

procedure decr_acc_debt_level;

end cst_lvp_evt_rule_proc_pkg;
/
