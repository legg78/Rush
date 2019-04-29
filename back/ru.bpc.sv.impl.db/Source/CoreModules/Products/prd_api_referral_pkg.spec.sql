create or replace package prd_api_referral_pkg as
/*********************************************************
 *  Acquiring/issuing application API  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 28.09.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_api_referral_pkg <br />
 *  @headcom
 **********************************************************/

procedure add_referrer(
    o_id                      out com_api_type_pkg.t_medium_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id
  , i_customer_id          in     com_api_type_pkg.t_medium_id
  , i_referral_code        in     com_api_type_pkg.t_name
  , i_cust_number          in     com_api_type_pkg.t_name default null
  , i_prod_number          in     com_api_type_pkg.t_name default null
  , i_agent_number         in     com_api_type_pkg.t_name default null
);

procedure add_referral(
    o_id                      out com_api_type_pkg.t_medium_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id
  , i_customer_id          in     com_api_type_pkg.t_medium_id
  , i_referrer_id          in     com_api_type_pkg.t_name
);

end;
/
