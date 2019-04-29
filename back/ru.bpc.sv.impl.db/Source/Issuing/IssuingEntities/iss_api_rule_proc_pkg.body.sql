create or replace package body iss_api_rule_proc_pkg as

procedure create_virtual_card is
    l_expir_date                date;
    l_limit_type                com_api_type_pkg.t_dict_value;
    l_usage_limit_amount        com_api_type_pkg.t_money;
    l_card_number               com_api_type_pkg.t_card_number;
    l_party_type                com_api_type_pkg.t_dict_value;
    l_account_name              com_api_type_pkg.t_name;
    l_account                   acc_api_type_pkg.t_account_rec;
    l_tag_value                 com_api_type_pkg.t_name;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_virtual_card_id           com_api_type_pkg.t_long_id;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_virt_customer_id          com_api_type_pkg.t_medium_id;
    l_cardholder_id             com_api_type_pkg.t_medium_id;
    l_card                      iss_api_type_pkg.t_card_rec;
    l_card_instance_id          com_api_type_pkg.t_medium_id;
    l_participant_rec           opr_api_type_pkg.t_oper_part_rec;
    l_card_type_id              com_api_type_pkg.t_tiny_id;
    l_commun_address            com_api_type_pkg.t_name;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_status                    com_api_type_pkg.t_dict_value;
    l_card_status               com_api_type_pkg.t_dict_value;
    l_contract_id               com_api_type_pkg.t_medium_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_contact_id                com_api_type_pkg.t_medium_id;
    l_customer_status           com_api_type_pkg.t_dict_value;
begin
    l_limit_type   := 
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'LIMIT_TYPE'
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    l_account_name := 
        opr_api_shared_data_pkg.get_param_char (
            i_name          => 'ACCOUNT_NAME'
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    l_party_type := 
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'PARTY_TYPE'
          , i_mask_error    => com_api_const_pkg.FALSE
        );
        
    l_card_status :=
        opr_api_shared_data_pkg.get_param_char(
            i_name          => 'CARD_STATUS'
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    -- check card data presence on participant
    l_object_id := 
        opr_api_shared_data_pkg.get_object_id (
            i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_account_name    => null
          , i_party_type      => l_party_type
          , o_account_number  => l_account.account_number
        );

    if l_account_name is not null then
        opr_api_shared_data_pkg.get_account (
            i_name              => l_account_name
          , o_account_rec       => l_account
        );
    end if;
    
    -- get parent card
    l_card := 
        iss_api_card_pkg.get_card(
            i_card_id         => l_object_id
          , i_mask_error      => com_api_const_pkg.FALSE
        );
        
    trc_log_pkg.debug(
        i_text       => 'parent_card_id = ' || l_card.id
    );
    
    l_oper_id := opr_api_shared_data_pkg.get_operation().id;
    
    l_tag_value := 
        aup_api_tag_pkg.get_tag_value (
            i_auth_id           => opr_api_shared_data_pkg.get_operation().id
          , i_tag_id            => 5
        );
    
    if l_tag_value is not null then
        l_expir_date := add_months(to_date(l_tag_value, 'YYMM'), 1) - com_api_const_pkg.ONE_SECOND;
    end if;
        
    l_commun_address :=
        aup_api_tag_pkg.get_tag_value(
            i_auth_id           => l_oper_id
          , i_tag_id            => aup_api_const_pkg.TAG_MOBILE_NUMBER
        );
    
    l_tag_value :=
        aup_api_tag_pkg.get_tag_value(
            i_auth_id           => l_oper_id
          , i_tag_id            => aup_api_const_pkg.TAG_CUSTOMER_NUMBER
        );
    
    if l_tag_value is not null then
        l_customer_id :=
            prd_api_customer_pkg.get_customer_id(
                i_customer_number => l_tag_value
              , i_inst_id         => opr_api_shared_data_pkg.get_participant(l_party_type).inst_id
              , i_mask_error      => com_api_const_pkg.FALSE
            );
    else
        l_customer_id := l_card.customer_id;
    end if;
    
    l_tag_value :=
        aup_api_tag_pkg.get_tag_value(
            i_auth_id           => l_oper_id
          , i_tag_id            => aup_api_const_pkg.TAG_CARDHOLDER_ID
        );
    
    if l_tag_value is not null then
        l_cardholder_id :=
            iss_api_cardholder_pkg.get_cardholder(
                i_cardholder_id       => to_number(l_tag_value)
              , i_mask_error          => com_api_type_pkg.FALSE
            ).id;
    else
        l_cardholder_id := l_card.cardholder_id;
    end if;
    
    l_tag_value := 
        aup_api_tag_pkg.get_tag_value (
            i_auth_id           => opr_api_shared_data_pkg.get_operation().id
          , i_tag_id            => 7
        );
    
    if l_tag_value is not null then
        l_usage_limit_amount := to_number(l_tag_value);
    end if;
    
    l_card_number := aup_api_tag_pkg.get_tag_value (
                             i_auth_id           => opr_api_shared_data_pkg.get_operation().id
                           , i_tag_id            => 10
                     );

    begin
        select n.card_id
             , c.customer_id
             , c.card_type_id
          into l_virtual_card_id
             , l_virt_customer_id
             , l_card_type_id
          from iss_card_number n
             , iss_card c
         where reverse(n.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => l_card_number))
           and c.id = n.card_id;
    exception
        when no_data_found then
            null;
    end;
    
    -- issue virtual card
    if l_virtual_card_id is null then
    
        iss_api_virtual_card_pkg.issue_virtual_card (
            i_card_instance_id          => opr_api_shared_data_pkg.get_participant(l_party_type).card_instance_id
          , i_card_type_id              => null
          , i_expir_date                => l_expir_date
          , i_limit_type                => l_limit_type
          , i_usage_limit_count         => null
          , i_usage_limit_amount        => l_usage_limit_amount
          , i_usage_limit_currency      => l_account.currency
          , i_card_number               => l_card_number
          , i_account_id                => l_account.account_id
        );
    elsif l_virtual_card_id = l_object_id and l_virt_customer_id = l_customer_id then
        -- case 2. Update and activate virtual card for customer from pool
        -- get contact data and change status for: Card, Customer, Account from pool
        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id      => l_virt_customer_id
          , i_new_status     => prd_api_const_pkg.CUSTOMER_STATUS_ACTIVE
          , i_inst_id        => l_card.inst_id
          , i_reason         => null
          , o_status         => l_status
          , i_raise_error    => com_api_const_pkg.TRUE
          , i_params         => l_param_tab
        );
        
        l_card_instance_id :=
            iss_api_card_instance_pkg.get_card_instance_id(
                i_card_id        => l_virtual_card_id
            );
        
        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id      => l_card_instance_id
          , i_new_status     => nvl(l_card_status, iss_api_const_pkg.CARD_STATUS_VALID_CARD)
          , i_inst_id        => l_card.inst_id
          , i_reason         => null
          , o_status         => l_status
          , i_raise_error    => com_api_const_pkg.TRUE
          , i_params         => l_param_tab
        );
        
        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => l_account.account_id
          , i_new_status     => acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
          , i_inst_id        => l_account.inst_id
          , i_reason         => null
          , o_status         => l_status
          , i_raise_error    => com_api_const_pkg.TRUE
          , i_params         => l_param_tab
        );
        
        if l_commun_address is not null then
            begin
                select o.contact_id
                  into l_contact_id
                  from com_contact_object o
                 where o.entity_type    = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and o.object_id      = l_customer_id
                   and rownum          <= 1;
            exception
                when no_data_found then
                    l_contact_id       := null;
            end;
                com_api_contact_pkg.modify_contact_data(
                    i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id         => l_customer_id
                  , i_inst_id           => l_card.inst_id
                  , i_contact_id        => l_contact_id
                  , i_commun_method     => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                  , i_commun_address    => l_commun_address
                  , i_start_date        => null
                  , i_end_date          => null
                );
        end if;
    else

        select status
          into l_customer_status
          from prd_customer
         where id = l_virt_customer_id;

        trc_log_pkg.debug(
            i_text       => 'l_virtual_card_id[#1], l_customer_id[#2], l_virt_customer_id[#3], l_customer_status[#4], l_object_id[#5]'
          , i_env_param1 => l_virtual_card_id
          , i_env_param2 => l_customer_id
          , i_env_param3 => l_virt_customer_id
          , i_env_param4 => l_customer_status
          , i_env_param5 => l_object_id
        ); 

        if l_customer_status = prd_api_const_pkg.CUSTOMER_STATUS_ACTIV_REQUIRED and
            l_virt_customer_id <> l_customer_id and 
            l_virtual_card_id  <> l_object_id then

            select c.contract_id
                 , c.split_hash
              into l_contract_id
                 , l_split_hash
              from prd_customer c
                 , prd_contract t
             where t.customer_id = c.id
               and c.id = l_customer_id;

        else
            -- reconnect card if customer associated with agent
            begin
                select c.contract_id
                     , c.split_hash
                  into l_contract_id
                     , l_split_hash
                  from prd_customer c
                     , prd_contract t
                 where t.customer_id = c.id
                   and c.id = l_virt_customer_id
                   and t.contract_type    = prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD
                   and c.ext_entity_type  = ost_api_const_pkg.ENTITY_TYPE_AGENT
                   and c.ext_object_id   is not null;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error         => 'CARD_ALREADY_EXISTS'
                      , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
                    );
            end;
        end if;

        iss_api_virtual_card_pkg.reconnect_virtual_card(
            i_card_id               => l_virtual_card_id
          , i_parent_card_id        => l_card.id  
          , i_customer_id           => l_customer_id
          , i_contract_id           => l_contract_id
          , i_cardholder_id         => l_cardholder_id
          , i_expir_date            => l_expir_date
          , i_split_hash            => l_split_hash
          , i_card_type_id          => l_card_type_id
          , i_inst_id               => l_card.inst_id
          , i_limit_type            => l_limit_type
          , i_usage_limit_count     => null
          , i_usage_limit_amount    => l_usage_limit_amount
          , i_usage_limit_currency  => l_account.currency
          , i_card_number           => l_card_number
          , i_account_id            => l_account.account_id
        );
        
        opr_api_create_pkg.add_participant(
            i_oper_id               => opr_api_shared_data_pkg.get_operation().id
          , i_msg_type              => opr_api_shared_data_pkg.get_operation().msg_type
          , i_oper_type             => opr_api_shared_data_pkg.get_operation().oper_type
          , i_participant_type      => com_api_const_pkg.PARTICIPANT_DEST
          , i_client_id_type        => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_type
          , i_client_id_value       => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_value
          , i_inst_id               => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).inst_id
          , i_network_id            => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).network_id
          , i_card_id               => l_virtual_card_id
          , i_card_expir_date       => l_expir_date
          , i_customer_id           => l_customer_id
          , i_without_checks        => com_api_const_pkg.TRUE
        );
        
        l_participant_rec.oper_id           := opr_api_shared_data_pkg.get_operation().id;
        l_participant_rec.participant_type  := com_api_const_pkg.PARTICIPANT_DEST;
        l_participant_rec.client_id_type    := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_type;
        l_participant_rec.client_id_value   := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_value;
        l_participant_rec.inst_id           := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).inst_id;
        l_participant_rec.network_id        := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).network_id;
        l_participant_rec.card_id           := l_virtual_card_id;
        l_participant_rec.card_expir_date   := l_expir_date;
        l_participant_rec.customer_id       := l_customer_id;
        
        opr_api_shared_data_pkg.set_participant(l_participant_rec);
        
        trc_log_pkg.debug(
            i_text          => 'Added participant with parameters: [#1], [#2], [#3], [#4], [#5], [#6]'
            , i_env_param1  => l_participant_rec.participant_type
            , i_env_param2  => l_participant_rec.client_id_type
            , i_env_param3  => l_participant_rec.card_id
            , i_env_param4  => l_participant_rec.card_expir_date
            , i_env_param5  => l_participant_rec.inst_id
            , i_env_param6  => l_participant_rec.customer_id
        );
        
    end if;
     
end;

procedure check_card_autoreissue
is
    l_card_id       com_api_type_pkg.t_long_id;
    l_object_id     com_api_type_pkg.t_long_id;
    l_entity_type   com_api_type_pkg.t_dict_value;
    l_cnt           com_api_type_pkg.t_count := 0;
    l_start_date    date;
    l_end_date      date;

begin
    trc_log_pkg.debug(
        i_text => 'check_card_autoreissue: start'
    );

    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    case l_entity_type
        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            l_card_id := l_object_id;
        when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            l_card_id := iss_api_card_instance_pkg.get_instance(
                             i_id => l_object_id
                         ).card_id;
            l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => l_entity_type
            );
    end case;
    l_end_date := nvl(evt_api_shared_data_pkg.get_param_date(
                          i_name       => 'EVENT_DATE'
                        , i_mask_error => com_api_type_pkg.FALSE), com_api_sttl_day_pkg.get_sysdate);

    l_start_date := fcl_api_cycle_pkg.calc_next_date(
                        i_cycle_type    => iss_api_const_pkg.CYCLE_AUTHREISS_CHECK_LENGTH
                      , i_entity_type   => l_entity_type
                      , i_object_id     => l_card_id
                      , i_forward       => com_api_type_pkg.FALSE
                      , i_raise_error   => com_api_type_pkg.TRUE
                    );

    select count(*)
      into l_cnt
      from opr_operation o
      join opr_participant op on o.id = op.oper_id
                             and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                             and op.card_id = l_card_id
     where o.oper_date between l_start_date and l_end_date;

    trc_log_pkg.debug(
        i_text       => 'check_card_autoreissue: found [#1] ops found for period from [#2] till [#3]'
      , i_env_param1 => l_cnt
      , i_env_param2 => to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param3 => to_char(l_end_date  , com_api_const_pkg.XML_DATE_FORMAT)
    );

    if l_cnt = 0 then
        raise com_api_error_pkg.e_stop_execute_rule_set;
    end if;

end check_card_autoreissue;

procedure create_event_fee is

    l_params            com_api_type_pkg.t_param_tab;
    l_oper_id           com_api_type_pkg.t_long_id;
    l_object_id         com_api_type_pkg.t_long_id;
    l_event_date        date;
    l_event_type        com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_fee_id            com_api_type_pkg.t_long_id;
    l_fee_params        com_api_type_pkg.t_param_tab;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_fee_amount        com_api_type_pkg.t_money;
    l_fee_currency      com_api_type_pkg.t_curr_code;
    l_card              iss_api_type_pkg.t_card_rec;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_product_id        com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
        
    l_oper_type         com_api_type_pkg.t_dict_value;
    l_msg_type          com_api_type_pkg.t_dict_value;
    l_oper_status       com_api_type_pkg.t_dict_value;
    l_sttl_type         com_api_type_pkg.t_dict_value;
    l_calc_fee          com_api_type_pkg.t_boolean;
        
    l_account_number    com_api_type_pkg.t_account_number;
    l_account_id        com_api_type_pkg.t_medium_id;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_client_id_type    com_api_type_pkg.t_dict_value;

begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_type := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
    l_event_date := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_fee_type := rul_api_param_pkg.get_param_char('FEE_TYPE', l_params);
    l_inst_id := rul_api_param_pkg.get_param_num('INST_ID', l_params);
        
    l_oper_type := nvl(rul_api_param_pkg.get_param_char (
        i_name          => 'OPER_TYPE'
        , io_params     => l_params
        , i_mask_error  => com_api_type_pkg.TRUE
    ), opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE);
        
    l_msg_type := nvl(rul_api_param_pkg.get_param_char (
        i_name          => 'MSG_TYPE'
        , io_params     => l_params
        , i_mask_error  => com_api_type_pkg.TRUE
    ), opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT);
        
    l_oper_status := nvl(rul_api_param_pkg.get_param_char (
        i_name          => 'OPERATION_STATUS'
        , io_params     => l_params
        , i_mask_error  => com_api_type_pkg.TRUE
    ), opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);
        
    l_sttl_type := nvl(rul_api_param_pkg.get_param_char (
        i_name          => 'STTL_TYPE'
        , io_params     => l_params
        , i_mask_error  => com_api_type_pkg.TRUE
    ), opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST);
        
    l_calc_fee := nvl(rul_api_param_pkg.get_param_num (
        i_name          => 'CALCULATE_FEE'
        , io_params     => l_params
        , i_mask_error  => com_api_type_pkg.TRUE
    ), com_api_type_pkg.TRUE);

    case
    when l_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_customer_id := l_object_id;
        l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER;
            
    when l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        begin
            select
                id
                , account_number
                , customer_id
            into
                l_account_id
                , l_account_number
                , l_customer_id
            from
                acc_account_vw
            where
                id = l_object_id;
        exception
            when no_data_found then
                return;
        end;
            
        l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;

    when l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD, iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE) then
        if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            begin
                select
                    i.card_id
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                into
                    l_object_id
                    , l_entity_type
                from
                    iss_card_instance i
                where
                    i.id = l_object_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error (
                        i_error      => 'CARD_NOT_FOUND'
                      , i_env_param1 => l_object_id
                    );
            end;
        end if;
            
        l_card := iss_api_card_pkg.get_card (
            i_card_id  => l_object_id
        );
            
        l_customer_id := l_card.customer_id;
        
        rul_api_param_pkg.set_param (
            i_name              => 'CARD_TYPE_ID'
            , i_value           => l_card.card_type_id
            , io_params         => l_fee_params
        );
            
        l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    else
        com_api_error_pkg.raise_error (
            i_error         => 'EVNT_WRONG_ENTITY_TYPE'
            , i_env_param1  => l_event_type
            , i_env_param2  => l_inst_id
            , i_env_param3  => l_entity_type
        );
    end case;
            
    if nvl(l_calc_fee, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        l_product_id := prd_api_product_pkg.get_product_id (
            i_entity_type  => l_entity_type
            , i_object_id  => l_object_id
        );
        l_fee_id := prd_api_product_pkg.get_fee_id (
            i_product_id     => l_product_id
            , i_entity_type  => l_entity_type
            , i_object_id    => l_object_id
            , i_fee_type     => l_fee_type
            , i_params       => l_fee_params
            , i_eff_date     => l_event_date
            , i_inst_id      => l_inst_id
        );
        l_fee_amount := fcl_api_fee_pkg.get_fee_amount( 
            i_fee_id            => l_fee_id
            , i_base_amount     => 0
            , io_base_currency  => l_fee_currency
            , i_eff_date        => l_event_date
        );
    else
        l_fee_amount := 0;
        l_fee_currency := com_api_const_pkg.UNDEFINED_CURRENCY;
    end if;
            
    opr_api_create_pkg.create_operation (
        io_oper_id               => l_oper_id
        , i_session_id           => get_session_id
        , i_status               => l_oper_status
        , i_sttl_type            => l_sttl_type
        , i_msg_type             => l_msg_type
        , i_oper_type            => l_oper_type
        , i_oper_reason          => l_fee_type
        , i_oper_amount          => l_fee_amount
        , i_oper_currency        => l_fee_currency
        , i_is_reversal          => com_api_const_pkg.FALSE
        , i_oper_request_amount  => l_fee_amount
        , i_oper_date            => l_event_date
        , i_host_date            => l_event_date
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => l_msg_type
        , i_oper_type         => l_oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
        , i_host_date         => l_event_date
        , i_inst_id           => l_inst_id
        , i_customer_id       => l_customer_id
        , i_card_id           => l_card.id
        , i_card_instance_id  => case l_entity_type
                                     when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                     then l_object_id
                                     else null
                                 end
        , i_account_id        => l_account_id
        , i_account_number    => l_account_number
        , i_card_mask         => l_card.card_mask
        , i_card_hash         => l_card.card_hash
        , i_card_number       => l_card.card_number
        , i_card_type_id      => l_card.card_type_id
        , i_card_country      => l_card.country
        , i_split_hash        => l_split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
        , i_client_id_type    => l_client_id_type
        , i_client_id_value   => l_object_id
    );
end create_event_fee;

procedure calculate_reissue_date is
    l_params            com_api_type_pkg.t_param_tab;
    l_object_id         com_api_type_pkg.t_long_id;
    l_event_date        date;
    l_event_type        com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;

    l_cycle_params      com_api_type_pkg.t_param_tab;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_out_date          date;
    l_expir_date        date;
        
    l_card_id           com_api_type_pkg.t_medium_id;
    l_is_auto_reiss     com_api_type_pkg.t_boolean;
    l_product_id        com_api_type_pkg.t_short_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_contract_id       com_api_type_pkg.t_medium_id;
    l_card_type_id      com_api_type_pkg.t_tiny_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
        
    l_card_type         iss_api_type_pkg.t_product_card_type_rec;

begin
    l_params := evt_api_shared_data_pkg.g_params;
    l_object_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_type := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
    l_event_date := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_cycle_type := rul_api_param_pkg.get_param_char('CYCLE_TYPE', l_params);

    trc_log_pkg.debug(
        i_text          => 'l_object_id [#1], l_entity_type [#2]'
      , i_env_param1    => l_object_id
      , i_env_param2    => l_entity_type
    );

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        begin
            select
                i.expir_date
              , c.id  
              , c.split_hash
              , c.contract_id
              , c.card_type_id
              , c.inst_id
            into
                l_expir_date
              , l_card_id  
              , l_split_hash
              , l_contract_id
              , l_card_type_id
              , l_inst_id
            from
                iss_card_instance_vw i
              , iss_card c
              , prd_contract r  
            where
                i.id        = l_object_id
            and i.card_id   = c.id
            and c.contract_id = r.id;
     
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error      => 'CARD_NOT_FOUND'
                  , i_env_param1 => l_object_id
                );
        end;
            
        if l_expir_date < get_sysdate() then
            trc_log_pkg.debug(
                i_text          => 'Historical instance, ignore autoreissue; l_expir_date [#1], sysdate [#2]'
              , i_env_param1    => l_expir_date
              , i_env_param2    => get_sysdate()
            );
                
        else
            l_product_id := prd_api_product_pkg.get_product_id(
                                i_entity_type   => l_entity_type
                              , i_object_id     => l_object_id
                            );
                
            l_card_type := iss_api_product_pkg.get_product_card_type (
                i_contract_id       => l_contract_id
                , i_card_type_id    => l_card_type_id
            );
                
            begin 
                l_is_auto_reiss := prd_api_product_pkg.get_attr_value_number (
                    i_product_id    => l_product_id
                  , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id     => l_card_id
                  , i_attr_name     => iss_api_const_pkg.ATTR_CARD_AUTO_REISSUE
                  , i_params        => l_params
                  , i_split_hash    => l_split_hash
                  , i_service_id    => l_card_type.service_id
                  , i_eff_date      => l_event_date
                  , i_inst_id       => l_inst_id
                );
                    
            exception
                when others then
                    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                        raise;
                            
                    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                        l_is_auto_reiss := com_api_const_pkg.FALSE;
                            
                    else
                        raise;
                            
                    end if;
            end;
                
            if l_is_auto_reiss = com_api_const_pkg.TRUE then
                fcl_api_cycle_pkg.switch_cycle (
                    i_product_id        => l_product_id
                    , i_entity_type     => l_entity_type
                    , i_object_id       => l_object_id
                    , i_cycle_type      => l_cycle_type
                    , i_service_id      => l_card_type.service_id
                    , i_params          => l_cycle_params
                    , i_start_date      => l_expir_date
                    , i_eff_date        => l_event_date
                    , o_new_finish_date => l_out_date
                    , i_test_mode       => fcl_api_const_pkg.ATTR_MISS_IGNORE
                   -- , i_forward         => com_api_const_pkg.FALSE
                );
                    
                if l_out_date is null then
                    trc_log_pkg.warn(
                        i_text          => 'Cycle not switched!'
                    );
                end if;
                    
            end if;
                
        end if;
                
    else
        com_api_error_pkg.raise_error (
            i_error        => 'EVNT_WRONG_ENTITY_TYPE'
            , i_env_param1 => l_event_type
            , i_env_param2 => rul_api_param_pkg.get_param_num('INST_ID', l_params)
            , i_env_param3 => l_entity_type
            , i_env_param4 => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
        );
    end if;    
end calculate_reissue_date;
    
procedure reissue_card_instance is
    l_params            com_api_type_pkg.t_param_tab;
    l_object_id         com_api_type_pkg.t_long_id;
    l_event_type        com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
        
    l_card_number       com_api_type_pkg.t_card_number;
    l_out_card_number   com_api_type_pkg.t_card_number;
    l_seq_number        com_api_type_pkg.t_tiny_id;
    l_expir_date        date;

    l_is_auto_reiss     com_api_type_pkg.t_boolean;
    l_product_id        com_api_type_pkg.t_short_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_contract_id       com_api_type_pkg.t_medium_id;
    l_card_type_id      com_api_type_pkg.t_tiny_id;
    l_card_type         iss_api_type_pkg.t_product_card_type_rec;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
        
begin
    l_params        := evt_api_shared_data_pkg.g_params;
    l_object_id     := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type   := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_type    := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
        
    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        begin
            select
                n.card_number
                , i.seq_number
                , i.split_hash
                , c.id
                , c.contract_id
                , c.card_type_id
                , c.inst_id
            into
                l_card_number
                , l_seq_number
                , l_split_hash
                , l_card_id
                , l_contract_id
                , l_card_type_id
                , l_inst_id
            from
                iss_card_instance_vw i
                , iss_card_number_vw n
                , iss_card_vw c
            where
                i.id = l_object_id
                and n.card_id = i.card_id
                and c.id      = i.card_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error      => 'CARD_NOT_FOUND'
                  , i_env_param1 => l_object_id
                );
        end;
            
        l_product_id := prd_api_product_pkg.get_product_id(
                            i_entity_type   => l_entity_type
                          , i_object_id     => l_object_id
                        );
                
        l_card_type := iss_api_product_pkg.get_product_card_type (
            i_contract_id       => l_contract_id
            , i_card_type_id    => l_card_type_id
        );
                
        begin 
            l_is_auto_reiss := prd_api_product_pkg.get_attr_value_number (
                i_product_id    => l_product_id
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => l_card_id
              , i_attr_name     => iss_api_const_pkg.ATTR_CARD_AUTO_REISSUE
              , i_params        => l_params
              , i_split_hash    => l_split_hash
              , i_service_id    => l_card_type.service_id
              , i_eff_date      => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id)
              , i_inst_id       => l_inst_id
            );
                    
        exception
            when others then
                if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                    raise;
                            
                elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                    l_is_auto_reiss := com_api_const_pkg.FALSE;
                            
                else
                    raise;
                            
                end if;
        end;
            
        if l_is_auto_reiss = com_api_const_pkg.TRUE then

            iss_api_card_pkg.reissue (
                i_card_number       => l_card_number
              , io_seq_number       => l_seq_number
              , io_card_number      => l_out_card_number
              , io_expir_date       => l_expir_date
              , i_reissue_reason    => l_event_type
            );
                
        else
            trc_log_pkg.debug(
                i_text          => 'l_is_auto_reiss [' || l_is_auto_reiss || ']. Auto reissue was skiped.'
            );

        end if;
                
    else
        com_api_error_pkg.raise_error (
            i_error        => 'EVNT_WRONG_ENTITY_TYPE'
            , i_env_param1 => l_event_type
            , i_env_param2 => rul_api_param_pkg.get_param_char('INST_ID', l_params)
            , i_env_param3 => l_entity_type
            , i_env_param4 => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
        );
    end if;    
end reissue_card_instance;

procedure get_card_balance is
    l_party_type        com_api_type_pkg.t_dict_value;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_account_id        com_api_type_pkg.t_medium_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_eff_date          date;
    l_eff_date_name     com_api_type_pkg.t_name;
    l_amount_name       com_api_type_pkg.t_name;
    l_need_lock         com_api_type_pkg.t_boolean;    
    l_aval_amount       com_api_type_pkg.t_money;
    l_limit_amount      com_api_type_pkg.t_money;
    l_amount            com_api_type_pkg.t_money;
    l_account           acc_api_type_pkg.t_account_rec;
    l_balances          com_api_type_pkg.t_amount_by_name_tab;
    l_array_id          com_api_type_pkg.t_medium_id;
begin
    
    l_party_type    := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_card_id       := opr_api_shared_data_pkg.get_participant(l_party_type).card_id;
    l_account_id    := opr_api_shared_data_pkg.get_participant(l_party_type).account_id;
    l_inst_id       := opr_api_shared_data_pkg.get_participant(l_party_type).inst_id;

    l_need_lock     := nvl(opr_api_shared_data_pkg.get_param_num (
        i_name            => 'NEED_LOCK'
        , i_mask_error    => com_api_type_pkg.TRUE
        , i_error_value   => com_api_const_pkg.FALSE
    ), com_api_const_pkg.FALSE);

    l_amount_name   := opr_api_shared_data_pkg.get_param_char (
        i_name            => 'AMOUNT_NAME'
        , i_mask_error    => com_api_type_pkg.TRUE
        , i_error_value   => null
    );
    
    l_eff_date_name := 
        opr_api_shared_data_pkg.get_param_char(
            i_name        => 'EFFECTIVE_DATE'
          , i_mask_error  => com_api_type_pkg.TRUE
          , i_error_value => null
        );

    acc_api_balance_pkg.get_account_balances (
        i_account_id        => l_account_id
        , o_balances        => l_balances
        , o_balance         => l_aval_amount
        , i_lock_balances   => l_need_lock
    );

    l_account := acc_api_account_pkg.get_account(
        i_account_id      => l_account_id
      , i_mask_error      => com_api_const_pkg.FALSE
    );
    
    if l_eff_date_name = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_eff_date := 
            com_api_sttl_day_pkg.get_open_sttl_date (
                i_inst_id => l_inst_id
            );
    elsif l_eff_date_name is not null then
        opr_api_shared_data_pkg.get_date (
            i_name      => l_eff_date_name
          , o_date      => l_eff_date
        );
    else
        l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    end if;
    
    -- get aval balance of limits of card
    l_limit_amount := iss_api_card_pkg.get_card_limit_balance(
        i_card_id       => l_card_id
        , i_eff_date    => l_eff_date
        , i_inst_id     => l_inst_id
        , i_currency    => l_account.currency 
        , o_array_id    => l_array_id
    );
    
    if l_array_id is not null then
    
        l_amount := least(0, l_aval_amount, l_limit_amount);
    else            
        l_amount := l_aval_amount; 
    end if;
    
    if l_amount_name is not null then
        opr_api_shared_data_pkg.set_amount (
            i_name        => l_amount_name
            , i_amount    => l_amount
            , i_currency  => l_account.currency
        );
    end if;
    
end get_card_balance;

end iss_api_rule_proc_pkg;
/
