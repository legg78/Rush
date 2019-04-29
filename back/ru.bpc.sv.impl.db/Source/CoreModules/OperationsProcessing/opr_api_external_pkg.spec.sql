create or replace package opr_api_external_pkg as
/**********************************************************
 * API external for OPR <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 06.03.2018 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />Thank you, very much! I will wait so many as how necessary!
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: OPR_API_EXTERNAL_PKG
 * @headcom
 **********************************************************/        

type t_turnover_info_rec is record (oper_id                        com_api_type_pkg.t_long_id
                                  , oper_type                      com_api_type_pkg.t_dict_value
                                  , msg_type                       com_api_type_pkg.t_dict_value
                                  , sttl_type                      com_api_type_pkg.t_dict_value
                                  , reconciliation_type            com_api_type_pkg.t_dict_value
                                  , oper_date                      date
                                  , host_date                      date
                                  , oper_count                     com_api_type_pkg.t_long_id   
                                  , oper_amount_currency           com_api_type_pkg.t_dict_value
                                  , oper_amount                    com_api_type_pkg.t_money
                                  , oper_request_amount            com_api_type_pkg.t_money
                                  , oper_surcharge_amount          com_api_type_pkg.t_money
                                  , oper_cashback_amount           com_api_type_pkg.t_money
                                  , sttt_amount                    com_api_type_pkg.t_money
                                  , sttt_amount_currency           com_api_type_pkg.t_dict_value
                                  , interchange_fee_amount         com_api_type_pkg.t_money
                                  , interchange_feet_currency      com_api_type_pkg.t_dict_value
                                  , originator_refnum              com_api_type_pkg.t_rrn
                                  , network_refnum                 com_api_type_pkg.t_rrn
                                  , acq_inst_bin                   com_api_type_pkg.t_cmid
                                  , forwarding_inst_bin            com_api_type_pkg.t_cmid
                                  , response_code                  com_api_type_pkg.t_dict_value
                                  , oper_reason                    com_api_type_pkg.t_dict_value
                                  , status                         com_api_type_pkg.t_dict_value
                                  , status_reason                  com_api_type_pkg.t_dict_value
                                  , is_reversal                    com_api_type_pkg.t_boolean
                                  , merchant_number                com_api_type_pkg.t_merchant_number
                                  , mcc                            com_api_type_pkg.t_mcc
                                  , merchant_name                  com_api_type_pkg.t_name
                                  , merchant_street                com_api_type_pkg.t_name
                                  , merchant_city                  com_api_type_pkg.t_name
                                  , merchant_region                com_api_type_pkg.t_country_code
                                  , merchant_country               com_api_type_pkg.t_country_code
                                  , merchant_postcode              com_api_type_pkg.t_postal_code
                                  , terminal_type                  com_api_type_pkg.t_dict_value
                                  , terminal_number                com_api_type_pkg.t_dict_value
                                  , risk_indicator                 com_api_type_pkg.t_dict_value
                                  , sttl_date                      date
                                  , acq_sttl_date                  date
                                  , match_id                       com_api_type_pkg.t_long_id
                                  , match_status                   com_api_type_pkg.t_dict_value
                                  , clearing_sequence_num          com_api_type_pkg.t_seqnum
                                  , clearing_sequence_count        com_api_type_pkg.t_seqnum
                                  , payment_order_id               com_api_type_pkg.t_long_id
                                  , resp_code                      com_api_type_pkg.t_dict_value
                                  , proc_type                      com_api_type_pkg.t_dict_value
                                  , proc_mode                      com_api_type_pkg.t_dict_value
                                  , is_advice                      com_api_type_pkg.t_boolean
                                  , is_repeat                      com_api_type_pkg.t_boolean
                                  , bin_amount                     com_api_type_pkg.t_long_id
                                  , bin_currency                   com_api_type_pkg.t_curr_code
                                  , bin_cnvt_rate                  com_api_type_pkg.t_long_id
                                  , network_amount                 com_api_type_pkg.t_long_id
                                  , network_currency               com_api_type_pkg.t_curr_code
                                  , network_cnvt_date              date
                                  , network_cnvt_rate              com_api_type_pkg.t_long_id
                                  , account_cnvt_rate              com_api_type_pkg.t_long_id
                                  , addr_verif_result              com_api_type_pkg.t_dict_value
                                  , acq_resp_code                  com_api_type_pkg.t_dict_value
                                  , acq_device_proc_result         com_api_type_pkg.t_dict_value
                                  , cat_level                      com_api_type_pkg.t_dict_value
                                  , card_data_input_cap            com_api_type_pkg.t_dict_value
                                  , crdh_auth_cap                  com_api_type_pkg.t_dict_value
                                  , card_capture_cap               com_api_type_pkg.t_dict_value
                                  , terminal_operating_env         com_api_type_pkg.t_dict_value
                                  , crdh_presence                  com_api_type_pkg.t_dict_value
                                  , card_presence                  com_api_type_pkg.t_dict_value
                                  , card_data_input_mode           com_api_type_pkg.t_dict_value
                                  , crdh_auth_method               com_api_type_pkg.t_dict_value
                                  , crdh_auth_entity               com_api_type_pkg.t_dict_value
                                  , card_data_output_cap           com_api_type_pkg.t_dict_value
                                  , terminal_output_cap            com_api_type_pkg.t_dict_value
                                  , pin_capture_cap                com_api_type_pkg.t_dict_value
                                  , pin_presence                   com_api_type_pkg.t_dict_value
                                  , cvv2_presence                  com_api_type_pkg.t_dict_value
                                  , cvc_indicator                  com_api_type_pkg.t_dict_value
                                  , pos_entry_mode                 com_api_type_pkg.t_dict_value
                                  , pos_cond_code                  com_api_type_pkg.t_dict_value
                                  , emv_data                       com_api_type_pkg.t_param_value
                                  , atc                            com_api_type_pkg.t_dict_value
                                  , tvr                            com_api_type_pkg.t_name
                                  , cvr                            com_api_type_pkg.t_name
                                  , addl_data                      com_api_type_pkg.t_param_value
                                  , service_code                   com_api_type_pkg.t_dict_value
                                  , device_date                    date
                                  , cvv2_result                    com_api_type_pkg.t_dict_value
                                  , certificate_method             com_api_type_pkg.t_dict_value
                                  , certificate_type               com_api_type_pkg.t_dict_value
                                  , merchant_certif                com_api_type_pkg.t_name
                                  , cardholder_certif              com_api_type_pkg.t_name
                                  , ucaf_indicator                 com_api_type_pkg.t_dict_value
                                  , is_early_emv                   com_api_type_pkg.t_boolean
                                  , is_completed                   com_api_type_pkg.t_dict_value
                                  , amounts                        com_api_type_pkg.t_text
                                  , system_trace_audit_number      com_api_type_pkg.t_name
                                  , transaction_id                 com_api_type_pkg.t_name
                                  , external_auth_id               com_api_type_pkg.t_name
                                  , external_orig_id               com_api_type_pkg.t_name
                                  , agent_unique_id                com_api_type_pkg.t_name
                                  , native_resp_code               com_api_type_pkg.t_dict_value
                                  , auth_purpose_id                com_api_type_pkg.t_long_id
);  

type t_turnover_info_tab is table of t_turnover_info_rec index by binary_integer;

type t_ipm_data_rec is record (is_incoming  mcw_fin.is_incoming%type
                             , is_reversal  mcw_fin.is_reversal%type
                             , is_rejected  mcw_fin.is_rejected%type
                             , impact       mcw_fin.impact%type
                             , mti          mcw_fin.mti%type
                             , de024        mcw_fin.de024%type
                             , de002        mcw_fin.de002%type
                             , de003_1      mcw_fin.de003_1%type
                             , de003_2      mcw_fin.de003_2%type
                             , de003_3      mcw_fin.de003_3%type
                             , de004        mcw_fin.de004%type
                             , de005        mcw_fin.de005%type
                             , de006        mcw_fin.de006%type
                             , de009        mcw_fin.de009%type
                             , de010        mcw_fin.de010%type
                             , de012        mcw_fin.de012%type
                             , de014        mcw_fin.de014%type
                             , de022_1      mcw_fin.de022_1%type
                             , de022_2      mcw_fin.de022_2%type
                             , de022_3      mcw_fin.de022_3%type
                             , de022_4      mcw_fin.de022_4%type
                             , de022_5      mcw_fin.de022_5%type
                             , de022_6      mcw_fin.de022_6%type
                             , de022_7      mcw_fin.de022_7%type
                             , de022_8      mcw_fin.de022_8%type
                             , de022_9      mcw_fin.de022_9%type
                             , de022_10     mcw_fin.de022_10%type
                             , de022_11     mcw_fin.de022_11%type
                             , de022_12     mcw_fin.de022_12%type
                             , de023        mcw_fin.de023%type
                             , de025        mcw_fin.de025%type
                             , de026        mcw_fin.de026%type
                             , de030_1      mcw_fin.de030_1%type
                             , de030_2      mcw_fin.de030_2%type
                             , de031        mcw_fin.de031%type
                             , de032        mcw_fin.de032%type
                             , de033        mcw_fin.de033%type
                             , de037        mcw_fin.de037%type
                             , de038        mcw_fin.de038%type
                             , de040        mcw_fin.de040%type
                             , de041        mcw_fin.de041%type
                             , de042        mcw_fin.de042%type
                             , de043_1      mcw_fin.de043_1%type
                             , de043_2      mcw_fin.de043_2%type
                             , de043_3      mcw_fin.de043_3%type
                             , de043_4      mcw_fin.de043_4%type
                             , de043_5      mcw_fin.de043_5%type
                             , de043_6      mcw_fin.de043_6%type
                             , de049        mcw_fin.de049%type
                             , de050        mcw_fin.de050%type
                             , de051        mcw_fin.de051%type
                             , de054        mcw_fin.de054%type
                             , de055        mcw_fin.de055%type
                             , de063        mcw_fin.de063%type
                             , de071        mcw_fin.de071%type
                             , de072        mcw_fin.de072%type
                             , de073        mcw_fin.de073%type
                             , de093        mcw_fin.de093%type
                             , de094        mcw_fin.de094%type
                             , de095        mcw_fin.de095%type
                             , de100        mcw_fin.de100%type
                             , de111        mcw_fin.de111%type
                             , p0002        mcw_fin.p0002%type
                             , p0023        mcw_fin.p0023%type
                             , p0025_1      mcw_fin.p0025_1%type
                             , p0025_2      mcw_fin.p0025_2%type
                             , p0043        mcw_fin.p0043%type
                             , p0052        mcw_fin.p0052%type
                             , p0137        mcw_fin.p0137%type
                             , p0148        mcw_fin.p0148%type
                             , p0146        mcw_fin.p0146%type
                             , p0146_net    mcw_fin.p0146_net%type
                             , p0147        mcw_fin.p0147%type
                             , p0149_1      mcw_fin.p0149_1%type
                             , p0149_2      mcw_fin.p0149_2%type
                             , p0158_1      mcw_fin.p0158_1%type
                             , p0158_2      mcw_fin.p0158_2%type
                             , p0158_3      mcw_fin.p0158_3%type
                             , p0158_4      mcw_fin.p0158_4%type
                             , p0158_5      mcw_fin.p0158_5%type
                             , p0158_6      mcw_fin.p0158_6%type
                             , p0158_7      mcw_fin.p0158_7%type
                             , p0158_8      mcw_fin.p0158_8%type
                             , p0158_9      mcw_fin.p0158_9%type
                             , p0158_10     mcw_fin.p0158_10%type
                             , p0159_1      mcw_fin.p0159_1%type
                             , p0159_2      mcw_fin.p0159_2%type
                             , p0159_3      mcw_fin.p0159_3%type
                             , p0159_4      mcw_fin.p0159_4%type
                             , p0159_5      mcw_fin.p0159_5%type
                             , p0159_6      mcw_fin.p0159_6%type
                             , p0159_7      mcw_fin.p0159_7%type
                             , p0159_8      mcw_fin.p0159_8%type
                             , p0159_9      mcw_fin.p0159_9%type
                             , p0165        mcw_fin.p0165%type
                             , p0176        mcw_fin.p0176%type
                             , p0208_1      mcw_fin.p0208_1%type
                             , p0208_2      mcw_fin.p0208_2%type
                             , p0209        mcw_fin.p0209%type
                             , p0228        mcw_fin.p0228%type
                             , p0230        mcw_fin.p0230%type
                             , p0241        mcw_fin.p0241%type
                             , p0243        mcw_fin.p0243%type
                             , p0244        mcw_fin.p0244%type
                             , p0260        mcw_fin.p0260%type
                             , p0261        mcw_fin.p0261%type
                             , p0262        mcw_fin.p0262%type
                             , p0264        mcw_fin.p0264%type
                             , p0265        mcw_fin.p0265%type
                             , p0266        mcw_fin.p0266%type
                             , p0267        mcw_fin.p0267%type
                             , p0268_1      mcw_fin.p0268_1%type
                             , p0268_2      mcw_fin.p0268_2%type
                             , p0375        mcw_fin.p0375%type
                             , emv_9f26     mcw_fin.emv_9f26%type
                             , emv_9f02     mcw_fin.emv_9f02%type
                             , emv_9f27     mcw_fin.emv_9f27%type
                             , emv_9f10     mcw_fin.emv_9f10%type
                             , emv_9f36     mcw_fin.emv_9f36%type
                             , emv_95       mcw_fin.emv_95%type
                             , emv_82       mcw_fin.emv_82%type
                             , emv_9a       mcw_fin.emv_9a%type
                             , emv_9c       mcw_fin.emv_9c%type
                             , emv_9f37     mcw_fin.emv_9f37%type
                             , emv_5f2a     mcw_fin.emv_5f2a%type
                             , emv_9f33     mcw_fin.emv_9f33%type
                             , emv_9f34     mcw_fin.emv_9f34%type
                             , emv_9f1a     mcw_fin.emv_9f1a%type
                             , emv_9f35     mcw_fin.emv_9f35%type
                             , emv_9f53     mcw_fin.emv_9f53%type
                             , emv_84       mcw_fin.emv_84%type
                             , emv_9f09     mcw_fin.emv_9f09%type
                             , emv_9f03     mcw_fin.emv_9f03%type
                             , emv_9f1e     mcw_fin.emv_9f1e%type
                             , emv_9f41     mcw_fin.emv_9f41%type
                             , p0042        mcw_fin.p0042%type
                             , p0158_11     mcw_fin.p0158_11%type
                             , p0158_12     mcw_fin.p0158_12%type
                             , p0158_13     mcw_fin.p0158_13%type
                             , p0158_14     mcw_fin.p0158_14%type
                             , p0198        mcw_fin.p0198%type
                             , p0200_1      mcw_fin.p0200_1%type
                             , p0200_2      mcw_fin.p0200_2%type
                             , p0210_1      mcw_fin.p0210_1%type
                             , p0210_2      mcw_fin.p0210_2%type
                             , p0302        mcw_spd.p0302%type
                             , p0368        mcw_spd.p0368%type
);

type t_baseii_data_rec is record (is_reversal             com_api_type_pkg.t_boolean
                                , is_incoming             com_api_type_pkg.t_boolean
                                , is_returned             com_api_type_pkg.t_boolean
                                , is_invalid              com_api_type_pkg.t_boolean
                                , trans_code              vis_fin_message.trans_code%type
                                , trans_code_qualifier    vis_fin_message.trans_code_qualifier%type
                                , card_mask               vis_fin_message.card_mask%type
                                , oper_amount             vis_fin_message.oper_amount%type
                                , oper_currency           vis_fin_message.oper_currency%type
                                , oper_date               vis_fin_message.oper_date%type
                                , sttl_amount             vis_fin_message.sttl_amount%type
                                , sttl_currency           vis_fin_message.sttl_currency%type
                                , network_amount          vis_fin_message.network_amount%type
                                , network_currency        vis_fin_message.network_currency%type
                                , floor_limit_ind         vis_fin_message.floor_limit_ind%type
                                , exept_file_ind          vis_fin_message.exept_file_ind%type
                                , pcas_ind                vis_fin_message.pcas_ind%type
                                , arn                     vis_fin_message.arn%type
                                , acquirer_bin            vis_fin_message.acquirer_bin%type
                                , acq_business_id         vis_fin_message.acq_business_id%type
                                , merchant_name           vis_fin_message.merchant_name%type
                                , merchant_city           vis_fin_message.merchant_city%type
                                , merchant_country        vis_fin_message.merchant_country%type
                                , merchant_postal_code    vis_fin_message.merchant_postal_code%type
                                , merchant_region         vis_fin_message.merchant_region%type
                                , merchant_street         vis_fin_message.merchant_street%type
                                , mcc                     vis_fin_message.mcc%type
                                , req_pay_service         vis_fin_message.req_pay_service%type
                                , usage_code              vis_fin_message.usage_code%type
                                , reason_code             vis_fin_message.reason_code%type
                                , settlement_flag         vis_fin_message.settlement_flag%type
                                , auth_char_ind           vis_fin_message.auth_char_ind%type
                                , auth_code               vis_fin_message.auth_code%type
                                , pos_terminal_cap        vis_fin_message.pos_terminal_cap%type
                                , inter_fee_ind           vis_fin_message.inter_fee_ind%type
                                , crdh_id_method          vis_fin_message.crdh_id_method%type
                                , collect_only_flag       vis_fin_message.collect_only_flag%type
                                , pos_entry_mode          vis_fin_message.pos_entry_mode%type
                                , central_proc_date       vis_fin_message.central_proc_date%type
                                , reimburst_attr          vis_fin_message.reimburst_attr%type
                                , iss_workst_bin          vis_fin_message.iss_workst_bin%type
                                , acq_workst_bin          vis_fin_message.acq_workst_bin%type
                                , chargeback_ref_num      vis_fin_message.chargeback_ref_num%type
                                , docum_ind               vis_fin_message.docum_ind%type
                                , member_msg_text         vis_fin_message.member_msg_text%type
                                , spec_cond_ind           vis_fin_message.spec_cond_ind%type
                                , fee_program_ind         vis_fin_message.fee_program_ind%type
                                , issuer_charge           vis_fin_message.issuer_charge%type
                                , merchant_number         vis_fin_message.merchant_number%type
                                , terminal_number         vis_fin_message.terminal_number%type
                                , national_reimb_fee      vis_fin_message.national_reimb_fee%type
                                , electr_comm_ind         vis_fin_message.electr_comm_ind%type
                                , spec_chargeback_ind     vis_fin_message.spec_chargeback_ind%type
                                , interface_trace_num     vis_fin_message.interface_trace_num%type
                                , unatt_accept_term_ind   vis_fin_message.unatt_accept_term_ind%type
                                , prepaid_card_ind        vis_fin_message.prepaid_card_ind%type
                                , service_development     vis_fin_message.service_development%type
                                , avs_resp_code           vis_fin_message.avs_resp_code%type
                                , auth_source_code        vis_fin_message.auth_source_code%type
                                , purch_id_format         vis_fin_message.purch_id_format%type
                                , account_selection       vis_fin_message.account_selection%type
                                , installment_pay_count   vis_fin_message.installment_pay_count%type
                                , purch_id                vis_fin_message.purch_id%type
                                , cashback                vis_fin_message.cashback%type
                                , chip_cond_code          vis_fin_message.chip_cond_code%type
                                , pos_environment         vis_fin_message.pos_environment%type
                                , transaction_type        vis_fin_message.transaction_type%type
                                , card_seq_number         vis_fin_message.card_seq_number%type
                                , terminal_profile        vis_fin_message.terminal_profile%type
                                , unpredict_number        vis_fin_message.unpredict_number%type
                                , appl_trans_counter      vis_fin_message.appl_trans_counter%type
                                , appl_interch_profile    vis_fin_message.appl_interch_profile%type
                                , cryptogram              vis_fin_message.cryptogram%type
                                , term_verif_result       vis_fin_message.term_verif_result%type
                                , cryptogram_amount       vis_fin_message.cryptogram_amount%type
                                , card_verif_result       vis_fin_message.card_verif_result%type
                                , issuer_appl_data        vis_fin_message.issuer_appl_data%type
                                , issuer_script_result    vis_fin_message.issuer_script_result%type
                                , card_expir_date         vis_fin_message.card_expir_date%type
                                , cryptogram_version      vis_fin_message.cryptogram_version%type
                                , cvv2_result_code        vis_fin_message.cvv2_result_code%type
                                , auth_resp_code          vis_fin_message.auth_resp_code%type
                                , cryptogram_info_data    vis_fin_message.cryptogram_info_data%type
                                , transaction_id          vis_fin_message.transaction_id%type
                                , merchant_verif_value    vis_fin_message.merchant_verif_value%type
                                , proc_bin                vis_fin_message.proc_bin%type
                                , chargeback_reason_code  vis_fin_message.chargeback_reason_code%type
                                , destination_channel     vis_fin_message.destination_channel%type
                                , source_channel          vis_fin_message.source_channel%type
                                , acq_inst_bin            vis_fin_message.acq_inst_bin%type
                                , spend_qualified_ind     vis_fin_message.spend_qualified_ind%type
                                , service_code            vis_fin_message.service_code%type
                                , product_id              vis_fin_message.product_id%type
                                , sttl_service            vis_vss2.sttl_service%type
                                , sre_id                  vis_vss2.sre_id%type
                                , up_sre_id               vis_vss2.up_sre_id%type
                                , jurisdict               vis_vss4.jurisdict%type
                                , routing                 vis_vss4.routing%type
                                , src_region              vis_vss4.src_region%type
                                , dst_region              vis_vss4.dst_region%type
                                , src_country             vis_vss4.src_country%type
                                , dst_country             vis_vss4.dst_country%type
                                , bus_tr_type             vis_vss4.bus_tr_type%type
                                , first_count             vis_vss4.first_count%type
);

type t_opr_participant_rec is record (participant_type    com_api_type_pkg.t_dict_value
                                    , client_id_type      com_api_type_pkg.t_dict_value
                                    , client_id_value     com_api_type_pkg.t_name
                                    , card_number         com_api_type_pkg.t_card_number
                                    , card_id             com_api_type_pkg.t_medium_id
                                    , card_instance_id    com_api_type_pkg.t_medium_id
                                    , card_seq_number     com_api_type_pkg.t_tiny_id
                                    , card_expir_date     date
                                    , card_country        com_api_type_pkg.t_country_code
                                    , inst_id             com_api_type_pkg.t_inst_id
                                    , network_id          com_api_type_pkg.t_network_id
                                    , auth_code           com_api_type_pkg.t_auth_code
                                    , account_number      com_api_type_pkg.t_account_number
                                    , account_amount      com_api_type_pkg.t_money
                                    , account_currency    com_api_type_pkg.t_curr_code
);

type t_opr_participant_tab is table of t_opr_participant_rec;

type t_opr_add_amount_tab is record (amount_value    com_api_type_pkg.t_money
                                   , currency        com_api_type_pkg.t_curr_code
                                   , amount_type     com_api_type_pkg.t_dict_value
);

procedure get_operations_data(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_participant_type          in  com_api_type_pkg.t_dict_value       default null
  , i_start_date                in  date
  , i_end_date                  in  date
  , i_object_tab                in  com_api_type_pkg.t_object_tab
  , i_oper_currency             in  com_api_type_pkg.t_curr_code        default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id        default null
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error                in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count                out  com_api_type_pkg.t_long_id
  , o_ref_cursor               out  com_api_type_pkg.t_ref_cur
);

procedure get_oper_participants_data(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_oper_id                       in  com_api_type_pkg.t_long_id
  , i_array_oper_paricipant_type    in  com_api_type_pkg.t_medium_id        default null
  , i_mask_error                    in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count                    out  com_api_type_pkg.t_long_id
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
);

procedure get_aggr_oper_transact_data(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_start_date                    in  date
  , i_end_date                      in  date
  , i_object_tab                    in  com_api_type_pkg.t_object_tab
  , i_oper_currency                 in  com_api_type_pkg.t_curr_code        default null
  , i_array_oper_paricipant_type    in  com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_oper_statuses_id        in  com_api_type_pkg.t_medium_id        default null
  , i_aggr_operations_type          in  com_api_type_pkg.t_boolean
  , i_aggr_opr_participant          in  com_api_type_pkg.t_boolean
  , i_aggr_terminal_type            in  com_api_type_pkg.t_boolean
  , i_aggr_balance_impact           in  com_api_type_pkg.t_boolean
  , i_mask_error                    in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_row_count                    out  com_api_type_pkg.t_long_id
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
);

procedure get_operations(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_date_type                in  com_api_type_pkg.t_dict_value  
  , i_start_date               in  date
  , i_end_date                 in  date
  , i_array_balance_type_id    in  com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_settl_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_array_operations_type_id in  com_api_type_pkg.t_medium_id        default null
  , o_ref_cursor              out  com_api_type_pkg.t_ref_cur
);

procedure get_opr_clearing_data(
    i_oper_id      in  com_api_type_pkg.t_long_id
  , o_ipm_data    out  t_ipm_data_rec
  , o_baseii_data out  t_baseii_data_rec
);

procedure get_opr_participants(
    i_oper_id              in  com_api_type_pkg.t_long_id
  , i_participant_type     in  com_api_type_pkg.t_dict_value default null
  , o_ref_cursor          out  com_api_type_pkg.t_ref_cur
);

procedure get_opr_additional_amount(
    i_oper_id              in  com_api_type_pkg.t_long_id
  , i_amount_type          in  com_api_type_pkg.t_dict_value default null
  , o_ref_cursor          out  com_api_type_pkg.t_ref_cur
);

end opr_api_external_pkg;
/
