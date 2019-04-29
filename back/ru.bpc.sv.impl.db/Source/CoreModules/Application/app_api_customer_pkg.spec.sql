create or replace package app_api_customer_pkg as
/*********************************************************
*  Application - customer <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 26.01.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_CUSTOMER_PKG <br />
*  @headcom
**********************************************************/

/*
 *
 * @param i_appl_data_id
 * @param i_inst_id
 * @param io_appl_data
 * @param o_customer_id

 */

function get_customer_id return com_api_type_pkg.t_medium_id;

function get_customer_person_id return com_api_type_pkg.t_person_id;

function get_customer_count return com_api_type_pkg.t_short_id;

procedure process_customer(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , o_customer_id             out nocopy com_api_type_pkg.t_medium_id
  , i_pool_number          in            com_api_type_pkg.t_short_id   default 1
);

end app_api_customer_pkg;
/
