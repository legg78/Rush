create or replace package ntf_prc_notification_pkg as

procedure make_notification (
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_ignore_missing_service    in      com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
);

procedure make_user_notification (
    i_inst_id                   in      com_api_type_pkg.t_inst_id
);

procedure upload_notification(
    i_channel_id                in      com_api_type_pkg.t_tiny_id   default null
);
    
procedure send_message(
    i_inst_id                   in      com_api_type_pkg.t_inst_id   default null
  , i_product_id                in      com_api_type_pkg.t_short_id  default null
  , i_bin_range_start           in      com_api_type_pkg.t_short_id  default null
  , i_bin_range_end             in      com_api_type_pkg.t_short_id  default null
  , i_delivery_time             in      date                         default null
  , i_message_text              in      com_api_type_pkg.t_text      default null
);    

end;
/
