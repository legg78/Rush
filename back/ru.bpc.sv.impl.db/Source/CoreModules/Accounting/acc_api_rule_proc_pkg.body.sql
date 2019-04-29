create or replace package body acc_api_rule_proc_pkg as

procedure attach_account
is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.attach_account: ';
    l_party_type        com_api_type_pkg.t_dict_value := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_contract_id       com_api_type_pkg.t_medium_id;
    l_account_id        com_api_type_pkg.t_account_id;
    l_account_exists    com_api_type_pkg.t_boolean;
    l_forced_processing com_api_type_pkg.t_boolean;
    l_account_tab       acc_api_type_pkg.t_account_tab;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_account_object_id com_api_type_pkg.t_long_id;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_account_rec       acc_api_type_pkg.t_account_rec;
begin
    l_card_id       := opr_api_shared_data_pkg.get_participant(l_party_type).card_id;
    l_inst_id       := opr_api_shared_data_pkg.get_participant(l_party_type).inst_id;
    l_split_hash    := opr_api_shared_data_pkg.get_participant(l_party_type).split_hash;
    l_account_id    := opr_api_shared_data_pkg.get_participant(l_party_type).account_id;
    l_contract_id   := opr_api_shared_data_pkg.get_participant(l_party_type).contract_id;
    l_customer_id   := opr_api_shared_data_pkg.get_participant(l_party_type).customer_id;

    l_forced_processing :=
        opr_api_shared_data_pkg.get_param_num(
            i_name          => 'FORCED_PROCESSING'
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => com_api_const_pkg.FALSE
        );

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'l_card_id [#1], l_inst_id [#2], l_split_hash [#3], l_account_id [#4], l_contract_id [#5], l_forced_processing[#6]'
      , i_env_param1    => l_card_id
      , i_env_param2    => l_inst_id
      , i_env_param3    => l_split_hash
      , i_env_param4    => l_account_id
      , i_env_param5    => l_contract_id
      , i_env_param6    => l_forced_processing
    );

    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_account_id        => l_account_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    if l_account_rec.customer_id <> l_customer_id then
        com_api_error_pkg.raise_error(
            i_error             => 'CARD_OR_ACCOUNT_DOES_NOT_BELONG_TO_CUSTOMER'
          , i_env_param1        => l_card_id
          , i_env_param2        => l_account_id
          , i_env_param3        => l_customer_id
        );
    end if;

    l_account_exists :=
        acc_api_account_pkg.account_object_exists(
            i_account_id    => l_account_id
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
        );

    if      l_account_exists = com_api_const_pkg.TRUE
        and l_forced_processing = com_api_const_pkg.TRUE
    then
        acc_api_selection_pkg.get_accounts(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , o_accounts      => l_account_tab
        );

        if l_account_tab.count > 0 then
            for i in 1 .. l_account_tab.count loop
                null;
                acc_api_account_pkg.set_object_default_account(
                    i_object_id         => l_card_id
                  , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_account_id        => l_account_tab(i).account_id
                  , i_is_pos_default    => com_api_const_pkg.TRUE
                  , i_is_atm_default    => com_api_const_pkg.TRUE
                );
            end loop;
        end if;
    else
        acc_api_account_pkg.add_account_object(
            i_account_id        => l_account_id
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => l_card_id
          , i_is_pos_default    => com_api_const_pkg.TRUE
          , i_is_atm_default    => com_api_const_pkg.TRUE
          , o_account_object_id => l_account_object_id
        );

        acc_api_account_pkg.set_object_default_account(
            i_object_id         => l_card_id
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_account_id        => l_account_id
          , i_is_pos_default    => com_api_const_pkg.TRUE
          , i_is_atm_default    => com_api_const_pkg.TRUE
        );
    end if;

end attach_account;

procedure activate_pool_account
is
    l_account_name       com_api_type_pkg.t_name;
    l_party_type         com_api_type_pkg.t_name;

    l_card_id            com_api_type_pkg.t_long_id;
    l_card               iss_api_type_pkg.t_card_rec;
    l_account            acc_api_type_pkg.t_account_rec;
    l_params             com_api_type_pkg.t_param_tab;
    l_account_object_id  com_api_type_pkg.t_long_id;

begin
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_party_type   := nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_card_id      := opr_api_shared_data_pkg.get_object_id(
                          i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                        , i_account_name  => l_account_name
                        , i_party_type    => l_party_type
                      );

    if l_card_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'CARD_NOT_FOUND'
          , i_env_param1  => 'account_name [' || l_account_name || '] party type [' || l_party_type || ']'
        );
    end if;

    l_card := iss_api_card_pkg.get_card(i_card_id => l_card_id);

    l_account.account_id     := opr_api_shared_data_pkg.get_participant(l_party_type).account_id;
    l_account.account_number := opr_api_shared_data_pkg.get_participant(l_party_type).account_number;
    l_account.inst_id        := opr_api_shared_data_pkg.get_participant(l_party_type).inst_id;

    trc_log_pkg.debug(
        i_text         => 'Going to find account [#1][#2][#3]'
      , i_env_param1   => l_account.account_id
      , i_env_param2   => l_account.account_number
      , i_env_param3   => l_account.inst_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    begin
        if l_account.account_id is not null then
            select a.id
                 , a.account_number
                 , a.currency
                 , a.inst_id
                 , a.account_type
                 , a.contract_id
                 , a.customer_id
                 , a.status
                 , a.split_hash
              into l_account.account_id
                 , l_account.account_number
                 , l_account.currency
                 , l_account.inst_id
                 , l_account.account_type
                 , l_account.contract_id
                 , l_account.customer_id
                 , l_account.status
                 , l_account.split_hash
              from acc_account a
             where a.id = l_account.account_id;
        else
            select a.id
                 , a.currency
                 , a.account_type
                 , a.contract_id
                 , a.customer_id
                 , a.status
                 , a.split_hash
              into l_account.account_id
                 , l_account.currency
                 , l_account.account_type
                 , l_account.contract_id
                 , l_account.customer_id
                 , l_account.status
                 , l_account.split_hash
              from acc_account a
             where a.account_number = l_account.account_number
               and a.inst_id        = l_account.inst_id;
        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_NOT_FOUND'
            );
    end;

    trc_log_pkg.debug(
        i_text         => 'Going to reconnect account [#1][#2][#3]'
      , i_env_param1   => l_account.account_id
      , i_env_param2   => l_card.customer_id
      , i_env_param3   => l_card.contract_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    acc_api_account_pkg.reconnect_account(
        i_account_id    => l_account.account_id
      , i_customer_id   => l_card.customer_id
      , i_contract_id   => l_card.contract_id
    );

    trc_log_pkg.debug(
        i_text         => 'Going to change status of account [#1]'
      , i_env_param1   => l_account.account_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    l_account.status := acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE;
    evt_api_status_pkg.change_status(
        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id      => l_account.account_id
      , i_new_status     => l_account.status
      , i_reason         => null
      , o_status         => l_account.status
      , i_eff_date       => null
      , i_raise_error    => com_api_const_pkg.TRUE
      , i_register_event => com_api_const_pkg.TRUE
      , i_params         => l_params
    );

    trc_log_pkg.debug(
        i_text         => 'Going to add account object [#1][#2]'
      , i_env_param1   => l_account.account_id
      , i_env_param2   => l_card_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    acc_api_account_pkg.add_account_object(
        i_account_id         => l_account.account_id
      , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id          => l_card_id
      , o_account_object_id  => l_account_object_id
    );

    prd_api_service_pkg.update_service_object(
        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => l_account.account_id
      , i_split_hash  => l_card.split_hash
      , i_contract_id => l_card.contract_id
    );

    trc_log_pkg.debug(
        i_text         => 'Going to set account [#1]'
      , i_env_param1   => l_account.account_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    opr_api_shared_data_pkg.set_account(
        i_name          => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec   => l_account
    );

exception
    when others then
        opr_api_shared_data_pkg.rollback_process(
            i_id       => opr_api_shared_data_pkg.get_operation().id
          , i_status   => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason   => aup_api_const_pkg.RESP_CODE_ERROR
        );
end activate_pool_account;

procedure return_pool_account
is
    l_account_name       com_api_type_pkg.t_name;
    l_party_type         com_api_type_pkg.t_name;

    l_card_id            com_api_type_pkg.t_long_id;
    l_account            acc_api_type_pkg.t_account_rec;
    l_params             com_api_type_pkg.t_param_tab;
    l_balance_amount     com_api_type_pkg.t_money;
    l_account_object_id  com_api_type_pkg.t_long_id;

begin
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_party_type   := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');

    l_party_type   := nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_card_id      := opr_api_shared_data_pkg.get_object_id(
                          i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                        , i_account_name  => l_account_name
                        , i_party_type    => l_party_type
                      );

    if l_card_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'CARD_NOT_FOUND'
          , i_env_param1  => 'account_name [' || l_account_name || '] party type [' || l_party_type || ']'
        );
    end if;

    l_account.account_number := opr_api_shared_data_pkg.get_participant(l_party_type).account_number;
    l_account.account_id     := acc_api_account_pkg.get_account_id(i_account_number => l_account.account_number);

    trc_log_pkg.debug(
        i_text         => 'Going to check balance of account [#1] [#2]'
      , i_env_param1   => l_account.account_id
      ,i_env_param2    => l_account.account_number
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    l_balance_amount         := acc_api_balance_pkg.get_aval_balance_amount_only(l_account.account_id);
    if l_balance_amount <> 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'ACC_ACCOUNT_HAS_NONEMPTY_BALANCE'
          , i_env_param1  => l_account.account_id
        );
    end if;

    trc_log_pkg.debug(
        i_text         => 'Going to check the very first pool application of account [#1]'
      , i_env_param1   => l_account.account_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    for r in (select j.entity_type, j.object_id
                from app_object  j
               where j.appl_id = (select min(o.appl_id)
                                    from app_object   o
                                       , prd_contract c
                                   where o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                     and o.object_id   = l_account.account_id)
                 and j.entity_type in (prd_api_const_pkg.ENTITY_TYPE_CUSTOMER, prd_api_const_pkg.ENTITY_TYPE_CONTRACT))
    loop
        case r.entity_type
            when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                begin
                    select s.id
                         , s.split_hash
                      into l_account.customer_id
                         , l_account.split_hash
                      from prd_customer s
                         , ost_agent    g
                     where s.id              = r.object_id
                       and s.entity_type     = com_api_const_pkg.ENTITY_TYPE_COMPANY
                       and s.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                       and s.ext_object_id   = g.id;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error       => 'CUSTOMER_NOT_FOUND'
                        );
                end;

            when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
                begin
                    select t.id
                      into l_account.contract_id
                      from prd_contract t
                     where t.id            = r.object_id
                       and t.contract_type = prd_api_const_pkg.CONTRACT_TYPE_ACCOUNT_POOL;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error       => 'CONTRACT_NOT_FOUND'
                        );
                end;

        end case;
    end loop;

    if l_account.customer_id is null or l_account.contract_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'APPLICATION_NOT_FOUND'
        );
    end if;

    trc_log_pkg.debug(
        i_text         => 'Going to reconnect account [#1][#2][#3]'
      , i_env_param1   => l_account.account_id
      , i_env_param2   => l_account.customer_id
      , i_env_param3   => l_account.contract_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    acc_api_account_pkg.reconnect_account(
        i_account_id    => l_account.account_id
      , i_customer_id   => l_account.customer_id
      , i_contract_id   => l_account.contract_id
    );

    trc_log_pkg.debug(
        i_text         => 'Going to change status of account [#1]'
      , i_env_param1   => l_account.account_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    l_account.status := acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE_REQUIRED;
    evt_api_status_pkg.change_status(
        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id      => l_account.account_id
      , i_new_status     => l_account.status
      , i_reason         => null
      , o_status         => l_account.status
      , i_eff_date       => null
      , i_raise_error    => com_api_const_pkg.TRUE
      , i_register_event => com_api_const_pkg.TRUE
      , i_params         => l_params
    );

    begin
        select b.id
          into l_account_object_id
          from acc_account_object  b
         where b.account_id  = l_account.account_id
           and b.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and b.object_id   = l_card_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_IS_NOT_LINKED_WITH_OBJECT'
              , i_env_param1  => l_account.account_id
              , i_env_param2  => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_env_param3  => l_card_id
            );
    end;

    trc_log_pkg.debug(
        i_text         => 'Going to remove account object [#1]'
      , i_env_param1   => l_account_object_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    acc_api_account_pkg.remove_account_object(i_account_object_id  => l_account_object_id);

    prd_api_service_pkg.update_service_object(
        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => l_account.account_id
      , i_split_hash  => l_account.split_hash
      , i_contract_id => l_account.contract_id
    );

    trc_log_pkg.debug(
        i_text         => 'Going to set account [#1]'
      , i_env_param1   => l_account.account_id
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => opr_api_shared_data_pkg.get_operation().id
    );

    opr_api_shared_data_pkg.set_account(
        i_name          => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec   => l_account
    );

exception
    when others then
        opr_api_shared_data_pkg.rollback_process(
            i_id       => opr_api_shared_data_pkg.get_operation().id
          , i_status   => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason   => aup_api_const_pkg.RESP_CODE_ERROR
        );
end return_pool_account;

procedure create_account
is
    LOG_PREFIX             constant com_api_type_pkg.t_name               := lower($$PLSQL_UNIT) || '.create_account: ';
    l_party_type                    com_api_type_pkg.t_name;
    l_participant_rec               opr_api_type_pkg.t_oper_part_rec;
    l_issuer_rec                    opr_api_type_pkg.t_oper_part_rec;
    l_dest_rec                      opr_api_type_pkg.t_oper_part_rec;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_resp_code                     com_api_type_pkg.t_dict_value;
    l_account_type                  com_api_type_pkg.t_dict_value;
    l_account_seq_number            acc_api_type_pkg.t_account_seq_number;
    l_account_currency              com_api_type_pkg.t_dict_value;
    l_account_number                com_api_type_pkg.t_account_number;
    l_account_id                    com_api_type_pkg.t_account_id;
    l_account_object_id             com_api_type_pkg.t_medium_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_card                          iss_api_type_pkg.t_card_rec;
    l_contract                      prd_api_type_pkg.t_contract;
begin
    l_party_type         := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_participant_rec    := opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type);
    l_issuer_rec         := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER);
    l_dest_rec           := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_DEST);
    l_oper_id            := opr_api_shared_data_pkg.g_operation.id;
    l_resp_code          := opr_api_shared_data_pkg.get_param_char('RESP_CODE');

    l_account_type       :=
        aup_api_tag_pkg.get_tag_value(
            i_auth_id       => l_oper_id
          , i_tag_reference => 'ACCOUNT_TYPE'
        );
    l_account_seq_number := 
        to_number(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id       => l_oper_id
              , i_tag_reference => acc_api_const_pkg.TAG_REF_ACCOUNT_SEQ_NUMBER
            )
        );

    trc_log_pkg.debug(
        i_text           => LOG_PREFIX || 'l_party_type [#1], l_oper_id [#2], l_resp_code [#3], l_account_type [#4], l_account_seq_number [#5]'
      , i_env_param1     => l_party_type
      , i_env_param2     => l_oper_id
      , i_env_param3     => l_resp_code
      , i_env_param4     => l_account_type
      , i_env_param5     => l_account_seq_number
    );

    l_account_number     := l_participant_rec.account_number;

    l_account_currency   := nvl(l_dest_rec.account_currency, opr_api_shared_data_pkg.g_operation.oper_currency);    

    acc_api_account_pkg.get_seq_number(
        i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id          => l_issuer_rec.card_id
      , i_account_seq_number => l_account_seq_number
      , i_mask_error         => com_api_const_pkg.FALSE
      , o_account_seq_number => l_account_seq_number
    );

    l_card                   := 
        iss_api_card_pkg.get_card(
            i_card_id        => l_issuer_rec.card_id
          , i_inst_id        => l_issuer_rec.card_inst_id
          , i_mask_error     => com_api_const_pkg.FALSE
        );
    l_contract               := prd_api_contract_pkg.get_contract(i_contract_id => l_card.contract_id);

    trc_log_pkg.debug(
        i_text               => LOG_PREFIX || 'Going to create account: type [#1], currency [#2], inst_id [#3], l_agent_id [#4], l_contract_id [#5], customer_id [#6]'
      , i_env_param1         => l_account_type
      , i_env_param2         => l_account_currency
      , i_env_param3         => l_issuer_rec.inst_id
      , i_env_param4         => l_contract.agent_id
      , i_env_param5         => l_contract.id
      , i_env_param6         => l_contract.customer_id
      , i_entity_type        => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id          => opr_api_shared_data_pkg.get_operation().id
    );

    acc_api_account_pkg.create_account(
        o_id                 => l_account_id
      , io_split_hash        => l_issuer_rec.split_hash
      , i_account_type       => l_account_type
      , io_account_number    => l_account_number
      , i_currency           => l_account_currency
      , i_inst_id            => l_issuer_rec.inst_id
      , i_agent_id           => l_contract.agent_id
      , i_status             => acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
      , i_contract_id        => l_contract.id
      , i_customer_id        => l_contract.customer_id
      , i_customer_number    => prd_api_customer_pkg.get_customer_number(l_contract.customer_id)
    );

    acc_api_account_pkg.add_account_object(
        i_account_id         => l_account_id
      , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id          => l_issuer_rec.card_id
      , i_account_seq_number => l_account_seq_number
      , o_account_object_id  => l_account_object_id
    );

    l_account := 
        acc_api_account_pkg.get_account(
            i_account_id     => l_account_id
          , i_mask_error     => com_api_const_pkg.FALSE  
        );

    trc_log_pkg.debug(
        i_text               => LOG_PREFIX || 'Going to set shared data with created account [#1][#2][#3][#4]'
      , i_env_param1         => l_account.account_id
      , i_env_param2         => l_account.account_number
      , i_env_param3         => l_account.inst_id
      , i_env_param4         => l_participant_rec.participant_type
      , i_entity_type        => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id          => opr_api_shared_data_pkg.get_operation().id
    );

    trc_log_pkg.debug(
        i_text               => LOG_PREFIX || 'Going to set account [#1]'
      , i_env_param1         => l_account.account_id
      , i_entity_type        => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id          => opr_api_shared_data_pkg.get_operation().id
    );

    opr_api_shared_data_pkg.set_account(
        i_name               => opr_api_shared_data_pkg.get_param_char('RESULT_ACCOUNT_NAME')
      , i_account_rec        => l_account
    );

    update opr_participant
       set account_id        = l_account.account_id
         , account_number    = l_account.account_number
     where oper_id           = l_oper_id
       and participant_type  = l_party_type;

    l_participant_rec.account_number := l_account.account_number;
    l_participant_rec.account_id     := l_account.account_id;
    opr_api_shared_data_pkg.set_participant(l_participant_rec);

    rul_api_shared_data_pkg.load_account_params(
        i_account_id         => l_account.account_id
      , io_params            => opr_api_shared_data_pkg.g_params
      , i_usage              => com_api_const_pkg.FLEXIBLE_FIELD_PROC_OPER
    );
exception
    when com_api_error_pkg.e_application_error then
        opr_api_shared_data_pkg.rollback_process(
            i_id             => opr_api_shared_data_pkg.get_operation().id
          , i_status         => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason         => l_resp_code
        );
end create_account;

procedure calculate_rounding_error
is
    l_account_type                  com_api_type_pkg.t_dict_value;
    l_amount_purpose                com_api_type_pkg.t_dict_value;
    l_result_amount_name            com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_currency                      com_api_type_pkg.t_curr_code;

    l_prev_date                     date;
    l_next_date                     date;
    l_rounding_error                com_api_type_pkg.t_money;

begin
    l_account_type        := evt_api_shared_data_pkg.get_param_char('ACCOUNT_TYPE');
    l_amount_purpose      := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    l_result_amount_name  := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    l_event_type          := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_entity_type         := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id           := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    if l_entity_type <> acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        com_api_error_pkg.raise_error(
            i_error             => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1        => l_entity_type
        );
    end if;

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type   => l_event_type
      , i_entity_type  => l_entity_type
      , i_object_id    => l_object_id
      , i_split_hash   => null
      , i_add_counter  => com_api_type_pkg.FALSE
      , o_prev_date    => l_prev_date
      , o_next_date    => l_next_date
    );

    select round(sum(ae.rounding_error))
         , max(ae.currency)
      into l_rounding_error
         , l_currency
      from acc_entry           ae
         , acc_account         aa
         , acc_account_object  ao
         , acc_macros          am
     where ae.posting_date  >= nvl(l_prev_date, com_api_const_pkg.EPOCH_DATE)
       and ae.posting_date   < l_next_date
       and ae.account_id     = aa.id
       and aa.id             = ao.account_id
       and ao.entity_type    = l_entity_type
       and aa.account_type   = nvl(l_account_type, aa.account_type)
       and ae.macros_id      = am.id
       and am.amount_purpose = nvl(l_amount_purpose, am.amount_purpose);

    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => l_rounding_error
      , i_currency  => l_currency
    );

end calculate_rounding_error;

end acc_api_rule_proc_pkg;
/
