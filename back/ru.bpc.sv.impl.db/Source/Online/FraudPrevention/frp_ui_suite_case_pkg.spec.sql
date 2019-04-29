create or replace package frp_ui_suite_case_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP Suite Case
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 12.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_SUITE_CASE_PKG
* @headcom
*
*************************************************************/ 

procedure add_suite_case(
    i_suite_id   in      com_api_type_pkg.t_tiny_id
  , i_case_id    in      com_api_type_pkg.t_tiny_id
  , i_priority   in      com_api_type_pkg.t_tiny_id
);

procedure modify_suite_case(
    i_suite_id   in      com_api_type_pkg.t_tiny_id
  , i_case_id    in      com_api_type_pkg.t_tiny_id
  , i_priority   in      com_api_type_pkg.t_tiny_id
);

procedure remove_suite_case(
    i_suite_id   in      com_api_type_pkg.t_tiny_id
  , i_case_id    in      com_api_type_pkg.t_tiny_id
);

end;
/
