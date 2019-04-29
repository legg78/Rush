create or replace package app_api_service_pkg as
/******************************************************************
 * The api for app service <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 26.11.2010 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: app_api_service_pkg <br />
 * @headcom
 ******************************************************************/
type t_threshold_rec    is record (
    sum_threshold          com_api_type_pkg.t_money
    , count_threshold      com_api_type_pkg.t_money
);
type    t_threshold_tab          is table of t_threshold_rec index by binary_integer;

procedure process_entity_service(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_name         in            com_api_type_pkg.t_name
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , io_params              in out nocopy com_api_type_pkg.t_param_tab
);

procedure close_service(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_forced               in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
);

procedure process_attribute(
    i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_params               in            com_api_type_pkg.t_param_tab
  , i_service_status       in            com_api_type_pkg.t_dict_value  default null
  , i_campaign_id          in            com_api_type_pkg.t_short_id    default null
  , i_start_date           in            date                           default null
  , i_end_date             in            date                           default null
);

end app_api_service_pkg;
/
