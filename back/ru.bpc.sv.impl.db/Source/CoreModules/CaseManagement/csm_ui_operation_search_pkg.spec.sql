create or replace package csm_ui_operation_search_pkg is

procedure get_ref_cur(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt := null
);

procedure get_row_count(
    o_row_count         out     com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
);

end csm_ui_operation_search_pkg;
/
