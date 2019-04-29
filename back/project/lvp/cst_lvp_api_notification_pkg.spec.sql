create or replace package cst_lvp_api_notification_pkg as

procedure report_payment (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
);

end cst_lvp_api_notification_pkg;
/
