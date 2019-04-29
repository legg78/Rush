create or replace package cst_icc_prc_credit_pkg as

/*
 * The process checks out all credit accounts and generates events EVNT5034 for those
 * whose overlimit balances are equal or more than their credit limits.
 */
procedure check_bad_credits(
    i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_event_type         in     com_api_type_pkg.t_dict_value
);

end;
/
