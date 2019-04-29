create or replace package acc_api_customer_pkg is
/********************************************************* 
 *  API for customer's accounts <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 05.12.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acc_api_customer_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure get_customer_accounts(
    i_customer_id    in     com_api_type_pkg.t_medium_id
  , i_currency       in     com_api_type_pkg.t_curr_code
  , i_rate_type      in     com_api_type_pkg.t_dict_value
  , o_accounts          out sys_refcursor
);

end;
/
