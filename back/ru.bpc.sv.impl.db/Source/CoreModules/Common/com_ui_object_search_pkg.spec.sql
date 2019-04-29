create or replace package com_ui_object_search_pkg as
/*********************************************************
 *  Object search in the Web forms <br />
 *  Created by Truschelev O. (truschelev@bpcbt.com) at 19.12.2016 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate: 2016-12-19 19:30:00 +0400#$ <br />
 *  Remcwion: $LastChangedVersion: 1 $ <br />
 *  Module: com_ui_object_search_pkg <br />
 *  @headcom
 **********************************************************/

function get_mcc_name(
    i_mcc               in  com_api_type_pkg.t_mcc
) return                    com_api_type_pkg.t_name;

function get_inst_name(
    i_inst_id           in  com_api_type_pkg.t_inst_id
) return                    com_api_type_pkg.t_name;

function get_network_name(
    i_network_id        in  com_api_type_pkg.t_network_id
) return                    com_api_type_pkg.t_name;

function get_dictionary_name(
    i_dictionary_code   in  com_api_type_pkg.t_dict_value
) return                    com_api_type_pkg.t_name;

function get_sorting_clause(
    i_sorting_tab       in  com_param_map_tpt
  , i_use_id_sorting    in  com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
) return                    com_api_type_pkg.t_name;

function check_changed_param(
    i_old_param_tab     in  com_param_map_tpt
  , i_new_param_tab     in  com_param_map_tpt
) return                    com_api_type_pkg.t_boolean;

function is_used_sorting(
    i_is_first_call     in     com_api_type_pkg.t_boolean
  , i_sorting_count     in     com_api_type_pkg.t_tiny_id
  , i_row_count         in     com_api_type_pkg.t_long_id
  , i_mask_error        in     com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_boolean;

procedure start_search(
    i_is_first_call     in     com_api_type_pkg.t_boolean
);

procedure finish_search(
    i_is_first_call     in     com_api_type_pkg.t_boolean
  , i_row_count         in     com_api_type_pkg.t_long_id
  , i_sql_statement     in     com_api_type_pkg.t_sql_statement
  , i_is_failed         in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_sqlerrm_text      in     com_api_type_pkg.t_full_desc     default null
);

function get_char_value(
    i_param_tab         in out nocopy com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_name;

function get_date_value(
    i_param_tab         in out nocopy com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return date;

function get_number_value(
    i_param_tab         in out nocopy com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return number;

end com_ui_object_search_pkg;
/
