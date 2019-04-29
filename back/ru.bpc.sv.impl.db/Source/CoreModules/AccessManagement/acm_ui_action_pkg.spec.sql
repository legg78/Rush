create or replace package acm_ui_action_pkg as
/*********************************************************
*  UI for menu actions  <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 15.06.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_ACTION_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_call_mode             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_type           in      com_api_type_pkg.t_dict_value
  , i_group_id              in      com_api_type_pkg.t_tiny_id
  , i_section_id            in      com_api_type_pkg.t_tiny_id
  , i_priv_id               in      com_api_type_pkg.t_short_id
  , i_priv_object_id        in      com_api_type_pkg.t_long_id
  , i_is_default            in      com_api_type_pkg.t_boolean      default null
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_type_lov_id    in      com_api_type_pkg.t_tiny_id
);

procedure modify(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_call_mode             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_type           in      com_api_type_pkg.t_dict_value
  , i_group_id              in      com_api_type_pkg.t_tiny_id
  , i_section_id            in      com_api_type_pkg.t_tiny_id
  , i_priv_id               in      com_api_type_pkg.t_short_id
  , i_priv_object_id        in      com_api_type_pkg.t_long_id
  , i_is_default            in      com_api_type_pkg.t_boolean      default null
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_type_lov_id    in      com_api_type_pkg.t_tiny_id
);

procedure remove(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
);

end acm_ui_action_pkg;
/
