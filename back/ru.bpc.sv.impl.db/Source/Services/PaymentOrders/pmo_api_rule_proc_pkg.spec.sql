create or replace package pmo_api_rule_proc_pkg is
/*********************************************************
 *  API for event rule processing <br />
 *  Created by Fomichev A (fomichev@bpcbt.com)  at 04.04.2018 <br />
 *  Module: PMO_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_payment_order;

procedure stop_payment_order;

procedure register_oper_detail;

end pmo_api_rule_proc_pkg;
/
