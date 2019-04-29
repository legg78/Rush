create or replace package iap_api_card_pkg as
/*********************************************************
*  Application - cards <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 04.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: IAP_CARD_PKG <br />
*  @headcom
**********************************************************/

procedure process_card(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_agent_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , o_card_id                 out        com_api_type_pkg.t_medium_id
);

function get_app_merchant_service_count(
    i_appl_id         in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_short_id;

end;
/
