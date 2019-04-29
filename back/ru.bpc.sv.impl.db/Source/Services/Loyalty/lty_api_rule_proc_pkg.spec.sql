create or replace package lty_api_rule_proc_pkg is
/*********************************************************
*  Loyalty points rules processing <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 10.07.2016 <br />
*  Module: LTY_API_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure create_bonus_auth;

procedure create_bonus_oper;

procedure spend_bonus_oper;

procedure switch_limit_reward_bonuses;

procedure lottery_ticket_registration;

procedure check_lty_account;

procedure get_account_balance;

procedure calculate_lty_points;

procedure move_bonus_oper;

procedure spend_operation;

end;
/
