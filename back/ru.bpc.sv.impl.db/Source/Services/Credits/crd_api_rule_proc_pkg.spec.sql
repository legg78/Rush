create or replace package crd_api_rule_proc_pkg is
/************************************************************
 * Credit module operations processing rules <br />
 * Created by Kolodkina Y.(kolodkina@bpcbt.com)  at 02.06.2014 <br />
 * Module: CRD_API_RULE_PROC_PKG <br />
 * @headcom
 ***********************************************************/

procedure debt_in_collection;

procedure suspend_credit_calc;

procedure continue_credit_calc;

procedure cancel_credit_calc;

procedure credit_limit_increase;

procedure calc_total_accrued_amount;

procedure calc_accrued_amount;

procedure credit_clearance;

procedure credit_payment;

procedure calc_part_interest_return;

procedure calculate_credit_overlimit_fee;

procedure lending_clearance;

procedure lending_payment;

procedure reset_aging_period;

procedure load_invoice_data;

procedure credit_balance_transfer;

procedure revert_interest;

end;
/
