create or replace force view cst_ui_mpu_fund_stat_vw as
select s.id
     , s.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => s.inst_id, i_lang => l.lang) inst_name
     , s.network_id
     , s.status
     , s.file_id
     , s.record_type
     , s.member_inst_code
     , s.out_amount_sign
     , s.out_amount
     , s.out_fee_sign
     , s.out_fee_amount
     , s.in_amount_sign
     , s.in_amount
     , s.in_fee_sign
     , s.in_fee_amount
     , s.stf_amount_sign
     , s.stf_amount
     , s.stf_fee_sign
     , s.stf_fee_amount
     , s.out_summary
     , s.in_summary
     , s.sttl_currency
     , l.lang
  from cst_mpu_fund_stat s
     , com_language_vw l
/
