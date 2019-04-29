create or replace force view opr_ui_pos_batch_vw as
select b.oper_id
     , b.voucher_number
     , b.debit_credit
     , b.trans_type
     , b.pos_data_code
     , b.trans_status
     , b.add_data
     , b.emv_data
     , b.service_id
     , b.payment_details
     , b.service_provider_id
     , b.unique_number_payment
     , b.add_amounts
     , b.svfe_trace_number
     , l.lang
  from opr_pos_batch   b
     , com_language_vw l
/