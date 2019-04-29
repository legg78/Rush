create or replace package frp_ui_case_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP case
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 16.06.2010
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_CASE_PKG
* @headcom
*
*************************************************************/ 

procedure add_case(
    o_id              out  com_api_type_pkg.t_tiny_id 
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_hist_depth   in      com_api_type_pkg.t_tiny_id
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
);

procedure modify_case(
    i_id           in      com_api_type_pkg.t_tiny_id
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_hist_depth   in      com_api_type_pkg.t_tiny_id  
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
);

procedure remove_case(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
);

end;
/
