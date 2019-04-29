create or replace package app_ui_flow_transition_pkg as

/*******************************************************************
*  API for application's flow transition <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate: 2010-08-04 11:44:00 +0400#$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_flow_pkg <br />
*  @headcom
******************************************************************/


procedure add(
    o_id                      out  com_api_type_pkg.t_tiny_id
  , o_seqnum                  out  com_api_type_pkg.t_tiny_id
  , i_stage_id             in      com_api_type_pkg.t_short_id
  , i_transition_stage_id  in      com_api_type_pkg.t_short_id
  , i_stage_result         in      com_api_type_pkg.t_name
  , i_event_type           in      com_api_type_pkg.t_dict_value default null
  , i_reason_code          in      com_api_type_pkg.t_dict_value default null
) ;

procedure modify(
    i_id                   in       com_api_type_pkg.t_tiny_id
  , io_seqnum              in  out  com_api_type_pkg.t_tiny_id
  , i_stage_id             in      com_api_type_pkg.t_short_id
  , i_transition_stage_id  in      com_api_type_pkg.t_short_id
  , i_stage_result         in      com_api_type_pkg.t_name
  , i_event_type           in      com_api_type_pkg.t_dict_value default null
  , i_reason_code          in      com_api_type_pkg.t_dict_value default null
);

procedure remove( 
    i_id      in  com_api_type_pkg.t_short_id
  , i_seqnum  in  com_api_type_pkg.t_tiny_id
);

end;
/
