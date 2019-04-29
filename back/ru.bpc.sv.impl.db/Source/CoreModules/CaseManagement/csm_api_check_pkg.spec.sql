create or replace package csm_api_check_pkg as
/*********************************************************
 *  Case management check API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 29.11.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: csm_api_check_pkg <br />
 *  @headcom
 **********************************************************/

-- Perform check
procedure perform_check (
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_merchant_number       in      com_api_type_pkg.t_account_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_dispute_id            in      com_api_type_pkg.t_long_id
  , i_original_id           in      com_api_type_pkg.t_long_id
  , i_de_024                in      mcw_api_type_pkg.t_de024
  , i_reason_code           in      com_api_type_pkg.t_mcc
  , i_de004                 in      mcw_api_type_pkg.t_de004   default null
  , i_de049                 in      mcw_api_type_pkg.t_de049   default null
);

end csm_api_check_pkg;
/
