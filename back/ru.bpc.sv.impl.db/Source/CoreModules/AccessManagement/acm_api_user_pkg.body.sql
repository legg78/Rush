create or replace package body acm_api_user_pkg as
/************************************************************
 * API for user management <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009  <br />
 * Last changed by $Author: fomichev $  <br />
 * $LastChangedDate:: 2012-03-19 16:43:17 +0400#$ <br />
 * Revision: $LastChangedRevision: 16921 $ <br />
 * Module: ACM_API_USER_PKG <br />
 * @headcom
 ************************************************************/

g_user_name   com_api_type_pkg.t_name      := null;
g_user_id     com_api_type_pkg.t_short_id  := null;
g_person_id   com_api_type_pkg.t_medium_id := null;
g_user_active com_api_type_pkg.t_boolean   := null;
g_user_inst   com_api_type_pkg.t_inst_id   := null;
g_user_agent  com_api_type_pkg.t_agent_id  := null;
g_sandbox     com_api_type_pkg.t_inst_id   := null;

cursor curs_user (
    i_user_name      com_api_type_pkg.t_name
) is
    select a.id   as user_id
         , a.name as user_name
         , a.person_id
         , decode(a.status
             , user_active_status,   com_api_type_pkg.TRUE
             , user_noactive_status, com_api_type_pkg.FALSE
           ) as is_active
         , a.inst_id
      from acm_user_vw a
     where a.name = upper(i_user_name);

procedure clear_user is    
begin
    g_user_name   := null;
    g_user_id     := null;
    g_person_id   := null;
    g_user_active := null;
    g_user_inst   := null;
    g_user_agent  := null;
    g_sandbox     := null;
end clear_user;

procedure set_user_name(
    i_user_name in   com_api_type_pkg.t_name
) is
begin   
    clear_user;
    for rec in curs_user (i_user_name)
    loop
        g_user_name   := rec.user_name;
        g_user_id     := rec.user_id;
        g_person_id   := rec.person_id;
        g_user_active := rec.is_active;
        g_sandbox     := rec.inst_id;
        set_user_inst (i_user_id => g_user_id);
        set_user_agent(i_user_id => g_user_id);
        if g_user_active is null or g_user_active = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error      => 'USER_IS_BLOCKED'
              , i_env_param1 => i_user_name
            );
        end if;
    end loop;
end set_user_name;

procedure set_user_id(
    i_user_id in     com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select a.name as user_name
          from acm_user_vw a
         where a.id = i_user_id
    ) loop
        set_user_name(i_user_name => rec.user_name);
    end loop;
end set_user_id;

function get_user_id return com_api_type_pkg.t_short_id 
is
begin
    return g_user_id;
end get_user_id;

-- Search user by ID if it isn't null; otherwise, search user by name
function get_user(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_user_name     in     com_api_type_pkg.t_name
  , i_mask_error    in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return acm_api_type_pkg.t_user_rec
is
    l_user_rec             acm_api_type_pkg.t_user_rec;
begin
    begin
        if i_user_id is not null then
            select a.id
                 , a.name
                 , null
                 , a.person_id
                 , a.status
                 , a.inst_id
                 , a.password_change_needed
                 , a.creation_date
                 , a.auth_scheme
              into l_user_rec
              from acm_user a
             where a.id = i_user_id;
        elsif i_user_name is not null then
            select a.id
                 , a.name
                 , null
                 , a.person_id
                 , a.status
                 , a.inst_id
                 , a.password_change_needed
                 , a.creation_date
                 , a.auth_scheme
              into l_user_rec
              from acm_user a
             where a.name = i_user_name;
        else
            raise no_data_found;
        end if;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                -- User name isn't used for searching if user ID is specified 
                com_api_error_pkg.raise_error(
                    i_error      => 'USER_DOES_NOT_EXIST'
                  , i_env_param1 => i_user_id
                  , i_env_param2 => case when i_user_id is null then i_user_name end
                );
            end if;
    end;

    return l_user_rec;
end get_user;

function get_user_name return com_api_type_pkg.t_name 
is    
begin
    return g_user_name;
end get_user_name;

function get_user_name(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_mask_error    in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_name
is
    l_user_name            com_api_type_pkg.t_name;
begin
    begin
        select a.name
          into l_user_name
          from acm_user a
         where a.id = i_user_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'USER_DOES_NOT_EXIST'
                  , i_env_param1 => i_user_id
                );
            end if;
    end;

    return l_user_name;
end get_user_name;

function get_user_is_active (
    i_user_name     in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean 
is
begin
   
    for rec in curs_user (i_user_name)
    loop       
        return rec.is_active;
    end loop;

    com_api_error_pkg.raise_error(
        i_error      => 'USER_DOES_NOT_EXIST'
      , i_env_param2 => i_user_name
    );

 end get_user_is_active;

function get_person_id (
    i_user_name     in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_medium_id
    result_cache 
as
begin
   
    for rec in curs_user (i_user_name)
    loop        
        return rec.person_id;
    end loop;

    com_api_error_pkg.raise_error(
        i_error      => 'USER_DOES_NOT_EXIST'
      , i_env_param2 => i_user_name
    );

end get_person_id;

function user_active_status
    return com_api_type_pkg.t_dict_value
    result_cache
is
begin
    return acm_api_const_pkg.STATUS_ACTIVE;
end user_active_status;

function user_noactive_status
    return com_api_type_pkg.t_dict_value
    result_cache
is
begin
    return acm_api_const_pkg.STATUS_NOACTIVE;
end user_noactive_status;

function get_user_inst_id(
    i_user_id in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id
is
begin
    for rec in (
        select a.inst_id
          from acm_user_inst_vw a
         where a.user_id = i_user_id
         order by a.is_default desc
    ) loop           
        return rec.inst_id;
    end loop;

    return get_def_inst;

end get_user_inst_id;

procedure set_user_inst(
    i_user_id in     com_api_type_pkg.t_short_id
) 
is
begin
    g_user_inst := get_user_inst_id(
                       i_user_id => i_user_id
                   );
end set_user_inst;

function get_user_agent_id (
    i_user_id in     com_api_type_pkg.t_short_id
  , i_inst_id in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id
is
    l_user_inst_id   com_api_type_pkg.t_inst_id  := i_inst_id;
begin
    for rec in (
        select a.agent_id
          from acm_user_agent_vw a
         where a.user_id = i_user_id
         order by a.is_default desc
    ) loop
        return rec.agent_id;
    end loop;

    if l_user_inst_id is null then
        l_user_inst_id := get_user_inst_id(
                              i_user_id => i_user_id
                          );
    end if;

    return ost_api_institution_pkg.get_default_agent(
               i_inst_id => l_user_inst_id
           );

end get_user_agent_id;

procedure set_user_agent (
    i_user_id       in     com_api_type_pkg.t_short_id
) is
begin
    g_user_agent := get_user_agent_id (
                        i_user_id => i_user_id
                      , i_inst_id => g_user_inst
                    );
end set_user_agent;

function get_user_agent (
    i_user_id       in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_agent_id 
is
begin

    if g_user_id != i_user_id then
        set_user_id(i_user_id => i_user_id);
    end if;
    
    return g_user_agent;

end get_user_agent;

function get_user_inst(
    i_user_id       in     com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_inst_id
is
begin    
    
    if i_user_id is not null and g_user_id != i_user_id then
        set_user_id (i_user_id => i_user_id);
    end if;
    
    return g_user_inst;

end get_user_inst;

function get_user_sandbox(
    i_user_id       in     com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_inst_id
is
begin

    if i_user_id is not null and g_user_id != i_user_id then
        set_user_id(i_user_id => i_user_id);
    end if;
    
    return coalesce(g_sandbox, OST_API_CONST_PKG.DEFAULT_INST);
  
end get_user_sandbox;

procedure create_user(
    io_user_rec                 in out nocopy acm_api_type_pkg.t_user_rec
) is
begin
    -- Check that user with the same name doesn't exist
    io_user_rec.id := get_user(
                          i_user_id    => null
                        , i_user_name  => io_user_rec.name
                        , i_mask_error => com_api_type_pkg.TRUE
                      ).id;

    if io_user_rec.id is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'USER_ALREADY_EXISTS'
          , i_env_param1 => io_user_rec.id
          , i_env_param2 => io_user_rec.name
        );
    end if;

    begin
        io_user_rec.id   := acm_user_seq.nextval;
        io_user_rec.name := upper(io_user_rec.name);

        insert into acm_user(
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
            io_user_rec.id
          , io_user_rec.name
          , io_user_rec.person_id
          , nvl(io_user_rec.status, acm_api_const_pkg.STATUS_ACTIVE)
          , io_user_rec.inst_id
          , io_user_rec.password_change_needed
          , sysdate
          , io_user_rec.auth_scheme
        );

        trc_log_pkg.debug('New user with ID [' || io_user_rec.id || '] has been created');

        if io_user_rec.password_hash is not null then
            acm_api_password_pkg.set_password(
                i_user_id                   => io_user_rec.id
              , i_old_password_hash         => null
              , i_new_password_hash         => io_user_rec.password_hash
              , i_password_change_needed    => io_user_rec.password_change_needed
            );
        end if;

    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'PERSON_IS_ALREADY_USED'
              , i_env_param1 => io_user_rec.person_id
            );
    end;
end create_user;

/*
 * Update user data, user ID (id) is used to search a user and can't be updated.
 * @param i_check_password    it allows to skip check of password's hash for matching with previous hashes
 */
procedure update_user(
    i_user_rec                  in      acm_api_type_pkg.t_user_rec
  , i_check_password            in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
) is
begin
    trc_log_pkg.debug(
        i_text       => 'Updating data of user with ID [#1]: inst_id [#2], name [#3], person_id [#4], status [#5]'
      , i_env_param1 => i_user_rec.id
      , i_env_param2 => i_user_rec.inst_id
      , i_env_param3 => i_user_rec.name
      , i_env_param4 => i_user_rec.person_id
      , i_env_param5 => i_user_rec.status
    );

    begin
        update acm_user
           set name                     = nvl(upper(i_user_rec.name),               name)
             , inst_id                  = nvl(i_user_rec.inst_id,                   inst_id)
             , person_id                = nvl(i_user_rec.person_id,                 person_id)
             , status                   = nvl(i_user_rec.status,                    status)
             , auth_scheme              = nvl(i_user_rec.auth_scheme,               auth_scheme)
         where id = i_user_rec.id;
    exception
        when dup_val_on_index then
            -- There are unique constraints for fields <name> and <person_id>
            com_api_error_pkg.raise_error(
                i_error      => 'FORBIDDEN_USER_CHANGING'
              , i_env_param1 => upper(i_user_rec.name)
              , i_env_param2 => i_user_rec.person_id
            );
    end;

    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'User with ID [#1] is not found, update was SKIPPED'
          , i_env_param1 => i_user_rec.id
        );
    else
        trc_log_pkg.debug('User with ID [' || i_user_rec.id || '] has been changed');
    end if;

    if i_user_rec.password_hash is not null then
        acm_api_password_pkg.set_password(
            i_user_id                   => i_user_rec.id
          , i_old_password_hash         => null
          , i_new_password_hash         => i_user_rec.password_hash
          , i_skip_check                => com_api_type_pkg.boolean_not(nvl(i_check_password, com_api_type_pkg.TRUE))
          , i_password_change_needed    => i_user_rec.password_change_needed
        );
    end if;
end update_user;

procedure check_root_role(
    i_role_id       in            com_api_type_pkg.t_tiny_id
) is
    l_id            com_api_type_pkg.t_short_id;
begin
    -- Root role can be assigned only by a user that has root role
    begin
        select id
          into l_id
          from acm_role
         where id   = i_role_id
           and name = acm_api_const_pkg.ROLE_ROOT;

        begin
            select id
              into l_id
              from acm_user_role
             where user_id = get_user_id()
               and role_id = i_role_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'NEED_ROOT_ROLE'
                  , i_env_param1 => get_user_id()
                );
        end;
    exception
        when no_data_found then
            null;
    end;
end;

procedure add_role_to_user(
    i_role_id       in            com_api_type_pkg.t_tiny_id
  , i_user_id       in            com_api_type_pkg.t_short_id
  , o_id               out        com_api_type_pkg.t_short_id
  , i_mask_error    in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) is
    l_id            com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => 'add_role_to_user: i_user_id [#1], i_role_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_role_id
    );

    check_root_role(i_role_id => i_role_id);

    begin
        select id
          into l_id
          from acm_user_role
         where user_id = i_user_id
           and role_id = i_role_id;

        if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ROLE_USER_ALREADY_EXISTS'
              , i_env_param1 => i_user_id
              , i_env_param2 => i_role_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'ROLE_USER_ALREADY_EXISTS'
              , i_env_param1 => i_user_id
              , i_env_param2 => i_role_id
            );
        end if;
    exception
        when no_data_found then
            o_id := acm_user_role_seq.nextval;

            insert into acm_user_role_vw(
                id
              , user_id
              , role_id
            ) values (
                o_id
              , i_user_id
              , i_role_id
            );

        trc_log_pkg.debug(
            i_text       => 'User''s role [#2] was GRANTED to user with ID [#1]'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_role_id
        );
    end;
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end add_role_to_user;

procedure remove_role_from_user(
    i_role_id       in            com_api_type_pkg.t_tiny_id
  , i_user_id       in            com_api_type_pkg.t_short_id
  , i_mask_error    in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) is
    l_count         com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text       => 'remove_role_from_user: i_user_id [#1], i_role_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_role_id
    );

    check_root_role(i_role_id => i_role_id);

    -- Forbid to remove last user's role
    select count(*)
      into l_count
      from acm_user_role
     where user_id = i_user_id
       and rownum <= 2;

    if l_count = 1 then
        com_api_error_pkg.raise_error(
            i_error => 'USER_LAST_ROLE'
          , i_env_param1 => i_role_id
          , i_env_param2 => i_user_id
        );
    end if;

    delete from acm_user_role_vw
     where user_id = i_user_id
       and role_id = i_role_id;

    if sql%rowcount = 0 then
        if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ROLE_USER_NOT_FOUND'
              , i_env_param1 => i_user_id
              , i_env_param2 => i_role_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'ROLE_USER_NOT_FOUND'
              , i_env_param1 => i_user_id
              , i_env_param2 => i_role_id
            );
        end if;
    else
        trc_log_pkg.debug(
            i_text       => 'User''s role [#1] was REMOVED from user with ID [#2]'
          , i_env_param1 => i_role_id
          , i_env_param2 => i_user_id
        );
    end if;
exception
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error(
            i_error      => 'USER_ROLE_BLOCKED'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_role_id
        );
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end remove_role_from_user;

procedure add_inst_to_user(
    i_user_id       in            com_api_type_pkg.t_short_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
  , i_is_entirely   in            com_api_type_pkg.t_boolean
  , i_is_default    in            com_api_type_pkg.t_boolean
  , o_id               out        com_api_type_pkg.t_short_id
) is
    l_id            com_api_type_pkg.t_short_id;
    l_is_entirely   com_api_type_pkg.t_boolean   := i_is_entirely;
    l_is_default    com_api_type_pkg.t_boolean   := i_is_default;
    l_count         com_api_type_pkg.t_count     := 0;
begin
    trc_log_pkg.debug(
        i_text       => 'add_inst_to_user: i_user_id [#1], i_inst_id [#2], i_is_entirely [#3], i_is_default [#4]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_is_entirely
      , i_env_param4 => i_is_default
    );

    -- Forbid to add default institution for a user
    if i_inst_id = get_def_inst then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ADD_DEF_INST'
        );
    end if;

    begin
        select id
          into l_id
          from acm_user_inst t
         where t.user_id = i_user_id
           and t.inst_id = i_inst_id;
    exception
        when no_data_found then
            null;
    end;

    -- If institution <i_inst_id> is set as default then it is necessary to mark previous default institution as non-default
    if l_is_default = com_api_type_pkg.TRUE then

        update acm_user_inst t
           set t.is_default  = com_api_type_pkg.FALSE
         where t.user_id     = i_user_id
           and t.inst_id    != i_inst_id
           and t.is_default  = com_api_type_pkg.TRUE;

    end if;

    if l_id is not null then
        update acm_user_inst t
           set t.is_entirely = nvl(l_is_entirely, t.is_entirely)
             , t.is_default  = nvl(l_is_default,  t.is_default)
         where t.user_id = i_user_id
           and t.inst_id = i_inst_id;

        trc_log_pkg.debug(
            i_text       => 'Institution [#2] is changed for user with ID [#1]'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_inst_id
        );
    else
        select count(*)
          into l_count
          from acm_user_inst t
         where t.user_id = i_user_id
           and rownum    = 1;

        -- Set 1st institution as a default one for a user
        if l_count = 0 then
            l_is_default := com_api_type_pkg.TRUE;
        end if;

        o_id := acm_user_inst_seq.nextval;

        insert into acm_user_inst(
            id
          , user_id
          , inst_id
          , is_entirely
          , is_default
        )
        values (
            o_id
          , i_user_id
          , i_inst_id
          , nvl(l_is_entirely, com_api_type_pkg.FALSE)
          , nvl(l_is_default,  com_api_type_pkg.FALSE)
        );

        trc_log_pkg.debug(
            i_text       => 'Institution [#2] was granted to user with ID [#1]'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_inst_id
        );
    end if;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );

end add_inst_to_user;

procedure remove_inst_from_user(
    i_user_id       in            com_api_type_pkg.t_short_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
) is
    l_is_default    com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => 'remove_inst_from_user: i_user_id [#1], i_inst_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_inst_id
    );

    begin
        select is_default
          into l_is_default
          from acm_user_inst
         where user_id = i_user_id
           and inst_id = i_inst_id;

        if l_is_default = com_api_type_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error      => 'REMOVE_DEF_INST'
              , i_env_param1 => i_inst_id
              , i_env_param2 => i_user_id
            );
        else
            delete from acm_user_agent
             where user_id = i_user_id;

            trc_log_pkg.debug(sql%rowcount || ' agents were removed from user with ID [' || i_user_id || ']');

            delete from acm_user_inst
             where user_id = i_user_id
               and inst_id = i_inst_id;

            trc_log_pkg.debug(
                i_text       => 'User''s institution [#2] was REMOVED from user with ID [#1]'
              , i_env_param1 => i_user_id
              , i_env_param2 => i_inst_id
            );
        end if;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => 'User''s institution [#2] can NOT be removed from user with ID [#1] because it was not granted'
              , i_env_param1 => i_user_id
              , i_env_param2 => i_inst_id
            );
    end;
end remove_inst_from_user;

/*
 * It returns true if agent <i_agent_id> belongs to default institution of user <i_user_id>.  
 */
function agent_of_default_institution(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_agent_id      in     com_api_type_pkg.t_agent_id
) return com_api_type_pkg.t_boolean is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_default_agent: ';
    l_agent_inst_id        com_api_type_pkg.t_short_id;
    l_is_default_inst      com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'i_user_id [' || i_user_id || '], i_agent_id [' || i_agent_id || ']');

    l_agent_inst_id := ost_api_agent_pkg.get_inst_id(i_agent_id => i_agent_id);
    trc_log_pkg.debug('l_agent_inst_id [' || l_agent_inst_id || ']');    

    begin
        select is_default 
          into l_is_default_inst  
          from acm_user_inst_vw 
         where inst_id = l_agent_inst_id
           and user_id = i_user_id;

        trc_log_pkg.debug('l_is_default_inst [' || l_is_default_inst || ']');
    exception
        when no_data_found then
            l_is_default_inst := com_api_type_pkg.FALSE;
            trc_log_pkg.debug(LOG_PREFIX || 'institution <l_agent_inst_id> is not granted for user <i_user_id>, return FALSE');
    end;

    return l_is_default_inst;
end;

procedure add_agent_to_user(
    i_user_id       in            com_api_type_pkg.t_short_id
  , i_agent_id      in            com_api_type_pkg.t_agent_id
  , i_is_default    in            com_api_type_pkg.t_boolean
  , o_id               out        com_api_type_pkg.t_short_id
) is
    l_new_is_default    com_api_type_pkg.t_boolean := i_is_default;
    l_old_is_default    com_api_type_pkg.t_boolean := i_is_default;
    l_description       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => 'add_agent_to_user: i_user_id [#1], i_agent_id [#2], i_is_default [#3]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_agent_id
      , i_env_param3 => i_is_default
    );

    -- Check for uniqueness to prevent shift of seqeunce on duplicate UK
    begin
        select t.id
             , t.is_default
          into o_id
             , l_old_is_default
          from acm_user_agent t
         where t.user_id  = i_user_id
           and t.agent_id = i_agent_id;
    exception
        when no_data_found then
            null;
    end;

    -- We check flag <i_is_def> and change it if it is necessary
    if  l_new_is_default = com_api_type_pkg.TRUE
        and
        agent_of_default_institution(
            i_user_id   => i_user_id
          , i_agent_id  => i_agent_id
        ) = com_api_type_pkg.FALSE
    then
        l_new_is_default := com_api_type_pkg.FALSE;

        trc_log_pkg.debug(
            i_text       => 'Agent [#1] can NOT be set as default since it doesn''t belong to user''s default institution'
          , i_env_param1 => i_agent_id
        );
    end if;

    trc_log_pkg.debug('l_is_default [' || l_new_is_default || ']');

    -- If agent <i_agent_id> is set as default then it is necessary to mark previous default agent as non-default
    if l_new_is_default = com_api_type_pkg.TRUE then

        update acm_user_agent t
           set t.is_default = com_api_type_pkg.FALSE
         where t.user_id    = i_user_id
           and t.agent_id  != i_agent_id
           and t.is_default = com_api_type_pkg.TRUE;

    end if;

    if o_id is null then
        o_id := acm_user_agent_seq.nextval;
        
        insert into acm_user_agent(
            id
          , user_id
          , agent_id
          , is_default
        ) values(
            o_id
          , i_user_id
          , i_agent_id
          , nvl(l_new_is_default, com_api_type_pkg.FALSE)
        );

        l_description := 'ADDED';

    elsif o_id is not null
          and l_new_is_default is not null
          and l_new_is_default != l_old_is_default
    then

        update acm_user_agent t
           set t.is_default = l_new_is_default
         where t.user_id    = i_user_id
           and t.agent_id   = i_agent_id;

        l_description := 'CHANGED';
    else
        l_description := 'NOT CHANGED';
    end if;

    trc_log_pkg.debug(
        i_text       => 'User''s agent [#1] was #2: user ID [#3], agent ID [#4], l_new_is_default [#5]'
      , i_env_param1 => o_id
      , i_env_param2 => l_description
      , i_env_param3 => i_user_id
      , i_env_param4 => i_agent_id
      , i_env_param5 => l_new_is_default
    );

end add_agent_to_user;

procedure remove_agent_from_user (
    i_user_id       in      com_api_type_pkg.t_short_id
  , i_agent_id      in      com_api_type_pkg.t_agent_id
  , i_check_default in      com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
    l_id            com_api_type_pkg.t_short_id;
    l_is_default    com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => 'remove_agent_from_user: i_user_id [#1], i_agent_id [#2]'
      , i_env_param1 => i_user_id
      , i_env_param2 => i_agent_id
    );

    select a.id
         , a.is_default
      into l_id
         , l_is_default
      from acm_user_agent a
     where a.user_id  = i_user_id
       and a.agent_id = i_agent_id;
                
    if  l_is_default = com_api_type_pkg.TRUE
        and
        i_check_default = com_api_type_pkg.TRUE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'REMOVE_DEF_AGENT'
          , i_env_param1 => i_agent_id
          , i_env_param2 => i_user_id
        );
    else
        delete from acm_user_agent a
         where a.id = l_id;

        trc_log_pkg.debug(
            i_text       => 'User''s agent [#1] was REMOVED: user ID [#2], agent ID [#3], l_is_default [#4]'
          , i_env_param1 => l_id
          , i_env_param2 => i_user_id
          , i_env_param3 => i_agent_id
          , i_env_param4 => l_is_default
        );
    end if;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'User''s agent was NOT found: user ID [#2], agent ID [#3], EXIT'
          , i_env_param2 => i_user_id
          , i_env_param3 => i_agent_id
        );
end remove_agent_from_user;

procedure clean_agents is
begin
    delete from acm_user_agent a
     where a.agent_id not in (select b.id from ost_agent b);
end clean_agents;

procedure refresh_mview is
begin
    utl_deploy_pkg.refresh_mviews('ACM_USER_INST_MVW,ACM_USER_AGENT_MVW');
    commit;
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.refresh_mview: commit');
end refresh_mview;

function get_user_agent_id (
    i_user_name     in    com_api_type_pkg.t_name
) return com_api_type_pkg.t_agent_id
is
    l_user_name           com_api_type_pkg.t_name := upper(i_user_name);
begin
    if l_user_name = g_user_name then
        return g_user_agent;
    end if;

    for rec in (
        select u.id
          from acm_user_vw u
         where u.name = l_user_name
    ) loop
        return get_user_agent_id (
                   i_user_id => rec.id
                 , i_inst_id => null
               );
    end loop;

    return null;

end get_user_agent_id;

function get_user_role_list(
    i_user_id        in            com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc
is
    l_user_tab       com_api_type_pkg.t_short_tab;
    l_role_list      com_api_type_pkg.t_full_desc;
begin
    select distinct role_id
        bulk collect into l_user_tab
        from (
            select aur.role_id
              from acm_user_role aur
             where aur.user_id = i_user_id
            union all
            select arr.child_role_id
              from acm_role_role arr
              connect by prior arr.child_role_id = arr.parent_role_id
              start with arr.parent_role_id in (
                             select aur.role_id
                               from acm_user_role aur
                              where aur.user_id = i_user_id
                         )
        );

    for i in 1 .. l_user_tab.count loop
        if i > 1 then
            l_role_list := l_role_list || ',';
        end if;

        l_role_list := l_role_list || l_user_tab(i);
    end loop;

    trc_log_pkg.debug(
        i_text        => 'l_role_list [#1]'
      , i_env_param1  => l_role_list
    );

    return l_role_list;
end get_user_role_list;

function get_user_role_tab(
    i_user_id             in  com_api_type_pkg.t_short_id
) return com_text_trans_tpt
is
    l_user_name_tab           com_text_trans_tpt;
begin
    select com_text_trans_tpr(name, ext_name)
      bulk collect into l_user_name_tab
      from (select distinct name, ext_name
              from acm_role
             where id in (select aur.role_id
                            from acm_user_role aur
                           where aur.user_id = i_user_id
                           union all
                          select arr.child_role_id
                            from acm_role_role arr
                         connect by prior arr.child_role_id = arr.parent_role_id
                           start with arr.parent_role_id in (select aur.role_id
                                                               from acm_user_role aur
                                                              where aur.user_id = i_user_id
                                                            )
                         )
           );

    return l_user_name_tab;

end get_user_role_tab;

end acm_api_user_pkg;
/
