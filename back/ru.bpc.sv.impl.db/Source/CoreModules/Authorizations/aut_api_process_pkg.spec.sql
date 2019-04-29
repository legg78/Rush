create or replace package aut_api_process_pkg is

    procedure process_auth;

    procedure unhold (
        i_id                 in com_api_type_pkg.t_long_id
        , i_reason           in com_api_type_pkg.t_dict_value
        , i_rollback_limits  in com_api_type_pkg.t_boolean := null
    );

    procedure unhold_partial (
        i_id                 in com_api_type_pkg.t_long_id
        , i_reason           in com_api_type_pkg.t_dict_value
        , i_rollback_limits  in com_api_type_pkg.t_boolean := null
        , i_amount           in com_api_type_pkg.t_amount_rec := null
        , i_original_oper_id in com_api_type_pkg.t_long_id := null
    );

end aut_api_process_pkg;
/
