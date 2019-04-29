create or replace package cst_bof_api_rule_proc_pkg is
/*********************************************************
 *  API for custom rules processing <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com)  at 11.02.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::              $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_BOF_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure check_card_status_opr_proc;

procedure check_cycle_is_active_opr_proc;

procedure activate_card_opr_proc;

procedure deactivate_card_opr_proc;

procedure deactivate_card_evt_proc;

procedure reset_cycle_counter_opr_proc;

procedure get_remittance_opr_process;

procedure get_remittance_evt_process;

procedure create_reversal_from_original;

end;
/
