create or replace force view cst_mpu_file_vw as
select f.id
     , f.inst_id
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
  from cst_mpu_file f
/
