create or replace package cst_smt_api_rule_proc_pkg is
/*********************************************************
 *  API for custom rules processing <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com)  at 03.12.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::              $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_SMT_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure set_oper_status_evt_processing;

procedure set_oper_stage_evt_processing;

procedure set_oper_status_opr_processing;

procedure set_oper_stage_opr_processing;

procedure create_reversal_from_original;

procedure generate_arn;

end;
/
