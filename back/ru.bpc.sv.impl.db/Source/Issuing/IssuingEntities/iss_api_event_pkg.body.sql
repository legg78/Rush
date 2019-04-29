create or replace package body iss_api_event_pkg is
/*********************************************************
*  Event API for issuing <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 26.11.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ISS_API_EVENT_PKG <br />
*  @headcom
**********************************************************/
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
    end;

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
    end;
    
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
    end;

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
    
end;

end;
/
drop package iss_api_event_pkg
/
