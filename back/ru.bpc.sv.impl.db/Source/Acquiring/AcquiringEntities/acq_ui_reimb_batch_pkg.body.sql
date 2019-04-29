create or replace package body acq_ui_reimb_batch_pkg as

procedure modify_batch(
    i_reimb_batch_id    in      com_api_type_pkg.t_medium_id
  , i_reimb_date        in      date
  , i_cheque_number     in      com_api_type_pkg.t_name
  , i_status            in      com_api_type_pkg.t_dict_value
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update acq_reimb_batch_vw
       set reimb_date    = i_reimb_date
         , cheque_number = i_cheque_number
         , status        = i_status
         , seqnum        = i_seqnum
     where id            = i_reimb_batch_id;
end;

procedure modify_batch_bulk(
    i_reimb_batch_id    in      com_api_type_pkg.t_number_tab
  , i_reimb_date        in      com_api_type_pkg.t_date_tab
  , i_cheque_number     in      com_api_type_pkg.t_name_tab
  , i_status            in      com_api_type_pkg.t_dict_tab
  , i_seqnum            in      com_api_type_pkg.t_number_tab
) is
begin
    forall i in 1..i_reimb_batch_id.count
        update acq_reimb_batch_vw
           set reimb_date    = i_reimb_date(i)
             , cheque_number = i_cheque_number(i)
             , status        = i_status(i)
             , seqnum        = i_seqnum(i)
         where id            = i_reimb_batch_id(i);
end;

end;
/
