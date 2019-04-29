create or replace package iss_api_rule_proc_pkg as

procedure create_virtual_card;

procedure check_card_autoreissue;

procedure create_event_fee;

procedure calculate_reissue_date;

procedure reissue_card_instance;

procedure get_card_balance;

end iss_api_rule_proc_pkg;
/
