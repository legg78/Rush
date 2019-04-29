create or replace package body com_cst_object_pkg as

procedure get_ref_cur(i_object_id        in      com_api_type_pkg.t_short_id
                    , i_object_type      in      com_api_type_pkg.t_dict_value
                    , i_entity_type      in      com_api_type_pkg.t_dict_value
                    , o_ref_cur              out com_api_type_pkg.t_ref_cur)
is
begin
    open o_ref_cur for 'select null as name, null as value from dual where 1 = 0';
end;

end com_cst_object_pkg;
/