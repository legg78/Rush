create or replace package frp_ui_case_event_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP Case Event
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 12.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_CASE_EVENT_PKG
* @headcom
*
*************************************************************/ 

procedure add_case_event(
    o_id                out  com_api_type_pkg.t_short_id 
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_event_type     in      com_api_type_pkg.t_dict_value
  , i_resp_code      in      com_api_type_pkg.t_dict_value
  , i_risk_threshold in      com_api_type_pkg.t_tiny_id
);

procedure modify_case_event(
    i_id             in      com_api_type_pkg.t_short_id 
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_event_type     in      com_api_type_pkg.t_dict_value
  , i_resp_code      in      com_api_type_pkg.t_dict_value
  , i_risk_threshold in      com_api_type_pkg.t_tiny_id
);

procedure remove_case_event(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
);

end;
/
