create or replace package iss_ui_bin_search_pkg is
procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt := null
);

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
);

end;
/