create or replace package body atm_api_status_log_pkg is

    procedure add_status_log (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_status              in com_api_type_pkg.t_dict_value
        , i_atm_part_type       in com_api_type_pkg.t_dict_value
    ) is
    begin
        insert into atm_status_log_vw (
            terminal_id
            , status
            , change_date
            , atm_part_type
        ) values (
            i_terminal_id
            , i_status
            , com_api_sttl_day_pkg.get_sysdate()
            , i_atm_part_type
        );
    end;

end;
/
