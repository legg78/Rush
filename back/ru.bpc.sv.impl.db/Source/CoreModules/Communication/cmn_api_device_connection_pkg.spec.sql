create or replace package cmn_api_device_connection_pkg is

    procedure set_device_connection (
        i_device_id                 in com_api_type_pkg.t_short_id
        , i_connect_number          in com_api_type_pkg.t_tiny_id
        , i_status                  in com_api_type_pkg.t_dict_value
    );
    
    procedure set_device_connection (
        i_device_id                 in com_api_type_pkg.t_short_id
        , i_connect_status          in com_api_type_pkg.t_name
    );

    procedure remove_device_connection (
        i_device_id                 in com_api_type_pkg.t_short_id
    );
    
end;
/
