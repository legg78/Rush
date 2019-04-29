create or replace package rul_ui_name_base_param_pkg is
/*********************************************************
*  UI for naming base parameters <br />
*  Created by Khougaev A.(khougaev@bpcbt.com)  at 14.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate: 2010-04-27 17:29:49 +0400#$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_NAME_BASE_PARAM_PKG <br />
*  @headcom
**********************************************************/

procedure add (
    o_id                 out com_api_type_pkg.t_short_id
  , i_entity_type     in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_description     in     com_api_type_pkg.t_text
);

end rul_ui_name_base_param_pkg;
/
