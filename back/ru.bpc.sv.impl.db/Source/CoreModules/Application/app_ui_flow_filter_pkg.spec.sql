create or replace package app_ui_flow_filter_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_stage_id            in      com_api_type_pkg.t_short_id
  , i_struct_id           in      com_api_type_pkg.t_short_id
  , i_min_count           in      com_api_type_pkg.t_tiny_id
  , i_max_count           in      com_api_type_pkg.t_tiny_id
  , i_is_visible          in      com_api_type_pkg.t_boolean 
  , i_is_updatable        in      com_api_type_pkg.t_boolean
  , i_is_insertable       in      com_api_type_pkg.t_boolean
  , i_default_value_char  in      com_api_type_pkg.t_name
  , i_default_value_num   in      com_api_type_pkg.t_rate
  , i_default_value_date  in      date
);

procedure modify(
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_tiny_id
  , i_stage_id            in      com_api_type_pkg.t_short_id
  , i_struct_id           in      com_api_type_pkg.t_short_id
  , i_min_count           in      com_api_type_pkg.t_tiny_id
  , i_max_count           in      com_api_type_pkg.t_tiny_id
  , i_is_visible          in      com_api_type_pkg.t_boolean 
  , i_is_updatable        in      com_api_type_pkg.t_boolean
  , i_is_insertable       in      com_api_type_pkg.t_boolean
  , i_default_value_char  in      com_api_type_pkg.t_name
  , i_default_value_num   in      com_api_type_pkg.t_rate
  , i_default_value_date  in      date
);

procedure remove( 
    i_id      in  com_api_type_pkg.t_short_id
  , i_seqnum  in  com_api_type_pkg.t_tiny_id
);

end;
/
