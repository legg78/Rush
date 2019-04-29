create or replace package body app_ui_flow_transition_pkg as

procedure add(
    o_id                      out  com_api_type_pkg.t_tiny_id
  , o_seqnum                  out  com_api_type_pkg.t_tiny_id
  , i_stage_id             in      com_api_type_pkg.t_short_id
  , i_transition_stage_id  in      com_api_type_pkg.t_short_id
  , i_stage_result         in      com_api_type_pkg.t_name
  , i_event_type           in      com_api_type_pkg.t_dict_value default null
  , i_reason_code          in      com_api_type_pkg.t_dict_value default null
) is
begin
    select app_flow_transition_seq.nextval, 1
      into o_id, o_seqnum
      from dual;
    
    insert into app_flow_transition_vw (
        id
      , seqnum
      , stage_id
      , transition_stage_id
      , stage_result
      , event_type
      , reason_code
    ) values (
        o_id
      , o_seqnum
      , i_stage_id 
      , i_transition_stage_id
      , i_stage_result
      , i_event_type
      , i_reason_code
    );
end;

procedure modify(
    i_id                   in       com_api_type_pkg.t_tiny_id
  , io_seqnum              in  out  com_api_type_pkg.t_tiny_id
  , i_stage_id             in      com_api_type_pkg.t_short_id
  , i_transition_stage_id  in      com_api_type_pkg.t_short_id
  , i_stage_result         in      com_api_type_pkg.t_name
  , i_event_type           in      com_api_type_pkg.t_dict_value default null
  , i_reason_code          in      com_api_type_pkg.t_dict_value default null
) is
begin
    update app_flow_transition_vw
    set seqnum              = io_seqnum
      , stage_id            = i_stage_id
      , transition_stage_id = i_transition_stage_id
      , stage_result        = i_stage_result
      , event_type          = nvl(i_event_type, event_type)
      , reason_code         = i_reason_code
    where id                = i_id;
    
    io_seqnum := io_seqnum + 1;
end;

procedure remove( 
    i_id      in  com_api_type_pkg.t_short_id
  , i_seqnum  in  com_api_type_pkg.t_tiny_id
) is
begin
    update app_flow_transition_vw
    set seqnum  = i_seqnum
    where    id = i_id;
    
    delete from app_flow_transition_vw
    where id = i_id;
end;

end;
/
