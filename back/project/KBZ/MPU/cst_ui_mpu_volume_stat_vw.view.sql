create or replace force view cst_mpu_volume_stat_vw as
select s.id
     , s.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => s.inst_id, i_lang => l.lang) inst_name
     , s.network_id
     , s.status
     , s.file_id
     , s.record_type
     , s.member_inst_code
     , s.sttl_currency
     , s.stat_trans_code
     , s.summary
     , s.credit_amount
     , s.debit_amount
     , l.lang
  from cst_mpu_volume_stat s
     , com_language_vw l
/
