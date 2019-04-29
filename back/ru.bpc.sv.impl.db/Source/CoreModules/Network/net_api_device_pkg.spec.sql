CREATE OR REPLACE package net_api_device_pkg is

    procedure set_signed_on (
        i_device_id             in com_api_type_pkg.t_short_id
        , i_is_signed_on        in com_api_type_pkg.t_boolean
    );

    procedure set_connected_on (
        i_device_id             in com_api_type_pkg.t_short_id
        , i_is_connected        in com_api_type_pkg.t_boolean
    );

    procedure set_stand_in (
        i_device_id             in com_api_type_pkg.t_short_id
        , i_is_stand_in         in com_api_type_pkg.t_boolean
    );
    
end;
/