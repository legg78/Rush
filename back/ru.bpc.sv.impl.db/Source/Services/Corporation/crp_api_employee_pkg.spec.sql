create or replace package crp_api_employee_pkg is

    procedure add_employee (
        o_id                        out com_api_type_pkg.t_medium_id
        , i_corp_customer_id        in com_api_type_pkg.t_medium_id
        , i_corp_contract_id        in com_api_type_pkg.t_medium_id
        , i_dep_id                  in com_api_type_pkg.t_short_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_contract_id             in com_api_type_pkg.t_medium_id
        , i_account_id              in com_api_type_pkg.t_medium_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
    );

    procedure modify_employee (
        i_id                        in com_api_type_pkg.t_medium_id
        , i_corp_customer_id        in com_api_type_pkg.t_medium_id
        , i_corp_contract_id        in com_api_type_pkg.t_medium_id
        , i_dep_id                  in com_api_type_pkg.t_short_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_contract_id             in com_api_type_pkg.t_medium_id
        , i_account_id              in com_api_type_pkg.t_medium_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
    );
    
    procedure remove_employee (
        i_id                        in com_api_type_pkg.t_medium_id
    );

end;
/
