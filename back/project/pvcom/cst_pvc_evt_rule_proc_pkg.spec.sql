create or replace package cst_pvc_evt_rule_proc_pkg as
/************************************************************
 * API for event rules processing at PVCom bank <br />
 * Created by Man Do(m.do@bpcbt.com) at 25.09.2018 <br />
 * Module: CST_PVC_EVT_RULE_PROC_PKG <br />
 * @headcom
 ************************************************************/
 
function get_max_invoice_aging 
return com_api_type_pkg.t_tiny_id;

procedure get_unpaid_mad_amount;

end cst_pvc_evt_rule_proc_pkg;
/
