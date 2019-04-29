create or replace package body orq_api_application_pkg as

procedure process_request(
    i_appl_id          in     com_api_type_pkg.t_long_id    default null
) is
    l_root_id                 com_api_type_pkg.t_long_id;
    l_appl_id                 com_api_type_pkg.t_long_id;
    l_flow_id                 com_api_type_pkg.t_medium_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_match_id                com_api_type_pkg.t_long_id;
    l_source_operation        opr_api_type_pkg.t_oper_rec;

    l_local_root_id           com_api_type_pkg.t_long_id;
    l_participant_tab         com_api_type_pkg.t_number_tab;
    l_param_tab               com_param_map_tpt;
    l_gen_rule                com_api_type_pkg.t_name;
    l_skip_processing         com_api_type_pkg.t_boolean;
    l_sess_file_id            com_api_type_pkg.t_long_id;
    l_oper_id_tab             num_tab_tpt := new num_tab_tpt();

    function get_element_v(
        i_element_name  in     com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_full_desc is
    begin
        return app_api_application_pkg.get_element_value_v(
                   i_element_name => i_element_name
                 , i_parent_id    => l_local_root_id
               );
    end;

    function get_element_n(
        i_element_name  in     com_api_type_pkg.t_name
    ) return number is
    begin
        return app_api_application_pkg.get_element_value_n(
                   i_element_name => i_element_name
                 , i_parent_id    => l_local_root_id
               );
    end;

    function get_element_d(
        i_element_name  in     com_api_type_pkg.t_name
    ) return date is
    begin
        return app_api_application_pkg.get_element_value_d(
                   i_element_name => i_element_name
                 , i_parent_id    => l_local_root_id
               );
    end;

    function is_operation_successful(
        i_oper_status   in  com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
        l_result           com_api_type_pkg.t_boolean;
    begin
        if i_oper_status is not null then
            if i_oper_status = opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED or
               i_oper_status = opr_api_const_pkg.OPERATION_STATUS_UNHOLDED or
               i_oper_status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED or
               i_oper_status = opr_api_const_pkg.OPERATION_STATUS_CORRECTED or
               i_oper_status = opr_api_const_pkg.OPERATION_STATUS_MERGED
            then
                l_result := com_api_const_pkg.TRUE;
            else
                l_result := com_api_const_pkg.FALSE;
            end if;
        else
            l_result := com_api_const_pkg.FALSE;
        end if;
        return l_result;
    end;

    procedure operation_status(
        i_oper_id       in     com_api_type_pkg.t_long_id
      , i_appl_id       in     com_api_type_pkg.t_long_id
    ) is
        l_operation            opr_api_type_pkg.t_oper_rec;
        l_old_appl_status      com_api_type_pkg.t_dict_value;
        l_new_appl_status      com_api_type_pkg.t_dict_value;
        l_old_reject_code      com_api_type_pkg.t_dict_value;
        l_new_reject_code      com_api_type_pkg.t_dict_value;
    begin
        opr_api_operation_pkg.get_operation(
            i_oper_id     => i_oper_id
          , o_operation   => l_operation
        );

        if is_operation_successful(i_oper_status => l_operation.status) = com_api_const_pkg.TRUE then
            l_new_appl_status := app_api_const_pkg.APPL_STATUS_ACCEPTED;
        else
            l_new_appl_status := app_api_const_pkg.APPL_STATUS_REJECTED;
            l_new_reject_code := l_operation.status_reason;
        end if;

        select a.appl_status
             , a.reject_code
          into l_old_appl_status
             , l_old_reject_code
          from app_application a
         where a.id = i_appl_id;

        update app_application
           set appl_status = l_new_appl_status
             , reject_code = l_new_reject_code
        where id = i_appl_id;

        app_api_history_pkg.add_history (
            i_appl_id         => i_appl_id
          , i_action          => app_api_const_pkg.APPL_ACTION_STATUS_CHANGE
          , i_comments        => com_api_dictionary_pkg.get_article_text(
                                     i_article    => l_new_reject_code
                                   , i_lang       => get_user_lang
                                 )
          , i_new_appl_status => l_new_appl_status
          , i_old_appl_status => l_old_appl_status
          , i_new_reject_code => l_new_reject_code
          , i_old_reject_code => l_old_reject_code
        );
    end operation_status;

    procedure process_aup_tags(
        i_oper_id       in     com_api_type_pkg.t_long_id
      , i_parent_id     in     com_api_type_pkg.t_long_id
    ) is
        l_tags_data_id         com_api_type_pkg.t_long_id;
        l_aup_tag_id_tab       com_api_type_pkg.t_number_tab;
        l_aup_tag_tab          aup_api_type_pkg.t_aup_tag_tab;
    begin
        app_api_application_pkg.get_appl_data_id(
            i_element_name   => 'TAGS'
          , i_parent_id      => i_parent_id
          , o_appl_data_id   => l_tags_data_id
        );

        if l_tags_data_id is not null then
            app_api_application_pkg.get_appl_data_id(
                i_element_name   => 'AUP_TAG'
              , i_parent_id      => l_tags_data_id
              , o_appl_data_id   => l_aup_tag_id_tab
            );

            if l_aup_tag_id_tab.count > 0 then
                for x in l_aup_tag_id_tab.first .. l_aup_tag_id_tab.last loop
                    l_aup_tag_tab(x).tag_id :=
                        aup_api_tag_pkg.find_tag_by_reference(
                            i_reference => 
                                app_api_application_pkg.get_element_value_v(
                                    i_element_name => 'TAG'
                                  , i_parent_id    => l_aup_tag_id_tab(x)
                                )
                        );

                    l_aup_tag_tab(x).tag_value :=
                        app_api_application_pkg.get_element_value_v(
                            i_element_name => 'TAG_VALUE'
                          , i_parent_id    => l_aup_tag_id_tab(x)
                        );

                    l_aup_tag_tab(x).seq_number := 1;
                end loop;
            end if;

            aup_api_tag_pkg.save_tag(
                i_auth_id => i_oper_id
              , i_tags    => l_aup_tag_tab
            );
        end if;
    end process_aup_tags;

begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    l_local_root_id   := l_root_id;
    l_flow_id         := get_element_n(i_element_name => 'APPLICATION_FLOW_ID');
    l_skip_processing := get_element_n(i_element_name => 'SKIP_PROCESS_OPER');
    l_sess_file_id    := get_element_n(i_element_name => 'SESSION_FILE_ID');

    if i_appl_id is null then
        l_appl_id := get_element_n(i_element_name => 'APPLICATION_ID');
    else
        l_appl_id := i_appl_id;
    end if;

    app_api_application_pkg.get_appl_data_id(
        i_element_name   =>  'OPERATION'
      , i_parent_id      =>  l_root_id
      , o_appl_data_id   =>  l_local_root_id
    );

    l_oper_id := get_element_n(i_element_name => 'OPERATION_ID');

    if l_oper_id is not null then
        process_aup_tags(
            i_oper_id    => l_oper_id
          , i_parent_id  => l_local_root_id
        );
    end if;

    if l_flow_id = orq_api_const_pkg.FLOW_ID_UNHOLD_APP then
        opr_api_operation_pkg.get_operation(
            i_oper_id     => l_oper_id
          , o_operation   => l_source_operation
        );

        if l_source_operation.status = opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD then
            aut_api_process_pkg.unhold(
                i_id      => l_oper_id
              , i_reason  => get_element_v(i_element_name => 'OPER_REASON')
            );

        elsif l_source_operation.status = opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD then
            aut_api_process_pkg.unhold_partial(
                i_id      => l_oper_id
              , i_reason  => get_element_v(i_element_name => 'OPER_REASON')
            );

        end if;

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_REPROCESS_OPER then
        opr_ui_operation_pkg.modify_status(
            i_oper_id           => l_oper_id
          , i_oper_status       => get_element_v(i_element_name => 'OPER_STATUS')
          , i_forced_processing => com_api_const_pkg.FALSE
        );
        app_api_application_pkg.get_appl_data_id(
            i_element_name   =>  'PARTICIPANT'
          , i_parent_id      =>  l_local_root_id
          , o_appl_data_id   =>  l_participant_tab
        );

        if l_participant_tab is not null then
            for i in 1 .. l_participant_tab.count() loop
                l_local_root_id := l_participant_tab(i);

                opr_ui_operation_pkg.update_participant(
                    i_oper_id           =>  l_oper_id
                  , i_participant_type  =>  get_element_v(i_element_name => 'PARTICIPANT_TYPE')
                  , i_split_hash        =>  get_element_n(i_element_name => 'SPLIT_HASH')
                  , i_inst_id           =>  get_element_n(i_element_name => 'INSTITUTION_ID')
                  , i_network_id        =>  get_element_n(i_element_name => 'NETWORK_ID')
                  , i_card_inst_id      =>  get_element_n(i_element_name => 'CARD_INSTITUTION_ID')
                  , i_card_network_id   =>  get_element_n(i_element_name => 'CARD_NETWORK_ID')
                  , i_card_id           =>  to_number(get_element_v(i_element_name => 'CARD_ID'), com_api_const_pkg.XML_NUMBER_FORMAT)
                  , i_card_instance_id  =>  get_element_n(i_element_name => 'CARD_INSTANCE_ID')
                  , i_card_type_id      =>  get_element_n(i_element_name => 'CARD_TYPE')
                  , i_card_mask         =>  get_element_v(i_element_name => 'CARD_MASK')
                  , i_card_hash         =>  get_element_n(i_element_name => 'CARD_HASH')
                  , i_card_seq_number   =>  get_element_n(i_element_name => 'SEQUENTIAL_NUMBER')
                  , i_card_expir_date   =>  get_element_d(i_element_name => 'EXPIRATION_DATE')
                  , i_card_service_code =>  null
                  , i_card_country      =>  get_element_v(i_element_name => 'COUNTRY')
                  , i_customer_id       =>  get_element_n(i_element_name => 'CUSTOMER_ID')
                  , i_account_id        =>  get_element_n(i_element_name => 'ACCOUNT_ID')
                  , i_merchant_id       =>  get_element_n(i_element_name => 'MERCHANT_ID')
                  , i_terminal_id       =>  get_element_n(i_element_name => 'TERMINAL_ID')
                  , i_client_id_type    =>  get_element_v(i_element_name => 'CLIENT_ID_TYPE')
                  , i_client_id_value   =>  get_element_v(i_element_name => 'CLIENT_ID_VALUE')
                  , i_account_type      =>  get_element_v(i_element_name => 'ACCOUNT_TYPE')
                  , i_account_number    =>  get_element_v(i_element_name => 'ACCOUNT_NUMBER')
                  , i_account_amount    =>  get_element_n(i_element_name => 'AVAILABLE_BALANCE')
                  , i_account_currency  =>  get_element_v(i_element_name => 'CURRENCY')
                  , i_auth_code         =>  get_element_v(i_element_name => 'AUTH_CODE')
                  , i_card_number       =>  get_element_v(i_element_name => 'CARD_NUMBER')
                );
            end loop;
        end if;

        l_param_tab := com_param_map_tpt();
        l_param_tab.extend(1);
        l_param_tab(1) := com_param_map_tpr('INITIATOR', evt_api_const_pkg.INITIATOR_OPERATOR, null, null, null);

        if nvl(l_skip_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            opr_api_process_pkg.process_operation(
                i_operation_id   =>  l_oper_id
              , i_stage          =>  opr_api_const_pkg.PROCESSING_STAGE_COMMON
              , i_mask_error     =>  null
              , i_param_tab      =>  l_param_tab
            );
        end if;

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_CHANGE_OPER_STATUS then
        opr_ui_operation_pkg.modify_statuses(
            i_session_id         => get_element_n(i_element_name => 'SESSION_ID')
          , i_incom_sess_file_id => l_sess_file_id
          , i_host_date_from     => trunc(get_element_d(i_element_name => 'HOST_DATE_FROM'), 'DD')
          , i_host_date_to       => trunc(get_element_d(i_element_name => 'HOST_DATE_TO'), 'DD') + 1 - 1/86400
          , i_msg_type           => get_element_v(i_element_name => 'MESSAGE_TYPE')
          , i_sttl_type          => get_element_v(i_element_name => 'STTL_TYPE')
          , i_is_reversal        => get_element_n(i_element_name => 'IS_REVERSAL')
          , i_oper_currency      => get_element_v(i_element_name => 'OPER_CURRENCY')
          , i_oper_type          => get_element_v(i_element_name => 'OPERATION_TYPE')
          , i_oper_status        => get_element_v(i_element_name => 'OPER_STATUS')
          , i_new_status         => get_element_v(i_element_name => 'OPER_STATUS_NEW')
          , i_oper_id            => l_oper_id
          , i_oper_reason        => get_element_v(i_element_name => 'OPER_REASON')
        );

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_MATCH_OPER_MANUALLY then
        l_match_id :=
            app_api_application_pkg.get_element_value_n(
                i_element_name => 'MATCH_ID'
              , i_parent_id    => l_root_id
            );

        opr_ui_operation_pkg.match_operations(
            i_orig_oper_id => l_oper_id
          , i_pres_oper_id => l_match_id
        );

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_MATCH_REVERSAL_OPER then
        l_match_id := app_api_application_pkg.get_element_value_n(
                          i_element_name => 'MATCH_ID'
                        , i_parent_id    => l_root_id
                      );
        opr_ui_operation_pkg.match_operation_reversal(
            i_orig_oper_id     => l_oper_id
          , i_reversal_oper_id => l_match_id
        );

    elsif l_flow_id in (orq_api_const_pkg.FLOW_ID_BALANCE_CORRECTION
                      , orq_api_const_pkg.FLOW_ID_BALANCE_TRANSFER
                      , orq_api_const_pkg.FLOW_ID_COMMON_OPERATION
                      , orq_api_const_pkg.FLOW_ID_DISPUTE_WRITE_OFF)
    then
        l_oper_id := null;

        opr_api_create_pkg.create_operation(
            io_oper_id                 =>  l_oper_id
          , i_session_id               =>  get_element_n(i_element_name => 'SESSION_ID')
          , i_is_reversal              =>  get_element_n(i_element_name => 'IS_REVERSAL')
          , i_original_id              =>  get_element_n(i_element_name => 'ORIGINAL_ID')
          , i_oper_type                =>  get_element_v(i_element_name => 'OPERATION_TYPE')
          , i_oper_reason              =>  get_element_v(i_element_name => 'OPER_REASON')
          , i_msg_type                 =>  get_element_v(i_element_name => 'MESSAGE_TYPE')
          , i_status                   =>  get_element_v(i_element_name => 'OPER_STATUS')
          , i_status_reason            =>  get_element_v(i_element_name => 'STATUS_REASON')
          , i_sttl_type                =>  get_element_v(i_element_name => 'STTL_TYPE')
          , i_terminal_type            =>  get_element_v(i_element_name => 'TERMINAL_TYPE')
          , i_acq_inst_bin             =>  get_element_v(i_element_name => 'ACQUIRER_INST_BIN')
          , i_forw_inst_bin            =>  get_element_n(i_element_name => 'FORW_INST_BIN')
          , i_merchant_number          =>  get_element_v(i_element_name => 'MERCHANT_NUMBER')
          , i_terminal_number          =>  get_element_v(i_element_name => 'TERMINAL_NUMBER')
          , i_merchant_name            =>  get_element_v(i_element_name => 'MERCHANT_NAME')
          , i_merchant_street          =>  get_element_v(i_element_name => 'MERCHANT_STREET')
          , i_merchant_city            =>  get_element_v(i_element_name => 'MERCHANT_CITY')
          , i_merchant_region          =>  get_element_v(i_element_name => 'MERCHANT_REGION')
          , i_merchant_country         =>  get_element_v(i_element_name => 'MERCHANT_COUNTRY')
          , i_merchant_postcode        =>  get_element_v(i_element_name => 'MERCHANT_POSTCODE')
          , i_mcc                      =>  get_element_v(i_element_name => 'MCC')
          , i_originator_refnum        =>  get_element_v(i_element_name => 'ORIGINATOR_REFNUM')
          , i_network_refnum           =>  get_element_v(i_element_name => 'NETWORK_REFNUM')
          , i_oper_count               =>  get_element_n(i_element_name => 'OPER_COUNT')
          , i_oper_request_amount      =>  get_element_n(i_element_name => 'OPER_REQUEST_AMOUNT')
          , i_oper_amount_algorithm    =>  opr_api_const_pkg.OPER_AMOUNT_ALG_REQUESTED
          , i_oper_amount              =>  get_element_n(i_element_name => 'OPER_AMOUNT')
          , i_oper_currency            =>  get_element_v(i_element_name => 'OPER_CURRENCY')
          , i_oper_cashback_amount     =>  get_element_n(i_element_name => 'OPER_CASHBACK_AMOUNT')
          , i_oper_replacement_amount  =>  get_element_n(i_element_name => 'OPER_REPLACEMENT_AMOUNT')
          , i_oper_surcharge_amount    =>  get_element_n(i_element_name => 'OPER_SURCHARGE_AMOUNT')
          , i_oper_date                =>  get_element_d(i_element_name => 'OPER_DATE')
          , i_host_date                =>  get_element_d(i_element_name => 'HOST_DATE')
          , i_match_status             =>  get_element_v(i_element_name => 'MATCH_STATUS')
          , i_sttl_amount              =>  get_element_n(i_element_name => 'STTL_AMOUNT')
          , i_sttl_currency            =>  get_element_v(i_element_name => 'STTL_CURRENCY')
          , i_dispute_id               =>  get_element_n(i_element_name => 'DISPUTE_ID')
          , i_payment_order_id         =>  null
          , i_payment_host_id          =>  null
          , i_forced_processing        =>  com_api_const_pkg.FALSE
        );

        process_aup_tags(
            i_oper_id       => l_oper_id
          , i_parent_id     => l_local_root_id
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'PARTICIPANT'
          , i_parent_id     => l_local_root_id
          , o_appl_data_id  => l_participant_tab
        );

        if l_participant_tab is not null then
            for i in 1 .. l_participant_tab.count() loop
                l_local_root_id := l_participant_tab(i);

                opr_api_create_pkg.add_participant(
                    i_oper_id            =>  l_oper_id
                  , i_msg_type           =>  get_element_v(i_element_name => 'MESSAGE_TYPE')
                  , i_oper_type          =>  get_element_v(i_element_name => 'OPERATION_TYPE')
                  , i_participant_type   =>  get_element_v(i_element_name => 'PARTICIPANT_TYPE')
                  , i_host_date          =>  get_element_d(i_element_name => 'HOST_DATE')
                  , i_client_id_type     =>  get_element_v(i_element_name => 'CLIENT_ID_TYPE')
                  , i_client_id_value    =>  get_element_v(i_element_name => 'CLIENT_ID_VALUE')
                  , i_inst_id            =>  get_element_n(i_element_name => 'INSTITUTION_ID')
                  , i_network_id         =>  get_element_n(i_element_name => 'NETWORK_ID')
                  , i_card_inst_id       =>  get_element_n(i_element_name => 'CARD_INSTITUTION_ID')
                  , i_card_network_id    =>  get_element_n(i_element_name => 'CARD_NETWORK_ID')
                  , i_card_id            =>  to_number(
                                                 get_element_v(i_element_name => 'CARD_ID')
                                               , com_api_const_pkg.XML_NUMBER_FORMAT
                                             )
                  , i_card_instance_id   =>  get_element_n(i_element_name => 'CARD_INSTANCE_ID')
                  , i_card_type_id       =>  get_element_n(i_element_name => 'CARD_TYPE')
                  , i_card_number        =>  get_element_v(i_element_name => 'CARD_NUMBER')
                  , i_card_mask          =>  get_element_v(i_element_name => 'CARD_MASK')
                  , i_card_hash          =>  get_element_n(i_element_name => 'CARD_HASH')
                  , i_card_seq_number    =>  get_element_n(i_element_name => 'SEQUENTIAL_NUMBER')
                  , i_card_expir_date    =>  get_element_d(i_element_name => 'EXPIRATION_DATE')
                  , i_card_country       =>  get_element_v(i_element_name => 'COUNTRY')
                  , i_customer_id        =>  get_element_n(i_element_name => 'CUSTOMER_ID')
                  , i_account_id         =>  get_element_n(i_element_name => 'ACCOUNT_ID')
                  , i_account_type       =>  get_element_v(i_element_name => 'ACCOUNT_TYPE')
                  , i_account_number     =>  get_element_v(i_element_name => 'ACCOUNT_NUMBER')
                  , i_account_amount     =>  get_element_n(i_element_name => 'AVAILABLE_BALANCE')
                  , i_account_currency   =>  get_element_v(i_element_name => 'CURRENCY')
                  , i_split_hash         =>  get_element_n(i_element_name => 'SPLIT_HASH')
                  , i_without_checks     =>  com_api_const_pkg.TRUE
                  , i_merchant_number    =>  get_element_v(i_element_name => 'MERCHANT_NUMBER')
                  , i_merchant_id        =>  get_element_n(i_element_name => 'MERCHANT_ID')
                );
            end loop;
        end if;

        app_api_application_pkg.get_appl_data_id(
            i_element_name   =>  'OPERATION'
          , i_parent_id      =>  l_root_id
          , o_appl_data_id   =>  l_local_root_id
        );

        l_param_tab    := com_param_map_tpt();
        l_param_tab.extend(1);
        l_param_tab(1) := com_param_map_tpr('INITIATOR', evt_api_const_pkg.INITIATOR_OPERATOR, null, null, null);

        if nvl(l_skip_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            opr_api_process_pkg.process_operation(
                i_operation_id   => l_oper_id
              , i_stage          => opr_api_const_pkg.PROCESSING_STAGE_COMMON
              , i_mask_error     => null
              , i_param_tab      => l_param_tab
            );
        end if;

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_FEE_COLLECTION then

        if get_element_n(i_element_name => 'CARD_NETWORK_ID') = mcw_api_const_pkg.MCW_NETWORK_ID then
            -- Add the ipm_data
            l_param_tab := com_param_map_tpt();
            l_param_tab.extend(11);
            l_param_tab( 1) := com_param_map_tpr('MESSAGE_TYPE'      , get_element_v('mti')    , null, null, null);
            l_param_tab( 2) := com_param_map_tpr('DE_024'            , get_element_v('de024')  , null, null, null);
            l_param_tab( 3) := com_param_map_tpr('DE_002'            , get_element_v('de002')  , null, null, null);
            l_param_tab( 4) := com_param_map_tpr('DE_003_1'          , get_element_v('de003_1'), null, null, null);
            l_param_tab( 5) := com_param_map_tpr('DE_004'      , null, get_element_n('de004')  , null, null);
            l_param_tab( 6) := com_param_map_tpr('DE_025'            , get_element_v('de025')  , null, null, null);
            l_param_tab( 7) := com_param_map_tpr('DE_049'            , get_element_v('de049')  , null, null, null);
            l_param_tab( 8) := com_param_map_tpr('DE_072'            , get_element_v('de072')  , null, null, null);
            l_param_tab( 9) := com_param_map_tpr('DE_073', null, null, get_element_d('de073')  , null);
            l_param_tab(10) := com_param_map_tpr('DE_093'            , get_element_v('de093')  , null, null, null);
            l_param_tab(11) := com_param_map_tpr('DE_094'            , get_element_v('de094')  , null, null, null);

            l_gen_rule := orq_api_const_pkg.RUL_GEN_MEMBER_FEE;

        elsif get_element_n(i_element_name => 'CARD_NETWORK_ID') = vis_api_const_pkg.VISA_NETWORK_ID then
            -- Add baseII_data
            l_param_tab := com_param_map_tpt();
            l_param_tab.extend(10);
            l_param_tab( 1) := com_param_map_tpr('TRANSACTION_CODE'      , get_element_v('trans_code')     , null, null, null);
            l_param_tab( 2) := com_param_map_tpr('CARD_NUMBER'           , get_element_v('card_number')    , null, null, null);
            l_param_tab( 3) := com_param_map_tpr('OPER_AMOUNT'     , null, get_element_n('oper_amount')    , null, null);
            l_param_tab( 4) := com_param_map_tpr('OPER_CURRENCY'         , get_element_v('oper_currency')  , null, null, null);
            l_param_tab( 5) := com_param_map_tpr('EVENT_DATE', null, null, get_element_d('event_date')     , null);
            l_param_tab( 6) := com_param_map_tpr('COUNTRY'               , get_element_v('country')        , null, null, null);
            l_param_tab( 7) := com_param_map_tpr('REASON_CODE'           , get_element_v('reason_code')    , null, null, null);
            l_param_tab( 8) := com_param_map_tpr('SOURCE_BIN'            , get_element_v('source_bin')     , null, null, null);
            l_param_tab( 9) := com_param_map_tpr('DESTIN_BIN'            , get_element_v('destin_bin')     , null, null, null);
            l_param_tab(10) := com_param_map_tpr('MEMBER_MESSAGE_TEXT'   , get_element_v('member_msg_text'), null, null, null);

            l_gen_rule := orq_api_const_pkg.RUL_GEN_FEE_COLLECTION;

        end if;

        dsp_ui_process_pkg.exec_dispute(
            i_oper_id    => null
          , i_init_rule  => null
          , i_gen_rule   => l_gen_rule
          , i_param_map  => l_param_tab
          , i_is_editing => com_api_const_pkg.FALSE
        );

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_SET_OPER_STAGE then
        opr_api_create_pkg.set_oper_stage(
            i_oper_id          => l_oper_id
          , i_external_auth_id => get_element_n(i_element_name => 'EXTERNAL_AUTH_ID')
          , i_is_reversal      => get_element_n(i_element_name => 'IS_REVERSAL')
          , i_command          => get_element_v(i_element_name => 'COMMAND')
        );

    elsif l_flow_id = orq_api_const_pkg.FLOW_ID_LTY_SPENT_OPERATION then
        app_api_application_pkg.get_element_value(
            i_element_name  => 'LOYALTY_OPERATION_ID'
          , i_parent_id     => l_local_root_id
          , o_element_value => l_oper_id_tab
        );

        lty_api_acq_operation_pkg.add_spent_operation(
            i_oper_id_tab     => l_oper_id_tab
          , i_spent_operation => l_oper_id
        );

    else
        com_api_error_pkg.raise_error(
            i_error      => 'APPLICATION_FLOW_NOT_FOUND'
          , i_env_param1 => l_flow_id
        );
    end if;

    if l_oper_id is not null then
        app_api_appl_object_pkg.add_object(
            i_appl_id       => l_appl_id
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     => l_oper_id
          , i_seqnum        => 1
        );
    end if;

    if l_flow_id != orq_api_const_pkg.FLOW_ID_FEE_COLLECTION then
        operation_status(
            i_oper_id => l_oper_id
          , i_appl_id => l_appl_id
        );
    end if;

    commit; -- We commit the creation of new operation to see it in GUI in case of automatic processing failure

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
end process_request;

end orq_api_application_pkg;
/
