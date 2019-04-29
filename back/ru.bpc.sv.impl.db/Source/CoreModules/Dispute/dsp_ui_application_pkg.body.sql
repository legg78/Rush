create or replace package body dsp_ui_application_pkg as
/************************************************************
 * User interface for dispute applications <br />
 * Created by Kondratyev A.(kondratyev@bpcbt.com)  at 24.11.2016  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: dsp_api_application_pkg <br />
 * @headcom
 ************************************************************/
g_root_id           com_api_type_pkg.t_long_id;

procedure prepare(
    i_appl_id           in      com_api_type_pkg.t_long_id
) is
    l_appl_data_id      com_api_type_pkg.t_long_id;
begin
    com_api_sttl_day_pkg.set_sysdate;

    for r in (
        select *
          from app_data_vw
         where appl_id = i_appl_id
           and name = 'ERROR'
    ) loop
        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'ERROR_CODE'
          , i_parent_id         => r.id
          , o_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.remove_element(
            i_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'ERROR_DESC'
          , i_parent_id         => r.id
          , o_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.remove_element(
            i_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'ERROR_DETAILS'
          , i_parent_id         => r.id
          , o_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.remove_element(
            i_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'ERROR_ELEMENT'
          , i_parent_id         => r.id
          , o_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.remove_element(
            i_appl_data_id      => l_appl_data_id
        );

        app_api_application_pkg.remove_element(
            i_appl_data_id      => r.id
        );

    end loop;
    app_api_error_pkg.g_app_errors.delete();
end prepare;

procedure process_application
is
    l_dispute_id           com_api_type_pkg.t_long_id;
    l_message_type         com_api_type_pkg.t_dict_value;
    l_write_off_amount     com_api_type_pkg.t_money;
    l_write_off_currency   com_api_type_pkg.t_curr_code;
    l_oper_id              com_api_type_pkg.t_long_id;
    l_original_id          com_api_type_pkg.t_long_id;

    procedure create_operation (
        i_original_id             in     com_api_type_pkg.t_long_id
        , i_status                in     com_api_type_pkg.t_dict_value := null
        , i_oper_reason           in     com_api_type_pkg.t_dict_value := null
        , i_msg_type              in     com_api_type_pkg.t_dict_value := null
        , i_oper_type             in     com_api_type_pkg.t_dict_value := null
        , i_is_reversal           in     com_api_type_pkg.t_boolean := null
        , i_oper_amount           in     com_api_type_pkg.t_money := null
        , i_oper_currency         in     com_api_type_pkg.t_curr_code := null
        , io_oper_id                 out com_api_type_pkg.t_long_id
    ) is
        l_oper                    opr_api_type_pkg.t_oper_rec;
        l_oper_part               opr_api_type_pkg.t_oper_part_rec;
        l_count                   com_api_type_pkg.t_boolean;
    begin
        opr_api_operation_pkg.get_operation (
            i_oper_id      => i_original_id
            , o_operation  => l_oper
        );

        if i_is_reversal = get_true then
            select
                case when count(r.id) > 0 then 1 else 0 end
            into
                l_count
            from
                opr_operation r
            where
                r.original_id = i_original_id
                and r.is_reversal = get_true;

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
            , i_status_reason            => l_oper.status_reason
            , i_sttl_type                => l_oper.sttl_type
            , i_msg_type                 => i_msg_type
            , i_oper_type                => nvl(i_oper_type, l_oper.oper_type)
            , i_oper_reason              => nvl(i_oper_reason, l_oper.oper_reason)
            , i_is_reversal              => nvl(i_is_reversal, l_oper.is_reversal)
            , i_oper_amount              => nvl(i_oper_amount, l_oper.oper_amount)
            , i_oper_currency            => nvl(i_oper_currency, l_oper.oper_currency)
            , i_oper_cashback_amount     => l_oper.oper_cashback_amount
            , i_sttl_amount              => l_oper.sttl_amount
            , i_sttl_currency            => l_oper.sttl_currency
            , i_oper_surcharge_amount    => l_oper.oper_surcharge_amount
            , i_oper_date                => l_oper.oper_date
            , i_host_date                => null
            , i_terminal_type            => l_oper.terminal_type
            , i_mcc                      => l_oper.mcc
            , i_originator_refnum        => l_oper.originator_refnum
            , i_network_refnum           => l_oper.network_refnum
            , i_oper_count               => l_oper.oper_count
            , i_oper_request_amount      => l_oper.oper_request_amount
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
            , i_sttl_date                => get_sysdate
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
                , i_msg_type          => i_msg_type
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

begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => g_root_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'DISPUTE_ID'
      , i_parent_id      => g_root_id
      , o_element_value  => l_dispute_id
    );

    if l_dispute_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'NO_DISPUTE_FOUND'
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MESSAGE_TYPE'
      , i_parent_id      => g_root_id
      , o_element_value  => l_message_type
    );
    
    if l_message_type is null then
        com_api_error_pkg.raise_error (
            i_error         => 'ABSENT_MANDATORY_ELEMENT'
            , i_env_param1  => 'MESSAGE_TYPE'
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'WRITE_OFF_AMOUNT'
      , i_parent_id      => g_root_id
      , o_element_value  => l_write_off_amount
    );
    
    if l_write_off_amount is null then
        com_api_error_pkg.raise_error (
            i_error         => 'ABSENT_MANDATORY_ELEMENT'
            , i_env_param1  => 'WRITE_OFF_AMOUNT'
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'WRITE_OFF_CURRENCY'
      , i_parent_id      => g_root_id
      , o_element_value  => l_write_off_currency
    );
    
    if l_write_off_currency is null then
        com_api_error_pkg.raise_error (
            i_error         => 'ABSENT_MANDATORY_ELEMENT'
            , i_env_param1  => 'WRITE_OFF_CURRENCY'
        );
    end if;

    begin
        select id
          into l_oper_id
          from opr_operation_vw
         where dispute_id = l_dispute_id
           and msg_type = l_message_type;
           
        com_api_error_pkg.raise_error (
            i_error         => 'DISPUTE_ALREADY_EXIST'
            , i_env_param1  => l_dispute_id
            , i_env_param2  => l_message_type
        );
    exception
        when no_data_found then
            select min(id)
              into l_original_id
              from opr_operation_vw
             where dispute_id = l_dispute_id;
    end;
    
    if l_original_id is null then
        com_api_error_pkg.raise_error (
            i_error         => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
            , i_env_param1  => l_dispute_id
        );
    end if;
    
    create_operation (
        i_original_id     => l_original_id
        , i_msg_type      => l_message_type
        , i_is_reversal   => com_api_const_pkg.FALSE
        , i_oper_amount   => l_write_off_amount
        , i_oper_currency => l_write_off_currency
        , io_oper_id      => l_oper_id
    );
    
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => g_root_id
          , i_element_name  => 'APPLICATION'
        );
end process_application;

procedure process(
    i_appl_id      in      com_api_type_pkg.t_long_id
) is
    l_appl_type            com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin

    trc_log_pkg.debug(
        i_text  => 'process_application start'
    );

    begin
        select appl_type
          into l_appl_type
          from app_application_vw
         where id = i_appl_id
           for update nowait;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'APPLICATION_NOT_FOUND'
              , i_env_param1    => i_appl_id
            );
        when com_api_error_pkg.e_resource_busy then
            com_api_error_pkg.raise_error(
                i_error         => 'APPLICATION_IN_PROCESS'
              , i_env_param1    => i_appl_id
            );
    end;

    app_api_application_pkg.get_appl_data(
        i_appl_id        => i_appl_id
    );

    prepare(
        i_appl_id        => i_appl_id
    );

    -- we fix deleting old error messages;
    savepoint sp_before_app_process;

    trc_log_pkg.set_object(
        i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id    => i_appl_id
    );

    begin
        if l_appl_type = app_api_const_pkg.APPL_TYPE_DISPUTE then
            process_application;
        else
            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'APPLICATION'
              , i_parent_id     => null
              , o_appl_data_id  => l_appl_data_id
            );

            app_api_error_pkg.raise_error(
                i_error         => 'UNKNOWN_APPLICATION_TYPE'
              , i_env_param1    => l_appl_type
              , i_element_name  => 'APPLICATION'
              , i_appl_data_id  => l_appl_data_id
            );
        end if;
    exception
        when com_api_error_pkg.e_stop_appl_processing then
            trc_log_pkg.debug('e_stop_appl_processing exception was handled');
    end;
    
    if app_api_error_pkg.g_app_errors.count > 0
    then
        -- we rollback changes, maded by app process package such as new contracts etc
        begin
            rollback to sp_before_app_process;
        exception
            when com_api_error_pkg.e_savepoint_never_established then
                rollback;
        end;

        app_api_error_pkg.add_errors_to_app_data;
    end if;

    com_api_sttl_day_pkg.unset_sysdate;

    trc_log_pkg.debug(
        i_text  => 'process_application finished'
    );

    trc_log_pkg.clear_object;
exception
    when others then
        app_api_error_pkg.add_errors_to_app_data;
        trc_log_pkg.debug(sqlerrm);
        begin
            rollback to sp_before_app_process;
        exception
            when com_api_error_pkg.e_savepoint_never_established then
                rollback;
        end;

        trc_log_pkg.clear_object;

        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
          , i_env_param2  => i_appl_id
        );
end process;

function get_dispute_inst_id(
    i_oper_id      in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_inst_id
is
    l_sttl_type            com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
begin
    select op.sttl_type
         , coalesce(
               (
                   select iss.inst_id
                     from com_array_element el
                    where el.array_id       = opr_api_const_pkg.STTL_TYPE_ISS_ARRAY_ID
                      and el.element_value  = op.sttl_type
                      and iss.inst_id      is not null
               )
             , (
                   select acq.inst_id
                     from com_array_element el
                    where el.array_id       = opr_api_const_pkg.STTL_TYPE_ACQ_ARRAY_ID
                      and el.element_value  = op.sttl_type
                      and acq.inst_id      is not null
               )
           ) as inst_id
      into l_sttl_type
         , l_inst_id
      from opr_operation op
         , opr_participant iss
         , opr_participant acq
     where op.id                   = i_oper_id
       and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
       and iss.oper_id(+)          = op.id
       and acq.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and acq.oper_id(+)          = op.id;

    if l_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'NON_CLASSIFIED_SETTLEMENT_TYPE'
          , i_env_param1  => l_sttl_type
          , i_env_param2  => i_oper_id
        );            
    end if;

    return l_inst_id;
end get_dispute_inst_id;

end dsp_ui_application_pkg;
/
