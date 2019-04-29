create or replace package acq_ui_reimb_macros_type_pkg as

procedure add_macros_type(
    o_reimb_macros_id      out  com_api_type_pkg.t_tiny_id
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id
  , i_amount_type       in      com_api_type_pkg.t_dict_value
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure modify_macros_type(
    i_reimb_macros_id   in      com_api_type_pkg.t_tiny_id
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id
  , i_amount_type       in      com_api_type_pkg.t_dict_value
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure remove_macros_type(
    i_reimb_macros_id   in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
