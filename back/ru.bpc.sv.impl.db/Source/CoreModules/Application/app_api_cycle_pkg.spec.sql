create or replace package app_api_cycle_pkg as

procedure process_cycle(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
);

end;
/
