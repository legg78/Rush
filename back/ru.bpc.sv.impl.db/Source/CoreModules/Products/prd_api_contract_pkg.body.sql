create or replace package body prd_api_contract_pkg is
/*********************************************************
*  API for contracts <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 15.11.2010 <br />
*  Last changed by $Author: truschelev $ <br />
*  $LastChangedDate: 2015-09-21 17:16:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 8079 $ <br />
*  Module: PRD_API_CONTRACT_PKG <br />
*  @headcom
**********************************************************/
procedure add_contract (
    o_id                     out com_api_type_pkg.t_medium_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_product_id          in     com_api_type_pkg.t_short_id
  , i_start_date          in     date
  , i_end_date            in     date
  , io_contract_number    in out com_api_type_pkg.t_name
  , i_contract_type       in     com_api_type_pkg.t_dict_value
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_label               in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_full_desc
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_param                 com_api_type_pkg.t_param_tab;
    l_prd_contract_type     com_api_type_pkg.t_dict_value;
    l_start_date            date;
begin
    l_start_date := nvl(i_start_date, get_sysdate);
 
    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );
    o_id := prd_contract_seq.nextval;

    o_seqnum := 1;
    l_split_hash := com_api_hash_pkg.get_split_hash (
        i_entity_type   =>  com_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     =>  i_customer_id
    );

    if io_contract_number is null then
        l_param('CONTRACT_ID') := o_id;

        io_contract_number :=
            rul_api_name_pkg.get_name(
                i_inst_id     => i_inst_id
              , i_entity_type => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
              , i_param_tab   => l_param
            );
         trc_log_pkg.debug('Generate new contract number =' || io_contract_number );
    end if;

    if i_product_id is not null and i_contract_type is not null then
        begin
            select contract_type
              into l_prd_contract_type
              from prd_product
             where id = i_product_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'PRODUCT_NOT_FOUND'
                  , i_env_param2 => i_product_id
                );
        end;

        if l_prd_contract_type != i_contract_type then
            com_api_error_pkg.raise_error(
                i_error      => 'WRONG_CONTRACT_TYPE'
              , i_env_param1 => i_contract_type
              , i_env_param2 => i_product_id
              , i_env_param3 => l_prd_contract_type
            );
        end if;
    end if;

    io_contract_number := upper(io_contract_number);

    insert into prd_contract_vw (
        id
      , seqnum
      , product_id
      , start_date
      , end_date
      , contract_number
      , contract_type
      , inst_id
      , agent_id
      , customer_id
      , split_hash
    ) values (
        o_id
      , o_seqnum
      , i_product_id
      , l_start_date
      , i_end_date
      , io_contract_number
      , i_contract_type
      , i_inst_id
      , i_agent_id
      , i_customer_id
      , l_split_hash
    );

    update prd_customer vw
       set contract_id = o_id
     where id          = i_customer_id
       and contract_id is null;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_contract'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_contract'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'CONTRACT_ALREADY_EXISTS'
          , i_env_param1 => o_id
          , i_env_param2 => i_inst_id
          , i_env_param3 => io_contract_number
        );
end;

procedure modify_contract (
    i_id                  in     com_api_type_pkg.t_medium_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_product_id          in     com_api_type_pkg.t_short_id
  , i_end_date            in     date
  , i_contract_number     in     com_api_type_pkg.t_name       default null
  , i_agent_id            in     com_api_type_pkg.t_agent_id   default null
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_label               in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_full_desc
) is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_contract: ';
    l_old                 prd_api_type_pkg.t_contract;
    l_contract_type       com_api_type_pkg.t_dict_value;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_accounts_tab        acc_api_type_pkg.t_account_tab;
    l_count               com_api_type_pkg.t_tiny_id;
begin
    select id
         , seqnum
         , product_id
         , start_date
         , end_date
         , contract_number
         , inst_id
         , agent_id
         , customer_id
         , split_hash
         , contract_type
      into l_old.id
         , l_old.seqnum
         , l_old.product_id
         , l_old.start_date
         , l_old.end_date
         , l_old.contract_number
         , l_old.inst_id
         , l_old.agent_id
         , l_old.customer_id
         , l_old.split_hash
         , l_old.contract_type
      from prd_contract_vw
     where id = i_id;
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_old.inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    if i_end_date is not null and (i_end_date < get_sysdate or l_old.start_date > i_end_date) then
        com_api_error_pkg.raise_error(
            i_error => 'CANNOT_UPDATE_CONTRACT'
        );
    end if;

    if i_product_id is not null and l_old.product_id != i_product_id then
        begin
            select contract_type
                 , inst_id
              into l_contract_type
                 , l_inst_id
              from prd_product
             where id = i_product_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'PRODUCT_NOT_FOUND'
                  , i_env_param2 => i_product_id
                );
        end;

        if l_contract_type != l_old.contract_type or l_inst_id != l_old.inst_id then
            --check service on new product
            for rec in (
                select distinct o.service_id 
                  from prd_service_object o 
                     , prd_service s  
                 where o.contract_id = l_old.id
                   and o.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
                   and (o.end_date is null or o.end_date >= sysdate)  
                   and s.id = o.service_id 
                   and s.status = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
            )loop
                select count(1)
                  into l_count 
                  from prd_product_service ps
                     , prd_service s  
                 where product_id = i_product_id
                   and s.id = ps.service_id  
                   and s.status = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
                   and s.id = rec.service_id;
                
                if l_count = 0 then
                    com_api_error_pkg.raise_error(
                        i_error      => 'SERVICE_NOT_FOUND_ON_PRODUCT'
                      , i_env_param1 => rec.service_id
                      , i_env_param2 => i_product_id
                    );                   
                end if;                                   
            end loop;
        end if;
        
        trc_log_pkg.info(
            i_text          => 'Product of contract [#1] changed from [#2] to [#3]'
          , i_env_param1    => nvl(i_contract_number, l_old.contract_number)
          , i_env_param2    => l_old.product_id
          , i_env_param3    => i_product_id
          , i_object_id     => i_id
          , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
        );
    end if;

    update prd_contract_vw
       set seqnum          = io_seqnum
         , product_id      = nvl(i_product_id, product_id)
         , end_date        = nvl(i_end_date, end_date)
         , contract_number = nvl(upper(i_contract_number), contract_number)
         , agent_id        = nvl(i_agent_id, agent_id)
         , contract_type   = nvl(l_contract_type, contract_type) 
    where  id              = i_id;

    io_seqnum := io_seqnum + 1;

    if i_product_id is not null and l_old.product_id != i_product_id then
        insert into prd_contract_history(
            contract_id
          , product_id
          , start_date
          , end_date
          , split_hash
        ) select l_old.id
               , l_old.product_id
               , nvl(max(end_date) + com_api_const_pkg.ONE_SECOND, l_old.start_date) start_date
               , com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_old.inst_id)
               , l_old.split_hash
            from prd_contract_history
           where contract_id = l_old.id;

        evt_api_event_pkg.register_event(
            i_event_type        => prd_api_const_pkg.EVENT_PRODUCT_CHANGE
          , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_old.inst_id)
          , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
          , i_object_id         => l_old.id
          , i_inst_id           => l_old.inst_id
          , i_split_hash        => l_old.split_hash
        );
    end if;

    -- Changing agent for all contract's child entities
    if i_agent_id is not null and i_agent_id != l_old.agent_id then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'changing agent_id [#1] for contract [#2] to new value [#3]'
          , i_env_param1 => l_old.agent_id
          , i_env_param2 => i_id
          , i_env_param3 => i_agent_id
        );

        -- Processing accounts
        l_accounts_tab.delete;
        l_accounts_tab := acc_api_account_pkg.get_accounts(
                              i_contract_id => i_id
                            , i_inst_id     => l_old.inst_id
                            , i_split_hash  => l_old.split_hash
                          );
        for i in 1..l_accounts_tab.count loop
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'l_accounts_tab(#1) = {account_id [#2], split_hash [#3]}'
              , i_env_param1 => i
              , i_env_param2 => l_accounts_tab(i).account_id
              , i_env_param3 => l_accounts_tab(i).split_hash
            );

            acc_api_account_pkg.modify_account(
                i_account_id   => l_accounts_tab(i).account_id
              , i_split_hash   => l_accounts_tab(i).split_hash
              , i_new_agent_id => i_agent_id
            );
        end loop;

        -- Processing all active card's instances for the contract
        iss_api_card_instance_pkg.change_agent(
            i_contract_id  => i_id
          , i_split_hash   => l_old.split_hash
          , i_new_agent_id => i_agent_id
        );
    end if;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prd_contract'
        , i_column_name  => 'label'
        , i_object_id    => i_id
        , i_lang         => i_lang
        , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prd_contract'
        , i_column_name  => 'description'
        , i_object_id    => i_id
        , i_lang         => i_lang
        , i_text         => i_description
    );
end;

procedure remove_contract (
    i_id      in      com_api_type_pkg.t_medium_id
  , i_seqnum  in      com_api_type_pkg.t_seqnum
) is
    l_count           com_api_type_pkg.t_tiny_id;
    l_inst_id         com_api_type_pkg.t_inst_id;
begin
    select count(id)
      into l_count
      from prd_service_object_vw
     where contract_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'CUSTOMER_CONTRACTS_IS_ALREADY_USED'
          , i_env_param1  => i_id
        );
    end if;
    
    select c.inst_id
      into l_inst_id
      from prd_contract_vw c
     where c.id = i_id;
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );
    
    com_api_i18n_pkg.remove_text (
        i_table_name  => 'prd_contract'
      , i_object_id   => i_id
    );

    update prd_contract_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from prd_contract_vw
     where id     = i_id;
end;

function get_contract_number(
    i_contract_id           in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name is
begin
    for rec in (
        select a.contract_number
          from prd_contract_vw a
         where a.id = i_contract_id
    ) loop
        return rec.contract_number;
    end loop;

    return to_char(null);
end;

/*
 * Function return contract record by i_contract_id or i_contract_number with i_inst_id (to guarantee uniqueness).
 * @param i_contract_id     for searching by primary key
 * @param i_contract_number for searching by number, it must be used together with i_inst_id parameter
 */
function get_contract(
    i_contract_id           in     com_api_type_pkg.t_medium_id
  , i_contract_number       in     com_api_type_pkg.t_name       default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_raise_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) return prd_api_type_pkg.t_contract
is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_contract: ';
    l_contract              prd_api_type_pkg.t_contract;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_contract_id [' || i_contract_id
                             || '], i_contract_number [' || i_contract_number
                             || '], i_inst_id [' || i_inst_id || ']'
    );

    begin
        if i_contract_id is not null then
            select c.id
                 , c.seqnum
                 , c.product_id
                 , c.start_date
                 , c.end_date
                 , c.contract_number
                 , c.inst_id
                 , c.agent_id
                 , c.customer_id
                 , c.split_hash
                 , c.contract_type
              into l_contract.id
                 , l_contract.seqnum
                 , l_contract.product_id
                 , l_contract.start_date
                 , l_contract.end_date
                 , l_contract.contract_number
                 , l_contract.inst_id
                 , l_contract.agent_id
                 , l_contract.customer_id
                 , l_contract.split_hash
                 , l_contract.contract_type
              from prd_contract c
             where c.id = i_contract_id;
             
        elsif i_inst_id is not null and i_contract_number is not null then
        
            select c.id
                 , c.seqnum
                 , c.product_id
                 , c.start_date
                 , c.end_date
                 , c.contract_number
                 , c.inst_id
                 , c.agent_id
                 , c.customer_id
                 , c.split_hash
                 , c.contract_type
              into l_contract.id
                 , l_contract.seqnum
                 , l_contract.product_id
                 , l_contract.start_date
                 , l_contract.end_date
                 , l_contract.contract_number
                 , l_contract.inst_id
                 , l_contract.agent_id
                 , l_contract.customer_id
                 , l_contract.split_hash
                 , l_contract.contract_type
              from prd_contract c
             where c.inst_id = i_inst_id and c.contract_number = upper(i_contract_number);
        else
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'not enough data for search'
            );
        end if;
    exception
        when no_data_found then
            if i_raise_error = com_api_type_pkg.TRUE then
                com_api_error_pkg.raise_error(
                    i_error      => 'CONTRACT_NOT_FOUND'
                  , i_env_param1 => nvl(to_char(i_contract_id), i_contract_number)
                  , i_env_param2 => i_inst_id
                );
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'contract not found'
                );
            end if;
    end;

    return l_contract;
end get_contract;

procedure close_objects(
    i_contract_id   in      com_api_type_pkg.t_medium_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
) is
    l_card                 iss_api_type_pkg.t_card_rec;
    l_card_instance_id     com_api_type_pkg.t_medium_id;
    l_params               com_api_type_pkg.t_param_tab;
    l_status               com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug('Closing contract objects: START, contract_id = ' || i_contract_id);

    for rec in (
        select o.service_id
             , o.entity_type
             , o.object_id
             , o.status
             , t.is_initial
          from prd_service_object o
             , prd_service s
             , prd_service_type t
         where o.contract_id = i_contract_id
           and o.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
           and s.id = o.service_id
           and t.id = s.service_type_id
        order by t.is_initial
               , decode(o.entity_type, acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, 1, 0)
    )
    loop
        if rec.is_initial = 0 then
            -- initiating service - just close the service
            app_api_service_pkg.close_service(
                i_entity_type   => rec.entity_type
              , i_object_id     => rec.object_id
              , i_inst_id       => i_inst_id
              , i_forced        => com_api_type_pkg.TRUE
            );
        else
            trc_log_pkg.debug(
                i_text       => 'Closing entity [#1], object_id [#2]'
              , i_env_param1 => rec.entity_type
              , i_env_param2 => rec.object_id
            );

            -- not initiating service - close the service and entity
            if rec.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                -- close service for card
                l_card := iss_api_card_pkg.get_card(
                    i_card_id  => rec.object_id
                );
                trc_log_pkg.debug('Card mask = ' || iss_api_card_pkg.get_card_mask(l_card.card_number));

                rul_api_param_pkg.set_param(
                    i_value    => nvl(l_card.category, iss_api_const_pkg.CARD_CATEGORY_UNDEFINED)
                  , i_name     => 'CARD_CATEGORY'
                  , io_params  => app_api_application_pkg.g_params
                );

                app_api_service_pkg.close_service(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id     => l_card.id
                  , i_inst_id       => i_inst_id
                  , i_forced        => com_api_type_pkg.TRUE
                );

                -- close all active card instances (as usual it is the only one)
                for ci in (
                    select i.id
                      from iss_card_instance i
                     where i.card_id = l_card.id
                       and i.state  != iss_api_const_pkg.CARD_STATE_CLOSED
                ) loop
                    l_card_instance_id := ci.id;
                    trc_log_pkg.debug(
                        i_text       => 'Closing card_instance_id [#1], new state [#2]'
                      , i_env_param1 => l_card_instance_id
                      , i_env_param2 => iss_api_const_pkg.CARD_STATE_CLOSED
                    );
                    -- status
                    evt_api_status_pkg.change_status(
                        i_event_type     => iss_api_const_pkg.EVENT_TYPE_CARD_DEACTIVATION
                      , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                      , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id      => l_card_instance_id
                      , i_reason         => null
                      , i_eff_date       => null
                      , i_params         => l_params
                      , i_register_event => com_api_const_pkg.TRUE
                    );
                    -- state
                    evt_api_status_pkg.change_status(
                        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                      , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id      => l_card_instance_id
                      , i_new_status     => iss_api_const_pkg.CARD_STATE_CLOSED
                      , i_reason         => null
                      , o_status         => l_status
                      , i_eff_date       => null
                      , i_raise_error    => com_api_const_pkg.FALSE
                      , i_register_event => com_api_const_pkg.TRUE
                      , i_params         => l_params
                    );
                    trc_log_pkg.debug(
                        i_text       => 'Returned state: [#1]'
                      , i_env_param1 => l_status
                    );
                end loop;

                -- at least one active card's instance should exists
                if l_card_instance_id is null then
                    app_api_error_pkg.raise_error(
                        i_error         => 'CARD_INSTANCE_NOT_FOUND'
                      , i_env_param1    => l_card.card_number
                      , i_appl_data_id  => null
                      , i_element_name  => 'CARD_NUMBER'
                    );
                end if;

            elsif rec.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                -- close service
                app_api_service_pkg.close_service(
                    i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => rec.object_id
                  , i_inst_id      => i_inst_id
                  , i_forced        => com_api_type_pkg.TRUE
                );

                acc_api_account_pkg.close_account(
                    i_account_id   => rec.object_id
                );

            elsif rec.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                app_api_service_pkg.close_service(
                    i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_object_id     => rec.object_id
                  , i_inst_id       => i_inst_id
                  , i_forced        => com_api_type_pkg.TRUE
                );

                acq_api_merchant_pkg.set_status(
                    i_merchant_id   =>  rec.object_id
                  , i_status        =>  acq_api_const_pkg.MERCHANT_STATUS_CLOSED
                );

            elsif rec.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                app_api_service_pkg.close_service(
                    i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                  , i_object_id     => rec.object_id
                  , i_inst_id       => i_inst_id
                  , i_forced        => com_api_type_pkg.TRUE
                );

                acq_api_terminal_pkg.set_status(
                    i_terminal_id  => rec.object_id
                  , i_status       => acq_api_const_pkg.TERMINAL_STATUS_CLOSED
                );

            else
                trc_log_pkg.debug('No actions are required for this entity type');
            end if;

            trc_log_pkg.debug('Entity object [' || rec.object_id || '] is closed');
        end if;
    end loop;

    trc_log_pkg.debug('Closing contract objects: END');
end close_objects;

/*
 * Procedure closes contract and all linked entities and services.
 */
procedure close_contract(
    i_contract_id   in      com_api_type_pkg.t_medium_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_end_date      in      date
  , i_params        in      com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.close_contract: i_contract_id [#1], i_inst_id [#2], i_end_date [#3]'
      , i_env_param1 => i_contract_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_end_date
    );

    close_objects(
        i_contract_id => i_contract_id
      , i_inst_id     => i_inst_id
    );

    -- Close service
    prd_api_service_pkg.close_service(
        i_entity_type => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_id   => i_contract_id
      , i_inst_id     => i_inst_id
      , i_params      => i_params
    );

    update prd_contract
       set end_date = coalesce(i_end_date, com_api_sttl_day_pkg.get_sysdate())
     where id = i_contract_id;
end close_contract;

end;
/
