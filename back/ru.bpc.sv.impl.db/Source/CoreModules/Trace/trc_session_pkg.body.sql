create or replace package body trc_session_pkg as

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_text              in      com_api_type_pkg.t_text
) is
begin
    if i_trace_conf.use_session = com_api_type_pkg.TRUE then
       dbms_application_info.set_module(i_text, null);
       dbms_application_info.set_action(i_level || ' ' ||  to_char(i_timestamp, 'dd.mm.yyyy hh24:mi:ss') );
   end if;
end;

end;
/
