create or replace package acm_api_const_pkg as
/***********************************************************
* Access Managment constants. <br>
* Created by Kryukov E.(krukov@bpc.ru)  at 12.05.2010  <br>
* Last changed by $Author$ <br>
* $LastChangedDate::                           $  <br>
* Revision: $LastChangedRevision$ <br>
* Module: ACM_API_CONST_PKG <br>
* @headcom
*************************************************************/

-- ROLES
ROLE_ROOT            com_api_type_pkg.t_name        := 'ROOT';

-- Users
UNDEFINED_USER_ID               constant    com_api_type_pkg.t_short_id   := -1;

-- ENTITY
ENTITY_TYPE_ROLE                constant    com_api_type_pkg.t_dict_value := 'ENTTROLE';
ENTITY_TYPE_USER                constant    com_api_type_pkg.t_dict_value := 'ENTTUSER';
ENTITY_TYPE_USER_GROUP          constant    com_api_type_pkg.t_dict_value := 'ENTTAMUG';

-- User status
STATUS_ACTIVE                   constant    com_api_type_pkg.t_dict_value := 'USSTACTV';
STATUS_NOACTIVE                 constant    com_api_type_pkg.t_dict_value := 'USSTNOAC';

-- User Action Statuses
USER_ACTION_STATUS_SUCCESS      constant    com_api_type_pkg.t_dict_value := 'UASTOKAY';
USER_ACTION_STATUS_ERROR        constant    com_api_type_pkg.t_dict_value := 'UASTERR';
USER_ACTION_STATUS_ACCESS_DEN   constant    com_api_type_pkg.t_dict_value := 'UAST403';
USER_ACTION_STATUS_ACC_LOCK     constant    com_api_type_pkg.t_dict_value := 'UASTLOCK';

PASSWORD_EXPIRATION_CYCLE_TYPE  constant    com_api_type_pkg.t_dict_value := 'CYTP1301';
CYCLE_TYPE_LOCKOUT              constant    com_api_type_pkg.t_dict_value := 'CYTP1302';

LIMIT_TYPE_FAILED_LOGINS        constant    com_api_type_pkg.t_dict_value := 'LMTP1302';

PASSWORD_IS_CORRECT             constant    com_api_type_pkg.t_sign       := 1;
PASSWORD_IS_INCORRECT           constant    com_api_type_pkg.t_sign       := 0;
PASSWORD_IS_EXPIRED             constant    com_api_type_pkg.t_sign       := -1;

ACTION_TYPE_INSERT              constant    com_api_type_pkg.t_dict_value := 'INSERT';

PRIV_CHANGE_PASSWORD            constant    com_api_type_pkg.t_short_id   := 10000350;
PRIV_LOGIN                      constant    com_api_type_pkg.t_short_id   := 10000037;

-- Privilege limitation type
PRIV_LIMITATION_RESULT          constant    com_api_type_pkg.t_dict_value := 'PRLMRSLT';
PRIV_LIMITATION_FILTER          constant    com_api_type_pkg.t_dict_value := 'PRLMFLTR';

end acm_api_const_pkg;
/

