create or replace package cst_icc_evt_rule_proc_pkg is

ATTR_MAIN_PART_LIMIT_NOTIF        constant com_api_type_pkg.t_name := 'CST_ICC_MAIN_PART_LIMIT_NOTIF';

procedure product_autochange;

procedure stop_cycle_counter;

procedure get_loyalty_account_balance;

procedure init_birthday_cycle_notif;

procedure init_marriage_day_cycle_notif;

procedure check_main_part_credit_limit;

end;
/
