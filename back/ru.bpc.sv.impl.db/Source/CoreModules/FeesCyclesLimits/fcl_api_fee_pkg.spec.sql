create or replace package fcl_api_fee_pkg as

function get_fee_amount(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id          default 1
  , io_base_currency    in out  com_api_type_pkg.t_curr_code
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date                                default null
  , i_calc_period       in      com_api_type_pkg.t_tiny_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_fee_included      in      com_api_type_pkg.t_boolean          default null
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_tier_amount       in      com_api_type_pkg.t_money            default null
  , i_tier_count        in      com_api_type_pkg.t_long_id          default null
) return com_api_type_pkg.t_money;

procedure get_fee_amount(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id          default 1
  , i_base_currency     in      com_api_type_pkg.t_curr_code
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date                                default null
  , i_calc_period       in      com_api_type_pkg.t_tiny_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_fee_included      in      com_api_type_pkg.t_boolean          default null
  , io_fee_currency     in out  com_api_type_pkg.t_curr_code
  , o_fee_amount           out  com_api_type_pkg.t_money
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_tier_amount       in      com_api_type_pkg.t_money            default null
  , i_tier_count        in      com_api_type_pkg.t_long_id          default null
  , i_oper_date         in      date                                default null
);

procedure start_counter(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure stop_counter(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value       
  , i_object_id         in      com_api_type_pkg.t_long_id          
  , i_end_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
);

function select_fee(
    i_fee          in  fcl_api_type_pkg.t_fee
  , i_fee_tier     in  fcl_api_type_pkg.t_fee_tier_tab
  , i_fees         in  com_api_type_pkg.t_varchar2_tab
) return com_api_type_pkg.t_param_value;

procedure save_fee(
    io_fee_id       in out          com_api_type_pkg.t_short_id
  , i_entity_type   in              com_api_type_pkg.t_dict_value
  , i_object_id     in              com_api_type_pkg.t_long_id
  , i_attr_name     in              com_api_type_pkg.t_name
  , i_percent_rate  in              com_api_type_pkg.t_money
  , i_product_id    in              com_api_type_pkg.t_short_id
  , i_service_id    in              com_api_type_pkg.t_short_id
  , i_eff_date      in              date
  , i_fee_currency  in              com_api_type_pkg.t_curr_code
  , i_fee_type      in              com_api_type_pkg.t_dict_value
  , i_fee_rate_calc in              com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
  , i_fee_base_calc in              com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
  , i_length_type   in              com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.CYCLE_LENGTH_YEAR
  , i_inst_id       in              com_api_type_pkg.t_inst_id      default null
  , i_split_hash    in              com_api_type_pkg.t_tiny_id      default null
  , i_search_fee    in              com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab
);

end;
/
