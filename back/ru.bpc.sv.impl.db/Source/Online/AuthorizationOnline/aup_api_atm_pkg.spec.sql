create or replace package aup_api_atm_pkg is

    procedure add_atm_tech (
        i_terminal_id               in com_api_type_pkg.t_short_id
      , i_tech_id                   in com_api_type_pkg.t_uuid
      , i_message_type              in com_api_type_pkg.t_tiny_id
      , i_last_oper_id              in com_api_type_pkg.t_long_id
    );

    procedure add_atm_status (
        i_tech_id                   in com_api_type_pkg.t_uuid
      , i_device_id                 in com_api_type_pkg.t_dict_value
      , i_device_status             in com_api_type_pkg.t_exponent
      , i_error_severity            in com_api_type_pkg.t_name
      , i_diag_status               in com_api_type_pkg.t_exponent
      , i_supplies_status           in com_api_type_pkg.t_dict_value
    );

    function get_atm_disp_condition(
        i_auth_id                   in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_full_desc;
    
end;
/
