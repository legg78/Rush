create or replace package vch_ui_voucher_pkg as
/*********************************************************
*  UI for vouchers <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.03.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::       $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: vch_ui_batch_pkg<br />
*  @headcom
**********************************************************/
procedure add_voucher(
    o_id                     out  com_api_type_pkg.t_long_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_batch_id            in      com_api_type_pkg.t_long_id
  , i_expir_date          in      date
  , i_oper_amount         in      com_api_type_pkg.t_money
  , i_oper_type           in      com_api_type_pkg.t_dict_value
  , i_auth_code           in      com_api_type_pkg.t_auth_code
  , i_oper_request_amount in      com_api_type_pkg.t_money
  , i_oper_date           in      date
  , i_card_number         in      com_api_type_pkg.t_card_number
);

procedure modify_voucher(
    i_id              in      com_api_type_pkg.t_long_id
  , io_seqnum         in out  com_api_type_pkg.t_tiny_id
  , i_oper_amount     in      com_api_type_pkg.t_money
);

procedure remove_voucher(
    i_id             in      com_api_type_pkg.t_long_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
);

end;
/
