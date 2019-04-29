create or replace package cst_apc_evt_rule_proc_pkg is
/************************************************************
 * Event processing rules of APAC <br />
 * Created by Alalykin A. (alalykin@bpcbt.com) at 25.12.2018 <br />
 * Module: CST_APC_EVT_RULE_PROC_PKG <br />
 * @headcom
 ***********************************************************/

procedure set_skip_mad_date;

procedure get_total_debt_amount;

procedure switch_card_cycle;

end cst_apc_evt_rule_proc_pkg;
/
