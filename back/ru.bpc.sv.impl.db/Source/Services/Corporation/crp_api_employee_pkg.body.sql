create or replace package body crp_api_employee_pkg is

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
    ) is
        l_seqnum                    com_api_type_pkg.t_seqnum;
        l_corp_company_id           com_api_type_pkg.t_short_id;
    begin
        crp_api_department_pkg.get_customer_compamy (
            i_customer_id   => i_corp_customer_id
            , o_company_id  => l_corp_company_id
        );
        
        o_id := crp_employee_seq.nextval;
        l_seqnum := 1;

        insert into crp_employee_vw (
            id
            , seqnum
            , corp_company_id
            , corp_customer_id
            , corp_contract_id
            , dep_id
            , entity_type
            , object_id
            , contract_id
            , account_id
            , inst_id
        ) values (
            o_id
            , l_seqnum
            , l_corp_company_id
            , i_corp_customer_id
            , i_corp_contract_id
            , i_dep_id
            , i_entity_type
            , i_object_id
            , i_contract_id
            , i_account_id
            , i_inst_id
        );
    
    end;

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
    ) is
        l_corp_company_id           com_api_type_pkg.t_short_id;
    begin
        crp_api_department_pkg.get_customer_compamy (
            i_customer_id   => i_corp_customer_id
            , o_company_id  => l_corp_company_id
        );
        
        update
            crp_employee_vw
        set
            seqnum = seqnum + 1
            , corp_company_id = l_corp_company_id
            , corp_customer_id = i_corp_customer_id
            , corp_contract_id = i_corp_contract_id
            , dep_id = i_dep_id
            , entity_type = i_entity_type
            , object_id = i_object_id
            , contract_id = i_contract_id
            , account_id = i_account_id
            , inst_id = i_inst_id
        where
            id = i_id;
    
    end;
    
    procedure remove_employee (
        i_id                        in com_api_type_pkg.t_medium_id
    ) is
    begin
        delete from
            crp_employee_vw
        where
            id = i_id;
    end;

end;
/
