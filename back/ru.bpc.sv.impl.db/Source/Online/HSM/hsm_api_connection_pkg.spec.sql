create or replace package hsm_api_connection_pkg is

    procedure set_connection (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_connect_number          in com_api_type_pkg.t_tiny_id
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_action                  in com_api_type_pkg.t_dict_value
    );

    procedure set_connection (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_connect_status          in com_api_type_pkg.t_name
        , i_action                  in com_api_type_pkg.t_dict_value
    );

    procedure remove_connection (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_action                  in com_api_type_pkg.t_dict_value := null
    );
    
    procedure remove_connection;

end;
/
