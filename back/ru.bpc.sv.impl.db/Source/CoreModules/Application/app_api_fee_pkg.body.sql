create or replace package body app_api_fee_pkg as

procedure process_fee(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
begin
    -- trc_log_pkg.debug('app_api_fee_pkg.process_fee: i_appl_data_id='||i_appl_data_id);
    null;
end;

end;
/
