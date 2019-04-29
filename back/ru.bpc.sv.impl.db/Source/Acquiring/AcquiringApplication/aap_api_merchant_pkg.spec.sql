create or replace package aap_api_merchant_pkg as
/*********************************************************
 *  Acquiring applications merchants API  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 10.11.2010 <br />
 *  Module: aap_api_merchant_pkg <br />
 *  @headcom
 **********************************************************/

g_merchant_card_tab              acq_api_type_pkg.t_merchant_card_tab;

procedure process_merchant(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
);

procedure check_merchant_tree(
    i_parent_id            in            com_api_type_pkg.t_short_id
  , i_merchant_type        in            com_api_type_pkg.t_dict_value
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
);

end;
/
