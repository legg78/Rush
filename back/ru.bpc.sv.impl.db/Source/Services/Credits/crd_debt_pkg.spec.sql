create or replace package crd_debt_pkg as

procedure set_balance(
    i_debt_id                       in      com_api_type_pkg.t_long_id
  , i_eff_date                      in      date
  , i_account_id                    in      com_api_type_pkg.t_medium_id
  , i_service_id                    in      com_api_type_pkg.t_short_id
  , i_inst_id                       in      com_api_type_pkg.t_inst_id
  , i_split_hash                    in      com_api_type_pkg.t_tiny_id
  , i_is_overdue                    in      com_api_type_pkg.t_boolean          default null
);

procedure load_debt_param(
    i_debt_id                       in      com_api_type_pkg.t_long_id
  , io_param_tab                    in out  com_api_type_pkg.t_param_tab
  , i_split_hash                    in      com_api_type_pkg.t_tiny_id          default null
);

procedure load_debt_param(
    i_debt_id                       in      com_api_type_pkg.t_long_id
  , io_param_tab                    in out  com_api_type_pkg.t_param_tab
  , i_split_hash                    in      com_api_type_pkg.t_tiny_id          default null
  , o_product_id                       out  com_api_type_pkg.t_short_id
);

procedure product_change(
    i_contract_id                   in      com_api_type_pkg.t_medium_id
  , i_eff_date                      in      date
  , i_split_hash                    in      com_api_type_pkg.t_tiny_id
);

procedure set_debt_paid(
    i_debt_id                       in      com_api_type_pkg.t_long_id
);

procedure set_debt_paid(
    i_debt_id                       in      com_api_type_pkg.t_long_id
  , o_unpaid_debt                      out  com_api_type_pkg.t_money
);

procedure set_detailed_entity_types(
    i_detailed_entities_array_id    in      com_api_type_pkg.t_short_id         default null
);

function get_count_debt_for_period(
    i_account_id                    in      com_api_type_pkg.t_account_id
  , i_split_hash                    in      com_api_type_pkg.t_tiny_id          default null
  , i_start_date                    in      date
  , i_end_date                      in      date
) return com_api_type_pkg.t_short_id;

procedure change_debt(
    i_debt_id                       in      com_api_type_pkg.t_long_id
  , i_eff_date                      in      date
  , i_account_id                    in      com_api_type_pkg.t_medium_id
  , i_service_id                    in      com_api_type_pkg.t_short_id         default null
  , i_inst_id                       in      com_api_type_pkg.t_inst_id
  , i_split_hash                    in      com_api_type_pkg.t_tiny_id
  , i_event_type                    in      com_api_type_pkg.t_dict_value
  , i_forced_interest               in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_unpaid_debt                      out  com_api_type_pkg.t_money
);

procedure credit_clearance(
    i_account                       in      acc_api_type_pkg.t_account_rec
  , i_operation                     in      opr_api_type_pkg.t_oper_rec
  , i_macros_type_id                in      com_api_type_pkg.t_tiny_id
  , i_credit_bunch_type_id          in      com_api_type_pkg.t_tiny_id
  , i_over_bunch_type_id            in      com_api_type_pkg.t_tiny_id
  , i_card_id                       in      com_api_type_pkg.t_medium_id
  , i_card_type_id                  in      com_api_type_pkg.t_tiny_id
  , i_service_id                    in      com_api_type_pkg.t_short_id         default null
  , i_detailed_entities_array_id    in      com_api_type_pkg.t_short_id         default null
  , o_over_amount                      out  com_api_type_pkg.t_money
  , o_credit_amount                    out  com_api_type_pkg.t_money
);

procedure lending_clearance(
    i_account                       in      acc_api_type_pkg.t_account_rec
  , i_operation                     in      opr_api_type_pkg.t_oper_rec
  , i_macros_type_id                in      com_api_type_pkg.t_tiny_id
  , i_bunch_type_id                 in      com_api_type_pkg.t_tiny_id
  , i_service_id                    in      com_api_type_pkg.t_short_id         default null
);

end;
/
