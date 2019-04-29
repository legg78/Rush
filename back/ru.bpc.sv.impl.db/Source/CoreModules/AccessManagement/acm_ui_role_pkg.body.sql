create or replace package body acm_ui_role_pkg is
/************************************************************
 * Provides an interface for managing roles. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 17.08.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ACM_UI_ROLE_PKG <br />
 * @headcom
 *************************************************************/

procedure check_unique (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_name                    in com_api_type_pkg.t_name
) is
    l_count                     pls_integer;
begin
    if i_name is not null then
        select
            count(1)
        into
            l_count
        from
            acm_role_vw
        where
            (id != i_id or i_id is null)
            and name = upper(i_name);

        if l_count > 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'ROLE_ALREADY_EXISTS'
                 , i_env_param1  => upper(i_name)
            );
        end if;
    end if;
end;

procedure add_role(
    i_role_name        in     com_api_type_pkg.t_name
  , i_role_short_desc  in     com_api_type_pkg.t_short_desc
  , i_role_full_desc   in     com_api_type_pkg.t_full_desc
  , i_role_lang        in     com_api_type_pkg.t_dict_value
  , i_notif_scheme_id  in     com_api_type_pkg.t_tiny_id
  , i_ext_name         in     com_api_type_pkg.t_name       := null
  , io_role_id         in out com_api_type_pkg.t_tiny_id
) is
begin
    -- check unique
    check_unique (
        i_id    => io_role_id
      , i_name  => i_role_name
    );

    if io_role_id is null then

        io_role_id := acm_role_seq.nextval;

        insert into acm_role_vw(
            id
          , name
          , notif_scheme_id
          , inst_id
          , ext_name
        )
        values(
            io_role_id
          , upper(i_role_name)
          , i_notif_scheme_id
          , ost_api_institution_pkg.get_sandbox
          , i_ext_name
        );

    else

        for rec in (
            select
                t.id
              , t.name
            from
                acm_role_vw t
            where
                t.id = io_role_id
        ) loop

            if rec.name = acm_api_const_pkg.ROLE_ROOT
            then
                com_api_error_pkg.raise_error(
                    i_error => 'ROLE_ROOT_CANNOT_REMOVED'
                );
            end if;

            update
                acm_role_vw a
            set
                a.name = upper(i_role_name)
              , a.notif_scheme_id = i_notif_scheme_id
              , a.ext_name = i_ext_name
            where
                a.id = io_role_id;

        end loop;

    end if;

    -- add/modify description
    com_api_i18n_pkg.add_text (
        i_table_name    => 'ACM_ROLE'
      , i_column_name   => 'NAME'
      , i_object_id     => io_role_id
      , i_text          => i_role_short_desc
      , i_lang          => i_role_lang
    );

    com_api_i18n_pkg.add_text (
        i_table_name    => 'ACM_ROLE'
      , i_column_name   => 'DESCRIPTION'
      , i_object_id     => io_role_id
      , i_text          => i_role_full_desc
      , i_lang          => i_role_lang
    );

exception
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error(
            i_error       => 'ROLE_IN_PROCESSING'
          , i_env_param1  => io_role_id
          , i_entity_type => com_api_const_pkg.ENTITY_TYPE_ROLE
          , i_object_id   => io_role_id
        );
end add_role;

procedure add_role_in_role(
    i_role_child  in     com_api_type_pkg.t_tiny_id
  , i_role_parent in     com_api_type_pkg.t_tiny_id
  , o_id          out    com_api_type_pkg.t_short_id
) is
    l_role_name          com_api_type_pkg.t_name;
begin
    if i_role_child = i_role_parent then return; end if;
    -- check circle role
    for rec in (select 1 from (
                    select a.parent_role_id from acm_role_role a
                    connect by prior a.parent_role_id = a.child_role_id
                    start with a.child_role_id = i_role_parent)
                where parent_role_id = i_role_child
    ) loop
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'ROLE_TREE_ERROR_CHILD'
          , i_env_param1  => i_role_child
          , i_env_param2  => i_role_parent
          , i_entity_type => com_api_const_pkg.ENTITY_TYPE_ROLE
          , i_object_id   => i_role_parent
        );
    end loop;

    select name
      into l_role_name
      from acm_role
     where id = i_role_child;

    if l_role_name = 'ROOT' then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'ERROR_ADD_ROOT_TO_ROLE'
          , i_env_param1  => i_role_parent
        );
    end if;

    o_id := acm_role_role_seq.nextval;

    insert into acm_role_role_vw(
        parent_role_id
      , child_role_id
      , id
    ) values(
        i_role_parent
      , i_role_child
      , o_id
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error        => 'ROLE_TREE_ERROR_INDEX'
          , i_env_param1   => i_role_child
          , i_env_param2   => i_role_parent
          , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_ROLE
          , i_object_id    => i_role_parent
        );
end add_role_in_role;

procedure remove_role_from_role(
    i_id in com_api_type_pkg.t_short_id
) is
begin
    delete from acm_role_role_vw
     where id = i_id;
end;

procedure remove_role_from_role (
    i_role_child in  com_api_type_pkg.t_tiny_id
  , i_role_parent in com_api_type_pkg.t_tiny_id
) is
begin
    delete from acm_role_role_vw t
     where t.parent_role_id = i_role_parent
       and t.child_role_id  = i_role_child;
end;

procedure remove_role(
    i_role_id         in     com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name :=
                        lower($$PLSQL_UNIT) || '.remove_role: ';
    l_role_name              com_api_type_pkg.t_text;
    l_count                  com_api_type_pkg.t_count := 0;
begin
    select a.name
      into l_role_name
      from acm_role a
     where a.id = i_role_id;

    if l_role_name = acm_api_const_pkg.ROLE_ROOT then
        com_api_error_pkg.raise_error(
            i_error => 'ROLE_ROOT_CANNOT_REMOVED'
        );
    end if;

    select count(1)
      into l_count
      from acm_user_role
     where role_id = i_role_id
       and rownum = 1;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error => 'ROLE_GRANTED_TO_USER'
        );
    end if;

    -- Check if this role is used as subrole for some roles,
    -- pass to an error message only first 3 roles to make it shorter 
    l_role_name := null;

    for r in (
        select r.name
          from acm_role_role rr
          join acm_role r       on r.id = rr.parent_role_id
         where rr.child_role_id = i_role_id
           and rownum <= 3
    ) loop
        l_role_name := l_role_name || r.name || ', ';
    end loop;

    if l_role_name is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'ROLE_GRANTED_TO_ROLE'
          , i_env_param1 => substr(l_role_name, 1, length(l_role_name)-2)
        );
    end if;

    delete acm_role_vw
     where id = i_role_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'ACM_ROLE'
      , i_object_id  => i_role_id
    );
    
    -- Delete all child records (like on delete cascade)
    delete acm_role_object_vw
     where role_id = i_role_id;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || sql%rowcount || ' records are deleted from ACM_ROLE_OBJECT'
    );

    delete acm_role_privilege_vw
     where role_id = i_role_id;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || sql%rowcount || ' records are deleted from ACM_ROLE_PRIVILEGE'
    );

    delete acm_role_role_vw
     where parent_role_id = i_role_id;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || sql%rowcount || ' records are deleted from ACM_ROLE_ROLE'
    );

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'role i_role_id [' || i_role_id
                                 || '] doesn''t exist, removing is skipped'
        );
end remove_role;

/*
 * Check uniqueness of an entity object for a role.
 * @param i_role_id        Role identifier
 * @param i_entity_type    Object's entity type
 * @param i_object_id      Object identifier
 */
procedure check_role_object_unique(
    i_role_id        in     com_api_type_pkg.t_tiny_id
  , i_entity_type    in     com_api_type_pkg.t_dict_value
  , i_object_id      in     com_api_type_pkg.t_long_id
) is
    l_id                    com_api_type_pkg.t_short_id;
begin
    begin
        select r.id
          into l_id
          from acm_role r
         where r.id = i_role_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'ROLE_DOES_NOT_EXIST'
              , i_env_param1 => i_role_id
            );
    end;

    com_api_dictionary_pkg.check_article(
        i_dict => com_api_const_pkg.ENTITY_TYPE_DICTIONARY
      , i_code => i_entity_type
    );

    select id
      into l_id
      from acm_role_object
     where role_id     = i_role_id
       and entity_type = i_entity_type
       and object_id   = i_object_id
       and rownum      = 1;

    -- Entity object already exists for the role, throw exception
    case i_entity_type
        when com_api_const_pkg.ENTITY_TYPE_PROCESS then
            com_api_error_pkg.raise_error(
                i_error      => 'ROLE_PRC_ALREADY_EXISTS'
              , i_env_param1 => i_role_id
              , i_env_param2 => i_object_id
            );
        when com_api_const_pkg.ENTITY_TYPE_REPORT then
            com_api_error_pkg.raise_error(
                i_error      => 'ROLE_RPT_ALREADY_EXISTS'
              , i_env_param1 => i_role_id
              , i_env_param2 => i_object_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ROLE_OBJECT_ALREADY_EXISTS'
              , i_env_param1 => i_role_id
              , i_env_param2 => i_object_id
              , i_env_param3 => i_entity_type
            );
    end case;

exception
    when no_data_found then
        null;
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.check_role_object_unique FAILED: '
                         || 'i_role_id [' || i_role_id
                         || '], i_entity_type [#1], i_object_id [' || i_object_id || ']'
          , i_env_param1 => i_entity_type
        );
        raise;
end check_role_object_unique;

/*
 * Add process role
 * @param o_id      Record identifier
 * @param i_role_id Role identifier
 * @param i_prc_id  Process identifier
 */
procedure add_role_prc(
    i_role_id in     com_api_type_pkg.t_tiny_id
  , i_prc_id  in     com_api_type_pkg.t_long_id
  , o_id         out com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select 1
        from   dual
        where  exists (select 1
                       from   prc_process_vw b
                       where  b.id = i_prc_id
                         and  b.is_container = com_api_type_pkg.TRUE)
    ) loop
        check_role_object_unique(
            i_role_id     => i_role_id
          , i_entity_type => com_api_const_pkg.ENTITY_TYPE_PROCESS
          , i_object_id   => i_prc_id
        );

        o_id := acm_role_object_seq.nextval;

        insert into acm_role_object_vw(
            id
          , role_id
          , object_id
          , entity_type
        ) values(
            o_id
          , i_role_id
          , i_prc_id
          , com_api_const_pkg.ENTITY_TYPE_PROCESS
        );
    end loop;
end add_role_prc;

/*
 * Remove role process
 * @param i_id Record identifier
*/
procedure remove_role_prc (
    i_id    in  com_api_type_pkg.t_long_id
) is
begin
    delete from acm_role_process_vw
     where id = i_id;
end;

/*
 * Add report role
 * @param o_id      Record identifier
 * @param i_role_id Role identifier
 * @param i_rpt_id  Report identifier
 */
procedure add_role_rpt(
    i_role_id in     com_api_type_pkg.t_tiny_id
  , i_rpt_id  in     com_api_type_pkg.t_long_id
  , o_id         out com_api_type_pkg.t_short_id
) is
begin
    for rec in (select 1
                from   dual
                where  exists (select 1
                               from   rpt_report_vw b
                               where  b.id = i_rpt_id) )
    loop
        check_role_object_unique(
            i_role_id     => i_role_id
          , i_entity_type => com_api_const_pkg.ENTITY_TYPE_REPORT
          , i_object_id   => i_rpt_id
        );

        o_id := acm_role_object_seq.nextval;

        insert into acm_role_object_vw(
            id
          , role_id
          , object_id
          , entity_type
        )
        values(
            o_id
          , i_role_id
          , i_rpt_id
          , com_api_const_pkg.ENTITY_TYPE_REPORT
        );
    end loop;
end add_role_rpt;

/*
 * Remove role report
 * @param i_id Record identifier
*/
procedure remove_role_rpt(
    i_id    in       com_api_type_pkg.t_long_id
) is
begin
    delete from acm_role_report_vw
     where id = i_id;
end;

/*
 * Add entity object to a role.
 * @param o_id         New role identifier
 * @param i_role_id    Role identifier
 * @param i_object_id  Entity object identifier
 */
procedure add_role_object(
    i_role_id        in     com_api_type_pkg.t_tiny_id
  , i_entity_type    in     com_api_type_pkg.t_dict_value
  , i_object_id      in     com_api_type_pkg.t_long_id
  , o_id                out com_api_type_pkg.t_short_id
) is
begin
    check_role_object_unique(
        i_role_id     => i_role_id
      , i_entity_type => i_entity_type
      , i_object_id   => i_object_id
    );

    o_id := acm_role_object_seq.nextval;

    insert into acm_role_object_vw(
        id
      , role_id
      , object_id
      , entity_type
    )
    values(
        o_id
      , i_role_id
      , i_object_id
      , i_entity_type
    );

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.add_role_object FAILED: '
                         || 'i_role_id [' || i_role_id
                         || '], i_entity_type [#1], i_object_id [' || i_object_id || ']'
          , i_env_param1 => i_entity_type
        );
        raise;
end add_role_object;

/*
 * Remove entity object from a role.
 * @param i_id    Record identifier
*/
procedure remove_role_object(
    i_id    in       com_api_type_pkg.t_long_id
) is
begin
    delete from acm_role_object_vw
     where id = i_id;
exception
    when others then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.remove_role_object FAILED: i_id [' || i_id || ']');
        raise;
end;

end acm_ui_role_pkg;
/
