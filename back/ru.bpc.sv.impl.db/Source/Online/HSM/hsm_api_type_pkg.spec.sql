create or replace package hsm_api_type_pkg is

    type            t_hsm_device_rec is record (
        id                   com_api_type_pkg.t_tiny_id
        , is_enabled         com_api_type_pkg.t_boolean
        , seqnum             com_api_type_pkg.t_seqnum
        , comm_protocol      com_api_type_pkg.t_dict_value
        , plugin             com_api_type_pkg.t_dict_value
        , manufacturer       com_api_type_pkg.t_dict_value
        , serial_number      com_api_type_pkg.t_name
        , lmk_id             com_api_type_pkg.t_tiny_id
        , address            com_api_type_pkg.t_merchant_number
        , port               com_api_type_pkg.t_dict_value
        , max_connection     com_api_type_pkg.t_tiny_id
        , model_number       com_api_type_pkg.t_dict_value
        , firmware           com_api_type_pkg.t_dict_value
        , lmk_value          com_api_type_pkg.t_name
    );
    type            t_hsm_device_tab is table of t_hsm_device_rec index by binary_integer;

end; 
/
