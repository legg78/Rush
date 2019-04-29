create or replace package body rcn_api_rule_proc_pkg is

procedure mirror_oper_cbs_recon is
    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_iss_participant               opr_api_type_pkg.t_oper_part_rec;
    l_msg_date                      date;
    l_msg_id                        com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_recon_type                    com_api_type_pkg.t_dict_value;
    l_amounts                       com_api_type_pkg.t_amount_by_name_tab;
    l_index                         com_api_type_pkg.t_oracle_name;
begin
    l_operation       := opr_api_shared_data_pkg.get_operation();
    l_iss_participant := opr_api_shared_data_pkg.get_participant(
                             i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
                         );
    l_msg_date        := com_api_sttl_day_pkg.get_sysdate();
    l_inst_id         := opr_api_shared_data_pkg.get_param_num('INST_ID');
    l_recon_type      := opr_api_shared_data_pkg.get_param_char('RECON_TYPE');

    l_msg_id          := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);
    l_amounts         := opr_api_shared_data_pkg.get_amounts();
            
    begin
        insert into rcn_cbs_msg (
            id
          , recon_type
          , msg_source
          , msg_date
          , oper_id
          , recon_msg_id
          , recon_status
          , recon_date
          , recon_inst_id
          , oper_type
          , msg_type
          , sttl_type
          , oper_date
          , oper_amount
          , oper_currency
          , oper_request_amount
          , oper_request_currency
          , oper_surcharge_amount
          , oper_surcharge_currency
          , originator_refnum
          , network_refnum
          , acq_inst_bin
          , status
          , is_reversal
          , merchant_number
          , mcc
          , merchant_name
          , merchant_street
          , merchant_city
          , merchant_region
          , merchant_country
          , merchant_postcode
          , terminal_type
          , terminal_number
          , acq_inst_id
          , card_mask
          , card_seq_number
          , card_expir_date
          , card_country
          , iss_inst_id
          , auth_code
        ) values (
            l_msg_id
          , l_recon_type
          , rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL
          , l_msg_date
          , l_operation.id
          , null
          , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
          , null
          , l_inst_id
          , l_operation.oper_type
          , l_operation.msg_type
          , l_operation.sttl_type
          , l_operation.oper_date --2017-06-30T10:10:00
          , l_operation.oper_amount
          , l_operation.oper_currency
          , l_operation.oper_request_amount
          , l_operation.oper_currency
          , l_operation.oper_surcharge_amount
          , l_operation.oper_currency
          , l_operation.originator_refnum
          , l_operation.network_refnum
          , l_operation.acq_inst_bin
          , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
          , l_operation.is_reversal
          , l_operation.merchant_number
          , l_operation.mcc
          , l_operation.merchant_name
          , l_operation.merchant_street
          , l_operation.merchant_city
          , l_operation.merchant_region
          , l_operation.merchant_country
          , l_operation.merchant_postcode
          , l_operation.terminal_type
          , l_operation.terminal_number
          , l_iss_participant.acq_inst_id
          , l_iss_participant.card_mask
          , l_iss_participant.card_seq_number
          , l_iss_participant.card_expir_date
          , l_iss_participant.card_country
          , l_iss_participant.inst_id
          , l_iss_participant.auth_code
        );
                
        insert into rcn_card (
            id
          , card_number
        ) values (
            l_msg_id
          , iss_api_token_pkg.encode_card_number(i_card_number => l_iss_participant.card_number)
        );

        trc_log_pkg.debug('rcn_api_rule_proc_pkg.mirror_oper_cbs_recon: l_amounts.count=' || l_amounts.count);

        if l_amounts.count > 0 then

            l_index := l_amounts.first;
            while l_index is not null
            loop
                if l_index like com_api_const_pkg.AMOUNT_PURPOSE_DICTIONARY || '%'
                   and l_index not in (com_api_const_pkg.AMOUNT_PURPOSE_DESTINATION, com_api_const_pkg.AMOUNT_PURPOSE_SOURCE)
                   and l_amounts(l_index).amount is not null
                then
                    begin
                        insert into rcn_additional_amount(
                            rcn_id
                          , rcn_type
                          , amount_type
                          , currency
                          , amount
                        ) values (
                            l_msg_id
                          , l_recon_type
                          , l_index
                          , l_amounts(l_index).currency
                          , l_amounts(l_index).amount
                        );
                    exception
                        when dup_val_on_index then
                            com_api_error_pkg.raise_error(
                                i_error      => 'Message parameter with rcn_id [#1], rcn_type [#2], amount_type [#3], '
                                             || 'currency [#4], amount [#5] already exists in reconciliation additional amount table'
                              , i_env_param1 => l_msg_id
                              , i_env_param2 => l_recon_type
                              , i_env_param3 => l_index
                              , i_env_param4 => l_amounts(l_index).currency
                              , i_env_param5 => l_amounts(l_index).amount
                            );
                    end;
                end if;

                l_index := l_amounts.next(l_index);

            end loop;

        end if;

    exception
        when dup_val_on_index then
            trc_log_pkg.debug(
                i_text => 'Message with oper_id [' || l_operation.id || '], already exists in reconciliation table'
            );
    end;

end mirror_oper_cbs_recon;

procedure mirror_oper_atm_recon is
    l_operation         opr_api_type_pkg.t_oper_rec;
    l_iss_participant   opr_api_type_pkg.t_oper_part_rec;
    l_acq_participant   opr_api_type_pkg.t_oper_part_rec;
    l_msg_date          date;
    l_msg_id            com_api_type_pkg.t_long_id;
    l_acq_inst_id       com_api_type_pkg.t_inst_id;
begin
    l_operation       := opr_api_shared_data_pkg.get_operation();

    l_iss_participant := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER);
    l_acq_participant := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ACQUIRER);

    l_msg_date        := com_api_sttl_day_pkg.get_sysdate();
    l_acq_inst_id     := l_acq_participant.inst_id;

    l_msg_id      := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);
            
    begin
        insert into rcn_atm_msg (
            id
          , msg_source
          , msg_date
          , operation_id
          , recon_msg_ref
          , recon_status
          , recon_last_date
          , recon_inst_id
          , oper_type
          , oper_date
          , oper_amount
          , oper_currency
          , trace_number
          , acq_inst_id
          , card_mask
          , auth_code
          , is_reversal
          , terminal_type
          , terminal_number
          , iss_fee
          , acc_from
          , acc_to
        ) values (
            l_msg_id
          , rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL
          , l_msg_date
          , l_operation.id
          , null -- recon_msg_ref
          , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
          , null  -- recon_last_date
          , l_acq_inst_id
          , l_operation.oper_type
          , l_operation.oper_date --2017-06-30T10:10:00
          , l_operation.oper_amount
          , l_operation.oper_currency
          , (select a.system_trace_audit_number from aut_auth a where a.id = l_operation.id)
          , l_acq_inst_id 
          , l_iss_participant.card_mask
          , l_iss_participant.auth_code
          , l_operation.is_reversal
          , l_operation.terminal_type
          , l_operation.terminal_number
          , (select min(o.fee_amount) from opr_operation o where o.id = l_operation.id)
          , (select min(v.tag_value) from aup_tag_value v where v.tag_id = aup_api_const_pkg.TAG_SOURCE_ACC and v.seq_number = 1)
          , (select min(v.tag_value) from aup_tag_value v where v.tag_id = aup_api_const_pkg.TAG_DESTINATION_ACC  and v.seq_number = 1)
        );

        insert into rcn_card (
            id
          , card_number
        ) values (
            l_msg_id
          , iss_api_token_pkg.encode_card_number(i_card_number => l_iss_participant.card_number)
        );
    exception
        when dup_val_on_index then
            trc_log_pkg.debug(
                i_text => 'Message with oper_id [' || l_operation.id || '], already exists in rcn_atm_msg table'
            );
    end;
end mirror_oper_atm_recon;

procedure mirror_oper_host_recon is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.mirror_oper_host_recon: ';
    l_operation             opr_api_type_pkg.t_oper_rec;
    l_iss_participant       opr_api_type_pkg.t_oper_part_rec;
    l_acq_participant       opr_api_type_pkg.t_oper_part_rec;
    l_msg_date              date;
    l_msg_id                com_api_type_pkg.t_long_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_recon_type            com_api_type_pkg.t_dict_value;
    l_forw_inst_code        com_api_type_pkg.t_cmid;
    l_receiv_inst_code      com_api_type_pkg.t_cmid;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_rcn_host_msg_rec      rcn_api_type_pkg.t_rcn_host_msg_rec;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_acq_host_id           com_api_type_pkg.t_inst_id;
    l_acq_network_id        com_api_type_pkg.t_network_id;
    l_acq_standard_id       com_api_type_pkg.t_tiny_id;
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_host_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_network_id;
    l_iss_standard_id       com_api_type_pkg.t_tiny_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    l_operation         := opr_api_shared_data_pkg.get_operation();
    l_iss_participant   := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER);
    l_acq_participant   := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ACQUIRER);

    l_inst_id           :=
        nvl(
            opr_api_shared_data_pkg.get_param_num(
                i_name       => 'INST_ID'
              , i_mask_error => com_api_type_pkg.TRUE
            )
          , opr_api_shared_data_pkg.g_iss_participant.inst_id
        );

    l_recon_type        :=
        nvl(
            opr_api_shared_data_pkg.get_param_char(
                i_name       => 'RECON_TYPE'
              , i_mask_error => com_api_type_pkg.TRUE
            )
          , rcn_api_const_pkg.RECON_TYPE_HOST
        );

    l_iss_inst_id       := l_inst_id;
    l_iss_network_id    := opr_api_shared_data_pkg.g_iss_participant.network_id;

    l_iss_host_id       :=
        net_api_network_pkg.get_host_id(
            i_inst_id       => l_iss_inst_id
          , i_network_id    => l_iss_network_id
        );

    l_iss_standard_id   :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_iss_host_id
        );

    l_receiv_inst_code  :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_iss_inst_id
          , i_standard_id   => l_iss_standard_id
          , i_object_id     => l_iss_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => h2h_api_const_pkg.H2H_INST_CODE
          , i_param_tab     => l_param_tab
        );

    l_acq_inst_id       := opr_api_shared_data_pkg.g_acq_participant.inst_id;
    l_acq_network_id    := opr_api_shared_data_pkg.g_acq_participant.network_id;

    l_acq_host_id       :=
        net_api_network_pkg.get_host_id(
            i_inst_id       => l_acq_inst_id
          , i_network_id    => l_acq_network_id
        );

    l_acq_standard_id       :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_acq_host_id
        );

    l_forw_inst_code    :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_acq_inst_id
          , i_standard_id   => l_acq_standard_id
          , i_object_id     => l_acq_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => h2h_api_const_pkg.H2H_INST_CODE
          , i_param_tab     => l_param_tab
        );

    l_msg_date   := com_api_sttl_day_pkg.get_sysdate();
    l_msg_id     := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

    emv_api_tag_pkg.parse_emv_data(
        i_emv_data          => opr_api_shared_data_pkg.g_auth.emv_data
      , o_emv_tag_tab       => l_emv_tag_tab
      , i_is_binary         => emv_api_tag_pkg.is_binary()
      , i_mask_error        => com_api_const_pkg.FALSE
    );

    trc_log_pkg.debug(
        LOG_PREFIX ||
        'l_iss_inst_id [' || l_iss_inst_id ||
        '], l_iss_host_id [' || l_iss_host_id ||
        '], l_iss_network_id [' || l_iss_network_id ||
        '], l_iss_standard_id [' || l_iss_standard_id ||
        '], l_receiv_inst_code [' || l_receiv_inst_code ||
        '], l_acq_inst_id [' || l_acq_inst_id ||
        '], l_acq_host_id [' || l_acq_host_id ||
        '], l_acq_network_id [' || l_acq_network_id ||
        '], l_acq_standard_id [' || l_acq_standard_id ||
        '], l_forw_inst_code [' || l_forw_inst_code ||
        '], l_emv_tag_tab.count [' || l_emv_tag_tab.count ||
        ']'
    );

    if l_emv_tag_tab.count > 0 then
        if l_emv_tag_tab.exists('5F2A') then
            l_rcn_host_msg_rec.emv_5f2a := l_emv_tag_tab('5F2A');
        end if;
        if l_emv_tag_tab.exists('5F34') then
            l_rcn_host_msg_rec.emv_5f34 := l_emv_tag_tab('5F34');
        end if;
        if l_emv_tag_tab.exists('71') then
            l_rcn_host_msg_rec.emv_71   := l_emv_tag_tab('71');
        end if;
        if l_emv_tag_tab.exists('72') then
            l_rcn_host_msg_rec.emv_72   := l_emv_tag_tab('72');
        end if;
        if l_emv_tag_tab.exists('82') then
            l_rcn_host_msg_rec.emv_82   := l_emv_tag_tab('82');
        end if;
        if l_emv_tag_tab.exists('84') then
            l_rcn_host_msg_rec.emv_84   := l_emv_tag_tab('84');
        end if;
        if l_emv_tag_tab.exists('8A') then
            l_rcn_host_msg_rec.emv_8a   := l_emv_tag_tab('8A');
        end if;
        if l_emv_tag_tab.exists('91') then
            l_rcn_host_msg_rec.emv_91   := l_emv_tag_tab('91');
        end if;
        if l_emv_tag_tab.exists('95') then
            l_rcn_host_msg_rec.emv_95   := l_emv_tag_tab('95');
        end if;
        if l_emv_tag_tab.exists('9A') then
            l_rcn_host_msg_rec.emv_9a   := l_emv_tag_tab('9A');
        end if;
        if l_emv_tag_tab.exists('9C') then
            l_rcn_host_msg_rec.emv_9c   := l_emv_tag_tab('9C');
        end if;
        if l_emv_tag_tab.exists('9F02') then
            l_rcn_host_msg_rec.emv_9f02 := l_emv_tag_tab('9F02');
        end if;
        if l_emv_tag_tab.exists('9F03') then
            l_rcn_host_msg_rec.emv_9f03 := l_emv_tag_tab('9F03');
        end if;
        if l_emv_tag_tab.exists('9F06') then
            l_rcn_host_msg_rec.emv_9f06 := l_emv_tag_tab('9F06');
        end if;
        if l_emv_tag_tab.exists('9F09') then
            l_rcn_host_msg_rec.emv_9f09 := l_emv_tag_tab('9F09');
        end if;
        if l_emv_tag_tab.exists('9F10') then
            l_rcn_host_msg_rec.emv_9f10 := l_emv_tag_tab('9F10');
        end if;
        if l_emv_tag_tab.exists('9F18') then
            l_rcn_host_msg_rec.emv_9f18 := l_emv_tag_tab('9F18');
        end if;
        if l_emv_tag_tab.exists('9F1A') then
            l_rcn_host_msg_rec.emv_9f1a := l_emv_tag_tab('9F1A');
        end if;
        if l_emv_tag_tab.exists('9F1E') then
            l_rcn_host_msg_rec.emv_9f1e := l_emv_tag_tab('9F1E');
        end if;
        if l_emv_tag_tab.exists('9F26') then
            l_rcn_host_msg_rec.emv_9f26 := l_emv_tag_tab('9F26');
        end if;
        if l_emv_tag_tab.exists('9F27') then
            l_rcn_host_msg_rec.emv_9f27 := l_emv_tag_tab('9F27');
        end if;
        if l_emv_tag_tab.exists('9F28') then
            l_rcn_host_msg_rec.emv_9f28 := l_emv_tag_tab('9F28');
        end if;
        if l_emv_tag_tab.exists('9F29') then
            l_rcn_host_msg_rec.emv_9f29 := l_emv_tag_tab('9F29');
        end if;
        if l_emv_tag_tab.exists('9F33') then
            l_rcn_host_msg_rec.emv_9f33 := l_emv_tag_tab('9F33');
        end if;
        if l_emv_tag_tab.exists('9F34') then
            l_rcn_host_msg_rec.emv_9f34 := l_emv_tag_tab('9F34');
        end if;
        if l_emv_tag_tab.exists('9F35') then
            l_rcn_host_msg_rec.emv_9f35 := l_emv_tag_tab('9F35');
        end if;
        if l_emv_tag_tab.exists('9F36') then
            l_rcn_host_msg_rec.emv_9f36 := l_emv_tag_tab('9F36');
        end if;
        if l_emv_tag_tab.exists('9F37') then
            l_rcn_host_msg_rec.emv_9f37 := l_emv_tag_tab('9F37');
        end if;
        if l_emv_tag_tab.exists('9F41') then
            l_rcn_host_msg_rec.emv_9f41 := l_emv_tag_tab('9F41');
        end if;
        if l_emv_tag_tab.exists('9F53') then
            l_rcn_host_msg_rec.emv_9f53 := l_emv_tag_tab('9F53');
        end if;
    end if;

    begin
        insert into rcn_host_msg(
            id
          , recon_type
          , msg_source
          , msg_date
          , oper_id
          , recon_msg_id
          , recon_status
          , recon_date
          , recon_inst_id
          , oper_type
          , msg_type
          , host_date
          , oper_date
          , oper_amount
          , oper_currency
          , oper_surcharge_amount
          , oper_surcharge_currency
          , status
          , is_reversal
          , merchant_number
          , mcc
          , merchant_name
          , merchant_street
          , merchant_city
          , merchant_region
          , merchant_country
          , merchant_postcode
          , terminal_type
          , terminal_number
          , acq_inst_id
          , card_mask
          , card_seq_number
          , card_expir_date
          , oper_cashback_amount
          , oper_cashback_currency
          , service_code
          , approval_code
          , rrn
          , trn
          , original_id
          , emv_5f2a
          , emv_5f34
          , emv_71
          , emv_72
          , emv_82
          , emv_84
          , emv_8a
          , emv_91
          , emv_95
          , emv_9a
          , emv_9c
          , emv_9f02
          , emv_9f03
          , emv_9f06
          , emv_9f09
          , emv_9f10
          , emv_9f18
          , emv_9f1a
          , emv_9f1e
          , emv_9f26
          , emv_9f27
          , emv_9f28
          , emv_9f29
          , emv_9f33
          , emv_9f34
          , emv_9f35
          , emv_9f36
          , emv_9f37
          , emv_9f41
          , emv_9f53
          , pdc_1
          , pdc_2
          , pdc_3
          , pdc_4
          , pdc_5
          , pdc_6
          , pdc_7
          , pdc_8
          , pdc_9
          , pdc_10
          , pdc_11
          , pdc_12
          , forw_inst_code
          , receiv_inst_code
          , sttl_date
          , oper_reason
        ) values (
            l_msg_id
          , l_recon_type
          , rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL  -- RMSC0000
          , l_msg_date
          , l_operation.id
          , null
          , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
          , null
          , l_inst_id
          , l_operation.oper_type
          , l_operation.msg_type
          , l_operation.host_date
          , l_operation.oper_date
          , l_operation.oper_amount
          , l_operation.oper_currency
          , l_operation.oper_surcharge_amount
          , l_operation.oper_currency
          , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
          , l_operation.is_reversal
          , l_operation.merchant_number
          , l_operation.mcc
          , l_operation.merchant_name
          , l_operation.merchant_street
          , l_operation.merchant_city
          , l_operation.merchant_region
          , l_operation.merchant_country
          , l_operation.merchant_postcode
          , l_operation.terminal_type
          , l_operation.terminal_number
          , l_acq_participant.inst_id
          , l_iss_participant.card_mask
          , l_iss_participant.card_seq_number
          , l_iss_participant.card_expir_date
          , l_operation.oper_cashback_amount
          , l_operation.oper_currency
          , opr_api_shared_data_pkg.g_auth.service_code
          , opr_api_shared_data_pkg.g_auth.auth_code            --approval_code
          , opr_api_shared_data_pkg.g_auth.originator_refnum    --rrn
          , null                                                --trn
          , opr_api_shared_data_pkg.g_auth.original_id
          , l_rcn_host_msg_rec.emv_5f2a
          , l_rcn_host_msg_rec.emv_5f34
          , l_rcn_host_msg_rec.emv_71
          , l_rcn_host_msg_rec.emv_72
          , l_rcn_host_msg_rec.emv_82
          , l_rcn_host_msg_rec.emv_84
          , l_rcn_host_msg_rec.emv_8a
          , l_rcn_host_msg_rec.emv_91
          , l_rcn_host_msg_rec.emv_95
          , l_rcn_host_msg_rec.emv_9a
          , l_rcn_host_msg_rec.emv_9c
          , l_rcn_host_msg_rec.emv_9f02
          , l_rcn_host_msg_rec.emv_9f03
          , l_rcn_host_msg_rec.emv_9f06
          , l_rcn_host_msg_rec.emv_9f09
          , l_rcn_host_msg_rec.emv_9f10
          , l_rcn_host_msg_rec.emv_9f18
          , l_rcn_host_msg_rec.emv_9f1a
          , l_rcn_host_msg_rec.emv_9f1e
          , l_rcn_host_msg_rec.emv_9f26
          , l_rcn_host_msg_rec.emv_9f27
          , l_rcn_host_msg_rec.emv_9f28
          , l_rcn_host_msg_rec.emv_9f29
          , l_rcn_host_msg_rec.emv_9f33
          , l_rcn_host_msg_rec.emv_9f34
          , l_rcn_host_msg_rec.emv_9f35
          , l_rcn_host_msg_rec.emv_9f36
          , l_rcn_host_msg_rec.emv_9f37
          , l_rcn_host_msg_rec.emv_9f41
          , l_rcn_host_msg_rec.emv_9f53
          , substr(opr_api_shared_data_pkg.g_auth.card_data_input_cap, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.crdh_auth_cap, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.card_capture_cap, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.terminal_operating_env, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.crdh_presence, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.card_presence, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.card_data_input_mode, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.crdh_auth_method, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.crdh_auth_entity, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.card_data_output_cap, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.terminal_output_cap, -1, 1)
          , substr(opr_api_shared_data_pkg.g_auth.pin_capture_cap, -1, 1)
          , l_forw_inst_code
          , l_receiv_inst_code
          , l_operation.sttl_date
          , l_operation.oper_reason
        );

        insert into rcn_card(
            id
          , card_number
        ) values (
            l_msg_id
          , iss_api_token_pkg.encode_card_number(i_card_number => l_iss_participant.card_number)
        );
    exception
        when dup_val_on_index then
            trc_log_pkg.debug(
                i_text => 'Message with oper_id [' || l_operation.id || '], already exists in rcn_host_msg'
            );
    end;
end mirror_oper_host_recon;

procedure mirror_order_srvp_recon
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.mirror_order_srvp_recon: ';
    l_operation            opr_api_type_pkg.t_oper_rec;
    l_msg_date             date;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_recon_type           com_api_type_pkg.t_dict_value;
    l_payment_order_rec    pmo_api_type_pkg.t_payment_order_rec;

    l_srvp_msg_id          com_api_type_pkg.t_long_id;
    l_srvp_data_id         com_api_type_pkg.t_long_id;

    l_provider_id          com_api_type_pkg.t_short_id;
    l_purpose_number       com_api_type_pkg.t_short_desc;
    l_provider_number      com_api_type_pkg.t_short_desc;
    l_customer_number      com_api_type_pkg.t_name;

    cursor cur_pmo_data(
        p_payment_order_id  in com_api_type_pkg.t_long_id
    ) is
    select od.id
         , od.order_id
         , od.param_id
         , od.param_value
         , od.purpose_id
         , od.direction
      from pmo_order_data od
     where od.order_id      = p_payment_order_id;

    l_pmo_data_rec         cur_pmo_data%rowtype;

begin
    l_operation  := opr_api_shared_data_pkg.get_operation();

    l_inst_id    := nvl(opr_api_shared_data_pkg.get_param_num(
                                 i_name       => 'INST_ID'
                               , i_mask_error => com_api_type_pkg.TRUE
                             )
                             , 1001
                         );
    l_recon_type := nvl(opr_api_shared_data_pkg.get_param_char(
                                 i_name       => 'RECON_TYPE'
                               , i_mask_error => com_api_type_pkg.TRUE
                             )
                           , rcn_api_const_pkg.RECON_TYPE_SRVP
                         );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' l_inst_id [' || l_inst_id ||
            '], l_recon_type [' || l_recon_type ||
            '], l_operation.payment_order_id [' || l_operation.payment_order_id ||
            ']'
    );

    l_payment_order_rec :=
        pmo_api_order_pkg.get_order(
            i_order_id          => l_operation.payment_order_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    l_msg_date      := com_api_sttl_day_pkg.get_sysdate();
    l_srvp_msg_id   := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

    l_customer_number :=
        prd_api_customer_pkg.get_customer_number(
            i_customer_id   => l_payment_order_rec.customer_id
          , i_inst_id       => l_payment_order_rec.inst_id
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    trc_log_pkg.debug(LOG_PREFIX || ' l_operation.id [' || l_operation.id
                                 || '], l_operation.payment_order_id [' || l_operation.payment_order_id
                                 || '], l_recon_type [' || l_recon_type
                                 || '], l_inst_id [' || l_inst_id 
                                 || '], l_customer_number [' || l_customer_number
                                 || ']');
    begin
        begin
            select pr.id                as provider_id
                 , p.purpose_number     as purpose_number
                 , pr.provider_number   as provider_number
              into l_provider_id
                 , l_purpose_number
                 , l_provider_number
              from pmo_purpose p
                 , pmo_provider pr
             where p.id                 = l_payment_order_rec.purpose_id
               and p.provider_id        = pr.id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'OBJECT_NOT_FOUND'
                  , i_env_param1 => 'Purpose'
                  , i_env_param2 => l_payment_order_rec.purpose_id
                );
        end;

        insert into rcn_srvp_msg(
            id
          , recon_type
          , msg_source
          , recon_status
          , msg_date
          , recon_date
          , inst_id
          , split_hash
          , order_id
          , recon_msg_id
          , payment_order_number
          , order_date
          , order_amount
          , order_currency
          , customer_id
          , customer_number
          , purpose_id
          , purpose_number
          , provider_id
          , provider_number
          , order_status
        ) values (
            l_srvp_msg_id
          , l_recon_type
          , rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL
          , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
          , l_msg_date
          , null
          , l_payment_order_rec.inst_id
          , l_payment_order_rec.split_hash
          , l_payment_order_rec.id
          , null 
          , l_payment_order_rec.payment_order_number
          , l_payment_order_rec.event_date
          , l_payment_order_rec.amount
          , l_payment_order_rec.currency
          , l_payment_order_rec.customer_id
          , l_customer_number
          , l_payment_order_rec.purpose_id
          , l_purpose_number
          , l_provider_id
          , l_provider_number
          , l_payment_order_rec.status
        );

        begin
            open cur_pmo_data(
                p_payment_order_id   => l_payment_order_rec.id
            );
            loop
                fetch cur_pmo_data into l_pmo_data_rec;
                    exit when cur_pmo_data%notfound;

                    l_srvp_data_id  := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

                    insert into rcn_srvp_data(
                        id
                      , msg_id
                      , purpose_id
                      , param_id
                      , param_value
                    ) values (
                        l_srvp_data_id
                      , l_srvp_msg_id
                      , l_pmo_data_rec.purpose_id
                      , l_pmo_data_rec.param_id
                      , l_pmo_data_rec.param_value
                    );
            end loop;
            close cur_pmo_data;
        exception
        when dup_val_on_index then
            trc_log_pkg.debug(
                i_text => 'Message with l_pmo_data_rec.purpose_id [' || l_pmo_data_rec.purpose_id || 
                    '], l_pmo_data_rec.param_id [' || l_pmo_data_rec.param_id || 
                    '] already exists in rcn_srvp_data table'
            );
        end;

    exception
        when dup_val_on_index then
            trc_log_pkg.debug(
                i_text => 'Message with order_id [' || l_payment_order_rec.id || '], already exists in rcn_srvp_msg table'
            );
    end;

end mirror_order_srvp_recon;

end rcn_api_rule_proc_pkg;
/
