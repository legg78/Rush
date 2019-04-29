create or replace package acc_api_scheme_pkg is

    function select_distinct_account (
        i_account_id                    in com_api_type_pkg.t_account_id
        , i_transf_entity_type          in com_api_type_pkg.t_dict_value
        , i_transf_entity_id            in com_api_type_pkg.t_long_id
        , i_transf_account_type         in com_api_type_pkg.t_dict_value
        , i_transf_currency             in com_api_type_pkg.t_curr_code := null
    ) return acc_api_type_pkg.t_account_rec;

end;
/
