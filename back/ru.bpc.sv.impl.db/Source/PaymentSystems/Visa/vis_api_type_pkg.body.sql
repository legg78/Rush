create or replace package body vis_api_type_pkg is

function get_clearing_file_ack_status (
    i_file_id      in com_api_type_pkg.t_long_id    -- vis_file.id
  , i_is_incoming  in com_api_type_pkg.t_boolean    -- vis_file.is_incoming
  , i_is_rejected  in com_api_type_pkg.t_boolean    -- vis_file.is_returned
  , i_status       in com_api_type_pkg.t_dict_value -- prc_session_file.status
) return com_api_type_pkg.t_dict_value
is
    l_is_exist_reject_rec com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
begin
    for rc in (
        select 1 from vis_fin_message
         where file_id = i_file_id
           and nvl(is_returned, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
           and rownum = 1
    ) loop
        l_is_exist_reject_rec := com_api_type_pkg.TRUE;
    end loop;

    if i_is_incoming = com_api_type_pkg.TRUE then
        return null;

    elsif nvl(i_status, '&') = prc_api_const_pkg.FILE_STATUS_ACCEPTED then
        return 'FLCS0004';    --approved

    elsif nvl(i_is_rejected, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        return 'FLCS0002';    --rejected

    else

        if l_is_exist_reject_rec = com_api_type_pkg.TRUE then
            return 'FLCS0003';    --partial rejected

        elsif  nvl(i_status, '&') != prc_api_const_pkg.FILE_STATUS_ACCEPTED then
            return 'FLCS0001';    --sended

        else
            return null ;   --???????
        end if;

    end if;
end;

end;
/
