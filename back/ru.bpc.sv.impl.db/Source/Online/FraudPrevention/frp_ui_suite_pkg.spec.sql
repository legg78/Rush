create or replace package frp_ui_suite_pkg as
/************************************************************* 
* 
*   User Interface procedures for FRP Suite
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 11.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2010-06-18 15:12:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_SUITE_PKG
* @headcom
*
*************************************************************/ 

procedure add_suite(
    o_id              out  com_api_type_pkg.t_tiny_id 
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
);

procedure modify_suite(
    i_id           in      com_api_type_pkg.t_tiny_id
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_inst_id      in      com_api_type_pkg.t_inst_id  
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
);

procedure remove_suite(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
);

procedure add_suite_object(
    o_suite_object_id      out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_suite_id          in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_start_date        in      date
  , i_end_date          in      date
);

procedure modify_suite_object(
    i_suite_object_id   in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_end_date          in      date
);

procedure remove_suite_object(
    i_suite_object_id   in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
