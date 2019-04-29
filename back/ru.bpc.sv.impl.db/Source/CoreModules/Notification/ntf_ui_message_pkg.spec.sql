create or replace package ntf_ui_message_pkg as

procedure remove_message(
    i_message_id_tab    in      num_tab_tpt
);

procedure remove_message(
    i_message_id        in      com_api_type_pkg.t_long_id
);

procedure get_undelivered_messages(
    i_channel_id        in      com_api_type_pkg.t_tiny_id  default null
  , i_max_count         in      com_api_type_pkg.t_long_id  default null
  , i_urgency_level     in      com_api_type_pkg.t_tiny_id  default null
  , o_messages             out  com_api_type_pkg.t_ref_cur
);

/*
 * Procedure marks a notification message unprocessed (undelivered).
 */
procedure mark_message_unprocessed(
    i_message_id        in      com_api_type_pkg.t_long_id
  , i_message_status    in      com_api_type_pkg.t_dict_value    
  , i_mask_error        in      com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
);

/*
 * Procedure set a notification message status. Feedback from sms-gate.
 */
procedure update_message_status(
    i_sms_gate_reference       in      com_api_type_pkg.t_short_id      default null  
  , i_message_status           in      com_api_type_pkg.t_dict_value    
  , i_message_status_reference in      com_api_type_pkg.t_name          default null 
  , i_mask_error               in      com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_delivery_date            in      date                             default null     
);

procedure update_message_status(
    i_message_id_tab           in      com_api_type_pkg.t_long_tab
  , i_message_status           in      com_api_type_pkg.t_dict_value 
  , i_mask_error               in      com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
);

end;
/
