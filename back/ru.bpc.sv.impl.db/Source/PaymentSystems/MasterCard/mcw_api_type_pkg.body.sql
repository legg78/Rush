create or replace package body mcw_api_type_pkg is

    function get_clearing_file_ack_status (
        i_file_id      in com_api_type_pkg.t_long_id    -- mcw_file.id
      , i_is_incoming  in com_api_type_pkg.t_boolean    -- mcw_file.is_incoming
      , i_is_rejected  in com_api_type_pkg.t_boolean    -- mcw_file.i_is_rejected
      , i_status       in com_api_type_pkg.t_dict_value -- prc_session_file.status
    ) return com_api_type_pkg.t_dict_value
    is
        l_is_exist_reject_rec com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    begin
        for rc in ( select 1 from mcw_fin
                     where file_id = i_file_id
                       and nvl(is_rejected, 0) = 1
                       and rownum = 1
                  )
        loop
            l_is_exist_reject_rec := com_api_type_pkg.TRUE;
        end loop;

        if i_is_incoming = 1 then
            return null;

        elsif nvl(i_status,'&') = 'FLSTACPT' then
            return 'FLCS0004';    --approved

        elsif nvl(i_is_rejected, 0) = 1 then
            return 'FLCS0002';    --rejected

        elsif nvl(i_is_rejected, 0) = 0 then

            if l_is_exist_reject_rec = 1 then
                return 'FLCS0003';    --partial rejected

            elsif  nvl(i_status,'&') <> 'FLSTACPT' then
                return 'FLCS0001';    --sended

            else
                return null;  --???????
            end if;

        end if;
    end;

end;
/
