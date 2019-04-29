create or replace package app_api_product_pkg as

/*********************************************************
*  Application API for products <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 12.02.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_PRODUCT_PKG <br />
*  @headcom
**********************************************************/

/*
 * process product  definition when creating customer, cardholder, etc
 * @param i_service_id
 * @param i_object_id
 * @param i_entity_type
 */
procedure process_product(
    i_service_id    in  com_api_type_pkg.t_long_id
  , i_object_id     in  com_api_type_pkg.t_long_id
  , i_entity_type   in  com_api_type_pkg.t_dict_value
  , i_inst_id       in  com_api_type_pkg.t_inst_id
);

procedure process_product(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
  , o_product_id   out nocopy     com_api_type_pkg.t_short_id
);

end app_api_product_pkg;
/
