create or replace package com_ui_object_pkg as
/*********************************************************
*  UI object descriptions <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.12.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_UI_OBJECT_PKG <br />
*  @headcom
**********************************************************/
function get_object_desc(
    i_entity_type   in    com_api_type_pkg.t_dict_value
  , i_object_id     in    com_api_type_pkg.t_long_id
  , i_lang          in    com_api_type_pkg.t_dict_value default get_user_lang
  , i_enable_empty  in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text;

end;
/
