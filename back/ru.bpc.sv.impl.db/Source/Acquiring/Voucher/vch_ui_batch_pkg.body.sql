create or replace package body vch_ui_batch_pkg as
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
) is
begin
    o_id     := vch_batch_seq.nextval;
    o_seqnum := 1;
    
    insert into vch_batch_vw(
        id
      , seqnum
      , status
      , total_amount
      , currency
      , total_count
      , reg_date
      , merchant_id
      , terminal_id
      , status_reason
      , user_id
      , inst_id
      , card_network_id
    ) values(
        o_id
      , o_seqnum
      , i_status
      , i_total_amount
      , i_currency
      , i_total_count
      , get_sysdate
      , i_merchant_id
      , i_terminal_id
      , null
      , get_user_id
      , i_inst_id
      , i_card_network_id
    );
end;

procedure modify_batch(
    i_id              in      com_api_type_pkg.t_long_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_status          in      com_api_type_pkg.t_dict_value
  , i_status_reason   in      com_api_type_pkg.t_dict_value
  , i_user_id         in      com_api_type_pkg.t_short_id
) is
begin
    update vch_batch_vw
       set seqnum        = io_seqnum
         , status        = i_status
         , status_reason = i_status_reason
         , user_id       = i_user_id
     where id            = i_id;

    io_seqnum  := io_seqnum + 1; 
end;

procedure remove_batch(
    i_id              in      com_api_type_pkg.t_long_id
  , i_seqnum          in      com_api_type_pkg.t_seqnum
) is
begin
    update vch_batch_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete vch_batch_vw
     where id     = i_id;

end;

end;
/
