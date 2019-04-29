create or replace package body acm_ui_user_pkg as
/**********************************************************
 * Provides an interface for managing users. <br>
 * Created by Kryukov E.(krukov@bpc.ru)  at 17.08.2009  <br>
 * Last changed by $Author$ <br>
 * $LastChangedDate::                           $  <br>
 * Revision: $LastChangedRevision$ <br>
 * Module: ACM_UI_USER_PKG <br>
 * @headcom
 ************************************************************/

procedure refresh_mview(
    i_change_user_via_appl  in  com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
  , i_need_refresh          in  com_api_type_pkg.t_boolean  default com_api_type_pkg.TRUE
) is
begin
    if nvl(i_change_user_via_appl, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
       and nvl(i_need_refresh, com_api_type_pkg.TRUE)      = com_api_type_pkg.TRUE
    then
        acm_api_user_pkg.refresh_mview;
    end if;
end refresh_mview;

function get_default_agent(
    i_user_id    in     com_api_type_pkg.t_short_id default get_user_id()
  , i_inst_id    in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_short_id is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_default_agent ';
    l_agent_id          com_api_type_pkg.t_agent_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START: i_user_id [' || i_user_id || '], i_inst_id [' || i_inst_id || ']');

    begin
        select a.id
          into l_agent_id
          from acm_user_agent_vw u
             , ost_agent_vw a
             , acm_user_inst_vw i
        where a.id         = u.agent_id
          and i.user_id    = u.user_id
          and i.inst_id    = a.inst_id
          and a.inst_id    = i_inst_id
          and u.user_id    = i_user_id
          and u.is_default = com_api_type_pkg.TRUE;
    exception
        when no_data_found then
            l_agent_id := ost_ui_institution_pkg.get_default_agent(
                i_inst_id  => i_inst_id
            );
    end;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH: l_agent_id [' || l_agent_id || ']');

    return l_agent_id;
end get_default_agent;

procedure add_new_user (
    i_user_name                 in      com_api_type_pkg.t_name
  , io_user_id                  in out  com_api_type_pkg.t_short_id
  , i_person_id                 in      com_api_type_pkg.t_medium_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_password_hash             in      com_api_type_pkg.t_hash_value   default null
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
  , i_auth_scheme               in      com_api_type_pkg.t_dict_value   default null
) is
    l_id                com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug('Add new user = ' || i_user_name);

    for rec in (
        select a.id
             , a.name
          from acm_user_vw a
         where a.name = upper(i_user_name)
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'USER_ALREADY_EXISTS'
          , i_env_param1 => rec.id
          , i_env_param2 => rec.name
        );
    end loop;

    begin
        -- add user
        io_user_id := acm_user_seq.nextval;

        insert into acm_user_vw(
            id
          , name
          , person_id
          , status
          , inst_id
          , password_change_needed
          , creation_date
          , auth_scheme
        )
        values (
            io_user_id
          , upper (i_user_name)
          , i_person_id
          , acm_api_user_pkg.user_active_status
          , ost_api_institution_pkg.get_sandbox(i_inst_id)
          , i_password_change_needed
          , sysdate
          , i_auth_scheme
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'PERSON_IS_ALREADY_USED'
              , i_env_param1 => i_person_id
            );
        when others then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
    end;

    add_inst_to_user (
        i_user_id    => io_user_id
      , i_inst_id    => i_inst_id
      , i_is_ent     => com_api_type_pkg.FALSE
      , io_id        => l_id
      , i_force      => com_api_type_pkg.FALSE
      , i_set_def    => com_api_type_pkg.TRUE
    );

    if i_password_hash is not null then
        acm_ui_password_pkg.set_password(
            i_user_id                   => io_user_id
          , i_old_password_hash         => null
          , i_new_password_hash         => i_password_hash
          , i_password_change_needed    => i_password_change_needed
        );
    end if;
end add_new_user;

procedure add_role_to_user (
    i_role_id     in        com_api_type_pkg.t_tiny_id
  , i_user_id     in        com_api_type_pkg.t_short_id
  , io_id            out    com_api_type_pkg.t_short_id
) is
    l_count                 com_api_type_pkg.t_count    := 0;
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'add_role_to_user: i_user_id [#1], i_role_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_role_id
    );

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    for rec in (
        select id
          from acm_role_vw
         where name = acm_api_const_pkg.ROLE_ROOT
           and id   = i_role_id
    ) loop
        select count(ur.id)
          into l_count
          from acm_user_role_vw ur
         where ur.user_id = get_user_id
           and ur.role_id = rec.id;

        if l_count = 0 then
            -- Root role can be assigned only by User that has Root role
            com_api_error_pkg.raise_error(
                i_error      => 'NEED_ROOT_ROLE'
              , i_env_param1 => get_user_id
            );
        end if;
    end loop;

    for rec in (
        select 1
          from acm_user_role_vw
         where user_id = i_user_id
           and role_id = i_role_id
    ) loop
        com_api_error_pkg.raise_error (
            i_error      => 'ROLE_USER_ALREADY_EXISTS'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_role_id
        );
    end loop;

    if l_change_user_via_appl = com_api_const_pkg.TRUE then
        acm_ui_application_pkg.create_application(
            io_appl_id          => l_appl_id
          , i_user_id           => i_user_id
          , i_role_command      => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , i_user_role_id      => i_role_id
        );
    else
        io_id := acm_user_role_seq.nextval;

        insert into acm_user_role_vw(
            id
          , user_id
          , role_id
        ) values (
            io_id
          , i_user_id
          , i_role_id
        );

    end if;

    if l_change_user_via_appl = com_api_const_pkg.FALSE then
        -- Re-init where role ROOT
        for rec in (
            select 1
              from acm_role_vw
             where name = acm_api_const_pkg.ROLE_ROOT
               and id   = i_role_id
        ) loop
            refresh_mview(i_change_user_via_appl => l_change_user_via_appl);
        end loop;
    end if;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end add_role_to_user;

procedure block_user (
    i_user_id    in        com_api_type_pkg.t_short_id
) is
begin
    -- check
    if i_user_id = get_user_id then
        com_api_error_pkg.raise_error(
            i_error => 'CANT_BLOCK_CU_USER'
        );
    end if;

    for rec in (
        select 1
          from acm_user_vw t
         where t.id = i_user_id
    ) loop
        update acm_user_vw t
           set t.status = acm_api_user_pkg.user_noactive_status
         where t.id = i_user_id;

        return;
    end loop;

    com_api_error_pkg.raise_error(
        i_error      => 'USER_DOES_NOT_EXIST'
      , i_env_param1 => i_user_id
    );

exception
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error(
            i_error      => 'USER_IS_BLOCKED'
          , i_env_param1 => i_user_id
    );
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end block_user;

procedure unblock_user (
    i_user_id    in        com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select 1
          from acm_user_vw t
         where t.id = i_user_id
    ) loop
        update acm_user_vw t
           set t.status = acm_api_user_pkg.user_active_status
         where t.id = i_user_id;

        return;
    end loop;

    com_api_error_pkg.raise_error (
        i_error      => 'USER_DOES_NOT_EXIST'
      , i_env_param1 => i_user_id
    );
end unblock_user;

procedure remove_role_from_user (
    i_role_id     in        com_api_type_pkg.t_tiny_id
  , i_user_id     in        com_api_type_pkg.t_short_id
) is
    l_count                 com_api_type_pkg.t_count    := 0;
    l_root_role_id          com_api_type_pkg.t_tiny_id;
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'remove_role_from_user: i_user_id [#1], i_role_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_role_id
    );

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    -- check last role
    select count(1)
      into l_count
      from acm_user_role_vw a
     where a.user_id = i_user_id;

    if l_count = 1 then
        com_api_error_pkg.raise_error(
            i_error => 'USER_LAST_ROLE'
          , i_env_param1 => i_role_id
          , i_env_param2 => i_user_id
        );
    end if;

    select id
      into l_root_role_id
      from acm_role r
     where r.name = acm_api_const_pkg.ROLE_ROOT;

    if l_root_role_id = i_role_id then
        begin
            select 1
              into l_count
              from acm_user_role_vw
             where user_id = get_user_id
               and role_id = l_root_role_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'NEED_ROOT_ROLE'
                  , i_env_param1    => get_user_id
                );
        end;

    end if;

    for rec in (
        select t.id
             , t.user_id
             , t.role_id
          from acm_user_role_vw t
         where t.user_id = i_user_id
           and t.role_id = i_role_id
    ) loop
        if l_change_user_via_appl = com_api_const_pkg.TRUE then
            acm_ui_application_pkg.create_application(
                io_appl_id          => l_appl_id
              , i_user_id           => rec.user_id
              , i_role_command      => app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
              , i_user_role_id      => rec.role_id
            );
        else
            delete acm_user_role_vw t
             where t.id = rec.id;

            if sql%rowcount = 0 then
                com_api_error_pkg.raise_error (
                    i_error      => 'ROLE_USER_NOT_FOUND'
                  , i_env_param1 => i_user_id
                  , i_env_param2 => i_role_id
                );
            end if;
        end if;
    end loop;

    if l_change_user_via_appl = com_api_const_pkg.FALSE then
        -- Re-init where role ROOT
        for rec in (
            select 1
              from acm_role_vw
             where name = acm_api_const_pkg.ROLE_ROOT
               and id   = i_role_id
        ) loop
            refresh_mview(i_change_user_via_appl => l_change_user_via_appl);
        end loop;
    end if;

exception
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error(
            i_error      => 'USER_ROLE_BLOCKED'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_role_id
        );
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end remove_role_from_user;

procedure add_inst_to_user (
    i_user_id      in       com_api_type_pkg.t_short_id
  , i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_is_ent       in       com_api_type_pkg.t_boolean
  , io_id          in out   com_api_type_pkg.t_short_id
  , i_force        in       com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
  , i_set_def      in       com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
  , i_need_refresh in       com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
) is
    l_is_default            com_api_type_pkg.t_boolean   := com_api_type_pkg.FALSE;
    l_count                 com_api_type_pkg.t_short_id;
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'add_inst_to_user: i_user_id [#1], i_inst_id [#2], i_is_ent [#3], io_id [#4], i_force [#5], i_set_def [#6]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_is_ent
      , i_env_param4 => io_id
      , i_env_param5 => i_force
      , i_env_param6 => i_set_def
    );

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    -- check def inst
    if i_inst_id = get_def_inst then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ADD_DEF_INST'
        ); -- 9999
    end if;

    -- check unique
    for rec in (
        select t.id
             , t.user_id
             , t.inst_id
             , t.is_default
             , t.is_entirely
          from acm_user_inst_vw t
         where t.user_id = i_user_id
           and t.inst_id = i_inst_id
    ) loop
        if i_force = com_api_type_pkg.TRUE
           and i_is_ent is not null
        then
            if l_change_user_via_appl = com_api_const_pkg.TRUE then
                acm_ui_application_pkg.create_application(
                    io_appl_id          => l_appl_id
                  , i_user_id           => rec.user_id
                  , i_inst_command      => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                  , i_user_inst_id      => rec.inst_id
                  , i_is_entirely       => i_is_ent
                );
            else
                update acm_user_inst_vw t
                   set t.is_entirely = i_is_ent
                 where t.id = rec.id;
            end if;
        end if;

        trc_log_pkg.info(
            i_text => 'Exists institution ' || i_inst_id || ' for user ' || i_user_id
        );

        refresh_mview(
            i_change_user_via_appl => l_change_user_via_appl
          , i_need_refresh         => i_need_refresh
        );
        return;
    end loop;

    io_id := acm_user_inst_seq.nextval;

    -- if first institution - set default
    select count(1)
      into l_count
      from acm_user_inst_vw c
     where c.user_id = i_user_id;

    if l_count = 0 then
        l_is_default := com_api_type_pkg.TRUE;
    end if;

    if l_change_user_via_appl = com_api_const_pkg.TRUE then
        acm_ui_application_pkg.create_application(
            io_appl_id          => l_appl_id
          , i_user_id           => i_user_id
          , i_inst_command      => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , i_user_inst_id      => i_inst_id
          , i_is_entirely       => i_is_ent
          , i_is_inst_default   => l_is_default
        );
    else
        insert into acm_user_inst_vw(
            id
          , user_id
          , inst_id
          , is_entirely
          , is_default
        )
        values (
            io_id
          , i_user_id
          , i_inst_id
          , i_is_ent
          , l_is_default
        );
    end if;

    if i_set_def = com_api_type_pkg.TRUE then
        set_def_inst (
            i_inst_id      => i_inst_id
          , i_user_id      => i_user_id
          , i_need_refresh => i_need_refresh
        );
    end if;

    refresh_mview(
        i_change_user_via_appl => l_change_user_via_appl
      , i_need_refresh         => i_need_refresh
    );

    trc_log_pkg.info(
        i_text => 'Add new institution ' || i_inst_id || ' to user ' || i_user_id
    );
end add_inst_to_user;

procedure remove_inst_from_user(
    i_user_id      in       com_api_type_pkg.t_short_id
  , i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_need_refresh in       com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
) is
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
begin

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    for rec in (
        select a.id
             , a.is_default
          from acm_user_inst_vw a
         where a.user_id = i_user_id
           and a.inst_id = i_inst_id
    ) loop
        if rec.is_default = com_api_type_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error      => 'REMOVE_DEF_INST'
              , i_env_param1 => i_inst_id
              , i_env_param2 => i_user_id
            );
        else
            -- remove agents
            for rec in (select b.id
                          from ost_agent b
                         where b.inst_id = i_inst_id)
            loop
                remove_agent_from_user(
                    i_user_id        => i_user_id
                  , i_agent_id       => rec.id
                  , i_check_default  => com_api_type_pkg.FALSE
                );
            end loop;

            if l_change_user_via_appl = com_api_const_pkg.TRUE then
                acm_ui_application_pkg.create_application(
                    io_appl_id          => l_appl_id
                  , i_user_id           => i_user_id
                  , i_inst_command      => app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
                  , i_user_inst_id      => i_inst_id
                );
            else
                delete acm_user_inst_vw a
                 where a.id = rec.id;
            end if;
        end if;

        refresh_mview(
            i_change_user_via_appl => l_change_user_via_appl
          , i_need_refresh         => i_need_refresh
        );
    end loop;
end remove_inst_from_user;

procedure add_agent_to_user (
    i_user_id      in       com_api_type_pkg.t_short_id
  , i_agent_id     in       com_api_type_pkg.t_agent_id
  , i_is_def       in       com_api_type_pkg.t_boolean
  , io_id          in out   com_api_type_pkg.t_short_id
  , i_force        in       com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
  , i_need_refresh in       com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name      := lower($$PLSQL_UNIT) || '.add_agent_to_user: ';
    l_new_is_default        com_api_type_pkg.t_boolean   := i_is_def;
    l_old_is_default        com_api_type_pkg.t_boolean;
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
    l_id                    com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'add_agent_to_user: i_user_id [#1], i_agent_id [#2], i_is_def [#3], i_force [#4]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_agent_id
      , i_env_param3 => i_is_def
      , i_env_param4 => i_force
    );

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    -- We check flag <i_is_def> and change it if it is necessary
    if l_new_is_default = com_api_type_pkg.TRUE then
        if  acm_api_user_pkg.agent_of_default_institution(
                i_user_id   => i_user_id
              , i_agent_id  => i_agent_id
            ) = com_api_type_pkg.FALSE
        then
            l_new_is_default := com_api_type_pkg.FALSE;

            trc_log_pkg.debug(LOG_PREFIX || 'agent can''t be set as default because it doesn''t belong to user''s default institution');
        else
            -- If agent <i_agent_id> is set as default then it is necessary to mark previous default agent as non-default
            if l_change_user_via_appl = com_api_const_pkg.FALSE then
                update acm_user_agent_vw t
                   set t.is_default  = com_api_type_pkg.FALSE
                 where t.user_id     = i_user_id
                   and t.agent_id   != i_agent_id
                   and t.is_default  = com_api_type_pkg.TRUE;
             end if;
        end if;
    end if;
    trc_log_pkg.debug(LOG_PREFIX || 'l_new_is_default [' || l_new_is_default || ']');

    -- Check for uniqueness
    begin
        select t.id
             , t.is_default
          into l_id
             , l_old_is_default
          from acm_user_agent_vw t
         where t.user_id  = i_user_id
           and t.agent_id = i_agent_id;
    exception
        when no_data_found then
            null;
    end;

    if l_id is not null then
        trc_log_pkg.debug(LOG_PREFIX || 'agent is already added to the user, l_is_default [' || l_old_is_default || ']');

        if i_force = com_api_type_pkg.TRUE
           and
           l_old_is_default != l_new_is_default
        then
            trc_log_pkg.debug(LOG_PREFIX || 'FORCE updating flag <is_default>=l_is_default to <l_is_def>');

            for rec in (
                select t.id
                     , t.user_id
                     , t.agent_id
                  from acm_user_agent_vw t
                 where t.user_id     = i_user_id
                   and t.agent_id    = i_agent_id
                   and t.is_default != l_new_is_default
            ) loop
                if l_change_user_via_appl = com_api_const_pkg.TRUE then
                    acm_ui_application_pkg.create_application(
                        io_appl_id          => l_appl_id
                      , i_user_id           => rec.user_id
                      , i_agent_command     => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                      , i_user_agent_id     => rec.agent_id
                      , i_is_agent_default  => l_new_is_default
                    );
                else
                    update acm_user_agent_vw t
                       set t.is_default = l_new_is_default
                     where t.id = rec.id;
                end if;
            end loop;

            refresh_mview(
                i_change_user_via_appl => l_change_user_via_appl
              , i_need_refresh         => i_need_refresh
            );
        else
            trc_log_pkg.debug(LOG_PREFIX || 'EXIT from the procedure');
        end if;
    else
        trc_log_pkg.debug(LOG_PREFIX || 'adding new record');

        if l_change_user_via_appl = com_api_const_pkg.TRUE then
            acm_ui_application_pkg.create_application(
                io_appl_id          => l_appl_id
              , i_user_id           => i_user_id
              , i_agent_command     => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , i_user_agent_id     => i_agent_id
              , i_is_agent_default  => l_new_is_default
            );
        else
            io_id := acm_user_agent_seq.nextval;

            insert into acm_user_agent_vw(
                id
              , user_id
              , agent_id
              , is_default
            ) values(
                io_id
              , i_user_id
              , i_agent_id
              , l_new_is_default
            );
        end if;

        refresh_mview(
            i_change_user_via_appl => l_change_user_via_appl
          , i_need_refresh         => i_need_refresh
        );
    end if;
end add_agent_to_user;

procedure remove_agent_from_user (
    i_user_id       in      com_api_type_pkg.t_short_id
  , i_agent_id      in      com_api_type_pkg.t_agent_id
  , i_check_default in      com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
  , i_need_refresh  in      com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
) is
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
begin

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    for rec in (
        select a.id
             , a.is_default
          from acm_user_agent_vw a
         where a.user_id  = i_user_id
           and a.agent_id = i_agent_id
    ) loop
        if rec.is_default      = com_api_type_pkg.TRUE
           and i_check_default = com_api_type_pkg.TRUE
        then
            com_api_error_pkg.raise_error(
                i_error      => 'REMOVE_DEF_AGENT'
              , i_env_param1 => i_agent_id
              , i_env_param2 => i_user_id
            );
        else

            for r in (
                select t.id
                     , t.user_id
                     , t.agent_id
                  from acm_user_agent_vw t
                 where t.id = rec.id
            ) loop
                if l_change_user_via_appl = com_api_const_pkg.TRUE then
                    acm_ui_application_pkg.create_application(
                        io_appl_id          => l_appl_id
                      , i_user_id           => r.user_id
                      , i_agent_command     => app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
                      , i_user_agent_id     => r.agent_id
                    );
                else
                    delete from acm_user_agent_vw a
                     where a.id = r.id;
                end if;
            end loop;
        end if;
    end loop;

    if l_change_user_via_appl = com_api_const_pkg.FALSE then
        acm_api_user_pkg.clean_agents;
    end if;

    refresh_mview(
        i_change_user_via_appl => l_change_user_via_appl
      , i_need_refresh         => i_need_refresh
    );

end remove_agent_from_user;

procedure set_def_inst (
    i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_user_id      in       com_api_type_pkg.t_short_id
  , i_need_refresh in       com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
) is
    l_count                 com_api_type_pkg.t_count     := 0;
    l_user_inst             com_api_type_pkg.t_short_id;
    l_agent_id              com_api_type_pkg.t_agent_id;
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
    l_appl_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'set_def_inst: i_user_id [#1], i_inst_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_inst_id
    );

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    -- check def inst
    if i_inst_id = get_def_inst then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ADD_DEF_INST'
        ); -- 9999
    end if;

    -- check agents for inst
    l_agent_id := ost_api_institution_pkg.get_default_agent(i_inst_id => i_inst_id);
    if l_agent_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'DEF_AGENT_NOT_FOUND'
          , i_env_param1 => i_inst_id
        );
    end if;

    if l_change_user_via_appl = com_api_const_pkg.FALSE then
        update acm_user_inst_vw t
           set t.is_default  = com_api_type_pkg.FALSE
         where t.user_id     = i_user_id
           and t.inst_id    != i_inst_id;
    end if;

    trc_log_pkg.debug(
        i_text       => 'set_def_inst: updated #1 records in acm_user_inst_vw (aui.inst_id <> i_inst_id)'
      , i_env_param1 => sql%rowcount
    );

    select count(*)
      into l_count
      from acm_user_inst_vw a
     where a.user_id = i_user_id
       and a.inst_id = i_inst_id;

    trc_log_pkg.debug(
        i_text       => 'set_def_inst: l_count [#1]'
      , i_env_param1 => l_count
    );

    -- Adding inst if not found
    if l_count = 0 then
        add_inst_to_user(
            i_user_id      => i_user_id
          , i_inst_id      => i_inst_id
          , i_is_ent       => com_api_type_pkg.FALSE
          , io_id          => l_user_inst
          , i_need_refresh => i_need_refresh
        );
    end if;

    for rec in (
        select t.id
             , t.user_id
             , t.inst_id
          from acm_user_inst_vw t
         where t.user_id = i_user_id
           and t.inst_id = i_inst_id
    ) loop
        if l_change_user_via_appl = com_api_const_pkg.TRUE then
            acm_ui_application_pkg.create_application(
                io_appl_id          => l_appl_id
              , i_user_id           => rec.user_id
              , i_inst_command      => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , i_user_inst_id      => rec.inst_id
              , i_is_inst_default   => com_api_type_pkg.TRUE
            );
        else
            update acm_user_inst_vw b
               set b.is_default = com_api_type_pkg.TRUE
             where b.user_id = rec.user_id
               and b.inst_id = rec.inst_id;
        end if;
    end loop; 

    trc_log_pkg.debug(
        i_text       => 'set_def_inst: updated #1 records in acm_user_inst_vw (aui.inst_id = i_inst_id)'
      , i_env_param1 => sql%rowcount
    );

    --reset user default agent
    if l_change_user_via_appl = com_api_const_pkg.FALSE then
        update acm_user_agent_vw t
           set t.is_default = com_api_type_pkg.FALSE
         where t.user_id   = i_user_id
           and t.agent_id != l_agent_id;
    end if;

    --set default agent
    trc_log_pkg.debug (
        i_text          => 'set default agent ' || l_agent_id
    );

    for rec in (
        select t.id
             , t.user_id
             , t.agent_id
          from acm_user_agent_vw t
         where t.user_id  = i_user_id
           and t.agent_id = l_agent_id
    ) loop
        if l_change_user_via_appl = com_api_const_pkg.TRUE then
            acm_ui_application_pkg.create_application(
                io_appl_id          => l_appl_id
              , i_user_id           => rec.user_id
              , i_agent_command     => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , i_user_agent_id     => rec.agent_id
              , i_is_agent_default  => com_api_type_pkg.TRUE
            );
        else
            update acm_user_agent_vw t
               set t.is_default = com_api_type_pkg.TRUE
             where t.user_id  = i_user_id
               and t.agent_id = l_agent_id;
        end if;
    end loop;

    refresh_mview(
        i_change_user_via_appl => l_change_user_via_appl
      , i_need_refresh         => i_need_refresh
    );

end set_def_inst;

procedure set_user_id(
    i_user_id    in        com_api_type_pkg.t_short_id
) is
begin
    acm_api_user_pkg.set_user_id(i_user_id => i_user_id);
end set_user_id;

function get_user_full_name(
    i_user_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name is
    l_result        com_api_type_pkg.t_name;
begin
    select com_ui_person_pkg.get_person_name(person_id, get_user_lang)
      into l_result
      from acm_user
     where id = i_user_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_user_id_by_name(
    i_user_name     in      com_api_type_pkg.t_name
  , i_mask_error    in      com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_short_id
is
    l_user_id com_api_type_pkg.t_short_id;
begin
    begin
        select id
          into l_user_id
          from acm_user
         where upper(name) = upper(i_user_name);
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'USER_DOES_NOT_EXIST'
                  , i_env_param1 => i_user_name
                );
            end if;
    end;
    return l_user_id;
end;

procedure avoid_expire_date(
    i_user_name     in      com_api_type_pkg.t_name
) is
begin
    acm_api_password_pkg.avoid_expire_date(i_user_name => i_user_name);
end avoid_expire_date;

procedure change_user_auth_scheme (
    i_user_id       in      com_api_type_pkg.t_short_id,
    i_auth_scheme   in      com_api_type_pkg.t_dict_value       
) is
begin
    update
        acm_user_vw t
    set
        t.auth_scheme = i_auth_scheme
    where
        t.id = i_user_id;
    
    if sql%rowcount = 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'USER_DOES_NOT_EXIST'
          , i_env_param1 => i_user_id
        );
    end if;
end change_user_auth_scheme;

procedure modify_user_data(
    i_tab_name      in      com_api_type_pkg.t_name
  , i_user_data     in      acm_user_data_tpt
) is
    l_id                    com_api_type_pkg.t_short_id;
    l_change_user_via_appl  com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => 'modify_user_data Start: i_tab_name [#1], i_user_data.count [#2]'
      , i_env_param1 => i_tab_name
      , i_env_param2 => i_user_data.count
    );

    l_change_user_via_appl := acm_ui_application_pkg.check_change_user_via_appl;

    if i_tab_name = 'USER_INST' then

        for i in 1 .. i_user_data.count loop

            trc_log_pkg.debug(
                i_text              => 'tab_name [#1]: inst_command [#2], user_id [#3], user_inst_id [#4], is_entirely [#5]'
              , i_env_param1        => i_tab_name
              , i_env_param2        => i_user_data(i).inst_command
              , i_env_param3        => i_user_data(i).user_id
              , i_env_param4        => i_user_data(i).user_inst_id
              , i_env_param5        => i_user_data(i).is_entirely
            );

            if i_user_data(i).inst_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then

                add_inst_to_user(
                    i_user_id       => i_user_data(i).user_id
                  , i_inst_id       => i_user_data(i).user_inst_id
                  , i_is_ent        => i_user_data(i).is_entirely
                  , io_id           => l_id
                  , i_force         => com_api_type_pkg.TRUE
                  , i_set_def       => com_api_type_pkg.FALSE
                  , i_need_refresh  => com_api_type_pkg.FALSE
                );

            elsif i_user_data(i).inst_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then

                remove_inst_from_user(
                    i_user_id       => i_user_data(i).user_id
                  , i_inst_id       => i_user_data(i).user_inst_id
                  , i_need_refresh  => com_api_type_pkg.FALSE
                );

            end if;
        end loop;

    elsif i_tab_name = 'USER_AGENT' then

        for i in 1 .. i_user_data.count loop

            trc_log_pkg.debug(
                i_text              => 'tab_name [#1]: agent_command [#2], user_id [#3], user_agent_id [#4], is_agent_default [#5]'
              , i_env_param1        => i_tab_name
              , i_env_param2        => i_user_data(i).agent_command
              , i_env_param3        => i_user_data(i).user_id
              , i_env_param4        => i_user_data(i).user_agent_id
              , i_env_param5        => i_user_data(i).is_agent_default
            );

            if i_user_data(i).agent_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then

                add_agent_to_user(
                    i_user_id       => i_user_data(i).user_id
                  , i_agent_id      => i_user_data(i).user_agent_id
                  , i_is_def        => i_user_data(i).is_agent_default
                  , io_id           => l_id
                  , i_force         => com_api_type_pkg.TRUE
                  , i_need_refresh  => com_api_type_pkg.FALSE
                );

            elsif i_user_data(i).agent_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then

                remove_agent_from_user(
                    i_user_id       => i_user_data(i).user_id
                  , i_agent_id      => i_user_data(i).user_agent_id
                  , i_check_default => com_api_type_pkg.TRUE
                  , i_need_refresh  => com_api_type_pkg.FALSE
                );

            end if;
        end loop;

    end if;

    refresh_mview(
        i_change_user_via_appl => l_change_user_via_appl
      , i_need_refresh         => com_api_type_pkg.TRUE
    );

    trc_log_pkg.debug(
        i_text       => 'modify_user_data Finish'
    );

end modify_user_data;

procedure reset_lockout(
    i_user_id       in      com_api_type_pkg.t_short_id
) is
begin
    trc_log_pkg.debug(i_text => 'Reset lockout counters');

    fcl_api_cycle_pkg.reset_cycle_counter(
        i_cycle_type  => acm_api_const_pkg.CYCLE_TYPE_LOCKOUT
      , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
      , i_object_id   => i_user_id
    );

    fcl_api_limit_pkg.set_limit_counter(
        i_limit_type  => acm_api_const_pkg.LIMIT_TYPE_FAILED_LOGINS
      , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
      , i_object_id   => i_user_id
      , i_count_value => 0
      , i_sum_value   => 0
    );
end reset_lockout;

function get_lockout_date(
    i_user_id       in      com_api_type_pkg.t_short_id
) return date
is
    l_prev_date             date;
    l_next_date             date;
begin
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type  => acm_api_const_pkg.CYCLE_TYPE_LOCKOUT
      , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
      , i_object_id   => i_user_id
      , i_add_counter => com_api_const_pkg.FALSE
      , o_prev_date   => l_prev_date
      , o_next_date   => l_next_date
    );
    if l_next_date < com_api_sttl_day_pkg.get_sysdate then
        l_next_date := null;
    end if;
    
    return l_next_date;
end get_lockout_date;

procedure user_login(
    i_user_id       in      com_api_type_pkg.t_short_id
  , io_status       in out  com_api_type_pkg.t_dict_value
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name
) as
    l_prev_date             date;
    l_next_date             date;
    l_next_date_new         date;
    l_count                 com_api_type_pkg.t_count := 0;
    l_lockout_duration      com_api_type_pkg.t_count := 0;
    l_max_login_attempts    com_api_type_pkg.t_count := 0;
    l_eff_date              date;
    l_entity_type           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'user_login: i_user_id [#1], io_status [#2], io_session_id [#3], i_ip_address [#4]'
      , i_env_param1 => i_user_id
      , i_env_param2 => io_status
      , i_env_param4 => io_session_id
      , i_env_param3 => i_ip_address
    );

    if io_session_id is null then
        prc_api_session_pkg.start_session(
            io_session_id       => io_session_id
          , i_ip_address        => i_ip_address
          , i_user_id           => i_user_id
        );

        trc_log_pkg.debug(
            i_text => 'user_login: i_user_id=' || i_user_id
               || ', io_session_id=' || io_session_id
               || ', i_ip_address='  || i_ip_address
        );
    end if;
    
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    
    if i_user_id is not null then 
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type  => acm_api_const_pkg.CYCLE_TYPE_LOCKOUT
          , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
          , i_object_id   => i_user_id
          , i_add_counter => com_api_const_pkg.FALSE
          , o_prev_date   => l_prev_date
          , o_next_date   => l_next_date
        );
        
        begin
            select c.count_value
              into l_count
              from fcl_limit_counter c 
             where c.object_id   = i_user_id
               and c.entity_type = acm_api_const_pkg.ENTITY_TYPE_USER
               and c.limit_type  = acm_api_const_pkg.LIMIT_TYPE_FAILED_LOGINS;
        exception 
            when no_data_found then
                l_count := 0;
        end;
        
        trc_log_pkg.debug(
            i_text       => 'counters: l_next_date [#1], l_count [#2]'
          , i_env_param1 => l_next_date
          , i_env_param2 => l_count
        );
        
        if l_next_date is not null and l_next_date >= l_eff_date then
            trc_log_pkg.debug(i_text => 'User is already locked');
            
            io_status := acm_api_const_pkg.USER_ACTION_STATUS_ACC_LOCK;
        elsif io_status = acm_api_const_pkg.USER_ACTION_STATUS_SUCCESS then
            if l_count != 0 then
                reset_lockout(i_user_id => i_user_id);
            else
                trc_log_pkg.debug(i_text => 'Regular login');
            end if;
        else
            if l_next_date < l_eff_date and l_count > 0 then
                l_count := 0;
                reset_lockout(i_user_id => i_user_id);
            end if;
            l_lockout_duration := 
                nvl(
                    set_ui_value_pkg.get_system_param_n(
                        i_param_name => 'LOCKOUT_DURATION'
                      , i_data_type  => com_api_const_pkg.DATA_TYPE_NUMBER
                    )
                , 0);
            l_max_login_attempts := 
                nvl(
                    set_ui_value_pkg.get_system_param_n(
                        i_param_name => 'MAX_LOGIN_ATTEMPTS'
                      , i_data_type  => com_api_const_pkg.DATA_TYPE_NUMBER
                        )
                , 0);
                
            trc_log_pkg.debug(
                i_text       => 'l_lockout_duration [#1]; l_max_login_attempts [#2]'
              , i_env_param1 => l_lockout_duration
              , i_env_param2 => l_max_login_attempts
            );
            
            if l_lockout_duration != 0 and l_max_login_attempts != 0 then
                l_count := l_count + 1;
                
                fcl_api_limit_pkg.set_limit_counter(
                    i_limit_type   => acm_api_const_pkg.LIMIT_TYPE_FAILED_LOGINS
                  , i_entity_type  => acm_api_const_pkg.ENTITY_TYPE_USER
                  , i_object_id    => i_user_id
                  , i_count_value  => l_count
                  , i_sum_value    => 0
                  , i_allow_insert => com_api_const_pkg.TRUE
                );
                
                if l_count >= l_max_login_attempts then
                    l_next_date_new := l_eff_date + l_lockout_duration/24/60;
                    
                    fcl_api_cycle_pkg.add_cycle_counter(
                        i_cycle_type  => acm_api_const_pkg.CYCLE_TYPE_LOCKOUT
                      , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
                      , i_object_id   => i_user_id
                      , i_next_date   => l_next_date_new
                      , i_inst_id     => null
                    );
                    io_status := acm_api_const_pkg.USER_ACTION_STATUS_ACC_LOCK;
                    
                    trc_log_pkg.debug(
                        i_text       => 'User is locked until [#1]'
                      , i_env_param1 => l_next_date_new
                    );
                end if;
            else
                trc_log_pkg.debug(i_text => 'Lockout is disabled');
            end if;
        end if;
    else
        trc_log_pkg.debug(i_text => 'Username not found');
    end if;

    if io_status != acm_api_const_pkg.USER_ACTION_STATUS_SUCCESS then
        if i_user_id is not null then
            l_entity_type := acm_api_const_pkg.ENTITY_TYPE_USER;
        end if;

        adt_api_trail_pkg.add_audit_trail(
            i_entity_type => l_entity_type
          , i_object_id   => i_user_id
          , i_action_type => acm_api_const_pkg.ACTION_TYPE_INSERT
          , i_user_id     => i_user_id
          , i_priv_id     => acm_api_const_pkg.PRIV_LOGIN
          , i_status      => io_status
          , i_session_id  => io_session_id
        );
    end if;
end;

function get_person_name_by_user(
    i_user_id       in      com_api_type_pkg.t_short_id
  , i_user_name     in      com_api_type_pkg.t_name       default null
  , i_lang          in      com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name
is
    l_name      com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => 'get_person_name_by_user: i_user_id [#1], i_user_name [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_user_name
    );
    l_name := com_ui_person_pkg.get_person_name(
                  i_person_id => acm_api_user_pkg.get_user(
                                     i_user_id    => i_user_id
                                   , i_user_name  => i_user_name
                                   , i_mask_error => com_api_const_pkg.FALSE
                                 ).person_id 
               , i_lang => i_lang 
    );
    trc_log_pkg.debug(
        i_text       => 'get_person_name_by_user: return [#1]'
      , i_env_param1 => l_name
    );

    return l_name;
end get_person_name_by_user;

procedure set_user_role(
    i_user_id            in     com_api_type_pkg.t_short_id
  , i_ext_role_name_tab  in     raw_data_tpt)
is
    l_user_role_name_tab        com_text_trans_tpt;
    l_found                     com_api_type_pkg.t_boolean;
    l_user_role_id              com_api_type_pkg.t_tiny_id;
    l_ext_role_id               com_api_type_pkg.t_tiny_id;
    l_role_to_user_id           com_api_type_pkg.t_short_id;
    l_i                         com_api_type_pkg.t_tiny_id;
    l_need_refresh              com_api_type_pkg.t_boolean   := com_api_const_pkg.FALSE;

begin
    trc_log_pkg.debug(
        i_text       => 'acm_ui_user_pkg.set_user_role: i_user_id [#1], i_ext_role_name_tab.count [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_ext_role_name_tab.count
    );

    l_user_role_name_tab := acm_api_user_pkg.get_user_role_tab(i_user_id  => i_user_id);

    if l_user_role_name_tab.count = 0 or i_ext_role_name_tab.count = 0 then
        return;
    end if;

    for i in 1..i_ext_role_name_tab.count
    loop
        if i_ext_role_name_tab(i).raw_data is null then
            com_api_error_pkg.raise_error(
                i_error      => 'CANNOT_MAP_ROLE_SV_TO_EXTERNAL'
              , i_env_param1 => l_user_role_name_tab(i).src_text
            );
        end if;

        l_found  := com_api_const_pkg.FALSE;
        l_i      := l_user_role_name_tab.first;
        while l_i <= l_user_role_name_tab.last
        loop
            if l_user_role_name_tab(l_i).dst_text = i_ext_role_name_tab(i).raw_data then
                l_user_role_name_tab.delete(l_i);
                l_found := com_api_const_pkg.TRUE;
                exit;
            end if;

            l_i := l_user_role_name_tab.next(l_i);
        end loop;

        if l_found = com_api_const_pkg.FALSE then
            if i_ext_role_name_tab(i).raw_data = 'ROOT' then
                l_need_refresh := com_api_const_pkg.TRUE;
            end if;

            l_ext_role_id := acm_api_role_pkg.get_role_by_ext_name(
                                 i_role_ext_name  => i_ext_role_name_tab(i).raw_data
                               , i_mask_error     => com_api_const_pkg.TRUE
                             ).id;

            acm_ui_user_pkg.add_role_to_user(
                i_role_id  => l_ext_role_id
              , i_user_id  => i_user_id
              , io_id      => l_role_to_user_id
            );

        end if;
    end loop;

    l_i := l_user_role_name_tab.first;
    while l_i <= l_user_role_name_tab.last
    loop
        if l_user_role_name_tab(l_i).dst_text = 'ROOT' then
            l_need_refresh := com_api_const_pkg.TRUE;
        end if;

        l_user_role_id := acm_api_role_pkg.get_role_by_ext_name(
                              i_role_ext_name  => l_user_role_name_tab(l_i).dst_text
                            , i_mask_error     => com_api_const_pkg.TRUE
                          ).id;

        acm_ui_user_pkg.remove_role_from_user(
            i_role_id  => l_user_role_id
          , i_user_id  => i_user_id
        );

        l_i := l_user_role_name_tab.next(l_i);
    end loop;

    if l_need_refresh = com_api_const_pkg.TRUE then
        acm_api_user_pkg.refresh_mview;
    end if;

end set_user_role;

end acm_ui_user_pkg;
/
