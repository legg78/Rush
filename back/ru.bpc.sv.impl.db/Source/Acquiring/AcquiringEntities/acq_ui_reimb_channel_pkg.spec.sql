create or replace package acq_ui_reimb_channel_pkg as

procedure add_channel(
    o_channel_id           out  com_api_type_pkg.t_tiny_id
  , i_channel_number    in      com_api_type_pkg.t_name
  , i_payment_mode      in      com_api_type_pkg.t_dict_value
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_channel_name      in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
);

procedure modify_channel(
    i_channel_id        in      com_api_type_pkg.t_tiny_id
  , i_channel_number    in      com_api_type_pkg.t_name
  , i_payment_mode      in      com_api_type_pkg.t_dict_value
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_channel_name      in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
);

procedure remove_channel(
    i_channel_id        in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
