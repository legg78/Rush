create or replace package acm_api_privilege_pkg is

/**********************************************************
 *
 * API for privileges<br/>
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009<br/>
 * Last changed by $Author$<br/>
 * $LastChangedDate::                           $<br/>
 * Revision: $LastChangedRevision$<br/>
 * Module: ACM_API_PRIVILEGE_PKG
 * @headcom
 **********************************************************/

/*
* Check user privilege
* @param i_user_id User identifier
* @param i_priv_id Privilege identifier
* @return flag 1/0 - true/false
*/
  function check_privs_user (
    i_user_id in     com_api_type_pkg.t_short_id
  , i_priv_id in     com_api_type_pkg.t_short_id
  )
    return com_api_type_pkg.t_boolean;
end acm_api_privilege_pkg;
/
