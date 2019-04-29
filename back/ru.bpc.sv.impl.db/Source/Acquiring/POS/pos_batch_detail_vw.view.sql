create or replace force view pos_batch_detail_vw as
select d.id
     , d.batch_block_id
     , d.record_type
     , d.record_number
     , d.voucher_number
     , d.card_number
     , d.card_member_number
     , d.card_expir_date
     , d.trans_amount
     , d.trans_currency
     , d.debit_credit
     , d.trans_date
     , d.trans_time
     , d.auth_code
     , d.trans_type
     , d.utrnno 
     , d.is_reversal
     , d.auth_utrnno
     , d.pos_data_code
     , d.retrieval_reference_number
     , d.trace_number
     , d.network_id
     , d.acq_inst_id
     , d.trans_status
     , d.add_data
     , d.emv_data
     , d.service_id
     , d.payment_details
     , d.service_provider_id
     , d.unique_number_payment
     , d.add_amounts
     , d.svfe_trace_number
  from pos_batch_detail d
/
