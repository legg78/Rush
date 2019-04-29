create or replace force view vis_ui_vcr_advice_vw as
select a.id
     , a.file_id
     , a.record_number
     , a.status
     , a.inst_id
     , a.trans_code
     , a.trans_code_qualifier
     , a.trans_component_seq
     , a.dest_bin
     , a.source_bin
     , a.vcr_record_id
     , a.dispute_status
     , a.dispute_trans_code
     , a.dispute_tc_qualifier
     , a.orig_recipient_ind
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
     , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_mask
     , a.card_number_ext
     , a.acq_ref_number
     , a.purchase_date
     , a.source_amount
     , a.source_curr_code
     , a.merchant_name
     , a.merchant_city
     , a.merchant_country
     , a.mcc
     , a.merchant_region_code
     , a.merchant_postal_code
     , a.req_payment_service
     , a.auth_code
     , a.pos_entry_mode
     , a.central_proc_date
     , a.card_acceptor_id
     , a.reimbursement
     , a.network_code
     , a.dispute_condition
     , a.vrol_fin_id
     , a.vrol_case_number
     , a.vrol_bundle_case_num
     , a.client_case_number
     , a.clearing_seq_number
     , a.clearing_seq_count
     , a.product_id
     , a.spend_qualified_ind
     , a.dsp_fin_reason_code
     , a.processing_code
     , a.settlement_flag
     , a.usage_code
     , a.trans_identifier
     , a.acq_business_id
     , a.orig_trans_amount
     , a.orig_trans_curr_code
     , a.spec_chargeback_ind
     , a.pos_condition_code
     , a.rrn
     , a.acq_inst_code
     , a.message_reason_code
     , a.dest_amount
     , a.dest_curr_code
     , a.src_sttl_amount_sign 
     , l.lang
  from vis_vcr_advice a
     , vis_card c
     , com_language_vw l
 where c.id = a.id
/

