create or replace package acc_api_macros_pkg is

    function count_macros_by_status (
        i_entity_type           in com_api_type_pkg.t_dict_value
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_status              in com_api_type_pkg.t_dict_value
    ) return number;

end;
/