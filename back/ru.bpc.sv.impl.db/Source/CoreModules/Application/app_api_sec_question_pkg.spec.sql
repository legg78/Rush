create or replace package app_api_sec_question_pkg as
/*********************************************************
*  API for secure question <br />
*  Created by Kryukov A.(krukov@bpcbt.com)  at 18.10.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_SEC_QUESTION_PKG <br />
*  @headcom
**********************************************************/

/*
 * Process application block "Secure world"
 * @param i_appl_data_id
 * @param io_appl_data
 * @param i_object_id
 * @param i_entity_type
 */
procedure process_sec_question(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
);

end app_api_sec_question_pkg;
/
