create or replace package aap_api_terminal_pkg as
/*********************************************************
 *  Application -Terminals API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 03.09.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: aap_api_terminal_pkg <br />
 *  @headcom
 **********************************************************/
procedure process_terminal(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
);

end;
/
