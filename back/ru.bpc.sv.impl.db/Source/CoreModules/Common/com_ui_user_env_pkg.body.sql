create or replace package body com_ui_user_env_pkg as
/***********************************************************
 * User context
 * Created by Filimonov A.(filimonov@bpc.ru)  at 08.08.2009
 * Module: COM_UI_USER_ENV_PKG
 * @headcom
************************************************************/

g_agent_id               com_api_type_pkg.t_agent_id;
g_inst_id                com_api_type_pkg.t_inst_id;
g_user_name              com_api_type_pkg.t_name;
g_user_id                com_api_type_pkg.t_short_id;
g_person_id              com_api_type_pkg.t_medium_id;
g_user_lang              com_api_type_pkg.t_dict_value;
g_sandbox                com_api_type_pkg.t_inst_id;
g_ip_address             com_api_type_pkg.t_name;
g_trail_id               com_api_type_pkg.t_long_id;
g_nls_numeric_characters com_api_type_pkg.t_name;
g_format_mask            com_api_type_pkg.t_name;

function get_user_lang return com_api_type_pkg.t_dict_value is
begin
    return g_user_lang;
end get_user_lang;

function get_user_agent return com_api_type_pkg.t_agent_id is
begin
    return g_agent_id;
end get_user_agent;

function get_user_inst return com_api_type_pkg.t_inst_id is
begin
    return g_inst_id;
end get_user_inst;

function get_user_name return com_api_type_pkg.t_name is
begin
  return g_user_name;
end;

function get_user_id return com_api_type_pkg.t_short_id is
begin
  return g_user_id;
end get_user_id;

function get_person_id return com_api_type_pkg.t_medium_id is
begin
  return g_person_id;
end get_person_id;

function get_user_sandbox return com_api_type_pkg.t_inst_id is
begin
    return g_sandbox;
end get_user_sandbox;

function get_user_ip_address return com_api_type_pkg.t_name is
begin
    return g_ip_address;
end;

procedure set_user_context_common(
    i_extended_mode in      com_api_type_pkg.t_boolean
  , i_user_name     in      com_api_type_pkg.t_name
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name
  , i_priv_name     in      com_api_type_pkg.t_name
  , io_status       in out  com_api_type_pkg.t_dict_value
  , i_param_map     in      com_param_map_tpt
  , i_entity_type   in      com_api_type_pkg.t_dict_value
  , i_object_id     in      com_api_type_pkg.t_long_id
  , i_container_id  in      com_api_type_pkg.t_short_id         default null
) is
    l_count                 com_api_type_pkg.t_short_id;
    l_user_name             com_api_type_pkg.t_name;
    l_ip_address            com_api_type_pkg.t_name;
    l_priv_id               com_api_type_pkg.t_short_id;
    l_param_value           com_api_type_pkg.t_param_value;
    l_data_type             com_api_type_pkg.t_dict_value;
    l_digit_group_separator com_api_type_pkg.t_dict_value;
begin
    trc_config_pkg.init_cache;

    io_status := nvl(io_status, acm_api_const_pkg.USER_ACTION_STATUS_SUCCESS);

    -- Calculate privilege ID
    if i_priv_name is not null then
        begin
            select id
              into l_priv_id
              from acm_privilege
             where name = i_priv_name;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'UNKNOWN_PRIVILEGE'
                  , i_env_param1    => i_priv_name
                );
        end;

        -- Check privilege exists in array
        select count(1)
          into l_count 
          from com_array_element 
         where array_id = 10000001
           and numeric_value = l_priv_id;
    end if;

    -- Set context
    g_user_name  := upper(i_user_name);
    begin
        acm_api_user_pkg.set_user_name( i_user_name => g_user_name );

        dbms_session.set_identifier( client_id => g_user_name );
        g_user_id    := acm_api_user_pkg.get_user_id;
        g_person_id  := acm_api_user_pkg.get_person_id( i_user_name => g_user_name );
        g_inst_id    := acm_api_user_pkg.get_user_inst( i_user_id => g_user_id );
        g_agent_id   := acm_api_user_pkg.get_user_agent( i_user_id => g_user_id );
        g_user_lang  := set_ui_value_pkg.get_user_param_v(
                            i_param_name => 'LANGUAGE'
                          , i_user_id    => nvl(upper(i_user_name), nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), user))
                        );
        g_sandbox    := acm_api_user_pkg.get_user_sandbox( i_user_id => g_user_id );
        l_digit_group_separator  := set_ui_value_pkg.get_user_param_v(
                                        i_param_name => 'DIGIT_GROUP_SEPARATOR'
                                      , i_user_id    => nvl(upper(i_user_name), nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), user))
                                    );
        case
            when l_digit_group_separator = com_api_const_pkg.DIGIT_SEPARATOR_DOTE_EMPTY then
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = ''.,''';
                g_format_mask            := 'FM999999999999999990D0099';
            when l_digit_group_separator = com_api_const_pkg.DIGIT_SEPARATOR_DOTE_COMMA then
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = ''.,''';
                g_format_mask            := 'FM999G999G999G999G999G990D0099';
            when l_digit_group_separator = com_api_const_pkg.DIGIT_SEPARATOR_DOTE_SPACE then
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = ''. ''';
                g_format_mask            := 'FM999G999G999G999G999G990D0099';
            when l_digit_group_separator = com_api_const_pkg.DIGIT_SEPARATOR_COMMA_EMPTY then
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = '',.''';
                g_format_mask            := 'FM999999999999999990D0099';
            when l_digit_group_separator = com_api_const_pkg.DIGIT_SEPARATOR_COMMA_DOTE then
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = '',.''';
                g_format_mask            := 'FM999G999G999G999G999G990D0099';
            when l_digit_group_separator = com_api_const_pkg.DIGIT_SEPARATOR_COMMA_SPACE then
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = '', ''';
                g_format_mask            := 'FM999G999G999G999G999G990D0099';
            else
                g_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = ''.,''';
                g_format_mask            := 'FM999G999G999G999G999G990D0099';
        end case;

    exception -- intercept "blocked user" exception
        when com_api_error_pkg.e_application_error then
            trc_log_pkg.debug('set_user_context: user not found');
            if i_priv_name = 'LOGIN' then
                io_status := acm_api_const_pkg.USER_ACTION_STATUS_ACCESS_DEN;
            else
                raise;
            end if;
    end;

    g_ip_address := i_ip_address;
    com_api_sttl_day_pkg.unset_sysdate;

    -- Check user permissions according to the privilege
    if l_priv_id is not null and io_status = acm_api_const_pkg.USER_ACTION_STATUS_SUCCESS then
        if  acm_api_privilege_pkg.check_privs_user (
                i_user_id => g_user_id
              , i_priv_id => l_priv_id
            ) = com_api_type_pkg.FALSE
        then
            io_status := acm_api_const_pkg.USER_ACTION_STATUS_ACCESS_DEN;
        end if;
    end if;

--    trc_log_pkg.debug('set_user_context: permission status = '||io_status);

    -- Register session
    if io_session_id is null then
        prc_api_session_pkg.start_session(
            i_process_id        => null
          , io_session_id       => io_session_id
          , i_thread_number     => null
          , i_parent_session_id => null
          , i_ip_address        => i_ip_address
        );
    else
        begin
            select u.name
                 , s.ip_address
              into l_user_name
                 , l_ip_address
              from prc_session s
                 , acm_user u
             where s.id = io_session_id
               and s.user_id = u.id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'SESSION_NOT_FOUND'
                  , i_env_param1    => io_session_id
                );
        end;

        if l_user_name is not null and l_user_name != upper(i_user_name) then
            com_api_error_pkg.raise_error(
                i_error      => 'INCONSISTENT_CONTEXT_PARAMETERS'
              , i_env_param1 => io_session_id
              , i_env_param2 => l_user_name
              , i_env_param3 => upper(i_user_name)
            );
        end if;

        if l_ip_address is not null and l_ip_address != i_ip_address then
            com_api_error_pkg.raise_error(
                i_error      => 'INCONSISTENT_CONTEXT_PARAMETERS'
              , i_env_param1 => io_session_id
              , i_env_param2 => l_ip_address
              , i_env_param3 => i_ip_address
            );
        end if;

        prc_api_session_pkg.set_session_id(i_session_id => io_session_id);
    end if;

    prc_api_session_pkg.set_container_id(i_container_id => i_container_id);

    prc_api_session_pkg.set_session_last_use;

    trc_config_pkg.init_cache;

    trc_log_pkg.debug(
        i_text => 'set_user_context: i_user_name=' || i_user_name
               || ', io_session_id=' || io_session_id
               || ', i_ip_address='  || i_ip_address
               || ', i_priv_name='   || i_priv_name
    );
    -- Only if privilege exists in array
    if i_extended_mode = com_api_const_pkg.TRUE and l_count > 0 then  
        -- Create incomplete audit trail record
        g_trail_id := adt_api_trail_pkg.get_trail_id;
        adt_api_trail_pkg.put_audit_trail(
            i_trail_id     => g_trail_id
          , i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
          , i_action_type  => null
          , i_priv_id      => l_priv_id
          , i_session_id   => io_session_id
          , i_status       => io_status
        );

        if io_status <> acm_api_const_pkg.USER_ACTION_STATUS_SUCCESS then
            -- Access denied, saving parameters
            for rec in (
                select
                    name
                  , char_value
                  , number_value
                  , date_value
                from table(cast(i_param_map as com_param_map_tpt))
            ) loop
                if rec.number_value is not null then
                    l_param_value := to_char(rec.number_value, com_api_const_pkg.NUMBER_FORMAT);
                    l_data_type   := com_api_const_pkg.DATA_TYPE_NUMBER;
                elsif rec.date_value is not null then
                    l_param_value := to_char(rec.date_value, com_api_const_pkg.DATE_FORMAT);
                    l_data_type   := com_api_const_pkg.DATA_TYPE_DATE;
                else
                    l_param_value := rec.char_value;
                    l_data_type   := com_api_const_pkg.DATA_TYPE_CHAR;
                end if;
                insert into adt_detail(
                    id
                  , trail_id
                  , column_name
                  , data_type
                  , data_format
                  , old_value
                  , new_value
                ) values (
                    adt_api_trail_pkg.get_detail_id
                  , g_trail_id
                  , rec.name
                  , l_data_type
                  , decode(l_data_type,
                        com_api_const_pkg.DATA_TYPE_NUMBER, com_api_const_pkg.NUMBER_FORMAT,
                        com_api_const_pkg.DATA_TYPE_DATE,   com_api_const_pkg.DATE_FORMAT)
                  , null
                  , l_param_value
                );
            end loop;
        end if;
    else
        g_trail_id := null;
    end if;
end;

procedure set_user_context(
    i_user_name     in      com_api_type_pkg.t_name
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name             default null
  , i_entity_type   in      com_api_type_pkg.t_dict_value       default null
  , i_object_id     in      com_api_type_pkg.t_long_id          default null
  , i_container_id  in      com_api_type_pkg.t_short_id         default null
) is
    l_status        com_api_type_pkg.t_dict_value;
begin
    set_user_context_common(
        i_extended_mode => com_api_const_pkg.FALSE
      , i_user_name     => i_user_name
      , io_session_id   => io_session_id
      , i_ip_address    => i_ip_address
      , i_priv_name     => null
      , io_status       => l_status
      , i_param_map     => null
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_container_id  => i_container_id
    );
end;

procedure set_user_context(
    i_user_name     in      com_api_type_pkg.t_name
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name             default null
  , i_priv_name     in      com_api_type_pkg.t_name             default null
  , io_status       in out  com_api_type_pkg.t_dict_value
  , i_param_map     in      com_param_map_tpt                   default null
  , i_entity_type   in      com_api_type_pkg.t_dict_value       default null
  , i_object_id     in      com_api_type_pkg.t_long_id          default null
  , i_container_id  in      com_api_type_pkg.t_short_id         default null
) is
begin
    set_user_context_common(
        i_extended_mode => com_api_const_pkg.TRUE
      , i_user_name     => i_user_name
      , io_session_id   => io_session_id
      , i_ip_address    => i_ip_address
      , i_priv_name     => i_priv_name
      , io_status       => io_status
      , i_param_map     => i_param_map
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_container_id  => i_container_id
    );
end;

function get_trail_id return com_api_type_pkg.t_long_id is
begin
    return g_trail_id;
end get_trail_id;

function get_nls_numeric_characters return com_api_type_pkg.t_name is
begin
    return g_nls_numeric_characters;
end get_nls_numeric_characters;

function get_format_mask return com_api_type_pkg.t_name is
begin
    return g_format_mask;
end get_format_mask;

procedure drop_user_context is
begin
    g_user_name               := null;
    acm_api_user_pkg.set_user_name( i_user_name => g_user_name);
    dbms_session.set_identifier( client_id => g_user_name );
    g_user_id                 := null;
    g_person_id               := null;
    g_inst_id                 := null;
    g_agent_id                := null;
    g_user_lang               := null;
    g_sandbox                 := null;
    g_nls_numeric_characters  := null;
    g_format_mask             := null;
    com_api_sttl_day_pkg.unset_sysdate;
    prc_api_session_pkg.set_session_id(i_session_id => null);
end drop_user_context;

procedure start_session(
    io_session_id           in out  com_api_type_pkg.t_long_id
  , i_ip_address            in      com_api_type_pkg.t_name        default null
)
as
begin
    prc_api_session_pkg.start_session(
        io_session_id       => io_session_id
      , i_process_id        => null
      , i_thread_number     => null
      , i_parent_session_id => null
      , i_ip_address        => i_ip_address
    );
end;

end;
/
