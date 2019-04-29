create or replace package body fcl_cst_limit_pkg as

procedure calculate_limit_counter_count(
    i_counter_algorithm    in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                                default null
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , o_count_curr           out  com_api_type_pkg.t_long_id 
) is
begin
    o_count_curr := 0; 
end;


procedure calculate_limit_counter_sum(
    i_counter_algorithm    in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                                default null
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , o_sum_curr             out  com_api_type_pkg.t_money
) is
begin
    o_sum_curr   := 0;
end;

end;
/
