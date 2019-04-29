create or replace package body pmo_ui_provider_host_pkg as
/************************************************************
 * API for Host Providers<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 01.08.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_APII_PROVIDER_HOST_PKG <br />
 * @headcom
 ************************************************************/
procedure add_host(
    i_host_member_id       in     com_api_type_pkg.t_tiny_id
  , i_provider_id          in     com_api_type_pkg.t_short_id
  , i_execution_type       in     com_api_type_pkg.t_dict_value
  , i_priority             in     com_api_type_pkg.t_tiny_id
  , i_mod_id               in     com_api_type_pkg.t_tiny_id
  , i_inactive_till        in     date
  , i_status               in     com_api_type_pkg.t_dict_value
) is
begin
    insert into pmo_provider_host_vw(
        host_member_id
      , provider_id
      , execution_type
      , priority
      , mod_id
      , inactive_till
      , status   
    ) values (
        i_host_member_id
      , i_provider_id
      , i_execution_type
      , i_priority
      , i_mod_id
      , i_inactive_till  
      , i_status 
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_PROVIDER_HOST' 
          , i_env_param1 => i_host_member_id
          , i_env_param2 => i_provider_id
        );
end;

procedure modify_host(
    i_host_member_id       in     com_api_type_pkg.t_tiny_id
  , i_provider_id          in     com_api_type_pkg.t_short_id
  , i_execution_type       in     com_api_type_pkg.t_dict_value
  , i_priority             in     com_api_type_pkg.t_tiny_id
  , i_mod_id               in     com_api_type_pkg.t_tiny_id
  , i_inactive_till        in     date
  , i_status               in     com_api_type_pkg.t_dict_value
) is
begin
    update pmo_provider_host_vw a
       set a.execution_type = i_execution_type
         , a.priority       = i_priority
         , a.status         = nvl(i_status, status)
         , a.mod_id         = i_mod_id
         , a.inactive_till  = i_inactive_till
     where a.host_member_id = i_host_member_id
       and a.provider_id    = i_provider_id;
end;

procedure remove_host(
    i_host_member_id       in     com_api_type_pkg.t_tiny_id
  , i_provider_id          in     com_api_type_pkg.t_short_id
) is
begin
    delete pmo_provider_host_vw a
     where a.host_member_id = i_host_member_id
       and a.provider_id    = i_provider_id;
end;

end;
/
