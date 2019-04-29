create or replace force view cst_ui_mpu_mrch_settlement_vw as
select s.id
     , s.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => s.inst_id, i_lang => l.lang) inst_name
     , s.network_id
     , s.status
     , s.file_id
     , s.record_type
     , s.member_inst_code
     , s.merchant_number
     , s.in_amount_sign
     , s.in_amount
     , s.in_fee_sign
     , s.in_fee_amount
     , s.total_sttl_amount_sign
     , s.total_sttl_amount
     , s.in_summary
     , s.sttl_currency
     , s.mrch_sttl_account
     , l.lang
  from cst_mpu_mrch_settlement s
     , com_language_vw l
/
