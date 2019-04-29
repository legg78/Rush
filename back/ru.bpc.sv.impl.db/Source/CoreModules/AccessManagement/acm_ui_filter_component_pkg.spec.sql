create or replace package acm_ui_filter_component_pkg as
/*********************************************************
*  UI for access management filter component<br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 18.05.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_FILTER_COMPONENT_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_filter_id     in     com_api_type_pkg.t_short_id
  , i_name          in     com_api_type_pkg.t_name
  , i_value         in     com_api_type_pkg.t_name
);

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_filter_id     in     com_api_type_pkg.t_short_id
  , i_name          in     com_api_type_pkg.t_name
  , i_value         in     com_api_type_pkg.t_name
);

procedure modify_package(
    i_filter_id     in     com_api_type_pkg.t_short_id
  , i_package       in     com_param_map_tpt
);

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_seqnum
);

end acm_ui_filter_component_pkg;
/