create or replace package body acq_ui_reimb_macros_type_pkg as

procedure add_macros_type(
    o_reimb_macros_id      out  com_api_type_pkg.t_tiny_id
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id
  , i_amount_type       in      com_api_type_pkg.t_dict_value
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
begin
    select acq_reimb_macros_type_seq.nextval into o_reimb_macros_id from dual;

    insert into acq_reimb_macros_type_vw(
        id
      , macros_type_id
      , amount_type
      , is_reversal
      , inst_id
      , seqnum
    ) values (
        o_reimb_macros_id
      , i_macros_type_id
      , i_amount_type
      , i_is_reversal
      , i_inst_id
      , 1
    );
end;

procedure modify_macros_type(
    i_reimb_macros_id   in      com_api_type_pkg.t_tiny_id
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id
  , i_amount_type       in      com_api_type_pkg.t_dict_value
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update acq_reimb_macros_type_vw
       set macros_type_id = i_macros_type_id
         , amount_type    = i_amount_type
         , is_reversal    = i_is_reversal
         , seqnum         = i_seqnum
     where id             = i_reimb_macros_id;
end;

procedure remove_macros_type(
    i_reimb_macros_id   in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update acq_reimb_macros_type_vw
       set seqnum         = i_seqnum
     where id             = i_reimb_macros_id;

    delete from acq_reimb_macros_type_vw
     where id             = i_reimb_macros_id;
end;

end;
/
