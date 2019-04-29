create or replace package body prd_ui_contract_type_pkg as
/*********************************************************
*  UI for contract types <br />
*  Created by Kryukov E.(krukov@bpcsv.com)  at 25.05.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: PRD_UI_CONTRACT_TYPE_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_contract_type         in      com_api_type_pkg.t_dict_value
  , i_customer_entity_type  in      com_api_type_pkg.t_dict_value
  , i_product_type          in      com_api_type_pkg.t_dict_value
) is
begin
    o_id     := prd_contract_type_seq.nextval;
    o_seqnum := 1;

    insert into prd_contract_type_vw(
        id
      , seqnum
      , contract_type
      , customer_entity_type
      , product_type
    ) values (
        o_id
      , o_seqnum
      , i_contract_type
      , i_customer_entity_type
      , i_product_type
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'CONTRACT_TYPE_ALREADY_EXISTS'
          , i_env_param1 => i_contract_type
          , i_env_param2 => i_customer_entity_type
          , i_env_param3 => i_product_type
        );
end add;

procedure remove(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
) is
    l_contract_type                 com_api_type_pkg.t_dict_value;
begin
    begin
        select t.contract_type
          into l_contract_type
          from prd_contract t
             , prd_contract_type ct
             , prd_customer c
         where ct.id = i_id
           and ct.contract_type = t.contract_type
           and c.entity_type = ct.customer_entity_type
           and c.contract_id = t.id
           and rownum = 1;
           
        com_api_error_pkg.raise_error(
            i_error      => 'CONTRACT_TYPE_ALREADY_USED'
          , i_env_param1 => l_contract_type
          , i_env_param2 => i_id
        );
        
    exception
        when no_data_found then
            null;       
    end;

    update prd_contract_type_vw a
       set a.seqnum = i_seqnum
     where a.id     = i_id;

    delete prd_contract_type_vw a
     where a.id     = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'prd_contract_type'
      , i_object_id  => i_id
    );

end remove;

function get_product_type (
    i_contract_type                in com_api_type_pkg.t_dict_value
    , i_customer_entity_type       in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
begin
    for r in (
        select
            t.product_type
        from
            prd_contract_type_vw t
        where
            t.contract_type = i_contract_type
            and t.customer_entity_type = i_customer_entity_type
    ) loop
        return r.product_type;
    end loop;
    
    return null;
end;

end prd_ui_contract_type_pkg;
/
