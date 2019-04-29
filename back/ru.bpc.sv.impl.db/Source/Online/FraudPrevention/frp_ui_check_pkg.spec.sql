create or replace package frp_ui_check_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP Check
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 11.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_CHECK_PKG
* @headcom
*
*************************************************************/ 

procedure add_check(
    o_id                out  com_api_type_pkg.t_short_id 
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_check_type     in      com_api_type_pkg.t_dict_value
  , i_alert_type     in      com_api_type_pkg.t_dict_value
  , i_expression     in      com_api_type_pkg.t_name
  , i_risk_score     in      com_api_type_pkg.t_tiny_id
  , i_risk_matrix_id in      com_api_type_pkg.t_tiny_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
);

procedure modify_check(
    i_id             in      com_api_type_pkg.t_short_id 
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_check_type     in      com_api_type_pkg.t_dict_value
  , i_alert_type     in      com_api_type_pkg.t_dict_value
  , i_expression     in      com_api_type_pkg.t_name
  , i_risk_score     in      com_api_type_pkg.t_tiny_id
  , i_risk_matrix_id in      com_api_type_pkg.t_tiny_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
);

procedure remove_check(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
);

end;
/
