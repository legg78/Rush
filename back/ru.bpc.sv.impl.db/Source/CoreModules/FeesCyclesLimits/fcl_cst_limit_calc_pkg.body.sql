create or replace package body fcl_cst_limit_calc_pkg as

procedure calculate_limit_counter_count(
    i_counter_algorithm    in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                                default null
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , o_count_curr           out  com_api_type_pkg.t_long_id 
  , i_limit_type           in   com_api_type_pkg.t_dict_value
  , i_product_id           in   com_api_type_pkg.t_long_id
  , i_limit_id             in   com_api_type_pkg.t_long_id
) is
begin
    fcl_cst_limit_pkg.calculate_limit_counter_count(
        i_counter_algorithm    => i_counter_algorithm
      , i_eff_date             => i_eff_date
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , o_count_curr           => o_count_curr
    ); 
end;


procedure calculate_limit_counter_sum(
    i_counter_algorithm    in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                                default null
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , o_sum_curr             out  com_api_type_pkg.t_money
  , i_limit_type           in   com_api_type_pkg.t_dict_value
  , i_product_id           in   com_api_type_pkg.t_long_id
  , i_limit_id             in   com_api_type_pkg.t_long_id
) is
begin
    fcl_cst_limit_pkg.calculate_limit_counter_sum(
        i_counter_algorithm    => i_counter_algorithm
      , i_eff_date             => i_eff_date
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , o_sum_curr             => o_sum_curr
    );
end;

end;
/
