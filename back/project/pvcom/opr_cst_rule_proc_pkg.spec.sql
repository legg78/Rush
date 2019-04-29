create or replace package opr_cst_rule_proc_pkg is
/************************************************************
 * API for operation rules processing at PVCom bank <br />
 * Created by Man Do(m.do@bpcbt.com) at 12.09.2018 <br />
 * Module: OPR_CST_RULE_PROC_PKG <br />
 * @headcom
 ************************************************************/

procedure update_repay_priority_before;

procedure update_repay_priority_after;

procedure select_auth_account;

procedure select_reversal_status;

end;
/
