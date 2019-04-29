create or replace package body evt_ui_status_map_pkg is
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
) is
begin
    o_id := evt_status_map_seq.nextval;
    o_seqnum := 1;

    insert into evt_status_map_vw (
        id
      , seqnum
      , event_type
      , initiator
      , initial_status
      , result_status
	  , priority
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_event_type
      , i_initiator
      , i_initial_status
      , i_result_status
	  , i_priority
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_STATUS_MAP'
        );    
end;

procedure modify (
    i_id             in     com_api_type_pkg.t_tiny_id
  , io_seqnum        in out com_api_type_pkg.t_tiny_id
  , i_event_type     in     com_api_type_pkg.t_dict_value
  , i_initiator      in     com_api_type_pkg.t_dict_value
  , i_initial_status in     com_api_type_pkg.t_dict_value
  , i_result_status  in     com_api_type_pkg.t_dict_value
  , i_priority       in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_tiny_id := null
) is
begin
    update evt_status_map_vw
       set seqnum         = io_seqnum
         , event_type     = i_event_type
         , initiator      = i_initiator
         , initial_status = i_initial_status 
         , result_status  = i_result_status  
         , priority       = i_priority	
         , inst_id        = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)	 
     where id = i_id;

    io_seqnum := io_seqnum + 1;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_STATUS_MAP'
        );    
    
end;

procedure remove (
    i_id      in     com_api_type_pkg.t_tiny_id
  , i_seqnum  in     com_api_type_pkg.t_tiny_id
) is
begin
    update evt_status_map_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from evt_status_map_vw
     where id = i_id;
end;

end;
/
