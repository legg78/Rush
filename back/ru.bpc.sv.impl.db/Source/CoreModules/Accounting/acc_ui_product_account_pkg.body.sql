create or replace package body acc_ui_product_account_pkg is

    procedure add_product_account_type (
        o_id                        out com_api_type_pkg.t_short_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_account_type            in com_api_type_pkg.t_dict_value
        , i_scheme_id               in com_api_type_pkg.t_tiny_id
        , i_currency                in com_api_type_pkg.t_curr_code
        , i_service_id              in com_api_type_pkg.t_short_id
        , i_aval_algorithm          in com_api_type_pkg.t_dict_value
    ) is
    l_count com_api_type_pkg.t_short_id;
      
    begin
        o_id := acc_product_account_type_seq.nextval;

        insert into acc_product_account_type_vw (
            id
            , product_id
            , account_type
            , scheme_id
            , currency
            , service_id
            , aval_algorithm
        ) values (
            o_id
            , i_product_id
            , i_account_type
            , i_scheme_id
            , i_currency
            , i_service_id
            , i_aval_algorithm
        );
    exception when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error => 'ACCOUNT_TYPE_OF_PRODUCT_ALREADY_EXISTS'
          , i_env_param1 => i_account_type
          , i_env_param2 => i_product_id
          , i_env_param3 => i_currency
          , i_env_param4 => i_service_id
        );             
    end;

    procedure modify_product_account_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_account_type            in com_api_type_pkg.t_dict_value
        , i_scheme_id               in com_api_type_pkg.t_tiny_id
        , i_currency                in com_api_type_pkg.t_curr_code
        , i_service_id              in com_api_type_pkg.t_short_id
        , i_aval_algorithm          in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            acc_product_account_type_vw
        set
            product_id       = i_product_id
            , account_type   = i_account_type
            , scheme_id      = i_scheme_id
            , currency       = i_currency
            , service_id     = i_service_id
            , aval_algorithm = i_aval_algorithm
        where
            id = i_id;
            
    exception when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error => 'ACCOUNT_TYPE_OF_PRODUCT_ALREADY_EXISTS'
          , i_env_param1 => i_account_type
          , i_env_param2 => i_product_id
          , i_env_param3 => i_currency
          , i_env_param4 => i_service_id
        );             
    end;

    procedure remove_product_account_type (
        i_id                        in com_api_type_pkg.t_tiny_id
    ) is
        l_check_cnt   number;
    begin
        -- check dependent

        if l_check_cnt > 0 then
            null;
        end if;

        delete from
            acc_product_account_type_vw
        where
            id = i_id;
    end;

end;
/
