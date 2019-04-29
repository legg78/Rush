create or replace package body dsp_api_generate_pkg is

    procedure create_authorization(
        i_original_id            in com_api_type_pkg.t_long_id
      , i_oper_id                in com_api_type_pkg.t_long_id
    ) is
    begin
        insert into aut_auth (
            id
          , resp_code
          , proc_type
          , proc_mode
          , cat_level          
          , card_data_input_cap
          , crdh_auth_cap
          , card_capture_cap
          , terminal_operating_env
          , crdh_presence
          , card_presence
          , card_data_input_mode
          , crdh_auth_method
          , crdh_auth_entity
          , card_data_output_cap
          , terminal_output_cap
          , pin_capture_cap
          , pin_presence
          , service_code
        )
        select i_oper_id
             , resp_code
             , proc_type
             , proc_mode
             , cat_level          
             , card_data_input_cap
             , crdh_auth_cap
             , card_capture_cap
             , terminal_operating_env
             , 'F2250001' -- not present
             , 'F2260001' -- not present
             , 'F2270001' -- manual. no terminal
             , 'F2280000' -- not authenticated
             , 'F2290000' -- not authenticated
             , card_data_output_cap
             , terminal_output_cap
             , pin_capture_cap
             , 'PINP0000' -- undefined (data not available)
             , service_code
         from aut_auth
        where id   = i_original_id;
    end create_authorization;

    procedure create_operation(
      i_original_id             in com_api_type_pkg.t_long_id
      , i_status                in com_api_type_pkg.t_dict_value  := null
      , i_oper_reason           in com_api_type_pkg.t_dict_value  := null
      , i_msg_type              in com_api_type_pkg.t_dict_value  := null
      , i_oper_type             in com_api_type_pkg.t_dict_value  := null
      , i_is_reversal           in com_api_type_pkg.t_boolean     := null
      , i_oper_amount           in com_api_type_pkg.t_money       := null
      , i_oper_currency         in com_api_type_pkg.t_curr_code   := null
      , io_oper_id              in out com_api_type_pkg.t_long_id
    ) is
        l_oper                    opr_api_type_pkg.t_oper_rec;
        l_oper_part               opr_api_type_pkg.t_oper_part_rec;
        l_count                   com_api_type_pkg.t_boolean;
    begin
        opr_api_operation_pkg.get_operation(
            i_oper_id    => i_original_id
          , o_operation  => l_oper
        );

        if l_oper.dispute_id is null then
            l_oper.dispute_id := dsp_api_shared_data_pkg.get_id;
            update
                opr_operation
            set
                dispute_id = l_oper.dispute_id
            where
                id = i_original_id;
        end if;

        if i_is_reversal = com_api_type_pkg.TRUE then
            select
                case when count(r.id) > 0 then 1 else 0 end
            into
                l_count
            from
                opr_operation r
            where
                r.original_id = i_original_id
                and r.is_reversal = com_api_type_pkg.TRUE;

            if l_count = com_api_type_pkg.TRUE then
                com_api_error_pkg.raise_error (
                    i_error        => 'DISPUTE_DOUBLE_REVERSAL'
                    , i_env_param1 => l_oper.dispute_id
                );
            end if;

            if nvl(l_oper.oper_amount, 0) < nvl(i_oper_amount, 0) then
                com_api_error_pkg.raise_error (
                    i_error         => 'REVERSAL_AMOUNT_GREATER_ORIGINAL_AMOUNT'
                    , i_env_param1  => nvl(l_oper.oper_amount, 0) 
                    , i_env_param2  => nvl(i_oper_amount, 0)
                );
            end if;
        end if;

        opr_api_create_pkg.create_operation(
            io_oper_id                 => io_oper_id
          , i_session_id               => get_session_id
          , i_status                   => nvl(i_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
          , i_status_reason            => null
          , i_sttl_type                => l_oper.sttl_type
          , i_msg_type                 => nvl(i_msg_type, l_oper.msg_type)
          , i_oper_type                => nvl(i_oper_type, l_oper.oper_type)
          , i_oper_reason              => nvl(i_oper_reason, l_oper.oper_reason)
          , i_is_reversal              => nvl(i_is_reversal, l_oper.is_reversal)
          , i_oper_amount              => nvl(i_oper_amount, l_oper.oper_amount)
          , i_oper_currency            => nvl(i_oper_currency, l_oper.oper_currency)
          , i_oper_cashback_amount     => l_oper.oper_cashback_amount
          , i_sttl_amount              => l_oper.sttl_amount
          , i_sttl_currency            => l_oper.sttl_currency
          , i_oper_date                => l_oper.oper_date
          , i_host_date                => null
          , i_terminal_type            => l_oper.terminal_type
          , i_mcc                      => l_oper.mcc
          , i_originator_refnum        => l_oper.originator_refnum
          , i_network_refnum           => l_oper.network_refnum
          , i_acq_inst_bin             => l_oper.acq_inst_bin
          , i_merchant_number          => l_oper.merchant_number
          , i_terminal_number          => l_oper.terminal_number
          , i_merchant_name            => l_oper.merchant_name
          , i_merchant_street          => l_oper.merchant_street
          , i_merchant_city            => l_oper.merchant_city
          , i_merchant_region          => l_oper.merchant_region
          , i_merchant_country         => l_oper.merchant_country
          , i_merchant_postcode        => l_oper.merchant_postcode
          , i_dispute_id               => l_oper.dispute_id
          , i_match_status             => l_oper.match_status
          , i_original_id              => l_oper.id
          , i_proc_mode                => l_oper.proc_mode
          , i_clearing_sequence_num    => l_oper.clearing_sequence_num
          , i_clearing_sequence_count  => l_oper.clearing_sequence_count
          , i_incom_sess_file_id       => null    
        );

        for p in (
            select
                oper_id
                , participant_type
            from
                opr_participant
            where
                oper_id = i_original_id
        ) loop
            opr_api_operation_pkg.get_participant(
                i_oper_id            => i_original_id
              , i_participaint_type  => p.participant_type
              , o_participant        => l_oper_part
            );

            opr_api_create_pkg.add_participant(
                i_oper_id           => io_oper_id
              , i_msg_type          => nvl(i_msg_type, l_oper.msg_type)
              , i_oper_type         => nvl(i_oper_type, l_oper.oper_type)
              , i_oper_reason       => nvl(i_oper_reason, l_oper.oper_reason)
              , i_participant_type  => l_oper_part.participant_type
              , i_host_date         => null
              , i_client_id_type    => l_oper_part.client_id_type
              , i_client_id_value   => l_oper_part.client_id_value
              , i_inst_id           => l_oper_part.inst_id
              , i_network_id        => l_oper_part.network_id
              , i_card_inst_id      => l_oper_part.card_inst_id
              , i_card_network_id   => l_oper_part.card_network_id
              , i_card_id           => l_oper_part.card_id
              , i_card_instance_id  => l_oper_part.card_instance_id
              , i_card_type_id      => l_oper_part.card_type_id
              , i_card_number       => l_oper_part.card_number
              , i_card_mask         => l_oper_part.card_mask
              , i_card_hash         => l_oper_part.card_hash
              , i_card_seq_number   => l_oper_part.card_seq_number
              , i_card_expir_date   => l_oper_part.card_expir_date
              , i_card_service_code => l_oper_part.card_service_code
              , i_card_country      => l_oper_part.card_country
              , i_customer_id       => l_oper_part.customer_id
              , i_account_id        => l_oper_part.account_id
              , i_account_type      => l_oper_part.account_type
              , i_account_number    => l_oper_part.account_number
              , i_account_amount    => l_oper_part.account_amount
              , i_account_currency  => l_oper_part.account_currency
              , i_auth_code         => l_oper_part.auth_code
              , i_merchant_number   => l_oper.merchant_number
              , i_merchant_id       => l_oper_part.merchant_id
              , i_terminal_number   => l_oper.terminal_number
              , i_terminal_id       => l_oper_part.terminal_id
              , i_split_hash        => l_oper_part.split_hash
              , i_without_checks    => com_api_const_pkg.TRUE
              , i_payment_host_id   => l_oper.payment_host_id
              , i_payment_order_id  => l_oper.payment_order_id
              , i_terminal_type     => l_oper.terminal_type
            );
        end loop;
    end;

    procedure gen_internal_reversal is
        l_fin_id                  com_api_type_pkg.t_long_id;
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_oper_amount             com_api_type_pkg.t_money;
    begin
        l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
        l_oper_amount := dsp_api_shared_data_pkg.get_param_num (
            i_name          => 'OPER_AMOUNT'
            , i_mask_error  => com_api_type_pkg.FALSE
        );
        
        create_operation (
            i_original_id    => l_oper_id
            , i_is_reversal  => com_api_const_pkg.TRUE
            , i_oper_amount  => l_oper_amount
            , io_oper_id     => l_fin_id
        );
    end;
    
    procedure gen_write_off_positive is
        l_fin_id                  com_api_type_pkg.t_long_id;
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_msg_type                com_api_type_pkg.t_dict_value;
        l_oper_amount             com_api_type_pkg.t_money;
        l_oper_currency           com_api_type_pkg.t_curr_code;
    begin
        l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
        l_oper_amount := dsp_api_shared_data_pkg.get_param_num (
            i_name           => 'OPER_AMOUNT'
            , i_mask_error   => com_api_type_pkg.FALSE
        );
        
        l_oper_currency := dsp_api_shared_data_pkg.get_param_char (
            i_name           => 'OPER_CURRENCY'
            , i_mask_error   => com_api_type_pkg.FALSE
        );
        
        create_operation (
            i_original_id    => l_oper_id
            , i_msg_type     => opr_api_const_pkg.MESSAGE_TYPE_WRITEOFF_POSITIVE
            , i_is_reversal  => com_api_const_pkg.FALSE
            , i_oper_amount  => l_oper_amount
            , io_oper_id     => l_fin_id
        );
    end;
    
    procedure gen_write_off_negative is
        l_fin_id                  com_api_type_pkg.t_long_id;
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_msg_type                com_api_type_pkg.t_dict_value;
        l_oper_amount             com_api_type_pkg.t_money;
    begin
        l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
        create_operation (
            i_original_id    => l_oper_id
            , i_msg_type     => opr_api_const_pkg.MESSAGE_TYPE_WRITEOFF_NEGATIVE
            , i_is_reversal  => com_api_const_pkg.FALSE
            , i_oper_amount  => l_oper_amount
            , io_oper_id     => l_fin_id
        );
    end;

    procedure gen_common_refund is
        l_fin_id                  com_api_type_pkg.t_long_id;
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_oper_amount             com_api_type_pkg.t_money;
        l_oper_reason             com_api_type_pkg.t_dict_value;  
    begin
        l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
        l_oper_amount := dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_type_pkg.FALSE
        );

        l_oper_reason := dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_REASON'
          , i_mask_error  => com_api_type_pkg.FALSE
        );
        
        create_operation(
            i_original_id  => l_oper_id
          , i_oper_reason  => l_oper_reason
          , i_msg_type     => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type    => opr_api_const_pkg.OPERATION_TYPE_REFUND
          , i_is_reversal  => com_api_const_pkg.FALSE
          , i_oper_amount  => l_oper_amount
          , io_oper_id     => l_fin_id
        );
        
        if l_fin_id is not null then
            create_authorization(
                i_original_id   => l_oper_id
              , i_oper_id       => l_fin_id
            );
        end if;

    end gen_common_refund;

end;
/
