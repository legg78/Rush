create or replace package body acc_api_macros_pkg is

    function count_macros_by_status (
        i_entity_type           in com_api_type_pkg.t_dict_value
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_status              in com_api_type_pkg.t_dict_value
    ) return number is
    
        l_count                 number;
    
    begin
        select
            count(*)
        into
            l_count
        from
            acc_macros m
        where
            m.entity_type = i_entity_type
            and m.object_id = i_object_id
            and m.status = i_status;
    
        return l_count;
    end;

end;
/