create or replace package app_api_flexible_field_pkg as
/*********************************************************
 *  Acquiring application API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 28.05.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_flexible_field_pkg <br />
 *  @headcom
 **********************************************************/
procedure process_flexible_fields(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
);

end;
/
