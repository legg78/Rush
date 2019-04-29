create or replace package dpp_api_rule_proc_pkg is
/*********************************************************
*  DPP rules processing <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 11.05.2017 <br />
*  Module: DPP_API_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/ 

procedure register_dpp;

procedure accelerate_dpps;

procedure register_instalment_event;

procedure check_dpp_account;

procedure cancel_dpp;

procedure load_dpp_data;

procedure restructure_dpp;

end;
/
