create or replace package prs_ui_batch_search_pkg is

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

procedure get_batch_counts(
    i_batch_id          in      com_api_type_pkg.t_short_id
  , o_card_count           out  com_api_type_pkg.t_short_id
  , o_pin_count            out  com_api_type_pkg.t_short_id
  , o_pin_mailer_count     out  com_api_type_pkg.t_short_id
  , o_embossing_count      out  com_api_type_pkg.t_short_id
);

end;
/
