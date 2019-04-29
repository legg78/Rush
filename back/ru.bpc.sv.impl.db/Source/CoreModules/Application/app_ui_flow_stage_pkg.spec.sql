create or replace package app_ui_flow_stage_pkg as
/*******************************************************************
*  API for application's flow stage <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate: 2010-08-04 11:44:00 +0400#$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id              out  com_api_type_pkg.t_short_id
  , o_seqnum          out  com_api_type_pkg.t_tiny_id
  , i_flow_id      in      com_api_type_pkg.t_tiny_id
  , i_appl_status  in      com_api_type_pkg.t_dict_value
  , i_handler      in      com_api_type_pkg.t_name
  , i_handler_type in      com_api_type_pkg.t_dict_value
  , i_reject_code  in      com_api_type_pkg.t_dict_value    default null
  , i_role_id      in      com_api_type_pkg.t_short_id      default null
);

procedure modify(
    i_id           in      com_api_type_pkg.t_short_id
  , io_seqnum      in out  com_api_type_pkg.t_tiny_id
  , i_flow_id      in      com_api_type_pkg.t_tiny_id
  , i_appl_status  in      com_api_type_pkg.t_dict_value
  , i_handler      in      com_api_type_pkg.t_name
  , i_handler_type in      com_api_type_pkg.t_dict_value
  , i_reject_code  in      com_api_type_pkg.t_dict_value    default null
  , i_role_id      in      com_api_type_pkg.t_short_id      default null
);

procedure remove(
    i_id           in      com_api_type_pkg.t_short_id
  , i_seqnum       in      com_api_type_pkg.t_tiny_id
);

/*
 * Procedure returns application status and reject code for an initial stage of some specified flow ID
 * (that actually is a stage without transitions from other stages to it, or first stage in the flow).
 */
procedure get_initial_stage(
    i_flow_id      in      com_api_type_pkg.t_tiny_id
  , o_appl_status     out  com_api_type_pkg.t_dict_value
  , o_reject_code     out  com_api_type_pkg.t_dict_value
);

/*
 * Function returns application status of initial stage for specified flow ID.
 */
function get_initial_status(
    i_flow_id      in      com_api_type_pkg.t_tiny_id
)
return com_api_type_pkg.t_dict_value;

end;
/
