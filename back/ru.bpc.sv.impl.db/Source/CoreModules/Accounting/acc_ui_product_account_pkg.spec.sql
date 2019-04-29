create or replace package acc_ui_product_account_pkg is

    procedure add_product_account_type (
        o_id                        out com_api_type_pkg.t_short_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_account_type            in com_api_type_pkg.t_dict_value
        , i_scheme_id               in com_api_type_pkg.t_tiny_id
        , i_currency                in com_api_type_pkg.t_curr_code
        , i_service_id              in com_api_type_pkg.t_short_id
        , i_aval_algorithm          in com_api_type_pkg.t_dict_value
    );

    procedure modify_product_account_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_account_type            in com_api_type_pkg.t_dict_value
        , i_scheme_id               in com_api_type_pkg.t_tiny_id
        , i_currency                in com_api_type_pkg.t_curr_code
        , i_service_id              in com_api_type_pkg.t_short_id
        , i_aval_algorithm          in com_api_type_pkg.t_dict_value
    );

    procedure remove_product_account_type (
        i_id                        in com_api_type_pkg.t_tiny_id
    );

end;
/
