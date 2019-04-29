create or replace package prd_ui_customer_pkg is
/*********************************************************
*  UI for customers <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 16.08.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: prd_ui_customer_pkg <br />
*  @headcom
**********************************************************/

procedure modify_customer(
    i_customer_id     in      com_api_type_pkg.t_medium_id
  , i_ext_entity_type in      com_api_type_pkg.t_dict_value
  , i_ext_object_id   in      com_api_type_pkg.t_long_id
);

procedure clear_ext_fields(
    i_customer_id     in      com_api_type_pkg.t_medium_id
);

function get_customer_name(
    i_customer_id     in       com_api_type_pkg.t_medium_id
  , i_lang            in       com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name;

end;
/
