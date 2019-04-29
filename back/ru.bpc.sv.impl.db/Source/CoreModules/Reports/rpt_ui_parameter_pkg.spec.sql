create or replace package rpt_ui_parameter_pkg as
/*********************************************************
*  UI for report parametets <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 19.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RPT_UI_PARAMETER_PKG <br />
*  @headcom
**********************************************************/

procedure add_parameter(
    i_report_id        in  com_api_type_pkg.t_short_id
  , i_system_name      in  com_api_type_pkg.t_attr_name
  , i_param_label      in  com_api_type_pkg.t_name
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_data_type        in  com_api_type_pkg.t_attr_name
  , i_default_value_n  in  number
  , i_default_value_d  in  date
  , i_default_value_v  in  com_api_type_pkg.t_full_desc
  , i_is_mandatory     in  com_api_type_pkg.t_boolean
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lov_id           in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , o_param_id         out com_api_type_pkg.t_short_id
  , i_selection_form   in  com_api_type_pkg.t_name
);

procedure modify_parameter (
    i_param_id         in  com_api_type_pkg.t_short_id
  , i_system_name      in  com_api_type_pkg.t_attr_name
  , i_param_label      in  com_api_type_pkg.t_short_desc
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_is_mandatory     in  com_api_type_pkg.t_boolean
  , i_default_value_n  in  number
  , i_default_value_d  in  date
  , i_default_value_v  in  com_api_type_pkg.t_full_desc
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lov_id           in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , i_selection_form   in  com_api_type_pkg.t_name
);

procedure sync_parameters(
    i_report_id in      com_api_type_pkg.t_medium_id
);

procedure remove_parameter (
    i_param_id  in  com_api_type_pkg.t_short_id
);

procedure add_out_parameter(
    o_param_id         out com_api_type_pkg.t_short_id
  , i_report_id        in  com_api_type_pkg.t_short_id
  , i_param_label      in  com_api_type_pkg.t_name
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_data_type        in  com_api_type_pkg.t_attr_name
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , i_is_grouping      in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
  , i_is_sorting       in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
);

procedure modify_out_parameter (
    i_param_id         in  com_api_type_pkg.t_short_id
  , i_param_label      in  com_api_type_pkg.t_name
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , i_is_grouping      in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
  , i_is_sorting       in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
);

end;
/
