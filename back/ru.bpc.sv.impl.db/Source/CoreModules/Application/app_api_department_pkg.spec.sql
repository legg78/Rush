create or replace package app_api_department_pkg as
/************************************************************
 * API for departments<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.10.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: APP_API_DEPARTMENT_PKG <br />
 * @headcom
 ************************************************************/

/*
 *
 * @param i_appl_data_id
 * @param i_parent_appl_data
 * @param i_customer_id
 * @param io_appl_data
 * @param i_contract_id
 */
procedure process_department(
    i_appl_data_id         in      com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_customer_id          in      com_api_type_pkg.t_medium_id
  , i_contract_id          in      com_api_type_pkg.t_medium_id
);

end app_api_department_pkg;
/
