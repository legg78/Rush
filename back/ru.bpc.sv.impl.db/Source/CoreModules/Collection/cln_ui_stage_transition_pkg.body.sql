create or replace package body cln_ui_stage_transition_pkg is

procedure add(
    o_id                     out com_api_type_pkg.t_short_id
  , o_seqnum                 out com_api_type_pkg.t_tiny_id
  , i_stage_id            in     com_api_type_pkg.t_short_id
  , i_transition_stage_id in     com_api_type_pkg.t_short_id
  , i_reason_code         in     com_api_type_pkg.t_dict_value
) is
begin
    o_id     := cln_stage_transition_seq.nextval;
    o_seqnum := 1;
    insert into cln_stage_transition_vw(
        id
      , seqnum
      , stage_id
      , transition_stage_id
      , reason_code
    ) values(
        o_id
      , o_seqnum
      , i_stage_id
      , i_transition_stage_id
      , i_reason_code
    );
end;

procedure modify(
    i_id                  in     com_api_type_pkg.t_short_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_stage_id            in     com_api_type_pkg.t_short_id
  , i_transition_stage_id in     com_api_type_pkg.t_short_id
  , i_reason_code         in     com_api_type_pkg.t_dict_value
)is
begin
    update cln_stage_transition_vw
       set stage_id            = i_stage_id
         , transition_stage_id = i_transition_stage_id
         , reason_code         = i_reason_code
     where id                  = i_id;
     
    io_seqnum := io_seqnum + 1;
end;

procedure remove(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
) is
begin
    update cln_stage_transition_vw
       set seqnum = i_seqnum
     where id     = i_id;
    
    delete cln_stage_transition_vw
     where id = i_id;
end;

function get_transition_count(
    i_case_id   in     com_api_type_pkg.t_long_id
  , i_status    in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_count
is
    l_count            com_api_type_pkg.t_count := 0 ;
    l_old_status       com_api_type_pkg.t_dict_value;
begin
    select status
      into l_old_status
      from cln_case c
      where c.id = i_case_id;

    select count(1)
      into l_count
      from cln_stage_transition st
         , cln_stage s
         , cln_stage t
    where st.stage_id            = s.id
      and s.status               = l_old_status
      and st.transition_stage_id = t.id
      and t.status               = i_status;
    
    return l_count;
end;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_status            in    com_api_type_pkg.t_dict_value
  , i_resolution        in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null
) is
begin
    cln_api_case_pkg.change_case_status(
        i_case_id           => i_case_id
      , i_status            => i_status
      , i_resolution        => i_resolution
      , i_activity_category => i_activity_category
      , i_activity_type     => i_activity_type
      , i_split_hash        => i_split_hash
    );
end;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_reason_code       in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null  
) is
begin
    cln_api_case_pkg.change_case_status(
        i_case_id           => i_case_id
      , i_reason_code       => i_reason_code
      , i_activity_category => i_activity_category
      , i_activity_type     => i_activity_type
      , i_split_hash        => i_split_hash
    );
end;

end cln_ui_stage_transition_pkg;
/
