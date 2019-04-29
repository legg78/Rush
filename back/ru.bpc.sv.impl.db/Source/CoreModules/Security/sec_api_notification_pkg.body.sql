create or replace package body sec_api_notification_pkg as

g_otp                   com_api_type_pkg.t_name;

procedure otp_report(
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
begin
    if g_otp is null then
        g_otp := 
            sec_api_passwd_pkg.generate_otp(
                i_inst_id       => i_inst_id
            );    
    end if;

    select
        xmlelement("report"
          , xmlelement("event_type", i_event_type)
          , xmlelement("one_time_password", g_otp)
        ).getclobval()
    into
        o_xml
    from
        dual;

end;

function get_otp return com_api_type_pkg.t_name is
begin
    return g_otp;
end;

procedure unset_otp is
begin
    g_otp := null;
end;

procedure set_otp(
    i_otp               in      com_api_type_pkg.t_name
) is
begin
    g_otp := i_otp;
end;

end;
/