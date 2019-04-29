create or replace package atm_api_status_log_pkg is

    procedure add_status_log (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_status              in com_api_type_pkg.t_dict_value
        , i_atm_part_type       in com_api_type_pkg.t_dict_value := null
    );

end;
/
