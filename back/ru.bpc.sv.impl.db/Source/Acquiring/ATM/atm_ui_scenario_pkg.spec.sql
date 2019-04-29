create or replace package atm_ui_scenario_pkg as
/*******************************************************************
*  API for application's structure <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 13.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_structure_pkg <br />
*  @headcom
******************************************************************/

procedure add_scenario(
    o_id              out  com_api_type_pkg.t_tiny_id
  , i_luno         in      com_api_type_pkg.t_medium_id
  , i_atm_type     in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
  , i_lang         in      com_api_type_pkg.t_dict_value   default null
);

procedure modify_scenario(
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_luno              in      com_api_type_pkg.t_medium_id
  , i_atm_type          in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
);

procedure remove_scenario(
    i_id       in      com_api_type_pkg.t_tiny_id
);

procedure add_scenario_config(
    o_id                   out  com_api_type_pkg.t_tiny_id
  , i_scenario_id       in      com_api_type_pkg.t_medium_id
  , i_config_type       in      com_api_type_pkg.t_dict_value
  , i_config_source     in out nocopy clob
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_file_name         in      com_api_type_pkg.t_name
) ;

procedure modify_scenario_config(
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_config_type       in      com_api_type_pkg.t_dict_value
  , i_config_source     in out nocopy clob
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_file_name         in      com_api_type_pkg.t_name
);

procedure remove_scenario_config(
    i_id  in      com_api_type_pkg.t_tiny_id

);

end atm_ui_scenario_pkg;
/
