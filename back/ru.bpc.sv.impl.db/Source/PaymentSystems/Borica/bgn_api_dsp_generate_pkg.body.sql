create or replace package body bgn_api_dsp_generate_pkg is

    procedure update_dispute_id (
        i_oper_id                 in com_api_type_pkg.t_long_id
        , i_dispute_id            in com_api_type_pkg.t_long_id
    ) is
    begin
        update
            bgn_fin
        set
            dispute_id = i_dispute_id
        where
            oper_id = i_oper_id;

        update
            opr_operation
        set
            dispute_id = i_dispute_id
        where
            id = i_oper_id;
    end;
    
    procedure create_operation (
        i_original_id             in com_api_type_pkg.t_long_id
        , i_status                in com_api_type_pkg.t_dict_value := null
        , i_oper_reason           in com_api_type_pkg.t_dict_value := null
        , i_msg_type              in com_api_type_pkg.t_dict_value := null
        , i_oper_type             in com_api_type_pkg.t_dict_value := null
        , i_is_reversal           in com_api_type_pkg.t_boolean := null
        , i_oper_amount           in com_api_type_pkg.t_money := null
        , i_oper_currency         in com_api_type_pkg.t_curr_code := null
        , io_oper_id              in out com_api_type_pkg.t_long_id
        , o_dispute_id            out com_api_type_pkg.t_long_id
    ) is
        l_oper                    opr_api_type_pkg.t_oper_rec;
        l_oper_part               opr_api_type_pkg.t_oper_part_rec;
        l_dispute_id              com_api_type_pkg.t_long_id;
        l_count                   com_api_type_pkg.t_boolean;
    begin
        opr_api_operation_pkg.get_operation (
            i_oper_id      => i_original_id
            , o_operation  => l_oper
        );
        
        l_dispute_id := l_oper.dispute_id;
        if l_oper.dispute_id is null then
            l_oper.dispute_id := dsp_api_shared_data_pkg.get_id;
        end if;
        o_dispute_id := l_oper.dispute_id;

        -- update original operation
        if l_dispute_id is null then
            update_dispute_id (
                i_oper_id       => i_original_id
                , i_dispute_id  => l_oper.dispute_id
            );
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
        
        opr_api_create_pkg.create_operation (
            io_oper_id                   => io_oper_id
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
            opr_api_operation_pkg.get_participant (
                i_oper_id              => i_original_id
                , i_participaint_type  => p.participant_type
                , o_participant        => l_oper_part
            );
            
            opr_api_create_pkg.add_participant (
                i_oper_id             => io_oper_id
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
    
    procedure gen_reversal is
        l_fin_rec                 bgn_api_type_pkg.t_bgn_fin_rec;
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_oper_amount             com_api_type_pkg.t_money;
        l_oper_currency           com_api_type_pkg.t_name;
        
        l_stage                   varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating reversal message'
        );
        
        l_stage := 'get params';
        l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        l_oper_amount := dsp_api_shared_data_pkg.get_param_num (
            i_name          => 'OPER_AMOUNT'
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        l_oper_currency := dsp_api_shared_data_pkg.get_param_char (
            i_name          => 'OPER_CURRENCY'
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        
        l_stage := 'get fin';
        bgn_api_fin_pkg.get_fin (
            i_id             => null
            , i_oper_id      => l_oper_id
            , i_is_incoming  => com_api_type_pkg.FALSE
            , o_fin_rec      => l_fin_rec
            , i_mask_error   => com_api_type_pkg.TRUE
        );
        
        l_stage := 'set oper id';
        l_fin_rec.oper_id := opr_api_create_pkg.get_id;
        
        l_stage := 'create oper';
        create_operation (
            i_original_id      => l_oper_id
            , i_is_reversal    => com_api_type_pkg.TRUE
            , i_oper_amount    => l_oper_amount
            , i_oper_currency  => l_oper_currency
            , io_oper_id       => l_fin_rec.oper_id
            , o_dispute_id     => l_fin_rec.dispute_id
        );
        
        if l_fin_rec.id is not null then
            l_stage := 'init fin';
            l_fin_rec.id := opr_api_create_pkg.get_id;
            
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            l_fin_rec.is_reversal := com_api_type_pkg.TRUE;
            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reject := 'R';
            l_fin_rec.is_invalid  := com_api_type_pkg.FALSE;
            
            l_fin_rec.file_id := null;
            l_fin_rec.record_number := null;
            l_fin_rec.file_record_number := null;
            
            l_fin_rec.transaction_amount := nvl(l_oper_amount, l_fin_rec.transaction_amount);
            l_fin_rec.transaction_currency := nvl(l_oper_currency, l_fin_rec.transaction_currency);
            
            l_stage := 'create fin';
            l_fin_rec.id := bgn_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Generating reversal message. Assigned oper_id[#1]'
            , i_env_param1 => l_fin_rec.oper_id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating reversal message on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

end;
/
 