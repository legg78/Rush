create or replace package sec_api_notification_pkg as

procedure otp_report(
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date := null
  , i_entity_type       in      com_api_type_pkg.t_dict_value := null
  , i_object_id         in      com_api_type_pkg.t_long_id := null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
);

function get_otp return com_api_type_pkg.t_name;

procedure unset_otp;

procedure set_otp(
    i_otp               in      com_api_type_pkg.t_name
);

end;
/