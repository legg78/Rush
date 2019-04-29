create or replace package body acc_api_scheme_pkg is

    function select_distinct_account (
        i_account_id                    in com_api_type_pkg.t_account_id
        , i_transf_entity_type          in com_api_type_pkg.t_dict_value
        , i_transf_entity_id            in com_api_type_pkg.t_long_id
        , i_transf_account_type         in com_api_type_pkg.t_dict_value
        , i_transf_currency             in com_api_type_pkg.t_curr_code
    ) return acc_api_type_pkg.t_account_rec is
    
        result                          acc_api_type_pkg.t_account_rec;
    
    begin
        begin
            select
                g.id
                , g.split_hash
                , g.account_type
                , g.account_number
                , g.currency
                , g.inst_id
                , g.agent_id
                , g.status
                , g.contract_id
                , g.customer_id
                , null              -- scheme_id
            into
                result.account_id
                , result.split_hash
                , result.account_type
                , result.account_number
                , result.currency
                , result.inst_id
                , result.agent_id
                , result.status
                , result.contract_id
                , result.customer_id
                , result.scheme_id
            from
                acc_account a
                , acc_gl_account_mvw g
            where
                a.id = nvl(i_account_id, a.id)
                and g.entity_id = nvl(i_transf_entity_id, decode(i_transf_entity_type, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, a.inst_id, ost_api_const_pkg.ENTITY_TYPE_AGENT, a.agent_id))
                and g.entity_type = i_transf_entity_type
                and g.account_type = i_transf_account_type
                and g.currency = nvl(i_transf_currency, a.currency)
                and a.id = g.id
                and a.status = 'ACSTACTV';
        exception
            when others then
                com_api_error_pkg.raise_error (
                    i_error     => 'DESTINATION_ACCOUNT_NOT_FOUND'
                );
        end;
        
        return result;
    end;

end;
/
