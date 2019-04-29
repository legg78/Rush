create or replace package body evt_ui_status_pkg as

procedure change_status(
    i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_reason                in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_event_date            in      date                             default null
) is
    l_params                        com_api_type_pkg.t_param_tab;
begin
    evt_api_status_pkg.change_status(
        i_event_type    => i_event_type
      , i_initiator     => i_initiator
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_reason        => i_reason
      , i_eff_date      => i_eff_date
      , i_params        => l_params
      , i_event_date    => i_event_date
    );
end;

function get_object_status (
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value is
    l_result                        com_api_type_pkg.t_dict_value;
begin
    case i_entity_type
        when prc_api_const_pkg.ENTITY_TYPE_SESSION then
            select result_code
              into l_result
              from prc_session
             where id = i_object_id;
        when prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE then
            select status
              into l_result
              from prc_session_file
             where id = i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'UNKNOWN_ENTITY_TYPE'
          , i_env_param1 => i_entity_type
        );
    end case;
    
    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'OBJECT_NOT_FOUND'
          , i_env_param1    => i_entity_type
          , i_env_param2    => i_object_id
        );
end;

procedure change_event_status_date(
    i_status_log_id         in      com_api_type_pkg.t_long_id
  , i_date                  in      date
)
is
begin
    if i_date is not null
        and i_status_log_id is not null
    then
        update evt_status_log_vw
           set event_date = i_date
         where id = i_status_log_id;
    end if;
end;

function get_status_reason(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value is
begin
    return
        evt_api_status_pkg.get_status_reason(
            i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_raise_error   => com_api_const_pkg.FALSE
        );
end get_status_reason;

end;
/
