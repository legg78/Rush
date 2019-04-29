create or replace package dpp_api_instalment_pkg as
/*********************************************************
*  API for dpp instalment <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: DPP_API_INSTALMENT_PKG <br />
*  @headcom
**********************************************************/

procedure add_instalment(
    o_id                         out com_api_type_pkg.t_long_id
  , i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_instalment_number       in     com_api_type_pkg.t_tiny_id
  , i_instalment_date         in     date
  , i_instalment_amount       in     com_api_type_pkg.t_money
  , i_payment_amount          in     com_api_type_pkg.t_money
  , i_interest_amount         in     com_api_type_pkg.t_money
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , i_macros_intr_id          in     com_api_type_pkg.t_long_id  
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
  , i_split_hash              in     com_api_type_pkg.t_tiny_id
  , i_fee_id                  in     com_api_type_pkg.t_short_id    default null
  , i_acceleration_reason     in     com_api_type_pkg.t_dict_value  default null
);

function get_last_paid_instalm_number(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id;

end dpp_api_instalment_pkg;
/
