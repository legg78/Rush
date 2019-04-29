create or replace package crd_ui_debt_search_pkg is
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

procedure get_interest_details(
    o_ref_cur           out        com_api_type_pkg.t_ref_cur
  , i_debt_id            in        com_api_type_pkg.t_long_id
  , i_sorting_tab        in        com_param_map_tpt
);

procedure get_interest_details_count(
    o_row_count         out        com_api_type_pkg.t_medium_id
  , i_debt_id            in        com_api_type_pkg.t_long_id
);

procedure get_unpaid_dpp_details(
    o_ref_cur           out        com_api_type_pkg.t_ref_cur
  , i_acount_id          in        com_api_type_pkg.t_account_id
  , i_sorting_tab        in        com_param_map_tpt
);

procedure get_unpaid_dpp_details_count(
    o_row_count         out        com_api_type_pkg.t_medium_id
  , i_account_id         in        com_api_type_pkg.t_account_id
);

end;
/
