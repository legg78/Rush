create or replace package opr_cst_rule_proc_pkg is
/*********************************************************
 *  API for operation rules processing at Woori bank <br />
 *  Created by Chau Huynh (huynh@bpcbt.com)  at 28.07.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::              $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: OPR_CST_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure select_auth_account;

procedure select_reversal_status;

procedure update_repay_priority_before;

procedure update_repay_priority_after;

end;
/
