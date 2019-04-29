create or replace package body acq_api_event_pkg is
/********************************************************* 
 *  API for Address in application <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 07.10.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acq_api_event_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

    procedure calculate_fee is
        l_params            com_api_type_pkg.t_param_tab;
        l_entity_type       com_api_type_pkg.t_dict_value;
        l_object_id         com_api_type_pkg.t_long_id;
        l_event_type        com_api_type_pkg.t_dict_value;
        l_event_date        date;
        l_product_id        com_api_type_pkg.t_long_id;
        l_fee_params        com_api_type_pkg.t_param_tab;
        l_fee_id            com_api_type_pkg.t_long_id;
        l_fee_type          com_api_type_pkg.t_dict_value;
        l_fee_amount        com_api_type_pkg.t_money;
        l_fee_currency      com_api_type_pkg.t_curr_code;
        l_amount_name       com_api_type_pkg.t_name;
    begin
        l_params := evt_api_shared_data_pkg.g_params;
        
        l_object_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
        l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
        l_event_type := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
        l_event_date := to_date(rul_api_param_pkg.get_param_char('EVENT_DATE', l_params), com_api_const_pkg.DATE_FORMAT);
        l_fee_type := rul_api_param_pkg.get_param_char('FEE_TYPE', l_params);
        l_amount_name := rul_api_param_pkg.get_param_char('AMOUNT_NAME', l_params);
        
        case l_entity_type 
            when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                l_product_id := acq_api_merchant_pkg.get_product_id (
                    i_merchant_id  => l_object_id
                );

            when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                l_product_id := acq_api_terminal_pkg.get_product_id (
                    i_terminal_id  => l_object_id
                );

            else
                com_api_error_pkg.raise_error (
                    i_error         => 'EVNT_WRONG_ENTITY_TYPE'
                    , i_env_param1  => l_event_type
                    , i_env_param2  => rul_api_param_pkg.get_param_char('INST_ID', l_params)
                    , i_env_param3  => l_entity_type
                );
        end case;
        
        l_fee_id := prd_api_product_pkg.get_fee_id (
            i_product_id     => l_product_id
            , i_entity_type  => l_entity_type
            , i_object_id    => l_object_id
            , i_fee_type     => l_fee_type
            , i_params       => l_fee_params
            , i_eff_date     => l_event_date
        );

        l_fee_amount := fcl_api_fee_pkg.get_fee_amount (
            i_fee_id            => l_fee_id
            , i_base_amount     => 0
            , io_base_currency  => l_fee_currency
            , i_eff_date        => l_event_date
        );
                
        evt_api_shared_data_pkg.set_amount (
            i_name        => l_amount_name
            , i_amount    => l_fee_amount
            , i_currency  => l_fee_currency
        );
    end;
    
    procedure create_oper_fee is
        l_params                        com_api_type_pkg.t_param_tab;
        l_merchant_id                   com_api_type_pkg.t_long_id;
        l_oper_id                       com_api_type_pkg.t_long_id;
        l_entity_type                   com_api_type_pkg.t_dict_value;
        l_object_id                     com_api_type_pkg.t_long_id;
        l_event_type                    com_api_type_pkg.t_dict_value;
        l_event_date                    date;
        l_fee_type                      com_api_type_pkg.t_dict_value;
        l_fee_amount                    com_api_type_pkg.t_money;
        l_fee_currency                  com_api_type_pkg.t_curr_code;
        l_amount_name                   com_api_type_pkg.t_name;
        l_merchant_number               com_api_type_pkg.t_merchant_number;
        l_merchant_name                 com_api_type_pkg.t_name;
        l_merchant_street               com_api_type_pkg.t_name;
        l_merchant_city                 com_api_type_pkg.t_name;
        l_merchant_country              com_api_type_pkg.t_country_code;
        l_merchant_postcode             com_api_type_pkg.t_postal_code;
        l_split_hash                    com_api_type_pkg.t_tiny_id;
        l_inst_id                       com_api_type_pkg.t_inst_id;
        l_oper_type                     com_api_type_pkg.t_dict_value;
        l_sttl_type                     com_api_type_pkg.t_dict_value;
    begin
        l_params := evt_api_shared_data_pkg.g_params;

        l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
        l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
        l_event_type  := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
        l_event_date  := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
        l_fee_type    := rul_api_param_pkg.get_param_char('FEE_TYPE', l_params);
        l_amount_name := rul_api_param_pkg.get_param_char('AMOUNT_NAME', l_params);
        l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
        l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params);
        l_sttl_type   := rul_api_param_pkg.get_param_char('STTL_TYPE', l_params);
        l_oper_type   := rul_api_param_pkg.get_param_char('OPER_TYPE', l_params);

        case l_entity_type
            when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                evt_api_shared_data_pkg.get_amount (
                    i_name        => l_amount_name
                    , o_amount    => l_fee_amount
                    , o_currency  => l_fee_currency
                );

                for rec in (
                    select
                        inst_id
                        , merchant_number
                        , merchant_name
                    from
                        acq_merchant_vw m
                    where
                        m.id = l_object_id
                ) loop
                    l_merchant_number := rec.merchant_number;
                    l_merchant_name := rec.merchant_name;
                end loop;

                for rec in (
                    select
                        a.street merchant_street
                        , a.city merchant_city
                        , a.country merchant_country
                        , a.postal_code merchant_postcode
                    from
                        com_address_vw a
                    where
                        a.id = acq_api_merchant_pkg.get_merchant_address_id (
                            i_merchant_id  => l_object_id
                        )
                        and a.lang = 'LANGENG'
                ) loop
                    l_merchant_street := rec.merchant_street;
                    l_merchant_city := rec.merchant_city;
                    l_merchant_country := rec.merchant_country;
                    l_merchant_postcode := rec.merchant_postcode;
                end loop;

                opr_api_create_pkg.create_operation (
                    io_oper_id              => l_oper_id
                  , i_session_id            => get_session_id
                  , i_status                => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                  , i_sttl_type             => l_sttl_type
                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type             => l_oper_type
                  , i_oper_reason           => l_fee_type
                  , i_oper_amount           => l_fee_amount
                  , i_oper_currency         => l_fee_currency
                  , i_merchant_number       => l_merchant_number
                  , i_merchant_name         => l_merchant_name
                  , i_merchant_street       => l_merchant_street
                  , i_merchant_city         => l_merchant_city
                  , i_merchant_country      => l_merchant_country
                  , i_merchant_postcode     => l_merchant_postcode
                  , i_is_reversal           => com_api_const_pkg.FALSE
                  , i_oper_date             => l_event_date
                  , i_host_date             => l_event_date
                );

                opr_api_create_pkg.add_participant(
                    i_oper_id               => l_oper_id
                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type             => l_oper_type
                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , i_inst_id               => l_inst_id
                  , i_merchant_number       => l_merchant_number
                  , i_merchant_id           => l_object_id
                  , i_split_hash            => l_split_hash
                  , i_without_checks        => com_api_const_pkg.TRUE
                );    


            when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                l_merchant_id := acq_api_terminal_pkg.get_merchant_id (
                    i_terminal_id  => l_object_id
                );
                
                evt_api_shared_data_pkg.get_amount (
                    i_name        => l_amount_name
                    , o_amount    => l_fee_amount
                    , o_currency  => l_fee_currency
                );                
                
                opr_api_create_pkg.create_operation (
                    io_oper_id              => l_oper_id
                  , i_session_id            => get_session_id
                  , i_status                => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                  , i_sttl_type             => l_sttl_type
                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type             => l_oper_type
                  , i_oper_reason           => l_fee_type
                  , i_oper_amount           => l_fee_amount
                  , i_oper_currency         => l_fee_currency
                  , i_is_reversal           => com_api_const_pkg.FALSE
                  , i_oper_date             => l_event_date
                  , i_host_date             => l_event_date
                );

                opr_api_create_pkg.add_participant(
                    i_oper_id               => l_oper_id
                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type             => l_oper_type
                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , i_inst_id               => l_inst_id
                  , i_terminal_id           => l_object_id
                  , i_merchant_id           => l_merchant_id
                  , i_split_hash            => l_split_hash
                  , i_without_checks        => com_api_const_pkg.TRUE
                );    
        else
            com_api_error_pkg.raise_error (
                i_error         => 'EVNT_WRONG_ENTITY_TYPE'
                , i_env_param1  => l_event_type
                , i_env_param2  => rul_api_param_pkg.get_param_char('INST_ID', l_params)
                , i_env_param3  => l_entity_type
            );
        end case;
    end;

end;
/
