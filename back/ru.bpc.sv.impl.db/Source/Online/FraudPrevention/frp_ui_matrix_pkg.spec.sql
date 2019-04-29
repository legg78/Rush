create or replace package frp_ui_matrix_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP Matrix
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 11.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_MATRIX_PKG
* @headcom
*
*************************************************************/ 

procedure add_matrix(
    o_id              out  com_api_type_pkg.t_short_id 
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_x_scale      in      com_api_type_pkg.t_name
  , i_y_scale      in      com_api_type_pkg.t_name
  , i_matrix_type  in      com_api_type_pkg.t_dict_value
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
);

procedure modify_matrix(
    i_id           in      com_api_type_pkg.t_short_id 
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_x_scale      in      com_api_type_pkg.t_name
  , i_y_scale      in      com_api_type_pkg.t_name
  , i_matrix_type  in      com_api_type_pkg.t_dict_value
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
);

procedure remove_matrix(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) ;

end;
/
