create or replace package body crp_api_department_pkg is
/*********************************************************
*  Corporation - Departments <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 07.10.2011 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate: 2010-04-27 17:29:49 +0400#$ <br />
*  Revision: $LastChangedRevision: 11321 $ <br />
*  Module: CRP_API_DEPARTMENT_PKG <br />
*  @headcom
**********************************************************/

procedure get_customer_compamy (
    i_customer_id               in     com_api_type_pkg.t_medium_id
  , o_company_id                   out com_api_type_pkg.t_short_id
) is
begin
    select
        c.id
    into
        o_company_id
    from
        prd_customer_vw a
        , com_company_vw c
    where
        a.id = i_customer_id
        and a.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
        and c.id = a.object_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => 'CUSTOMER_NOT_FOUND'
            , i_env_param1  => i_customer_id
        );
end;

procedure add_department (
    o_id                         out com_api_type_pkg.t_short_id
  , i_parent_id               in     com_api_type_pkg.t_short_id
  , i_corp_customer_id        in     com_api_type_pkg.t_medium_id
  , i_corp_contract_id        in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_label                   in     com_api_type_pkg.t_name
) is
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_corp_company_id           com_api_type_pkg.t_short_id;
begin
    o_id := crp_department_seq.nextval;
    l_seqnum := 1;

    get_customer_compamy (
        i_customer_id   => i_corp_customer_id
        , o_company_id  => l_corp_company_id
    );

    insert into crp_department_vw (
        id
        , seqnum
        , parent_id
        , corp_company_id
        , corp_customer_id
        , corp_contract_id
        , inst_id
    ) values (
        o_id
        , l_seqnum
        , i_parent_id
        , l_corp_company_id
        , i_corp_customer_id
        , i_corp_contract_id
        , i_inst_id
    );
    
    com_api_i18n_pkg.add_text (
        i_table_name     => 'crp_department'
        , i_column_name  => 'label'
        , i_object_id    => o_id
        , i_lang         => nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
        , i_text         => i_label
    );

end;

procedure modify_department (
    i_id                      in     com_api_type_pkg.t_short_id
  , i_parent_id               in     com_api_type_pkg.t_short_id
  , i_corp_customer_id        in     com_api_type_pkg.t_medium_id
  , i_corp_contract_id        in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_label                   in     com_api_type_pkg.t_name
) is
        l_corp_company_id           com_api_type_pkg.t_short_id;
begin
    get_customer_compamy (
        i_customer_id   => i_corp_customer_id
      , o_company_id    => l_corp_company_id
    );

    update
        crp_department_vw
    set
        seqnum = seqnum + 1
        , parent_id = i_parent_id
        , corp_company_id = l_corp_company_id
        , corp_customer_id = i_corp_customer_id
        , corp_contract_id = i_corp_contract_id
        , inst_id = i_inst_id
    where
        id = i_id;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'crp_department'
        , i_column_name  => 'label'
        , i_object_id    => i_id
        , i_lang         => nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
        , i_text         => i_label
    );

end;

procedure remove_department (
    i_id                      in     com_api_type_pkg.t_short_id
  , i_transfer_id             in     com_api_type_pkg.t_short_id
) is
begin
    -- transfer depend employee
    update
        crp_employee_vw
    set
        dep_id = i_transfer_id
    where
        dep_id in (
            select
                id
            from
                crp_department_vw
            connect by
                parent_id = prior id
            start with
                id = i_id
        );

    -- remove text
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'crp_department'
        , i_object_id  => i_id
    );

    delete from
        crp_department_vw
    where
        id in (
            select
                id
            from
                crp_department_vw
            connect by
                parent_id = prior id
            start with
                id = i_id
        );
end;

end;
/
