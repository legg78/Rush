create or replace package com_ui_dictionary_pkg as

/*********************************************************
*  UI for dictionary <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 14.09.2009 <br />
*  Last changed by $Author: Fomichev $ <br />
*  $LastChangedDate:: 2010-06-07 16:20:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 2432 $ <br />
*  Module: com_ui_dictionary_pkg <br />
*  @headcom
**********************************************************/

procedure add_dictionary (
    i_code         in      com_api_type_pkg.t_dict_value
  , i_short_desc   in      com_api_type_pkg.t_short_desc
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_is_numeric   in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_is_editable  in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_module_code  in      com_api_type_pkg.t_dict_value  default null
);

procedure add_article (
    i_dict         in      com_api_type_pkg.t_dict_value
  , i_code         in      com_api_type_pkg.t_dict_value
  , i_short_desc   in      com_api_type_pkg.t_short_desc
  , i_full_desc    in      com_api_type_pkg.t_full_desc   default null
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_is_numeric   in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_is_editable  in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_module_code  in      com_api_type_pkg.t_dict_value  default null
);

procedure modify_article (
    i_dict         in      com_api_type_pkg.t_dict_value
  , i_code         in      com_api_type_pkg.t_dict_value
  , i_short_desc   in      com_api_type_pkg.t_short_desc
  , i_full_desc    in      com_api_type_pkg.t_full_desc   default null
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_module_code  in      com_api_type_pkg.t_dict_value  default null
);

procedure remove_article (
    i_dict         in      com_api_type_pkg.t_dict_value
  , i_code         in      com_api_type_pkg.t_dict_value
  , i_is_leaf      in      com_api_type_pkg.t_boolean     default null
);

end;
/
