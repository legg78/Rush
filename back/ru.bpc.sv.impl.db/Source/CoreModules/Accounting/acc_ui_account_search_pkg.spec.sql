create or replace package acc_ui_account_search_pkg is
/************************************************************
 * User interface for displaying accounts in Issuing and Acquiring <br />
 * Created by Alalykin A.(alalykin@bpcbt.com) at 17.04.2014 <br />
 * Last changed by $Author: Alalykin $ <br />
 * $LastChangedDate:: 2014-04-17 00:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 1 $ <br />
 * Module: acc_ui_account_search_pkg <br />
 * @headcom
 ************************************************************/

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_row_count         in      com_api_type_pkg.t_medium_id  default null
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
);

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
);

end acc_ui_account_search_pkg;
/
