create or replace package opr_api_notification_pkg as

procedure report_card_operation (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value := null
);

procedure report_account_operation (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value := null
);

procedure report_card_account_operation (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type   in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id     in      com_api_type_pkg.t_long_id := null
);

end opr_api_notification_pkg;
/
