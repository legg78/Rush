create or replace package body acm_api_privilege_pkg
as
function check_privs_user (
    i_user_id in     com_api_type_pkg.t_short_id
  , i_priv_id in     com_api_type_pkg.t_short_id
)
return com_api_type_pkg.t_boolean is
begin

    acm_api_user_pkg.set_user_id (i_user_id);

    for rec in (select 1
                from   acm_api_user_privilege_vw t
                where  t.priv_id = i_priv_id)
    loop
        return com_api_type_pkg.TRUE;
    end loop;

    return com_api_type_pkg.FALSE;

end check_privs_user;

end acm_api_privilege_pkg;
/
