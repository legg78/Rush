create or replace package body frp_ui_fraud_pkg as

procedure modify_fraud(
    i_id           in      com_api_type_pkg.t_long_id
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_resolution   in      com_api_type_pkg.t_dict_value
) is
    l_event_type   com_api_type_pkg.t_dict_value;
begin
    update frp_fraud_vw
       set seqnum             = io_seqnum
         , resolution         = i_resolution
         , resolution_user_id = get_user_id
     where id          = i_id;

    io_seqnum := io_seqnum + 1;
end;

end;
/