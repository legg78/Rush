create or replace package app_ui_flow_step_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author: filimonov $ <br />
*  $LastChangedDate:: 2011-12-09 19:19:12 +0400#$ <br />
*  Revision: $LastChangedRevision: 14428 $ <br />
*  Module: app_ui_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                out     com_api_type_pkg.t_tiny_id
  , o_seqnum            out     com_api_type_pkg.t_tiny_id
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_step_label        in      com_api_type_pkg.t_name
  , i_appl_status       in      com_api_type_pkg.t_dict_value
  , i_step_source       in      com_api_type_pkg.t_name
  , i_read_only         in      com_api_type_pkg.t_boolean
  , i_display_order     in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
);

procedure modify(
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_step_label        in      com_api_type_pkg.t_name
  , i_appl_status       in      com_api_type_pkg.t_dict_value
  , i_step_source       in      com_api_type_pkg.t_name
  , i_read_only         in      com_api_type_pkg.t_boolean
  , i_display_order     in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
);

procedure remove(
    i_id                in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_tiny_id
);

end app_ui_flow_step_pkg;
/
