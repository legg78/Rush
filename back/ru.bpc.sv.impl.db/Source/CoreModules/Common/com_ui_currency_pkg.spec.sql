create or replace package com_ui_currency_pkg is

    procedure add_currency (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_code                    in com_api_type_pkg.t_curr_code
        , i_name                    in com_api_type_pkg.t_curr_name
        , i_exponent                in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_currency_name           in com_api_type_pkg.t_name
    );

    procedure modify_currency (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_code                    in com_api_type_pkg.t_curr_code
        , i_name                    in com_api_type_pkg.t_curr_name
        , i_exponent                in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_currency_name           in com_api_type_pkg.t_name
    );

    procedure remove_currency (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
