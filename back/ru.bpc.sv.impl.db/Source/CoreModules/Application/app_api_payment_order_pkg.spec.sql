create or replace package app_api_payment_order_pkg is
/*********************************************************
 *  API for Payment Order in application <br />
 *  Created by Kopachev A.(kopachev@bpc.ru)  at 29.05.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_API_PAYMENT_ORDER_PKG  <br />
 *  @headcom
 **********************************************************/

/*
 * @param i_appl_data_id
 * @param i_inst_id
 * @param i_agent_id
 * @param i_account_id
 * @param i_customer_id
 * @param i_contract_id
 * @param io_appl_data
 */
procedure process_order(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
);
end;
/
