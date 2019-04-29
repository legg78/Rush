create or replace package cst_lvp_opr_rule_proc_pkg is
/*********************************************************
 *  API for operation rules processing at LienVietPost bank <br />
 *  Created by Chau Huynh (huynh@bpcbt.com)  at 28.07.2017 <br />
 *  Module: CST_LVP_OPR_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure select_auth_account;

procedure select_reversal_status;

procedure check_payment_ability;

procedure get_debt_level;

procedure get_current_fee_debt;

procedure get_current_interest_debt;

procedure get_current_main_debt;

procedure get_spent_own_funds;

procedure get_mcw_billing_amount;

end cst_lvp_opr_rule_proc_pkg;
/
