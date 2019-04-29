create or replace force view mcw_ui_abu_file_vw as 
select f.id
     , sf.session_id
     , sf.file_name 
     , f.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => f.inst_id) inst_name
     , f.network_id
     , com_ui_object_search_pkg.get_network_name(i_network_id => f.network_id) network_name
     , f.file_type
     , f.proc_date
     , f.is_incoming
     , f.business_ica
     , f.reason_code
     , f.original_file_date
     , f.total_msg_count
     , f.total_add_count
     , f.total_changed_count
     , f.total_error_count
     , f.record_count
     , l.lang
  from mcw_abu_file f
  left join prc_session_file sf on sf.id = f.id
  cross join com_language_vw l
/     
