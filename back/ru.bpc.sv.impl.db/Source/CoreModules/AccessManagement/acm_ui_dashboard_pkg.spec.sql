create or replace package acm_ui_dashboard_pkg as
/********************************************************* 
 *  Interface for dashboards <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 29.02.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acm_ui_dashboard_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure add_dashboard(
    o_id             out com_api_type_pkg.t_short_id
  , o_seqnum         out com_api_type_pkg.t_seqnum
  , i_user_id     in     com_api_type_pkg.t_short_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_is_shared   in     com_api_type_pkg.t_boolean
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
);

procedure modify_dashboard(
    i_id          in     com_api_type_pkg.t_short_id
  , io_seqnum     in out com_api_type_pkg.t_seqnum
  , i_user_id     in     com_api_type_pkg.t_short_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_is_shared   in     com_api_type_pkg.t_boolean
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
);

procedure remove_dashboard(
    i_id          in     com_api_type_pkg.t_tiny_id
  , i_seqnum      in     com_api_type_pkg.t_seqnum
);

procedure add_dashboard_user(
    o_id               out com_api_type_pkg.t_short_id 
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_dashboard_id  in     com_api_type_pkg.t_short_id 
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_is_default    in     com_api_type_pkg.t_boolean
);

procedure add_dashboard_widget(
    o_id                   out com_api_type_pkg.t_short_id 
  , o_seqnum               out com_api_type_pkg.t_seqnum
  , i_dashboard_id      in     com_api_type_pkg.t_short_id 
  , i_widget_id         in     com_api_type_pkg.t_short_id
  , i_row_number        in     com_api_type_pkg.t_short_id
  , i_column_number     in     com_api_type_pkg.t_short_id
  , i_is_refresh        in     com_api_type_pkg.t_boolean
  , i_refresh_interval  in     com_api_type_pkg.t_short_id
);

procedure modify_dashboard_widget(
    i_id                in     com_api_type_pkg.t_short_id
  , io_seqnum           in out com_api_type_pkg.t_seqnum
  , i_is_refresh        in     com_api_type_pkg.t_boolean
  , i_refresh_interval  in     com_api_type_pkg.t_short_id
);

procedure remove_dashboard_widget(
    i_id                in     com_api_type_pkg.t_short_id 
  , i_seqnum            in     com_api_type_pkg.t_seqnum
);

end;
/
