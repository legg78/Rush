create or replace package com_ui_lov_pkg as
/*********************************************************
 *  UI for LOVs <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 01.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: com_ui_lov_pkg   <br />
 *  @headcom
 **********************************************************/

procedure get_lov(
    o_ref_cur              out  sys_refcursor
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt                   default null
  , i_add_where         in      com_api_type_pkg.t_text             default null
  , i_appearance        in      com_api_type_pkg.t_dict_value       default null
);

procedure get_lov_codes(
    o_code_tab             out  com_api_type_pkg.t_name_tab
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt                   default null
  , i_add_where         in      com_api_type_pkg.t_text             default null
);

function get_name(
  i_lov_id              in      com_api_type_pkg.t_tiny_id
  , i_code              in      varchar2
  , i_param_map         in      com_param_map_tpt                   default null
) return varchar2;

procedure add_lov(
    o_lov_id               out  com_api_type_pkg.t_tiny_id
  , i_dict              in      com_api_type_pkg.t_dict_value       default null
  , i_lov_query         in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
  , i_module_code       in      com_api_type_pkg.t_module_code      default null
  , i_sort_mode         in      com_api_type_pkg.t_dict_value       default com_api_const_pkg.LOV_SORT_DEFAULT
  , i_appearance        in      com_api_type_pkg.t_dict_value       default com_api_const_pkg.LOV_APPEARANCE_DEFAULT
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
  , i_is_parametrized   in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
);

procedure modify (
    i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_dict              in      com_api_type_pkg.t_dict_value
  , i_lov_query         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_sort_mode         in      com_api_type_pkg.t_dict_value
  , i_appearance        in      com_api_type_pkg.t_dict_value
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_is_parametrized   in      com_api_type_pkg.t_boolean
  , i_module_code       in      com_api_type_pkg.t_module_code      default null
);

function check_lov_value(
    i_lov_id            in      com_api_type_pkg.t_tiny_id
    , i_value           in      com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean;

function get_char_param(
    i_param_name        in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_param_value;

function get_number_param(
    i_param_name        in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_long_id;

function get_date_param(
    i_param_name        in      com_api_type_pkg.t_name
) return date;

function is_editable_lov(
    i_lov_id                  in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean;

end com_ui_lov_pkg;
/
