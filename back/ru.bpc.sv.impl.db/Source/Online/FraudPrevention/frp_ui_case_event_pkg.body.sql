create or replace package body frp_ui_case_event_pkg as

procedure add_case_event(
    o_id                out  com_api_type_pkg.t_short_id 
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_event_type     in      com_api_type_pkg.t_dict_value
  , i_resp_code      in      com_api_type_pkg.t_dict_value
  , i_risk_threshold in      com_api_type_pkg.t_tiny_id
) is
begin
    select frp_case_event_seq.nextval into o_id from dual;
    
    o_seqnum := 1;

    insert into frp_case_event_vw(
        id
      , seqnum
      , case_id
      , event_type
      , resp_code
      , risk_threshold
    ) values (
        o_id
      , o_seqnum
      , i_case_id
      , i_event_type
      , i_resp_code 
      , i_risk_threshold
    );
end;

procedure modify_case_event(
    i_id             in      com_api_type_pkg.t_short_id 
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_event_type     in      com_api_type_pkg.t_dict_value
  , i_resp_code      in      com_api_type_pkg.t_dict_value
  , i_risk_threshold in      com_api_type_pkg.t_tiny_id
) is
begin
    update frp_case_event_vw
       set seqnum         = io_seqnum
         , case_id        = i_case_id
         , event_type     = i_event_type
         , resp_code      = i_resp_code 
         , risk_threshold = i_risk_threshold 
     where id           = i_id;
     
    io_seqnum := io_seqnum + 1;
    
end;

procedure remove_case_event(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
begin
    update frp_case_event_vw
       set seqnum  = i_seqnum
     where id      = i_id;
     
    delete frp_case_event_vw
     where id      = i_id;
     
end;

end;
/
