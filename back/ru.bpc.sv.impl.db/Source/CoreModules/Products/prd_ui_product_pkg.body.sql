create or replace package body prd_ui_product_pkg is
/*********************************************************
*  UI for products <br />
*  Created by Filimonov A.(filimonov@bpcsv.com)  at 13.11.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2011-05-27 16:31:48 +0400#$ <br />
*  Revision: $LastChangedRevision: 9735 $ <br />
*  Module: PRD_UI_PRODUCT_PKG <br />
*  @headcom
**********************************************************/

procedure synch_product_service (
    i_product_id            in com_api_type_pkg.t_short_id
  , i_params                in com_api_type_pkg.t_param_tab
) is
    l_date                      date := get_sysdate;    
begin
    trc_log_pkg.debug(
        i_text => 'synch_product_service: i_product_id=' || i_product_id
    );
    -- remove
    delete from prd_product_service_vw
     where product_id in (
               select id as product_id
                 from prd_product_vw
                where id != i_product_id
                connect by prior id = parent_id
                start with id = i_product_id
           );

    -- update
    for r in (
        select id as product_id
             , inst_id
          from prd_product_vw
         where id != i_product_id
         connect by prior id = parent_id
         start with id = i_product_id
    ) loop
        insert into prd_product_service_vw (
            id
          , seqnum
          , parent_id
          , service_id
          , product_id
          , min_count
          , max_count
        )
        with ps as (
            select p.id
                 , p.parent_id
                 , p.service_id
                 , p.min_count
                 , p.max_count
                 , get_seq_val('prd_product_service_seq') new_id
              from prd_product_service p
             where p.product_id = i_product_id
             connect by prior p.id = p.parent_id
             start with p.parent_id is null
        )
        select p1.new_id
             , 1
             , (select p2.new_id from ps p2 where p2.id = p1.parent_id) parent_new_id
             , p1.service_id
             , r.product_id
             , p1.min_count
             , p1.max_count
          from ps p1;

        evt_api_event_pkg.register_event(
            i_event_type        => prd_api_const_pkg.EVENT_ADD_SERVICE
          , i_eff_date          => l_date
          , i_param_tab         => i_params
          , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_object_id         => r.product_id
          , i_inst_id           => r.inst_id
          , i_split_hash        => null
        );   
    end loop;

end synch_product_service;

-- Wrapper for compatibility
procedure synch_product_service(
    i_product_id            in com_api_type_pkg.t_short_id
) is
    l_params                com_api_type_pkg.t_param_tab;
begin
    synch_product_service(
        i_product_id => i_product_id
      , i_params     => l_params
    );
end synch_product_service;

procedure add_product (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_product_type        in com_api_type_pkg.t_dict_value
    , i_contract_type       in com_api_type_pkg.t_dict_value
    , i_parent_id           in com_api_type_pkg.t_short_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_lang                in com_api_type_pkg.t_dict_value
    , i_label               in com_api_type_pkg.t_name
    , i_description         in com_api_type_pkg.t_full_desc
    , i_status              in com_api_type_pkg.t_dict_value
    , i_product_number      in com_api_type_pkg.t_name          default null
    , i_split_hash          in com_api_type_pkg.t_tiny_id       default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_product: ';
    l_product_type             com_api_type_pkg.t_dict_value;
    l_product_number           com_api_type_pkg.t_name;
    l_split_hash               com_api_type_pkg.t_tiny_id;
begin
    if nvl(i_product_type, ' ') not in (prd_api_const_pkg.PRODUCT_TYPE_ISS
                                      , prd_api_const_pkg.PRODUCT_TYPE_ACQ
                                      , prd_api_const_pkg.PRODUCT_TYPE_INST
    ) then
        com_api_error_pkg.raise_error (
            i_error       => 'PRODUCT_OF_WRONG_TYPE'
          , i_env_param1  => i_product_type
        );
    end if;

    if i_contract_type is null
    then
        com_api_error_pkg.raise_error (
            i_error       => 'WRONG_CONTRACT_TYPE'
          , i_env_param1  => i_contract_type
        );
    end if;

    if i_parent_id is not null then
        begin
            select product_type
              into l_product_type
              from prd_product_vw
             where id = i_parent_id
               for update nowait;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'PARENT_PRODUCT_NOT_FOUND'
                  , i_env_param1  => i_parent_id
                );
        end;

        if l_product_type != i_product_type then
            com_api_error_pkg.raise_error (
                i_error       => 'PARENT_PRODUCT_OF_DIFFERENT_TYPE'
              , i_env_param1  => i_parent_id
              , i_env_param2  => i_product_type
              , i_env_param3  => l_product_type
            );
        end if;
    end if;

    declare
        l_count              com_api_type_pkg.t_count := 0;
    begin
        select 1
          into l_count
          from com_i18n a
             , prd_product b
         where a.table_name  = 'PRD_PRODUCT'
           and a.column_name = 'LABEL'
           and a.text        = i_label
           and b.inst_id     = i_inst_id
           and b.id          = a.object_id;

        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_DESCRIPTION'
          , i_env_param1  => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_env_param2  => 'LABEL'
          , i_env_param3  => i_label
        );
    exception
        when no_data_found then
            null;
    end;

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );

    o_id := prd_product_seq.nextval;
    o_seqnum := 1;

    -- if <i_product_number> is not passed then it is generated with using appropriate name format
    if i_product_number is not null then
        l_product_number := i_product_number;
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'generating product_number, i_product_id [#1], i_inst_id [#2]'
          , i_env_param1 => o_id
          , i_env_param2 => i_inst_id
        );

        l_product_number:= prd_api_product_pkg.generate_product_number(
                               i_product_id        => o_id
                             , i_inst_id           => i_inst_id
                             , i_eff_date          => com_api_sttl_day_pkg.get_sysdate()
                           );
    end if;

    l_split_hash := coalesce(i_split_hash, com_api_hash_pkg.get_split_hash(i_value => o_id));

    insert into prd_product_vw (
        id
      , product_type
      , contract_type
      , parent_id
      , seqnum
      , inst_id
      , status
      , product_number
      , split_hash
    ) values (
        o_id
      , i_product_type
      , i_contract_type
      , i_parent_id
      , o_seqnum
      , i_inst_id
      , i_status
      , l_product_number
      , l_split_hash
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_product'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_product'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'id[#1], i_product_type[#2], i_inst_id[#3], i_label[#4], i_status[#5], l_product_number[#6]'
      , i_env_param1  => o_id
      , i_env_param2  => i_product_type
      , i_env_param3  => i_inst_id
      , i_env_param4  => i_label
      , i_env_param5  => i_status
      , i_env_param6  => l_product_number
    );

    if i_parent_id is not null then
        synch_product_service( i_parent_id );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_PRODUCT_NUMBER'
          , i_env_param1 => i_product_number
          , i_env_param2 => i_inst_id
        );
    when others then
        trc_log_pkg.error(
            i_text      => LOG_PREFIX || 'id[#2], i_product_type[#3], i_inst_id[#4], '
                                        || 'i_status[#5], i_product_number[#6]; sqlerrm[#1]'
          , i_env_param1 => substr(sqlerrm, 1, 2000)
          , i_env_param2 => o_id
          , i_env_param3 => i_product_type
          , i_env_param4 => i_inst_id
          , i_env_param5 => i_status
          , i_env_param6 => i_product_number
        );
        raise;
end add_product;

procedure modify_product (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_lang                in com_api_type_pkg.t_dict_value
    , i_label               in com_api_type_pkg.t_name
    , i_description         in com_api_type_pkg.t_full_desc
    , i_status              in com_api_type_pkg.t_dict_value
    , i_product_number      in com_api_type_pkg.t_name          default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_product: ';
    l_count                    com_api_type_pkg.t_count := 0;
    l_inst_id                  com_api_type_pkg.t_inst_id;

begin
    begin
        select 1
          into l_count
          from com_i18n a
             , prd_product b
             , prd_product c
         where a.table_name  = 'PRD_PRODUCT'
           and a.column_name = 'LABEL'
           and a.text        = i_label
           and b.inst_id     = c.inst_id
           and b.id         != i_id
           and c.id          = i_id
           and b.id          = a.object_id;

        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_DESCRIPTION'
          , i_env_param1  => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_env_param2  => 'LABEL'
          , i_env_param3  => i_label
        );
    exception
        when no_data_found then
            null;
    end;

    select inst_id
      into l_inst_id
      from prd_product p
     where p.id= i_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update
        prd_product_vw v
    set
        v.seqnum = io_seqnum
      , v.status = i_status
      , v.product_number = coalesce(i_product_number, v.product_number)
    where
        v.id = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_product'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_product'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'id[#1], i_label[#2], i_status[#3], i_product_number[#4]'
      , i_env_param1  => i_id
      , i_env_param2  => i_label
      , i_env_param3  => i_status
      , i_env_param4  => i_product_number
    );

    for r in (
        select p.parent_id
          from prd_product p
         where p.id = i_id
           and p.parent_id is not null
    ) loop
        synch_product_service( r.parent_id );
    end loop;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_PRODUCT_NUMBER'
          , i_env_param1 => i_product_number
        );
    when others then
        trc_log_pkg.error(
            i_text        => LOG_PREFIX || 'id[#2], i_label[#3], i_status[#4], i_product_number[#5]; sqlerrm[#1]'
          , i_env_param1  => substr(sqlerrm, 1, 2000)
          , i_env_param2  => i_id
          , i_env_param3  => i_label
          , i_env_param4  => i_status
          , i_env_param5  => i_product_number
        );
        raise;
end modify_product;

procedure check_use_attributes(
    i_id                    in com_api_type_pkg.t_short_id
)is
   l_count      pls_integer := 0;
   l_text       com_api_type_pkg.t_full_desc; 
begin
    for r in (   
        select a.id
             , to_number(v.attr_value, com_api_const_pkg.NUMBER_FORMAT) attr_id
             , v.attr_value
             , a.entity_type
             , a.attr_name
          from prd_attribute_value v
             , prd_attribute a
         where v.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and v.object_id   = i_id
           and v.attr_id     = a.id
           and a.entity_type in (fcl_api_const_pkg.ENTITY_TYPE_FEE, fcl_api_const_pkg.ENTITY_TYPE_CYCLE, fcl_api_const_pkg.ENTITY_TYPE_LIMIT)
    ) loop
    
        select count(1)
          into l_count
          from prd_attribute_value v
         where v.attr_id = r.id
           and v.attr_value = r.attr_value
           and (v.object_id, v.entity_type) not in ((i_id, prd_api_const_pkg.ENTITY_TYPE_PRODUCT));           
        
        if l_count = 0 then
            case r.entity_type
            when fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
            
                delete from fcl_cycle_shift where cycle_id = r.attr_id;
                delete from fcl_cycle where id = r.attr_id;
                
            when fcl_api_const_pkg.ENTITY_TYPE_FEE then
            
                delete from fcl_fee_tier where fee_id = r.attr_id;
                delete from fcl_fee where id = r.attr_id;
                
            when fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
                
                delete from fcl_limit where id = r.attr_id;
                
            end case;
        
        else 
            l_text := l_text || get_article_text(r.entity_type) || ' with id ' || r.attr_id || ', ';               
        end if;              
                
    end loop;
    
    if l_text is not null then
    
        trc_log_pkg.warn (
            i_text          => 'ATTR_IS_USED_ON_PROD_OR_OBJECT'
            , i_env_param1  => i_id
            , i_env_param2  => substr(l_text, 1, length(l_text) - 2)
        );
        
    end if;              
end check_use_attributes;

procedure remove_product (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.remove_product: ';
    l_count                    com_api_type_pkg.t_count   := 0;
    l_inst_id                  com_api_type_pkg.t_inst_id := 0;
begin
    select inst_id
      into l_inst_id
      from prd_product p
     where p.id = i_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update prd_product_vw
       set seqnum = i_seqnum
     where id = i_id;

    select count(id)
      into l_count
      from prd_contract_vw
     where product_id = i_id;
    
    select count(id) + l_count
      into l_count
      from prd_product_vw
     where id != i_id
     connect by prior id = parent_id
     start with id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'PRODUCT_IS_ALREADY_IN_USE'
            , i_env_param1  => i_id
        );
    end if;

    check_use_attributes(
        i_id  => i_id
    );
    
    --cards
    for r in (
        select id
             , seqnum
          from iss_product_card_type_vw 
         where product_id = i_id    
    ) loop
        iss_ui_product_card_type_pkg.remove_product_card_type (
            i_id         => r.id
            , i_seqnum   => r.seqnum
        );
    end loop;
    
    --accounts
    for r in (
        select id
          from acc_product_account_type_vw 
         where product_id = i_id    
    ) loop
        acc_ui_product_account_pkg.remove_product_account_type (
            i_id        => r.id
        );     
    end loop;    

    -- schemes
    for r in (
        select id
             , seqnum
          from aup_scheme_object_vw 
         where object_id    = i_id
           and entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT   
    ) loop
        aup_ui_scheme_pkg.remove_scheme_object(
            i_scheme_object_id  => r.id
          , i_seqnum            => r.seqnum
        );    
    end loop;    
    
    -- notes
    delete 
      from ntb_note
     where entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
       and object_id   = i_id;     
    
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'prd_product'
        , i_object_id  => i_id
    );

    delete from prd_attribute_value_vw
     where entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
       and object_id   = i_id;

    delete from prd_product_service_vw
     where product_id = i_id;

    delete from prd_product_vw
     where id = i_id;

    trc_log_pkg.debug (
        i_text          => LOG_PREFIX || 'remove_product i_id[#1]'
        , i_env_param1  => i_id
    );
end remove_product;

procedure add_product_service (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_parent_id           in com_api_type_pkg.t_short_id
    , i_service_id          in com_api_type_pkg.t_short_id
    , i_product_id          in com_api_type_pkg.t_short_id
    , i_min_count           in com_api_type_pkg.t_tiny_id
    , i_max_count           in com_api_type_pkg.t_tiny_id
    , i_conditional_group   in com_api_type_pkg.t_dict_value default null
) is
    l_sv_product_type           com_api_type_pkg.t_dict_value;
    l_product_type              com_api_type_pkg.t_dict_value;
    l_params                    com_api_type_pkg.t_param_tab;
    l_date                      date default get_sysdate;
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text => 'add_product_service: start i_product_id=' || i_product_id || ' i_service_id=' || i_service_id
    );

    -- get service product_type
    select t.product_type
         , s.inst_id
      into l_sv_product_type
         , l_inst_id
      from prd_service_vw s
         , prd_service_type_vw t
     where s.service_type_id = t.id
       and s.id              = i_service_id;

    -- get product_type of product
    select p.product_type
      into l_product_type
      from prd_product_vw p
     where p.id = i_product_id;

    if l_product_type <> l_sv_product_type then
        com_api_error_pkg.raise_error (
            i_error         => 'DIFFERENT_PRODUCT_TYPE_FOR_SERVICE_AND_PRODUCT'
            , i_env_param1  => i_product_id
            , i_env_param2  => l_product_type
            , i_env_param3  => i_service_id
            , i_env_param4  => l_sv_product_type
        );
    end if;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    o_id := prd_product_service_seq.nextval;
    o_seqnum := 1;

    begin
        insert into prd_product_service_vw (
            id
          , seqnum
          , parent_id
          , service_id
          , product_id
          , min_count
          , max_count
          , conditional_group
        )
        values (
            o_id
          , o_seqnum
          , i_parent_id
          , i_service_id
          , i_product_id
          , i_min_count
          , i_max_count
          , i_conditional_group
        );
        rul_api_param_pkg.set_param(
            i_name          => 'SERVICE_ID'
          , i_value         => i_service_id
          , io_params       => l_params
        );
        evt_api_event_pkg.register_event(
            i_event_type        => prd_api_const_pkg.EVENT_ADD_SERVICE
          , i_eff_date          => l_date
          , i_param_tab         => l_params
          , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_object_id         => i_product_id
          , i_inst_id           => l_inst_id
          , i_split_hash        => null
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_PRODUCT_SERVICE'
                , i_env_param1  => i_service_id
                , i_env_param2  => i_product_id
            );
    end;

    synch_product_service (
        i_product_id  => i_product_id
      , i_params      => l_params
    );

    trc_log_pkg.debug(
        i_text => 'add_product_service: end'
    );
end add_product_service;

procedure modify_product_service (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_product_id          in com_api_type_pkg.t_short_id
    , i_min_count           in com_api_type_pkg.t_tiny_id
    , i_max_count           in com_api_type_pkg.t_tiny_id
    , i_conditional_group   in com_api_type_pkg.t_dict_value default null
) is
    l_inst_id                  com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_inst_id
      from prd_product p
     where p.id = i_product_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update prd_product_service_vw
       set seqnum            = io_seqnum
         , min_count         = nvl(i_min_count, min_count)
         , max_count         = nvl(i_max_count, max_count)
         , conditional_group = i_conditional_group
     where id = i_id;

    synch_product_service (
        i_product_id  => i_product_id
    );

    io_seqnum := io_seqnum + 1;
end modify_product_service;

procedure remove_product_service (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
    , i_product_id          in com_api_type_pkg.t_short_id
) is
    l_inst_id  com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_inst_id
      from prd_product p
     where p.id = i_product_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update prd_product_service_vw
       set seqnum = decode(id, i_id, i_seqnum, seqnum)
         , min_count = 0
         , max_count = 0
     where id in (
               select id
                 from prd_product_service_vw
                 connect by prior id = parent_id
                 start with id = i_id
           );

    synch_product_service (
        i_product_id  => i_product_id
    );

end remove_product_service;

function get_product_name (
    i_product_id  in     com_api_type_pkg.t_short_id
) return     com_api_type_pkg.t_name is
    l_result com_api_type_pkg.t_name;
begin
    select min(label)
      into l_result
      from prd_ui_product_vw
     where id   = i_product_id
       and lang = com_ui_user_env_pkg.get_user_lang;

    return l_result;
end get_product_name;

procedure compare_products(
    i_product_id1    in     com_api_type_pkg.t_short_id
    , i_product_id2  in     com_api_type_pkg.t_short_id
    , o_ref_cursor   out    sys_refcursor
)is
    l_lang              com_api_type_pkg.t_dict_value;

begin
    l_lang := get_user_lang;

    open o_ref_cursor for
        with p1 as(
          select s.id service_id
               , com_api_i18n_pkg.get_text('prd_service','label', s.id, l_lang) service_name
               , a.id attr_id
               , com_api_i18n_pkg.get_text('prd_attribute','label', a.id, l_lang) attr_name
               , a.parent_id parent_id
               , av.mod_id mod_id
               , com_api_i18n_pkg.get_text('rul_mod','name', av.mod_id, l_lang) mod_name
               , av.start_date start_date
               , av.end_date end_date
               , av.attr_value attr_value
               , a.display_order
               , av.object_id
            from prd_product p
               , prd_product_service ps
               , prd_service s
               , prd_attribute a
               , prd_attribute_value av
           where p.id = i_product_id1
             and ps.product_id = p.id
             and s.id = ps.service_id
             and a.service_type_id = s.service_type_id
             and av.attr_id = a.id
             and av.service_id = s.id
             and av.object_id = p.id
             and av.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             and av.start_date = (select max(start_date) from
                                    prd_attribute_value
                                  where attr_id = av.attr_id
                                    and object_id = p.id
                                    and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT)
            order by s.id
                   , a.display_order
        )
        , p2 as(
           select s.id service_id
               , com_api_i18n_pkg.get_text('prd_service','label', s.id, l_lang) service_name
               , a.id attr_id
               , com_api_i18n_pkg.get_text('prd_attribute','label', a.id, l_lang) attr_name
               , a.parent_id parent_id
               , av.mod_id mod_id
               , com_api_i18n_pkg.get_text('rul_mod','name', av.mod_id, l_lang) mod_name
               , av.start_date start_date
               , av.end_date end_date
               , av.attr_value attr_value
               , a.display_order
               , av.object_id
            from prd_product p
               , prd_product_service ps
               , prd_service s
               , prd_attribute a
               , prd_attribute_value av
           where p.id = i_product_id2
             and ps.product_id = p.id
             and s.id = ps.service_id
             and a.service_type_id = s.service_type_id
             and av.attr_id = a.id
             and av.service_id = s.id
             and av.object_id = p.id
             and av.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             and av.start_date = (select max(start_date) from
                                    prd_attribute_value
                                  where attr_id = av.attr_id
                                    and object_id = p.id
                                    and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT)

            order by s.id
                   , a.display_order
        )
        select *
         from p1
            , p2
        where p1.service_id = p2.service_id
          and p1.attr_id    = p2.attr_id
          and (nvl(p1.mod_id, 0) != nvl(p2.mod_id, 0)
          or p1.start_date     != p2.start_date
          or p1.attr_value     != p2.attr_value)
        order by p1.attr_id;

end compare_products;

end prd_ui_product_pkg;
/
