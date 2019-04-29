create or replace package com_api_object_pkg as
/*********************************************************
*  Common object <br />
*  Created by Nick (filimonov@bpcbt.com)  at 13.03.2019 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_api_object_pkg <br />
*  @headcom
**********************************************************/

function get_object_number(
    i_entity_type       in com_api_type_pkg.t_dict_value
  , i_object_id         in com_api_type_pkg.t_long_id
  , i_mask_error        in com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name;

end com_api_object_pkg;
/
