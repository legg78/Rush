create or replace package app_api_contact_pkg as
/*******************************************************************
*  API for application contacts <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 22.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                        $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_CONTACT_PKG <br />
*  @headcom
******************************************************************/

/*
<pre>
 * Process of contact details
 * @i_appl_data_id
 * @i_parent_appl_data_id
 * @io_appl_data
 * @i_object_id
 * @i_entity_type
 * @i_person_id
</pre>
 */
procedure process_contact(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id        default null
);

end;
/
