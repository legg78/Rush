create or replace package app_api_structure_pkg as
/*******************************************************************
*  API for application's structure <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 01.01.2010 <br />
*  Module: APP_API_STRUCTURE_PKG <br />
*  @headcom
******************************************************************/

procedure generate_xsd(
    i_appl_type         in       com_api_type_pkg.t_dict_value
  , i_flow_id           in       com_api_type_pkg.t_tiny_id     default null
);

function element_exists(
    i_appl_type         in       com_api_type_pkg.t_dict_value
  , i_element_id        in       com_api_type_pkg.t_short_id
  , i_parent_element_id in       com_api_type_pkg.t_short_id    default null
) return com_api_type_pkg.t_boolean;

end;
/
