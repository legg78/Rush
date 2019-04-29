create or replace force view h2h_file_vw as
select f.id
     , f.file_type
     , f.file_date
     , f.session_file_id
     , f.proc_date
     , f.is_incoming
     , f.is_rejected
     , f.orig_file_id
     , f.network_id
     , f.inst_id
     , f.forw_inst_code
     , f.receiv_inst_code
  from h2h_file f
/
