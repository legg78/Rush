create or replace force view cst_ui_mpu_file_vw as
select f.id
     , f.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => f.inst_id, i_lang => l.lang)inst_name
     , f.network_id
     , f.is_incoming
     , f.iin
     , f.trans_date
     , f.trans_total
     , f.generator
     , f.file_date
     , f.session_file_id
     , f.file_type
     , f.file_number
     , f.inst_role
     , f.data_type
     , f.proc_date
     , l.lang
  from cst_mpu_file f
     , com_language_vw l
/
