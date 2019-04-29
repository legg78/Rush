create or replace package acm_prc_export_pkg as
/*********************************************************
*  Export&Import utility for Access Managment module (ACM) <br />
*  Created by Truschelev O.(truschelev@bpcbt.com) at 30.06.2015 <br />
*  Last changed by $Author: truschelev $ <br />
*  $LastChangedDate:: 2015-06-30 09:30:45 +0300#$ <br />
*  Revision: $LastChangedRevision: 52893 $ <br />
*  Module: ACM_PRC_EXPORT_PKG <br />
*  @headcom
**********************************************************/

/*
 * Export either one or all roles into XML file.
 * Any parent role will exported with his child roles.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
procedure export_roles(
    i_role_id   in  com_api_type_pkg.t_tiny_id
);

procedure import_roles;

/*
 * Generate XML block for acm_role record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype;

/*
 * Generate XML block for acm_privilege record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_privilege(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype;

/*
 * Generate XML block for acm_role_role record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role_role(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype;

/*
 * Generate XML block for acm_priv_limitation record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_priv_limitation(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype;

/*
 * Generate XML block for acm_role_privilege record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role_privilege(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype;

/*
 * Generate XML block for acm_role_object record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role_object(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype;

end acm_prc_export_pkg;
/
