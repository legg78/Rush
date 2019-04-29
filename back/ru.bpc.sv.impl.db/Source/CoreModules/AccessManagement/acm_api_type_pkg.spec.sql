create or replace package acm_api_type_pkg as
/****************************************************************
* Access Module types                                      <br />
* Created by Alalykin A. (alalykin@bpc.ru) at 12.11.2015   <br />
* Last changed by $Author: alalykin $                      <br />
* $LastChangedDate:: 2015-11-12 00:00:01 +0300#$           <br />
* Revision: $LastChangedRevision: 1$                    <br />
* Module: ACM_API_TYPE_PKG                                 <br />
* @headcom                                                 <br />
*****************************************************************/

type t_user_rec is record (
    id                      com_api_type_pkg.t_short_id
  , name                    com_api_type_pkg.t_name
  , password_hash           com_api_type_pkg.t_hash_value
  , person_id               com_api_type_pkg.t_medium_id
  , status                  com_api_type_pkg.t_dict_value
  , inst_id                 com_api_type_pkg.t_inst_id
  , password_change_needed  com_api_type_pkg.t_boolean
  , creation_date           date
  , auth_scheme             com_api_type_pkg.t_dict_value
);

type t_role_rec is record (
    id                  com_api_type_pkg.t_tiny_id
  , name                com_api_type_pkg.t_name
  , notif_scheme_id     com_api_type_pkg.t_tiny_id
  , inst_id             com_api_type_pkg.t_inst_id
  , ext_name            com_api_type_pkg.t_name
);

type t_priv_limit_field_rec is record (
    id                           com_api_type_pkg.t_short_id
  , priv_limit_id                com_api_type_pkg.t_short_id
  , field                        com_api_type_pkg.t_name
  , condition                    com_api_type_pkg.t_full_desc
  , label_id                     com_api_type_pkg.t_large_id
);

type t_priv_limit_field_tab is table of t_priv_limit_field_rec;

end acm_api_type_pkg;
/
