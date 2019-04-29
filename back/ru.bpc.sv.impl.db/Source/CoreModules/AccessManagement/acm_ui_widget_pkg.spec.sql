create or replace package acm_ui_widget_pkg as
/********************************************************* 
 *  Interface for widgets <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 29.02.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acm_ui_widget_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure add_widget(
    o_id             out com_api_type_pkg.t_tiny_id
  , o_seqnum         out com_api_type_pkg.t_seqnum
  , i_path        in     com_api_type_pkg.t_full_desc
  , i_css_name    in     com_api_type_pkg.t_name
  , i_is_external in     com_api_type_pkg.t_boolean
  , i_width       in     com_api_type_pkg.t_tiny_id
  , i_height      in     com_api_type_pkg.t_tiny_id
  , i_priv_id     in     com_api_type_pkg.t_tiny_id
  , i_params_path in     com_api_type_pkg.t_full_desc
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
);

procedure modify_widget(
    i_id          in     com_api_type_pkg.t_tiny_id
  , io_seqnum     in out com_api_type_pkg.t_seqnum
  , i_path        in     com_api_type_pkg.t_full_desc
  , i_css_name    in     com_api_type_pkg.t_name
  , i_is_external in     com_api_type_pkg.t_boolean
  , i_width       in     com_api_type_pkg.t_tiny_id
  , i_height      in     com_api_type_pkg.t_tiny_id
  , i_priv_id     in     com_api_type_pkg.t_tiny_id
  , i_params_path in     com_api_type_pkg.t_full_desc
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
);

procedure remove_widget(
    i_id          in     com_api_type_pkg.t_tiny_id
  , i_seqnum      in     com_api_type_pkg.t_seqnum
);

end;
/
