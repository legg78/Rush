create or replace package h2h_api_rule_proc_pkg is
/*********************************************************
 *  Host-to-host processing rules  <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/
 
procedure create_fin_msg_from_auth;

procedure create_fin_msg_from_mc_pres;

procedure create_fin_msg_from_visa_pres;

procedure create_fin_msg_from_cup_pres;

procedure create_fin_msg_from_jcb_pres;

procedure create_fin_msg_from_din_pres;

procedure create_fin_msg_from_amx_pres;

procedure create_fin_msg_from_mup_pres;

end;
/
