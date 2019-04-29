create or replace package frp_ui_matrix_value_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP Matrix Value
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 11.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_MATRIX_VALUE_PKG
* @headcom
*
*************************************************************/ 

procedure add_matrix_value(
    o_id              out  com_api_type_pkg.t_short_id 
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_matrix_id    in      com_api_type_pkg.t_tiny_id
  , i_x_value      in      com_api_type_pkg.t_name
  , i_y_value      in      com_api_type_pkg.t_name
  , i_matrix_value in      com_api_type_pkg.t_name
);

procedure modify_matrix_value(
    i_id           in      com_api_type_pkg.t_short_id 
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_matrix_id    in      com_api_type_pkg.t_tiny_id
  , i_x_value      in      com_api_type_pkg.t_name
  , i_y_value      in      com_api_type_pkg.t_name
  , i_matrix_value in      com_api_type_pkg.t_name
);

procedure remove_matrix_value(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) ;

end;
/
