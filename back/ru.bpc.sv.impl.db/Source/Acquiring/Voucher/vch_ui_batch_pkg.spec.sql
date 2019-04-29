create or replace package vch_ui_batch_pkg as
/*********************************************************
*  UI for voucher batches <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.03.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::       $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: vch_ui_batch_pkg<br />
*  @headcom
**********************************************************/
procedure add_batch(
    o_id                 out  com_api_type_pkg.t_long_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_status          in      com_api_type_pkg.t_dict_value
  , i_total_amount    in      com_api_type_pkg.t_money
  , i_currency        in      com_api_type_pkg.t_curr_code
  , i_total_count     in      com_api_type_pkg.t_tiny_id
  , i_merchant_id     in      com_api_type_pkg.t_short_id
  , i_terminal_id     in      com_api_type_pkg.t_short_id
  , i_inst_id         in      com_api_type_pkg.t_tiny_id
  , i_card_network_id in      com_api_type_pkg.t_tiny_id
);

procedure modify_batch(
    i_id              in      com_api_type_pkg.t_long_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_status          in      com_api_type_pkg.t_dict_value
  , i_status_reason   in      com_api_type_pkg.t_dict_value
  , i_user_id         in      com_api_type_pkg.t_short_id
);

procedure remove_batch(
    i_id              in      com_api_type_pkg.t_long_id
  , i_seqnum          in      com_api_type_pkg.t_seqnum
);

end;
/
