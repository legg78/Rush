create or replace package body app_ui_flow_stage_pkg as

procedure add(
    o_id              out  com_api_type_pkg.t_short_id
  , o_seqnum          out  com_api_type_pkg.t_tiny_id
  , i_flow_id      in      com_api_type_pkg.t_tiny_id
  , i_appl_status  in      com_api_type_pkg.t_dict_value
  , i_handler      in      com_api_type_pkg.t_name
  , i_handler_type in      com_api_type_pkg.t_dict_value
  , i_reject_code  in      com_api_type_pkg.t_dict_value    default null
  , i_role_id      in      com_api_type_pkg.t_short_id      default null
) is
begin
    select app_flow_stage_seq.nextval, 1
      into o_id, o_seqnum
      from dual;

    insert into app_flow_stage_vw (
        id
      , seqnum
      , flow_id
      , appl_status
      , handler
      , handler_type
      , reject_code
      , role_id
    ) values (
        o_id
      , o_seqnum
      , i_flow_id
      , i_appl_status
      , i_handler
      , i_handler_type
      , i_reject_code
      , i_role_id
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'FLOW_STAGE_ALREADY_EXIST'
        );
end add;

procedure modify(
    i_id           in      com_api_type_pkg.t_short_id
  , io_seqnum      in out  com_api_type_pkg.t_tiny_id
  , i_flow_id      in      com_api_type_pkg.t_tiny_id
  , i_appl_status  in      com_api_type_pkg.t_dict_value
  , i_handler      in      com_api_type_pkg.t_name
  , i_handler_type in      com_api_type_pkg.t_dict_value
  , i_reject_code  in      com_api_type_pkg.t_dict_value    default null
  , i_role_id      in      com_api_type_pkg.t_short_id      default null
) is
begin
    update app_flow_stage_vw
       set seqnum       = io_seqnum
         , flow_id      = i_flow_id
         , appl_status  = i_appl_status
         , handler      = i_handler
         , handler_type = i_handler_type
         , reject_code  = i_reject_code
         , role_id      = i_role_id
     where id = i_id;

    io_seqnum := io_seqnum + 1;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'FLOW_STAGE_ALREADY_EXIST'
        );
end modify;

procedure remove(
    i_id           in      com_api_type_pkg.t_short_id
  , i_seqnum       in      com_api_type_pkg.t_tiny_id
) is
begin
    update app_flow_stage_vw
       set seqnum  = i_seqnum
     where id      = i_id;

    delete from app_flow_stage_vw
     where id      = i_id;
end;

/*
 * Procedure returns application status and reject code for an initial stage of some specified flow ID
 * (that actually is a stage without transitions from other stages to it, or first stage in the flow).
 */
procedure get_initial_stage(
    i_flow_id      in      com_api_type_pkg.t_tiny_id
  , o_appl_status     out  com_api_type_pkg.t_dict_value
  , o_reject_code     out  com_api_type_pkg.t_dict_value
) is
begin
    -- Try to find 1st (initial) application stage believing that
    -- there are no another stages in the flow with transition to this initial stage
    -- (i.e. there is no cycles in stage transitions involving initial stage)
    begin
        select st.appl_status
             , st.reject_code
          into o_appl_status
             , o_reject_code
          from      app_flow_stage      st
          left join app_flow_transition tr    on tr.transition_stage_id = st.id
         where st.flow_id = i_flow_id
           and tr.id is null;
    exception
        -- Otherwise, consider stage with minimal ID is an initial one
        when no_data_found or too_many_rows then
            trc_log_pkg.debug(
                i_text => 'get_initial_stage: no data found - get min for ' || i_flow_id
            );
            select min(stage.appl_status) keep (dense_rank first order by stage.id)
                 , min(stage.reject_code) keep (dense_rank first order by stage.id)
              into o_appl_status
                 , o_reject_code
              from app_flow_stage stage
             where stage.flow_id = i_flow_id;
    end;
end get_initial_stage;

/*
 * Function returns application status of initial stage for specified flow ID.
 */
function get_initial_status(
    i_flow_id      in      com_api_type_pkg.t_tiny_id
)
return com_api_type_pkg.t_dict_value
is
    l_appl_status          com_api_type_pkg.t_dict_value;
    l_reject_code          com_api_type_pkg.t_dict_value;
begin
    get_initial_stage(
        i_flow_id      => i_flow_id
      , o_appl_status  => l_appl_status
      , o_reject_code  => l_reject_code
    );
    return l_appl_status;
end;

end;
/
