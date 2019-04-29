create or replace package iap_cardholder_pkg as
/*********************************************************
*  API for cardholders <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 30.06.2010 <br />
*  Module: IAP_CARDHOLDER_PKG <br />
*  @headcom
**********************************************************/

/*
 * Create/modify cardholders
 * @param i_appl_data_id
 * @param i_parent_appl_data_id
 * @param io_appl_data
 * @param i_card_id
 * @param i_customer_id
 */

g_custom_event_tab              ntf_api_type_pkg.t_custom_event_tab;

procedure process_cardholder(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_card_id              in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_is_pool_card         in            com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , o_cardholder_id           out nocopy com_api_type_pkg.t_long_id
);

end iap_cardholder_pkg;
/
