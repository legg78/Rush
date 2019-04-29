create or replace package body acm_api_role_pkg as
/************************************************************
 * API for roles. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 17.08.2009 <br />
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-02-24 17:53:44 +0300#$<br />
 * Revision: $LastChangedRevision: 8229 $ <br />
 * Module: ACM_API_ROLE_PKG <br />
 * @headcom
 *************************************************************/
g_role_id com_api_type_pkg.t_tiny_id default null;

cursor role_cursor is
    select
        a.id
      , a.name
      , a.notif_scheme_id
    from
        acm_role_vw a
    where
        a.id = g_role_id;

procedure set_role_id (
    i_role_id in     com_api_type_pkg.t_tiny_id
) is
begin
    g_role_id := i_role_id;
end set_role_id;

function get_role_id return com_api_type_pkg.t_tiny_id is
begin
    return g_role_id;
end get_role_id;

function get_role_name (
    i_role_id in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name is
begin
    set_role_id (i_role_id => i_role_id);

    for rec in role_cursor
    loop
        return rec.name;
    end loop;

    com_api_error_pkg.raise_error(
        i_error      => 'ROLE_NOT_FOUND'
      , i_env_param1 => i_role_id
    );

end get_role_name;

function check_user_role_prc (
    i_prc_id in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
begin
    for rec in (select
                    a.role_id
                  , a.object_id
                from
                    acm_role_process_vw a
                  , acm_user_role_vw b
                where
                    a.role_id = b.role_id
                and
                    a.object_id = i_prc_id)
    loop
        return com_api_type_pkg.TRUE;
    end loop;

    return com_api_type_pkg.FALSE;

end check_user_role_prc;

function get_role(
    i_role_id       in     com_api_type_pkg.t_tiny_id
  , i_role_name     in     com_api_type_pkg.t_name
  , i_mask_error    in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return acm_api_type_pkg.t_role_rec
is
    l_role_rec             acm_api_type_pkg.t_role_rec;
begin
    begin
        if i_role_id is not null then
            select a.id
                 , a.name
                 , a.notif_scheme_id
                 , a.inst_id
                 , a.ext_name
              into l_role_rec
              from acm_role a
             where a.id = i_role_id;
        elsif i_role_name is not null then
            select a.id
                 , a.name
                 , a.notif_scheme_id
                 , a.inst_id
                 , a.ext_name
              into l_role_rec
              from acm_role a
             where a.name = i_role_name;
        else
            raise no_data_found;
        end if;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'ROLE_NOT_FOUND'
                  , i_env_param1 => nvl(i_role_id, i_role_name)
                );
            end if;
    end;

    return l_role_rec;
end get_role;

function get_role_by_ext_name(
    i_role_ext_name in     com_api_type_pkg.t_name
  , i_mask_error    in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return acm_api_type_pkg.t_role_rec
is
    l_role_rec             acm_api_type_pkg.t_role_rec;
begin
    begin
        if i_role_ext_name is not null then
            select a.id
                 , a.name
                 , a.notif_scheme_id
                 , a.inst_id
                 , a.ext_name
              into l_role_rec
              from acm_role a
             where a.ext_name = i_role_ext_name;
        else
            raise no_data_found;
        end if;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'ROLE_NOT_FOUND'
                  , i_env_param1 => i_role_ext_name
                );
            end if;
    end;

    return l_role_rec;
end get_role_by_ext_name;

end acm_api_role_pkg;
/
