create or replace package pmo_ui_provider_host_pkg as
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
);

procedure modify_host(
    i_host_member_id       in     com_api_type_pkg.t_tiny_id
  , i_provider_id          in     com_api_type_pkg.t_short_id
  , i_execution_type       in     com_api_type_pkg.t_dict_value
  , i_priority             in     com_api_type_pkg.t_tiny_id
  , i_mod_id               in     com_api_type_pkg.t_tiny_id
  , i_inactive_till        in     date
  , i_status               in     com_api_type_pkg.t_dict_value
);

procedure remove_host(
    i_host_member_id       in     com_api_type_pkg.t_tiny_id
  , i_provider_id          in     com_api_type_pkg.t_short_id
);

end;
/
