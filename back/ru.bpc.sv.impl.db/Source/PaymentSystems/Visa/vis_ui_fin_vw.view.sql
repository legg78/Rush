create or replace force view vis_ui_fin_vw as
select a.id
     , a.status
     , get_article_text ( i_article => a.status
                        , i_lang    => l.lang
       ) status_desc
     , a.file_id
     , a.batch_id
     , a.record_number
     , a.is_reversal
     , a.is_incoming
     , a.is_returned
     , a.is_invalid
     , a.dispute_id
     , a.rrn
     , a.inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => a.inst_id
                , i_lang        => l.lang
       ) inst_name
     , a.network_id
     , get_text ( i_table_name  => 'net_network'
                , i_column_name => 'name'
                , i_object_id   => a.network_id
                , i_lang        => l.lang
       ) network_name
     , a.trans_code
     , a.trans_code_qualifier
     , a.card_id
     , a.card_mask
     , a.card_hash
     , a.oper_amount
     , a.oper_currency
     , a.oper_date
     , a.sttl_amount
     , a.sttl_currency
     , a.network_amount
     , a.network_currency
     , a.floor_limit_ind
     , a.exept_file_ind
     , a.pcas_ind
     , a.arn
     , a.acquirer_bin
     , a.acq_business_id
     , a.merchant_name
     , a.merchant_city
     , a.merchant_country
     , a.merchant_postal_code
     , a.merchant_region
     , a.merchant_street
     , a.mcc
     , a.req_pay_service
     , a.usage_code
     , a.reason_code
     , a.settlement_flag
     , a.auth_char_ind
     , a.auth_code
     , a.pos_terminal_cap
     , a.inter_fee_ind
     , a.crdh_id_method
     , a.collect_only_flag
     , a.pos_entry_mode
     , a.central_proc_date
     , a.reimburst_attr
     , a.iss_workst_bin
     , a.acq_workst_bin
     , a.chargeback_ref_num
     , a.docum_ind
     , a.member_msg_text
     , a.spec_cond_ind
     , a.fee_program_ind
     , a.issuer_charge
     , a.merchant_number
     , a.terminal_number
     , a.national_reimb_fee
     , a.electr_comm_ind
     , a.spec_chargeback_ind
     , a.interface_trace_num
     , a.unatt_accept_term_ind
     , a.prepaid_card_ind
     , a.service_development
     , a.avs_resp_code
     , a.auth_source_code
     , a.purch_id_format
     , a.account_selection
     , a.installment_pay_count
     , a.purch_id
     , a.cashback
     , a.chip_cond_code
     , a.pos_environment
     , a.transaction_type
     , a.card_seq_number
     , a.terminal_profile
     , a.unpredict_number
     , a.appl_trans_counter
     , a.appl_interch_profile
     , a.cryptogram
     , a.card_verif_result
     , a.issuer_appl_data
     , a.issuer_script_result
     , a.card_expir_date
     , a.cryptogram_version
     , a.cvv2_result_code
     , a.auth_resp_code
     , a.cryptogram_info_data
     , a.transaction_id
     , a.merchant_verif_value
     , a.host_inst_id
     , a.proc_bin
     , a.chargeback_reason_code
     , a.destination_channel
     , a.source_channel
     , a.acq_inst_bin
     , a.spend_qualified_ind
     , a.recipient_name
     , l.lang
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
     , t4.agent_unique_id
     , t4.trans_comp_number
     , t4.business_format_code as business_format_code_4
     , t4.contact_information
     , t4.adjustment_indicator
     , t4.message_reason_code
     , t4.dispute_condition
     , t4.vrol_financial_id
     , t4.vrol_case_number
     , t4.vrol_bundle_number
     , t4.client_case_number
     , t4.dispute_status
     , t4.surcharge_amount
     , t4.surcharge_sign
     , t4.payment_acc_ref
     , t4.token_requestor_id
     , t3.trans_comp_number as trans_comp_number_tcr3
     , t3.business_application_id as business_application_id_tcr3
     , t3.business_format_code as business_format_code_tcr3
     , t3.passenger_name
     , t3.departure_date
     , t3.orig_city_airport_code
     , t3.carrier_code_1
     , t3.service_class_code_1
     , t3.stop_over_code_1
     , t3.dest_city_airport_code_1
     , t3.carrier_code_2
     , t3.service_class_code_2
     , t3.stop_over_code_2
     , t3.dest_city_airport_code_2
     , t3.carrier_code_3
     , t3.service_class_code_3
     , t3.stop_over_code_3
     , t3.dest_city_airport_code_3
     , t3.carrier_code_4
     , t3.service_class_code_4
     , t3.stop_over_code_4
     , t3.dest_city_airport_code_4
     , t3.travel_agency_code
     , t3.travel_agency_name
     , t3.restrict_ticket_indicator
     , t3.fare_basis_code_1
     , t3.fare_basis_code_2
     , t3.fare_basis_code_3
     , t3.fare_basis_code_4
     , t3.comp_reserv_system
     , t3.flight_number_1
     , t3.flight_number_2
     , t3.flight_number_3
     , t3.flight_number_4
     , t3.credit_reason_indicator
     , t3.ticket_change_indicator
  from vis_fin_message a
     , vis_card c
     , vis_tcr4 t4
     , vis_tcr3 t3
     , com_language_vw l
 where a.id = c.id(+)
   and a.id = t4.id(+)
   and a.id = t3.id(+)
/
