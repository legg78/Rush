create or replace package app_api_contract_pkg as
/*********************************************************
*  Application - contract <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 26.01.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_CONTRACT_PKG <br />
*  @headcom
**********************************************************/

/*
 * 
 * @param i_appl_data_id
 * @param i_inst_id
 * @param i_agent_id
 * @param i_customer_id 
 * @param io_appl_data
 * @param o_contract_id
 */
procedure process_contract(
    i_appl_data_id  in     com_api_type_pkg.t_long_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_agent_id      in     com_api_type_pkg.t_short_id  
  , i_customer_id   in     com_api_type_pkg.t_medium_id
  , o_contract_id      out com_api_type_pkg.t_medium_id
  , i_pool_number   in     com_api_type_pkg.t_short_id   default 1
);

end app_api_contract_pkg;
/
