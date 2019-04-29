create or replace package body vch_ui_voucher_pkg as
/*********************************************************
*  UI for voucher batches <br />
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
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    o_id      := vch_voucher_seq.nextval;
    o_seqnum  := 1;
    
    l_card_id := iss_api_card_pkg.get_card_id(i_card_number => i_card_number);

    insert into vch_voucher_vw(
        id
      , seqnum
      , batch_id
      , card_id
      , expir_date
      , oper_amount
      , oper_id
      , oper_type
      , auth_code
      , oper_request_amount
      , oper_date
    ) values(
        o_id
      , o_seqnum
      , i_batch_id
      , l_card_id
      , i_expir_date
      , i_oper_amount
      , null
      , i_oper_type
      , i_auth_code
      , i_oper_request_amount
      , i_oper_date
    );
    
    if i_card_number is not null then
        insert into vch_card_number(
            voucher_id
          , card_number
        ) values(
            o_id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
        );
    end if;
end;

procedure modify_voucher(
    i_id              in      com_api_type_pkg.t_long_id
  , io_seqnum         in out  com_api_type_pkg.t_tiny_id
  , i_oper_amount     in      com_api_type_pkg.t_money
)  is
begin
    update vch_voucher_vw
       set seqnum          = io_seqnum
         , oper_amount     = i_oper_amount
     where id              = i_id;
     
    io_seqnum := io_seqnum + 1;

end;

procedure remove_voucher(
    i_id             in      com_api_type_pkg.t_long_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
) is
begin
    update vch_voucher_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from vch_voucher_vw
     where id     = i_id;
end;

end;
/