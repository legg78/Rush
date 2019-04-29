create or replace package evt_ui_status_map_pkg is
/************************************************************
 UI for event status map <br />
 Created by Fomichev A.(fomichev@bpcbt.com)  at 23.06.2011  <br />
 Last changed by $Author: fomichev $  <br />
 $LastChangedDate:: 2011-06-23 18:19:34 +0400#$ <br />
 Revision: $LastChangedRevision: 9353 $ <br />
 Module: evt_ui_status_map_pkg <br />
 ************************************************************/
procedure add (
    o_id                out com_api_type_pkg.t_tiny_id
  , o_seqnum            out com_api_type_pkg.t_tiny_id
  , i_event_type     in     com_api_type_pkg.t_dict_value
  , i_initiator      in     com_api_type_pkg.t_dict_value
  , i_initial_status in     com_api_type_pkg.t_dict_value
  , i_result_status  in     com_api_type_pkg.t_dict_value
  , i_priority       in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_tiny_id := null
);

procedure modify (
    i_id             in     com_api_type_pkg.t_tiny_id
  , io_seqnum        in out com_api_type_pkg.t_tiny_id
  , i_event_type     in     com_api_type_pkg.t_dict_value
  , i_initiator      in     com_api_type_pkg.t_dict_value
  , i_initial_status in     com_api_type_pkg.t_dict_value
  , i_result_status  in     com_api_type_pkg.t_dict_value
  , i_priority       in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_tiny_id := null  
);

procedure remove (
    i_id      in     com_api_type_pkg.t_tiny_id
  , i_seqnum  in     com_api_type_pkg.t_tiny_id
);

end;
/
