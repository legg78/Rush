create or replace package frp_ui_fraud_search_pkg is
/********************************************************* 
 *  User Interface procedures for FRP Fraud search  <br /> 
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 06.06.2014 <br /> 
 *  Last changed by $Author: kondratyev $ <br /> 
 *  $LastChangedDate:: 2014-06-06 15:01:00 +0400#$ <br /> 
 *  Revision: $LastChangedRevision: 43029 $ <br /> 
 *  Module: frp_ui_fraud_search_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
);

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
);

end;
/
