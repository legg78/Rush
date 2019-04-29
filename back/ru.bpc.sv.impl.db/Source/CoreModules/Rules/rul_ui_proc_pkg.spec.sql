create or replace package rul_ui_proc_pkg is
/*********************************************************
*  User interface for Rules procedures <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 14.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure add (
    o_id                 out com_api_type_pkg.t_tiny_id
  , i_proc_name       in     com_api_type_pkg.t_name
  , i_category        in     com_api_type_pkg.t_dict_value
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
);

procedure modify (
    i_id              in     com_api_type_pkg.t_tiny_id
  , i_proc_name       in     com_api_type_pkg.t_name
  , i_category        in     com_api_type_pkg.t_dict_value
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
);
    
procedure remove (
    i_id              in     com_api_type_pkg.t_tiny_id
);

procedure add_param (
    o_id                 out com_api_type_pkg.t_short_id
  , i_proc_id         in     com_api_type_pkg.t_tiny_id
  , i_param_name      in     com_api_type_pkg.t_name
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_order           in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory    in     com_api_type_pkg.t_boolean
  , i_param_id        in     com_api_type_pkg.t_short_id
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
) ;

procedure modify_param (
    i_id              in     com_api_type_pkg.t_short_id
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_order           in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory    in     com_api_type_pkg.t_boolean
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
);
procedure remove_param (
    i_id              in     com_api_type_pkg.t_short_id
);

end;
/
