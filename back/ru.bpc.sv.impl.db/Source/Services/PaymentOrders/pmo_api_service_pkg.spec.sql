create or replace package pmo_api_service_pkg as
/************************************************************
 * API for Payment Service<br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 24.08.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_API_SERVICE_PKG <br />
 * @headcom
 ************************************************************/

procedure get_all_services(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , o_service_id_tab           out  com_api_type_pkg.t_number_tab
  , o_service_name_tab         out  com_api_type_pkg.t_name_tab
);

procedure get_own_services(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , o_service_id_tab           out  com_api_type_pkg.t_number_tab
  , o_service_name_tab         out  com_api_type_pkg.t_name_tab
);

procedure get_all_purposes(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_service_id            in      com_api_type_pkg.t_short_id
  , o_purpose_id_tab           out  com_api_type_pkg.t_number_tab
  , o_purpose_name_tab         out  com_api_type_pkg.t_name_tab
);

/*
 * Returns outgoing collections with data about purposes, providers and provider groups.
 * @param i_provider_group_id – identifiers of a root provider group, may be NULL
 * @param o_is_group_tab      – o_is_group_tab(i) indicates whether o_purpose_id_tab(i) is group's or purpose's identifier  
 * @param o_purpose_name_tab  – contains names (labels) of providers or provider groups (depends on o_is_group_tab)  
 */
procedure get_all_purposes(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_provider_group_id     in      com_api_type_pkg.t_short_id
  , o_purpose_id_tab           out  com_api_type_pkg.t_number_tab
  , o_purpose_name_tab         out  com_api_type_pkg.t_name_tab
  , o_logo_path_tab            out  com_api_type_pkg.t_name_tab
  , o_is_group_tab             out  com_api_type_pkg.t_boolean_tab
);

procedure get_own_purposes(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_service_id            in      com_api_type_pkg.t_short_id
  , o_purpose_id_tab           out  com_api_type_pkg.t_number_tab
  , o_purpose_name_tab         out  com_api_type_pkg.t_name_tab
);

end;
/
