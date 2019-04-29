create or replace package app_api_address_pkg as
/*********************************************************
 *  API for Address in application <br />
 *  Created by Khougaev A.(khougaev@bpc.ru)  at 23.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_API_ADDRESS_PKG  <br />
 *  @headcom
 **********************************************************/

procedure process_address(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , o_address_id              out nocopy com_api_type_pkg.t_medium_id
);

end;
/
