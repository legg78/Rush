create or replace package body crd_cst_interest_pkg as

function get_fee_amount(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id          default 1
  , io_base_currency    in out  com_api_type_pkg.t_curr_code
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date                                default null
  , i_calc_period       in      com_api_type_pkg.t_tiny_id          default 0
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_fee_included      in      com_api_type_pkg.t_boolean          default null
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value
  , i_debt_id           in      com_api_type_pkg.t_long_id
  , i_balance_type      in      com_api_type_pkg.t_dict_value
  , i_debt_intr_id      in      com_api_type_pkg.t_long_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_money
is
begin
    -- check algorithm
    return 0;
end;

function charge_interest_needed(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
)return com_api_type_pkg.t_boolean
is
begin
    --check debt
    return com_api_type_pkg.TRUE;
end;

function get_fee_desc(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value   default null
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_fee_id            in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_eff_date          in      date                            default null
) return com_api_type_pkg.t_full_desc
is
begin
    return fcl_ui_fee_pkg.get_fee_desc(i_fee_id => i_fee_id);
end;

function get_fee_desc(
    i_debt_intr_id      in      com_api_type_pkg.t_long_id
  , i_fee_id            in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc
is
begin
    return fcl_ui_fee_pkg.get_fee_desc(i_fee_id => i_fee_id);
end;

function get_interest_charge_event_type(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_period_date       in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value
is
begin
    return i_event_type;
end;

end;
/
