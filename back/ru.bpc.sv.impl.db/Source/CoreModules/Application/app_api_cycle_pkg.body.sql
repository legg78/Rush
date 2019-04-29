create or replace package body app_api_cycle_pkg as

procedure process_cycle(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_cycle_type           com_api_type_pkg.t_dict_value;
    l_cycle_id             com_api_type_pkg.t_short_id;
    l_start_date           date;
    l_end_date             date;
    l_mod_id               com_api_type_pkg.t_tiny_id;
    l_real_cycle_type      com_api_type_pkg.t_dict_value;
    l_attr_value_id        com_api_type_pkg.t_long_id;
begin
    -- trc_log_pkg.debug('app_api_cycle_pkg.process_cycle: i_appl_data_id='||i_appl_data_id);
    null;
end;

end;
/
