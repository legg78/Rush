create or replace package body h2h_api_rule_proc_pkg is
/*********************************************************
 *  Host-to-host processing rules  <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure init_fin_message(
    io_h2h_fin_msg_rec      in out  h2h_api_type_pkg.t_h2h_fin_message_rec
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_network_id            in      com_api_type_pkg.t_network_id   default null
  , o_standard_version         out  com_api_type_pkg.t_tiny_id
) is
    l_acq_inst_id               com_api_type_pkg.t_inst_id;
    l_iss_inst_id               com_api_type_pkg.t_inst_id;
    l_host_id                   com_api_type_pkg.t_inst_id;
    l_network_id                com_api_type_pkg.t_network_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_forw_inst_code            com_api_type_pkg.t_cmid;
    l_receiv_inst_code          com_api_type_pkg.t_cmid;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_operation                 opr_api_type_pkg.t_oper_rec;
begin
    l_network_id := nvl(i_network_id, opr_api_shared_data_pkg.g_iss_participant.network_id);

    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id    => l_network_id
        );

    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );

    o_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id    => l_network_id
        );

    l_acq_inst_id :=
        nvl(
            opr_api_shared_data_pkg.get_param_num(
                i_name          => 'ACQ_INST_ID'
              , i_mask_error    => com_api_const_pkg.TRUE
              , i_error_value   => null
            )
          , opr_api_shared_data_pkg.g_acq_participant.inst_id
        );

    l_iss_inst_id :=
        nvl(
            i_iss_inst_id
          , opr_api_shared_data_pkg.g_iss_participant.inst_id
        );

    l_forw_inst_code :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_acq_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => h2h_api_const_pkg.H2H_INST_CODE
          , i_param_tab     => l_param_tab
        );

    if l_forw_inst_code is null then
        com_api_error_pkg.raise_error(
            i_error         => 'STANDARD_PARAM_NOT_FOUND'
          , i_env_param1    => h2h_api_const_pkg.H2H_INST_CODE
          , i_env_param2    => l_acq_inst_id
          , i_env_param3    => l_standard_id
          , i_env_param4    => l_host_id
        );
    end if;

    l_receiv_inst_code :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_iss_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => h2h_api_const_pkg.H2H_INST_CODE
          , i_param_tab     => l_param_tab
        );

    if l_receiv_inst_code is null then
        com_api_error_pkg.raise_error(
            i_error         => 'STANDARD_PARAM_NOT_FOUND'
          , i_env_param1    => h2h_api_const_pkg.H2H_INST_CODE
          , i_env_param2    => l_iss_inst_id
          , i_env_param3    => l_standard_id
          , i_env_param4    => l_host_id
        );
    end if;

    l_operation := opr_api_shared_data_pkg.get_operation();

    io_h2h_fin_msg_rec.inst_id              := l_iss_inst_id;
    io_h2h_fin_msg_rec.network_id           := l_network_id;
    io_h2h_fin_msg_rec.is_incoming          := com_api_const_pkg.FALSE;
    io_h2h_fin_msg_rec.is_collection_only   := null;

    io_h2h_fin_msg_rec.split_hash           := opr_api_shared_data_pkg.g_iss_participant.split_hash;
    io_h2h_fin_msg_rec.status               := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    io_h2h_fin_msg_rec.forw_inst_code       := l_forw_inst_code;
    io_h2h_fin_msg_rec.receiv_inst_code     := l_receiv_inst_code;
    io_h2h_fin_msg_rec.reject_id            := null;

    io_h2h_fin_msg_rec.card_number          := opr_api_shared_data_pkg.g_iss_participant.card_number;
    io_h2h_fin_msg_rec.card_seq_num         := opr_api_shared_data_pkg.g_iss_participant.card_seq_number;
    io_h2h_fin_msg_rec.card_expiry          := opr_api_shared_data_pkg.g_iss_participant.card_expir_date;
    io_h2h_fin_msg_rec.service_code         := opr_api_shared_data_pkg.g_iss_participant.card_service_code;

    io_h2h_fin_msg_rec.file_type            := h2h_api_const_pkg.FILE_TYPE_H2H;
    io_h2h_fin_msg_rec.file_date            := com_api_sttl_day_pkg.get_sysdate;
    io_h2h_fin_msg_rec.file_id              := null;

    io_h2h_fin_msg_rec.oper_type                      := l_operation.oper_type;
    io_h2h_fin_msg_rec.oper_date                      := l_operation.oper_date;
    io_h2h_fin_msg_rec.oper_amount_value              := l_operation.oper_amount;
    io_h2h_fin_msg_rec.oper_amount_currency           := l_operation.oper_currency;
    io_h2h_fin_msg_rec.oper_surcharge_amount_value    := l_operation.oper_surcharge_amount;
    io_h2h_fin_msg_rec.oper_surcharge_amount_currency := l_operation.oper_currency;
    io_h2h_fin_msg_rec.oper_cashback_amount_value     := l_operation.oper_cashback_amount;
    io_h2h_fin_msg_rec.oper_cashback_amount_currency  := l_operation.oper_currency;
    io_h2h_fin_msg_rec.sttl_amount_value              := l_operation.sttl_amount;
    io_h2h_fin_msg_rec.sttl_amount_currency           := l_operation.sttl_currency;
    io_h2h_fin_msg_rec.sttl_rate                      := null;
    io_h2h_fin_msg_rec.crdh_bill_amount_value         := null;
    io_h2h_fin_msg_rec.crdh_bill_amount_currency      := null;
    io_h2h_fin_msg_rec.crdh_bill_rate                 := null;

    io_h2h_fin_msg_rec.acq_inst_bin                   := l_operation.acq_inst_bin;
    io_h2h_fin_msg_rec.merchant_number                := l_operation.merchant_number;
    io_h2h_fin_msg_rec.mcc                            := l_operation.mcc;
    io_h2h_fin_msg_rec.merchant_name                  := l_operation.merchant_name;
    io_h2h_fin_msg_rec.merchant_street                := l_operation.merchant_street;
    io_h2h_fin_msg_rec.merchant_city                  := l_operation.merchant_city;
    io_h2h_fin_msg_rec.merchant_region                := l_operation.merchant_region;
    io_h2h_fin_msg_rec.merchant_country               := l_operation.merchant_country;
    io_h2h_fin_msg_rec.merchant_postcode              := l_operation.merchant_postcode;
    io_h2h_fin_msg_rec.terminal_type                  := l_operation.terminal_type;
    io_h2h_fin_msg_rec.terminal_number                := l_operation.terminal_number;

    io_h2h_fin_msg_rec.trn                            := null;
    io_h2h_fin_msg_rec.oper_id                        := l_operation.id;
    io_h2h_fin_msg_rec.original_id                    := l_operation.original_id;

    trc_log_pkg.debug(
        i_text  => 'Fin. message initialization: l_acq_inst_id [' || l_acq_inst_id
                || '], l_iss_inst_id [' || l_iss_inst_id
                || '], l_host_id [' || l_host_id
                || '], l_network_id [' || l_network_id
                || '], l_standard_id [' || l_standard_id
                || '], l_forw_inst_code [' || l_forw_inst_code
                || '], l_receiv_inst_code [' || l_receiv_inst_code
                || '], o_standard_version [' || o_standard_version || ']'
    );
end init_fin_message;

procedure create_fin_msg_from_auth
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_auth: ';
    l_operation                 opr_api_type_pkg.t_oper_rec;
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_emv_tag_tab               com_api_type_pkg.t_tag_value_tab;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;
    l_iss_inst_id               com_api_type_pkg.t_inst_id;

    cursor cur_auth_tag_values(
        i_auth_id       in  com_api_type_pkg.t_long_id
    ) is
    select null as id
         , t.id as tag_id
         , null as tag_name
         , tv.tag_value
      from aup_tag_value tv
         , h2h_tag t
     where tv.tag_id    = t.fe_tag_id
       and tv.auth_id   = i_auth_id;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_auth.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
            );
        else
            open  cur_auth_tag_values(i_auth_id  => opr_api_shared_data_pkg.g_auth.id);
            fetch cur_auth_tag_values bulk collect into l_tag_value_tab;
            close cur_auth_tag_values;

            l_iss_inst_id :=
                nvl(
                    opr_api_shared_data_pkg.get_param_num(
                        i_name          => 'I_INST_ID'
                      , i_mask_error    => com_api_const_pkg.TRUE
                      , i_error_value   => null
                    )
                  , opr_api_shared_data_pkg.g_iss_participant.inst_id
                );

            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'start with iss_inst_id [#1], auth_id [#2]'
              , i_env_param1  => l_iss_inst_id
              , i_env_param2  => opr_api_shared_data_pkg.g_auth.id
            );

            l_operation := opr_api_shared_data_pkg.get_operation();

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , i_iss_inst_id       => l_iss_inst_id
              , o_standard_version  => l_standard_version
            );
            l_h2h_rec.id                         := opr_api_shared_data_pkg.g_auth.id;
            l_h2h_rec.is_reversal                := l_operation.is_reversal;
            l_h2h_rec.is_rejected                := com_api_const_pkg.FALSE;
            l_h2h_rec.dispute_id                 := null;
            l_h2h_rec.msg_type                   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
            l_h2h_rec.crdh_bill_amount_value     := opr_api_shared_data_pkg.g_auth.bin_amount;
            l_h2h_rec.crdh_bill_amount_currency  := opr_api_shared_data_pkg.g_auth.bin_currency;
            l_h2h_rec.crdh_bill_rate             := opr_api_shared_data_pkg.g_auth.bin_cnvt_rate;
            l_h2h_rec.arn                        := opr_api_shared_data_pkg.g_operation.network_refnum;
            l_h2h_rec.approval_code              := opr_api_shared_data_pkg.g_auth.auth_code;
            l_h2h_rec.rrn                        := l_operation.originator_refnum;
            l_h2h_rec.card_number                := nvl(
                                                        opr_api_shared_data_pkg.g_auth.card_number
                                                      , opr_api_shared_data_pkg.g_iss_participant.card_number
                                                    );
            l_h2h_rec.card_seq_num               := nvl(
                                                        opr_api_shared_data_pkg.g_auth.card_seq_number
                                                      , opr_api_shared_data_pkg.g_iss_participant.card_seq_number
                                                    );
            l_h2h_rec.card_expiry                := nvl(
                                                        opr_api_shared_data_pkg.g_auth.card_expir_date
                                                      , opr_api_shared_data_pkg.g_iss_participant.card_expir_date
                                                    );
            l_h2h_rec.service_code               := nvl(
                                                        opr_api_shared_data_pkg.g_auth.service_code
                                                      , opr_api_shared_data_pkg.g_iss_participant.card_service_code
                                                    );
            h2h_api_tag_pkg.save_tag_value(
                i_fin_id          => l_h2h_rec.id
              , io_tag_value_tab  => l_tag_value_tab
            );

            emv_api_tag_pkg.parse_emv_data(
                i_emv_data        => opr_api_shared_data_pkg.g_auth.emv_data
              , o_emv_tag_tab     => l_emv_tag_tab
              , i_is_binary       => emv_api_tag_pkg.is_binary()
              , i_mask_error      => com_api_const_pkg.FALSE
            );

            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'l_emv_tag_tab.count() = [#1]'
              , i_env_param1  => l_emv_tag_tab.count()
            );

            if l_emv_tag_tab.count() > 0 then
                l_h2h_rec.emv_5f2a  := emv_api_tag_pkg.get_tag_value('5F2A', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_5f34  := emv_api_tag_pkg.get_tag_value('5F34', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_71    := emv_api_tag_pkg.get_tag_value('71',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_72    := emv_api_tag_pkg.get_tag_value('72',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_82    := emv_api_tag_pkg.get_tag_value('82',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_84    := emv_api_tag_pkg.get_tag_value('84',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_8a    := emv_api_tag_pkg.get_tag_value('8A',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_91    := emv_api_tag_pkg.get_tag_value('91',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_95    := emv_api_tag_pkg.get_tag_value('95',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9a    := emv_api_tag_pkg.get_tag_value('9A',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9c    := emv_api_tag_pkg.get_tag_value('9C',   l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f02  := emv_api_tag_pkg.get_tag_value('9F02', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f03  := emv_api_tag_pkg.get_tag_value('9F03', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f06  := emv_api_tag_pkg.get_tag_value('9F06', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f09  := emv_api_tag_pkg.get_tag_value('9F09', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f10  := emv_api_tag_pkg.get_tag_value('9F10', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f18  := emv_api_tag_pkg.get_tag_value('9F18', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f1a  := emv_api_tag_pkg.get_tag_value('9F1A', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f1e  := emv_api_tag_pkg.get_tag_value('9F1E', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f26  := emv_api_tag_pkg.get_tag_value('9F26', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f27  := emv_api_tag_pkg.get_tag_value('9F27', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f28  := emv_api_tag_pkg.get_tag_value('9F28', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f29  := emv_api_tag_pkg.get_tag_value('9F29', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f33  := emv_api_tag_pkg.get_tag_value('9F33', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f34  := emv_api_tag_pkg.get_tag_value('9F34', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f35  := emv_api_tag_pkg.get_tag_value('9F35', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f36  := emv_api_tag_pkg.get_tag_value('9F36', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f37  := emv_api_tag_pkg.get_tag_value('9F37', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f41  := emv_api_tag_pkg.get_tag_value('9F41', l_emv_tag_tab, com_api_const_pkg.TRUE);
                l_h2h_rec.emv_9f53  := emv_api_tag_pkg.get_tag_value('9F53', l_emv_tag_tab, com_api_const_pkg.TRUE);
            end if;

            l_h2h_rec.pdc_1   := substr(opr_api_shared_data_pkg.g_auth.card_data_input_cap, -1, 1);
            l_h2h_rec.pdc_2   := substr(opr_api_shared_data_pkg.g_auth.crdh_auth_cap, -1, 1);
            l_h2h_rec.pdc_3   := substr(opr_api_shared_data_pkg.g_auth.card_capture_cap, -1, 1);
            l_h2h_rec.pdc_4   := substr(opr_api_shared_data_pkg.g_auth.terminal_operating_env, -1, 1);
            l_h2h_rec.pdc_5   := substr(opr_api_shared_data_pkg.g_auth.crdh_presence, -1, 1);
            l_h2h_rec.pdc_6   := substr(opr_api_shared_data_pkg.g_auth.card_presence, -1, 1);
            l_h2h_rec.pdc_7   := substr(opr_api_shared_data_pkg.g_auth.card_data_input_mode, -1, 1);
            l_h2h_rec.pdc_8   := substr(opr_api_shared_data_pkg.g_auth.crdh_auth_method, -1, 1);
            l_h2h_rec.pdc_9   := substr(opr_api_shared_data_pkg.g_auth.crdh_auth_entity, -1, 1);
            l_h2h_rec.pdc_10  := substr(opr_api_shared_data_pkg.g_auth.card_data_output_cap, -1, 1);
            l_h2h_rec.pdc_11  := substr(opr_api_shared_data_pkg.g_auth.terminal_output_cap, -1, 1);
            l_h2h_rec.pdc_12  := substr(opr_api_shared_data_pkg.g_auth.pin_capture_cap, -1, 1);

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);

            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'finish'
            );
        end if;
    end if;
end create_fin_msg_from_auth;

procedure create_fin_msg_from_mc_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_mc_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_fin_fields                com_api_type_pkg.t_param_tab;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;
    l_installment_data_1        com_api_type_pkg.t_param_value;
    l_installment_data_2        com_api_type_pkg.t_param_value;

    procedure process_pdc(
        io_h2h_rec          in out nocopy h2h_api_type_pkg.t_h2h_fin_message_rec
      , io_fin_fields       in out nocopy com_api_type_pkg.t_param_tab
      , i_standard_version  in            com_api_type_pkg.t_tiny_id
    ) is
    begin
        io_h2h_rec.pdc_1 :=
            case
                when io_fin_fields('de022_1') = 'B'                                         then '7'
                when io_fin_fields('de022_1') = 'M'                                         then 'S'
                when io_fin_fields('de022_1') = 'D'
                  or (io_fin_fields('de022_1') = 'D' and io_fin_fields('p0018') = '0')      then '5'
                else io_fin_fields('de022_1')
            end;

        io_h2h_rec.pdc_2 :=
            case
                when io_fin_fields('de022_2') = '3' then '1' else io_fin_fields('de022_2')
            end;

        io_h2h_rec.pdc_3 :=
            case
                when io_fin_fields('de022_3') = '9' then '2' else io_fin_fields('de022_3')
            end;

        io_h2h_rec.pdc_4 :=
            case
                when io_fin_fields('de022_4') = '9' and io_fin_fields('p0023') = 'CT1'      then 'S'
                when io_fin_fields('de022_4') = '9' and io_fin_fields('p0023') = 'CT2'      then 'T'
                when io_fin_fields('de022_4') = '9' and io_fin_fields('p0023') = 'CT3'      then 'U'
                when io_fin_fields('de022_4') = '9' and io_fin_fields('p0023') = 'CT4'      then 'V'
                when io_fin_fields('de022_4') = '5'                                         then 'X'
                when io_fin_fields('de022_4') = '1'                                         then 'A'
                when io_fin_fields('de022_4') = '2'                                         then 'B'
                else io_fin_fields('de022_4')
            end;

        io_h2h_rec.pdc_5 :=
            case
                when io_fin_fields('de022_7') != 'S' and io_fin_fields('p0023') = 'CT6'     then '5'
                else io_fin_fields('de022_5')
            end;

        io_h2h_rec.pdc_6 := io_fin_fields('de022_6');

        io_h2h_rec.pdc_7 :=
            case
                when io_fin_fields('de022_7') = 'S'  and io_fin_fields('p0023') = 'CT6'     then 'S'
                when io_fin_fields('de022_7') != 'S' and io_fin_fields('p0023') = 'CT6'     then '7'
                when io_fin_fields('de022_7') = 'C'  and io_fin_fields('de038') is not null then 'F'
                when io_fin_fields('de022_7') = 'T'                                         then 'W'
                when io_fin_fields('de022_7') = 'B'                                         then '2'
                when io_fin_fields('de022_7') = '0'                                         then '3'
                when io_fin_fields('de022_7') = 'R'                                         then 'O'
                when io_fin_fields('de022_7') = '7'                                         then 'E'
                else io_fin_fields('de022_7')
            end;

        io_h2h_rec.pdc_8  := io_fin_fields('de022_8');
        io_h2h_rec.pdc_9  := io_fin_fields('de022_9');
        io_h2h_rec.pdc_10 := io_fin_fields('de022_10');
        io_h2h_rec.pdc_11 := io_fin_fields('de022_11');

        io_h2h_rec.pdc_12 :=
            case
                when io_fin_fields('de022_2') = '3' then 'S' else io_fin_fields('de022_12')
            end;
    end process_pdc;

begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
            );
        else
            mcw_api_fin_pkg.get_fin_message(
                i_id            => opr_api_shared_data_pkg.g_operation.id
              , o_fin_fields    => l_fin_fields
              , i_mask_error    => com_api_const_pkg.FALSE
            );

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , o_standard_version  => l_standard_version
            );
            l_h2h_rec.id                         := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal                := l_fin_fields('is_reversal');
            l_h2h_rec.is_rejected                := l_fin_fields('is_rejected');
            l_h2h_rec.dispute_id                 := l_fin_fields('dispute_id');
            l_h2h_rec.msg_type                   := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.sttl_rate                  := l_fin_fields('de009');
            l_h2h_rec.crdh_bill_amount_value     := l_fin_fields('de006');
            l_h2h_rec.crdh_bill_amount_currency  := l_fin_fields('de051');
            l_h2h_rec.crdh_bill_rate             := l_fin_fields('de010');
            l_h2h_rec.arn                        := nvl(l_fin_fields('de031'), opr_api_shared_data_pkg.g_operation.network_refnum);
            l_h2h_rec.approval_code              := l_fin_fields('de038');
            l_h2h_rec.rrn                        := nvl(l_fin_fields('de037'), opr_api_shared_data_pkg.g_operation.originator_refnum);
            l_h2h_rec.trn                        := l_fin_fields('de063');

            l_h2h_rec.emv_5f2a                   := l_fin_fields('emv_5f2a');
            l_h2h_rec.emv_5f34                   := null;
            l_h2h_rec.emv_71                     := null;
            l_h2h_rec.emv_72                     := null;
            l_h2h_rec.emv_82                     := l_fin_fields('emv_82');
            l_h2h_rec.emv_84                     := l_fin_fields('emv_84');
            l_h2h_rec.emv_8a                     := null;
            l_h2h_rec.emv_91                     := null;
            l_h2h_rec.emv_95                     := l_fin_fields('emv_95');
            l_h2h_rec.emv_9a                     := to_char(l_fin_fields('emv_9a'), 'yymmdd');
            l_h2h_rec.emv_9c                     := l_fin_fields('emv_9c');
            l_h2h_rec.emv_9f02                   := l_fin_fields('emv_9f02');
            l_h2h_rec.emv_9f03                   := l_fin_fields('emv_9f03');
            l_h2h_rec.emv_9f06                   := null;
            l_h2h_rec.emv_9f09                   := l_fin_fields('emv_9f09');
            l_h2h_rec.emv_9f10                   := l_fin_fields('emv_9f10');
            l_h2h_rec.emv_9f18                   := null;
            l_h2h_rec.emv_9f1a                   := l_fin_fields('emv_9f1a');
            l_h2h_rec.emv_9f1e                   := l_fin_fields('emv_9f1e');
            l_h2h_rec.emv_9f26                   := l_fin_fields('emv_9f26');
            l_h2h_rec.emv_9f27                   := l_fin_fields('emv_9f27');
            l_h2h_rec.emv_9f28                   := null;
            l_h2h_rec.emv_9f29                   := null;
            l_h2h_rec.emv_9f33                   := l_fin_fields('emv_9f33');
            l_h2h_rec.emv_9f34                   := l_fin_fields('emv_9f34');
            l_h2h_rec.emv_9f35                   := l_fin_fields('emv_9f35');
            l_h2h_rec.emv_9f36                   := l_fin_fields('emv_9f36');
            l_h2h_rec.emv_9f37                   := l_fin_fields('emv_9f37');
            l_h2h_rec.emv_9f41                   := l_fin_fields('emv_9f41');
            l_h2h_rec.emv_9f53                   := l_fin_fields('emv_9f53');

            process_pdc(
                io_h2h_rec          => l_h2h_rec
              , io_fin_fields       => l_fin_fields
              , i_standard_version  => l_standard_version
            );

            h2h_api_tag_pkg.collect_tags(
                i_fin_id            => l_h2h_rec.id
              , i_ips_fin_fields    => l_fin_fields
              , i_ips_code          => h2h_api_const_pkg.MODULE_CODE_MASTERCARD
              , o_tag_value_tab     => l_tag_value_tab
            );

            -- Specific processing of PDS 0181
            if l_fin_fields('p0181') is not null then
                mcw_api_pds_pkg.parse_p0181(
                    i_p0181              => l_fin_fields('p0181')
                  , o_installment_data_1 => l_installment_data_1
                  , o_installment_data_2 => l_installment_data_2
                );

                h2h_api_tag_pkg.add_tag_value(
                    io_tag_value_tab     => l_tag_value_tab
                  , i_tag_id             => h2h_api_const_pkg.TAG_INSTALL_COUNT
                  , i_tag_value          => l_installment_data_1
                );
                h2h_api_tag_pkg.add_tag_value(
                    io_tag_value_tab     => l_tag_value_tab
                  , i_tag_id             => h2h_api_const_pkg.TAG_INSTALL_TYPE
                  , i_tag_value          => l_installment_data_2
                );
            end if;

            h2h_api_tag_pkg.save_tag_value(
                i_fin_id          => l_h2h_rec.id
              , io_tag_value_tab  => l_tag_value_tab
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_mc_pres;

procedure create_fin_msg_from_visa_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_visa_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_visa_fin_fields           com_api_type_pkg.t_param_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1  => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1  => opr_api_shared_data_pkg.g_operation.id
            );
        else
            vis_api_fin_message_pkg.get_fin_message(
                i_id          => opr_api_shared_data_pkg.g_operation.id
              , o_fin_fields  => l_visa_fin_fields
              , i_mask_error  => com_api_const_pkg.FALSE
            );

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , o_standard_version  => l_standard_version
            );
            l_h2h_rec.id             := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal    := l_visa_fin_fields('is_reversal');
            l_h2h_rec.is_rejected    := l_visa_fin_fields('is_returned');
            l_h2h_rec.dispute_id     := l_visa_fin_fields('dispute_id');
            l_h2h_rec.msg_type       := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.arn            := nvl(l_visa_fin_fields('arn'), opr_api_shared_data_pkg.g_operation.network_refnum);
            l_h2h_rec.approval_code  := null;
            l_h2h_rec.rrn            := nvl(l_visa_fin_fields('rrn'), opr_api_shared_data_pkg.g_operation.originator_refnum);

            l_h2h_rec.emv_5f2a       := null;
            l_h2h_rec.emv_5f34       := null;
            l_h2h_rec.emv_71         := null;
            l_h2h_rec.emv_72         := null;
            l_h2h_rec.emv_82         := l_visa_fin_fields('appl_interch_profile');
            l_h2h_rec.emv_84         := null;
            l_h2h_rec.emv_8a         := l_visa_fin_fields('auth_resp_code');
            l_h2h_rec.emv_91         := null;
            l_h2h_rec.emv_95         := l_visa_fin_fields('term_verif_result');
            l_h2h_rec.emv_9a         := null;
            l_h2h_rec.emv_9c         := l_visa_fin_fields('transaction_type');
            l_h2h_rec.emv_9f02       := null;
            l_h2h_rec.emv_9f03       := null;
            l_h2h_rec.emv_9f06       := null;
            l_h2h_rec.emv_9f09       := null;
            l_h2h_rec.emv_9f10       := l_visa_fin_fields('issuer_appl_data');
            l_h2h_rec.emv_9f18       := substr(
                                            l_visa_fin_fields('issuer_script_result')
                                          , 1
                                          , length(l_visa_fin_fields('issuer_script_result')) - 2
                                        );
            l_h2h_rec.emv_9f1a       := l_visa_fin_fields('terminal_country');
            l_h2h_rec.emv_9f1e       := null;
            l_h2h_rec.emv_9f26       := l_visa_fin_fields('cryptogram');
            l_h2h_rec.emv_9f27       := null;
            l_h2h_rec.emv_9f28       := null;
            l_h2h_rec.emv_9f29       := null;
            l_h2h_rec.emv_9f33       := l_visa_fin_fields('terminal_profile');
            l_h2h_rec.emv_9f34       := null;
            l_h2h_rec.emv_9f35       := null;
            l_h2h_rec.emv_9f36       := l_visa_fin_fields('appl_trans_counter');
            l_h2h_rec.emv_9f37       := l_visa_fin_fields('unpredict_number');
            l_h2h_rec.emv_9f41       := null;
            l_h2h_rec.emv_9f53       := null;

            h2h_api_tag_pkg.save_tag_value(
                i_fin_id          => l_h2h_rec.id
              , i_ips_fin_fields  => l_visa_fin_fields
              , i_ips_code        => h2h_api_const_pkg.MODULE_CODE_VISA
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_visa_pres;

procedure create_fin_msg_from_cup_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_cup_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_cup_fin_rec               cup_api_type_pkg.t_cup_fin_mes_rec;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1  => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
            );
        else
            cup_api_fin_message_pkg.get_fin_mes(
                i_id            => opr_api_shared_data_pkg.g_operation.id
              , o_fin_rec       => l_cup_fin_rec
              , i_mask_error    => com_api_const_pkg.FALSE
            );

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , o_standard_version  => l_standard_version
            );
            l_h2h_rec.id                         := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal                := l_cup_fin_rec.is_reversal;
            l_h2h_rec.is_rejected                := l_cup_fin_rec.is_rejected;
            l_h2h_rec.dispute_id                 := l_cup_fin_rec.dispute_id;
            l_h2h_rec.msg_type                   := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.sttl_rate                  := l_cup_fin_rec.settlement_exch_rate;
            l_h2h_rec.crdh_bill_amount_value     := l_cup_fin_rec.cardholder_bill_amount;
            l_h2h_rec.crdh_bill_amount_currency  := l_cup_fin_rec.cardholder_acc_currency;
            l_h2h_rec.crdh_bill_rate             := l_cup_fin_rec.cardholder_exch_rate;
            l_h2h_rec.arn                        := null;
            l_h2h_rec.approval_code              := l_cup_fin_rec.auth_resp_code;
            l_h2h_rec.rrn                        := nvl(l_cup_fin_rec.rrn, opr_api_shared_data_pkg.g_operation.originator_refnum);

            l_h2h_rec.emv_5f2a                   := l_cup_fin_rec.auth_currency;
            l_h2h_rec.emv_5f34                   := null;
            l_h2h_rec.emv_71                     := null;
            l_h2h_rec.emv_72                     := null;
            l_h2h_rec.emv_82                     := l_cup_fin_rec.appl_charact;
            l_h2h_rec.emv_84                     := l_cup_fin_rec.dedic_doc_name;
            l_h2h_rec.emv_8a                     := null;
            l_h2h_rec.emv_91                     := null;
            l_h2h_rec.emv_95                     := l_cup_fin_rec.terminal_verif_result;
            l_h2h_rec.emv_9a                     := to_char(l_cup_fin_rec.terminal_auth_date, 'yymmdd');
            l_h2h_rec.emv_9c                     := l_cup_fin_rec.trans_category;
            l_h2h_rec.emv_9f02                   := l_cup_fin_rec.auth_amount;
            l_h2h_rec.emv_9f03                   := l_cup_fin_rec.other_amount;
            l_h2h_rec.emv_9f06                   := null;
            l_h2h_rec.emv_9f09                   := l_cup_fin_rec.app_version_no;
            l_h2h_rec.emv_9f10                   := l_cup_fin_rec.iss_bank_app_data;
            l_h2h_rec.emv_9f18                   := null;
            l_h2h_rec.emv_9f1a                   := null;
            l_h2h_rec.emv_9f1e                   := l_cup_fin_rec.interface_serial;
            l_h2h_rec.emv_9f26                   := l_cup_fin_rec.appl_crypt;
            l_h2h_rec.emv_9f27                   := l_cup_fin_rec.cipher_text_inf_data;
            l_h2h_rec.emv_9f28                   := null;
            l_h2h_rec.emv_9f29                   := null;
            l_h2h_rec.emv_9f33                   := l_cup_fin_rec.terminal_capab;
            l_h2h_rec.emv_9f34                   := l_cup_fin_rec.auth_method;
            l_h2h_rec.emv_9f35                   := l_cup_fin_rec.terminal_category;
            l_h2h_rec.emv_9f36                   := l_cup_fin_rec.trans_counter;
            l_h2h_rec.emv_9f37                   := l_cup_fin_rec.unpred_num;
            l_h2h_rec.emv_9f41                   := l_cup_fin_rec.trans_serial_counter;
            l_h2h_rec.emv_9f53                   := l_cup_fin_rec.script_result_of_card_issuer;

            l_h2h_rec.pdc_1                      :=
                case l_cup_fin_rec.terminal_entry_capab
                    when 1 then '0'  -- Unknown; data not available
                    when 2 then '1'  -- no terminal used
                    when 3 then '3'  -- bar code
                    when 4 then '4'  -- OCR
                    when 5 then 'D'  -- magnetic stripe and chip reader
                    when 6 then '6'  -- key entry
                    when 7 then 'B'  -- magnetic stripe reader and key entry
                    when 8 then 'C'  -- magnetic stripe and chip reader and key entry
                    when 9 then '5'  -- chip reader
                    else null
                end;

            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab    => l_tag_value_tab
              , i_tag_id            => h2h_api_const_pkg.TAG_FACILITATOR
              , i_tag_value         => l_cup_fin_rec.payment_facilitator_id
            );
            h2h_api_tag_pkg.save_tag_value(
                i_fin_id            => l_h2h_rec.id
              , io_tag_value_tab    => l_tag_value_tab
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_cup_pres;

procedure create_fin_msg_from_jcb_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_jcb_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_jcb_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;

    procedure process_pdc(
        io_h2h_rec          in out nocopy h2h_api_type_pkg.t_h2h_fin_message_rec
      , io_jcb_fin_rec      in out nocopy jcb_api_type_pkg.t_fin_rec
      , i_standard_version  in            com_api_type_pkg.t_tiny_id
    ) is
    begin
        io_h2h_rec.pdc_1 :=
            case
                when io_jcb_fin_rec.de022_1 = '2'  then 'A'
                when io_jcb_fin_rec.de022_1 = '5'  then 'C'
                when io_jcb_fin_rec.de022_1 = '0'  then 'V'
                when io_jcb_fin_rec.de022_1 = 'M'  then 'S'
                when io_jcb_fin_rec.de022_7 = 'U'  then '5'
                                                   else io_jcb_fin_rec.de022_1
            end;

        io_h2h_rec.pdc_2 :=
            case
                when io_jcb_fin_rec.de022_2 = '3'  then '1'
                                                   else io_jcb_fin_rec.de022_2
            end;

        io_h2h_rec.pdc_3 :=
            case
                when io_jcb_fin_rec.de022_3 = '0'  then '2'
                                                   else io_jcb_fin_rec.de022_3
            end;

        io_h2h_rec.pdc_4 :=
            case
                when io_jcb_fin_rec.de022_4 = 'Z'  then '6'
                                                   else io_jcb_fin_rec.de022_4
            end;

        io_h2h_rec.pdc_5 :=
            case
                when io_jcb_fin_rec.de022_5 = '9'  then '5'
                when io_jcb_fin_rec.de022_5 = '4'  then '8'
                                                   else io_jcb_fin_rec.de022_5
            end;

        io_h2h_rec.pdc_6 :=
            case
                when io_jcb_fin_rec.de022_6 = '1'  then '0'
                when io_jcb_fin_rec.de022_6 = '0'  then '1'
                                                   else 'Z'
            end;

        io_h2h_rec.pdc_7 :=
            case
                when io_jcb_fin_rec.de022_7 = 'C'  then 'F'
                when io_jcb_fin_rec.de022_7 = 'U'  then '2'
                                                   else io_jcb_fin_rec.de022_7
            end;

        io_h2h_rec.pdc_8 :=
            case
                when io_jcb_fin_rec.de022_8 = 'Z'  then '9'
                                                   else io_jcb_fin_rec.de022_8
            end;

        io_h2h_rec.pdc_9 :=
            case
                when io_jcb_fin_rec.de022_9 = '4'  then '6'
                when io_jcb_fin_rec.de022_9 = '5'  then '9'
                                                   else io_jcb_fin_rec.de022_9
            end;

        io_h2h_rec.pdc_10 :=
            case
                when io_jcb_fin_rec.de022_10 = '0' then 'S'
                                                   else io_jcb_fin_rec.de022_10
            end;

        l_h2h_rec.pdc_11 := l_jcb_fin_rec.de022_11;

        io_h2h_rec.pdc_12 :=
            case
                when io_jcb_fin_rec.de022_2 = '3'  then 'S'
                                                   else io_jcb_fin_rec.de022_12
            end;
    end process_pdc;

begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1  => opr_api_shared_data_pkg.g_operation.id
            );
        else
            jcb_api_fin_pkg.get_fin(
                i_id                => opr_api_shared_data_pkg.g_operation.id
              , o_fin_rec           => l_jcb_fin_rec
              , i_mask_error        => com_api_const_pkg.FALSE
            );

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , o_standard_version  => l_standard_version
            );
            l_h2h_rec.id                         := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal                := l_jcb_fin_rec.is_reversal;
            l_h2h_rec.is_rejected                := l_jcb_fin_rec.is_rejected;
            l_h2h_rec.dispute_id                 := l_jcb_fin_rec.dispute_id;

            l_h2h_rec.msg_type                   := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.sttl_rate                  := l_jcb_fin_rec.de009;
            l_h2h_rec.crdh_bill_amount_value     := l_jcb_fin_rec.de006;
            l_h2h_rec.crdh_bill_amount_currency  := l_jcb_fin_rec.de051;
            l_h2h_rec.crdh_bill_rate             := l_jcb_fin_rec.de010;
            l_h2h_rec.arn                        := nvl(l_jcb_fin_rec.de031, opr_api_shared_data_pkg.g_operation.network_refnum);

            l_h2h_rec.approval_code              := l_jcb_fin_rec.de038;
            l_h2h_rec.rrn                        := nvl(l_jcb_fin_rec.de037, opr_api_shared_data_pkg.g_operation.originator_refnum);

            l_h2h_rec.emv_5f2a                   := l_jcb_fin_rec.emv_5f2a;
            l_h2h_rec.emv_5f34                   := null;
            l_h2h_rec.emv_71                     := null;
            l_h2h_rec.emv_72                     := null;
            l_h2h_rec.emv_82                     := l_jcb_fin_rec.emv_82;
            l_h2h_rec.emv_84                     := l_jcb_fin_rec.emv_84;
            l_h2h_rec.emv_8a                     := null;
            l_h2h_rec.emv_91                     := null;
            l_h2h_rec.emv_95                     := l_jcb_fin_rec.emv_95;
            l_h2h_rec.emv_9a                     := to_char(l_jcb_fin_rec.emv_9a, 'yymmdd');
            l_h2h_rec.emv_9c                     := l_jcb_fin_rec.emv_9c;
            l_h2h_rec.emv_9f02                   := l_jcb_fin_rec.emv_9f02;
            l_h2h_rec.emv_9f03                   := l_jcb_fin_rec.emv_9f03;
            l_h2h_rec.emv_9f06                   := null;
            l_h2h_rec.emv_9f09                   := l_jcb_fin_rec.emv_9f09;
            l_h2h_rec.emv_9f10                   := l_jcb_fin_rec.emv_9f10;
            l_h2h_rec.emv_9f18                   := null;
            l_h2h_rec.emv_9f1a                   := l_jcb_fin_rec.emv_9f1a;
            l_h2h_rec.emv_9f1e                   := l_jcb_fin_rec.emv_9f1e;
            l_h2h_rec.emv_9f26                   := l_jcb_fin_rec.emv_9f26;
            l_h2h_rec.emv_9f27                   := l_jcb_fin_rec.emv_9f27;
            l_h2h_rec.emv_9f28                   := null;
            l_h2h_rec.emv_9f29                   := null;
            l_h2h_rec.emv_9f33                   := l_jcb_fin_rec.emv_9f33;
            l_h2h_rec.emv_9f34                   := l_jcb_fin_rec.emv_9f34;
            l_h2h_rec.emv_9f35                   := l_jcb_fin_rec.emv_9f35;
            l_h2h_rec.emv_9f36                   := l_jcb_fin_rec.emv_9f36;
            l_h2h_rec.emv_9f37                   := l_jcb_fin_rec.emv_9f37;
            l_h2h_rec.emv_9f41                   := l_jcb_fin_rec.emv_9f41;
            l_h2h_rec.emv_9f53                   := null;

            process_pdc(
                io_h2h_rec          => l_h2h_rec
              , io_jcb_fin_rec      => l_jcb_fin_rec
              , i_standard_version  => l_standard_version
            );

            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab    => l_tag_value_tab
              , i_tag_id            => h2h_api_const_pkg.TAG_ACQ_SWITCH_DATE
              , i_tag_value         => to_char(l_jcb_fin_rec.de012, h2h_api_const_pkg.TAG_DATE_FORMAT)
            );
            h2h_api_tag_pkg.save_tag_value(
                i_fin_id            => l_h2h_rec.id
              , io_tag_value_tab    => l_tag_value_tab
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_jcb_pres;

procedure create_fin_msg_from_din_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_din_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_din_fin_rec               din_api_type_pkg.t_fin_message_rec;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;

    function get_addendum(
        io_addendum_values  in out nocopy din_api_type_pkg.t_addendum_values_tab
      , i_field_name        in            din_api_type_pkg.t_field_name
    ) return com_api_type_pkg.t_name is
    begin
        return
            case
                when io_addendum_values.exists(i_field_name)
                then io_addendum_values(i_field_name)
                else null
            end;
    end;

    procedure process_emv_tags(
        io_h2h_rec          in out nocopy h2h_api_type_pkg.t_h2h_fin_message_rec
    ) is
        l_addendum_values                 din_api_type_pkg.t_addendum_values_tab;
    begin
        l_addendum_values :=
            din_api_fin_message_pkg.get_addendum_value(
                i_fin_id              => io_h2h_rec.id
              , i_function_code       => din_api_const_pkg.FUNCTION_CODE_ADD_CHIP_CARD
            );
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || '->process_emv_tags: addendums count [#1]'
          , i_env_param1  => l_addendum_values.count()
        );

        if l_addendum_values.count() > 0 then
            l_h2h_rec.emv_5f2a := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_5F2A);
            l_h2h_rec.emv_5f34 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_5F34);
            l_h2h_rec.emv_72   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_72);
            l_h2h_rec.emv_82   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_82);
            l_h2h_rec.emv_84   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_84);
            l_h2h_rec.emv_8a   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_8A);
            l_h2h_rec.emv_91   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_91);
            l_h2h_rec.emv_95   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_95);
            l_h2h_rec.emv_9a   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9A);
            l_h2h_rec.emv_9c   := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9C);
            l_h2h_rec.emv_9f02 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F02);
            l_h2h_rec.emv_9f03 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F03);
            l_h2h_rec.emv_9f06 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F06);
            l_h2h_rec.emv_9f09 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F09);
            l_h2h_rec.emv_9f10 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F10);
            l_h2h_rec.emv_9f18 := null;
            l_h2h_rec.emv_9f1a := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F1A);
            l_h2h_rec.emv_9f1e := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F1E);
            l_h2h_rec.emv_9f26 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F26);
            l_h2h_rec.emv_9f27 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F27);
            l_h2h_rec.emv_9f28 := null;
            l_h2h_rec.emv_9f29 := null;
            l_h2h_rec.emv_9f33 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F33);
            l_h2h_rec.emv_9f34 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F34);
            l_h2h_rec.emv_9f35 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F35);
            l_h2h_rec.emv_9f36 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F36);
            l_h2h_rec.emv_9f37 := get_addendum(l_addendum_values, din_api_const_pkg.TAG_ADDENDUM_EMV_9F37);
            l_h2h_rec.emv_9f41 := null;
            l_h2h_rec.emv_9f53 := null;
        end if;
    end process_emv_tags;

begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
            );
        else
            l_din_fin_rec :=
                din_api_fin_message_pkg.get_fin_message(
                    i_id            => opr_api_shared_data_pkg.g_operation.id
                  , i_mask_error    => com_api_const_pkg.FALSE
                );

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , o_standard_version  => l_standard_version
            );
            l_h2h_rec.id                := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal       := l_din_fin_rec.is_reversal;
            l_h2h_rec.is_rejected       := l_din_fin_rec.is_rejected;
            l_h2h_rec.dispute_id        := l_din_fin_rec.dispute_id;
            l_h2h_rec.msg_type          := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.arn               := opr_api_shared_data_pkg.g_operation.network_refnum;
            l_h2h_rec.approval_code     := l_din_fin_rec.auth_code;
            l_h2h_rec.rrn               := opr_api_shared_data_pkg.g_operation.originator_refnum;

            l_h2h_rec.pdc_1             := l_din_fin_rec.card_data_input_capability; 
            l_h2h_rec.pdc_2             := null;
            l_h2h_rec.pdc_3             := null;
            l_h2h_rec.pdc_4             := null;
            l_h2h_rec.pdc_5             := l_din_fin_rec.crdh_presence;
            l_h2h_rec.pdc_6             := l_din_fin_rec.card_presence;
            l_h2h_rec.pdc_7             := l_din_fin_rec.card_data_input_mode;
            l_h2h_rec.pdc_8             := null;
            l_h2h_rec.pdc_9             := null;
            l_h2h_rec.pdc_10            := null;
            l_h2h_rec.pdc_11            := null;
            l_h2h_rec.pdc_12            := null;

            process_emv_tags(io_h2h_rec  => l_h2h_rec);

            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab    => l_tag_value_tab
              , i_tag_id            => h2h_api_const_pkg.TAG_NET_RESP_CODE
              , i_tag_value         => l_din_fin_rec.action_code
            );
            h2h_api_tag_pkg.save_tag_value(
                i_fin_id            => l_h2h_rec.id
              , io_tag_value_tab    => l_tag_value_tab
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_din_pres;

procedure create_fin_msg_from_amx_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_amx_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_amx_fin_rec               amx_api_type_pkg.t_amx_fin_mes_rec;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_amx_add_chip_rec          amx_api_type_pkg.t_amx_add_chip_rec;
    l_standard_version          com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1  => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
            );
        else
            amx_api_fin_message_pkg.get_fin(
                i_id            => opr_api_shared_data_pkg.g_operation.id
              , o_fin_rec       => l_amx_fin_rec
              , i_mask_error    => com_api_const_pkg.FALSE
            );
            amx_api_add_pkg.get_chip_addenda(
                i_fin_id        => l_amx_fin_rec.id
              , o_add_chip_rec  => l_amx_add_chip_rec
            );

            init_fin_message(
                o_standard_version      => l_standard_version
              , io_h2h_fin_msg_rec      => l_h2h_rec
            );
            l_h2h_rec.id                  := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal         := l_amx_fin_rec.is_reversal;
            l_h2h_rec.is_collection_only  := l_amx_fin_rec.is_collection_only;
            l_h2h_rec.is_rejected         := l_amx_fin_rec.is_rejected;
            l_h2h_rec.reject_id           := l_amx_fin_rec.reject_id;
            l_h2h_rec.dispute_id          := l_amx_fin_rec.dispute_id;

            l_h2h_rec.msg_type            := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.arn                 := nvl(l_amx_fin_rec.arn, opr_api_shared_data_pkg.g_operation.network_refnum);

            l_h2h_rec.approval_code       := l_amx_fin_rec.approval_code;
            l_h2h_rec.rrn                 := opr_api_shared_data_pkg.g_operation.originator_refnum;

            l_h2h_rec.emv_5f2a            := l_amx_add_chip_rec.emv_5f2a;
            l_h2h_rec.emv_5f34            := null;
            l_h2h_rec.emv_71              := null; 
            l_h2h_rec.emv_72              := null;
            l_h2h_rec.emv_82              := l_amx_add_chip_rec.emv_82;
            l_h2h_rec.emv_84              := null;
            l_h2h_rec.emv_8a              := null;
            l_h2h_rec.emv_91              := null;
            l_h2h_rec.emv_95              := l_amx_add_chip_rec.emv_95;
            l_h2h_rec.emv_9a              := to_char(l_amx_add_chip_rec.emv_9a, 'yymmdd'); 
            l_h2h_rec.emv_9c              := l_amx_add_chip_rec.emv_9c;
            l_h2h_rec.emv_9f02            := l_amx_add_chip_rec.emv_9f02;
            l_h2h_rec.emv_9f03            := l_amx_add_chip_rec.emv_9f03;
            l_h2h_rec.emv_9f06            := null;
            l_h2h_rec.emv_9f09            := null;
            l_h2h_rec.emv_9f10            := l_amx_add_chip_rec.emv_9f10;
            l_h2h_rec.emv_9f18            := null;
            l_h2h_rec.emv_9f1a            := l_amx_add_chip_rec.emv_9f1a;
            l_h2h_rec.emv_9f1e            := null;
            l_h2h_rec.emv_9f26            := l_amx_add_chip_rec.emv_9f26; 
            l_h2h_rec.emv_9f27            := l_amx_add_chip_rec.emv_9f27;
            l_h2h_rec.emv_9f28            := null;
            l_h2h_rec.emv_9f29            := null;
            l_h2h_rec.emv_9f33            := null;
            l_h2h_rec.emv_9f34            := l_amx_add_chip_rec.emv_5f34;
            l_h2h_rec.emv_9f35            := null;
            l_h2h_rec.emv_9f36            := l_amx_add_chip_rec.emv_9f36;
            l_h2h_rec.emv_9f37            := l_amx_add_chip_rec.emv_9f37;
            l_h2h_rec.emv_9f41            := null;
            l_h2h_rec.emv_9f53            := null;

            l_h2h_rec.pdc_1               := l_amx_fin_rec.pdc_1;
            l_h2h_rec.pdc_2               := l_amx_fin_rec.pdc_2;
            l_h2h_rec.pdc_3               := l_amx_fin_rec.pdc_3;
            l_h2h_rec.pdc_4               := l_amx_fin_rec.pdc_4;
            l_h2h_rec.pdc_5               := l_amx_fin_rec.pdc_5;
            l_h2h_rec.pdc_6               := l_amx_fin_rec.pdc_6;
            l_h2h_rec.pdc_7               := l_amx_fin_rec.pdc_7;
            l_h2h_rec.pdc_8               := l_amx_fin_rec.pdc_8;
            l_h2h_rec.pdc_9               := l_amx_fin_rec.pdc_9;
            l_h2h_rec.pdc_10              := l_amx_fin_rec.pdc_10;
            l_h2h_rec.pdc_11              := l_amx_fin_rec.pdc_11;
            l_h2h_rec.pdc_12              := l_amx_fin_rec.pdc_12;

            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab     => l_tag_value_tab
              , i_tag_id             => h2h_api_const_pkg.TAG_ECI
              , i_tag_value          => l_amx_fin_rec.eci
            );
            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab     => l_tag_value_tab
              , i_tag_id             => h2h_api_const_pkg.TAG_FORMAT_CODE
              , i_tag_value          => l_amx_fin_rec.format_code
            );

            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab     => l_tag_value_tab
              , i_tag_id             => h2h_api_const_pkg.TAG_MEDIA_CODE
              , i_tag_value          => l_amx_fin_rec.media_code
            );
            h2h_api_tag_pkg.add_tag_value(
                io_tag_value_tab     => l_tag_value_tab
              , i_tag_id             => h2h_api_const_pkg.TAG_ICC_CHIP_PIN_IND
              , i_tag_value          => l_amx_fin_rec.icc_pin_indicator
            );

            h2h_api_tag_pkg.save_tag_value(
                i_fin_id             => l_h2h_rec.id
              , io_tag_value_tab     => l_tag_value_tab
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_amx_pres;

procedure create_fin_msg_from_mup_pres
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_fin_msg_from_mup_pres: ';
    l_h2h_rec                   h2h_api_type_pkg.t_h2h_fin_message_rec;
    l_fin_fields                com_api_type_pkg.t_param_tab;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_standard_version          com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'start with operation ID [#1]'
      , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
    );

    if opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        if  h2h_api_fin_message_pkg.message_exists(
                i_fin_id => opr_api_shared_data_pkg.g_operation.id
            ) = com_api_const_pkg.TRUE
        then
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'outgoing H2H message for operation [#1] already exists'
              , i_env_param1    => opr_api_shared_data_pkg.g_operation.id
            );
        else
            mup_api_fin_pkg.get_fin_message(
                i_id            => opr_api_shared_data_pkg.g_operation.id
              , o_fin_fields    => l_fin_fields
              , i_mask_error    => com_api_const_pkg.FALSE
            );

            init_fin_message(
                io_h2h_fin_msg_rec  => l_h2h_rec
              , o_standard_version  => l_standard_version
            );

            l_h2h_rec.id                         := opr_api_shared_data_pkg.g_operation.id;
            l_h2h_rec.is_reversal                := l_fin_fields('is_reversal');
            l_h2h_rec.is_rejected                := l_fin_fields('is_rejected');
            l_h2h_rec.dispute_id                 := l_fin_fields('dispute_id');
            l_h2h_rec.msg_type                   := aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
            l_h2h_rec.sttl_rate                  := l_fin_fields('de009');
            l_h2h_rec.crdh_bill_amount_value     := l_fin_fields('de006');
            l_h2h_rec.crdh_bill_amount_currency  := l_fin_fields('de051');
            l_h2h_rec.crdh_bill_rate             := l_fin_fields('de010');
            l_h2h_rec.arn                        := nvl(l_fin_fields('de031'), opr_api_shared_data_pkg.g_operation.network_refnum);
            l_h2h_rec.approval_code              := l_fin_fields('de038');
            l_h2h_rec.rrn                        := nvl(l_fin_fields('de037'), opr_api_shared_data_pkg.g_operation.originator_refnum);
            l_h2h_rec.trn                        := l_fin_fields('de063');

            l_h2h_rec.emv_5f2a                   := l_fin_fields('emv_5f2a');
            l_h2h_rec.emv_5f34                   := null;
            l_h2h_rec.emv_71                     := l_fin_fields('emv_71');
            l_h2h_rec.emv_72                     := l_fin_fields('emv_72');
            l_h2h_rec.emv_82                     := l_fin_fields('emv_82');
            l_h2h_rec.emv_84                     := l_fin_fields('emv_84');
            l_h2h_rec.emv_8a                     := l_fin_fields('emv_8a');
            l_h2h_rec.emv_91                     := l_fin_fields('emv_91');
            l_h2h_rec.emv_95                     := l_fin_fields('emv_95');
            l_h2h_rec.emv_9a                     := to_char(l_fin_fields('emv_9a'), 'yymmdd');
            l_h2h_rec.emv_9c                     := l_fin_fields('emv_9c');
            l_h2h_rec.emv_9f02                   := l_fin_fields('emv_9f02');
            l_h2h_rec.emv_9f03                   := l_fin_fields('emv_9f03');
            l_h2h_rec.emv_9f06                   := null;
            l_h2h_rec.emv_9f09                   := l_fin_fields('emv_9f09');
            l_h2h_rec.emv_9f10                   := l_fin_fields('emv_9f10');
            l_h2h_rec.emv_9f18                   := null;
            l_h2h_rec.emv_9f1a                   := l_fin_fields('emv_9f1a');
            l_h2h_rec.emv_9f1e                   := l_fin_fields('emv_9f1e');
            l_h2h_rec.emv_9f26                   := l_fin_fields('emv_9f26');
            l_h2h_rec.emv_9f27                   := l_fin_fields('emv_9f27');
            l_h2h_rec.emv_9f28                   := null;
            l_h2h_rec.emv_9f29                   := null;
            l_h2h_rec.emv_9f33                   := l_fin_fields('emv_9f33');
            l_h2h_rec.emv_9f34                   := l_fin_fields('emv_9f34');
            l_h2h_rec.emv_9f35                   := l_fin_fields('emv_9f35');
            l_h2h_rec.emv_9f36                   := l_fin_fields('emv_9f36');
            l_h2h_rec.emv_9f37                   := l_fin_fields('emv_9f37');
            l_h2h_rec.emv_9f41                   := l_fin_fields('emv_9f41');
            l_h2h_rec.emv_9f53                   := l_fin_fields('emv_9f53');

            l_h2h_rec.pdc_1                      := l_fin_fields('de022_1');
            l_h2h_rec.pdc_2                      := l_fin_fields('de022_2');
            l_h2h_rec.pdc_3                      := l_fin_fields('de022_3');
            l_h2h_rec.pdc_4                      := l_fin_fields('de022_4');
            l_h2h_rec.pdc_5                      := l_fin_fields('de022_5');
            l_h2h_rec.pdc_6                      := substr(l_fin_fields('de022_6'), 1, 1);
            l_h2h_rec.pdc_7                      := substr(l_fin_fields('de022_6'), 2, 1);
            l_h2h_rec.pdc_8                      := l_fin_fields('de022_7');
            l_h2h_rec.pdc_9                      := l_fin_fields('de022_8');
            l_h2h_rec.pdc_10                     := l_fin_fields('de022_9');
            l_h2h_rec.pdc_11                     := l_fin_fields('de022_10');
            l_h2h_rec.pdc_12                     := l_fin_fields('de022_11');

            h2h_api_tag_pkg.collect_tags(
                i_fin_id            => l_h2h_rec.id
              , i_ips_fin_fields    => l_fin_fields
              , i_ips_code          => h2h_api_const_pkg.MODULE_CODE_MASTERCARD
              , o_tag_value_tab     => l_tag_value_tab
            );

            -- Specific processing of PDS 0176
            if l_fin_fields('p0176') is not null then
                h2h_api_tag_pkg.add_tag_value(
                    io_tag_value_tab     => l_tag_value_tab
                  , i_tag_id             => aup_api_tag_pkg.find_tag_by_reference('DF8A2B')
                  , i_tag_value          => l_fin_fields('p0176')
                );
            end if;

            h2h_api_tag_pkg.save_tag_value(
                i_fin_id          => l_h2h_rec.id
              , io_tag_value_tab  => l_tag_value_tab
            );

            l_h2h_rec.id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_rec);
        end if;
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'finish'
    );
end create_fin_msg_from_mup_pres;

end;
/
