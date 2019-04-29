create or replace force view mcw_ui_abu_acq_msg_vw as 
select m.id
     , m.status
     , m.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => m.inst_id) inst_name
     , m.network_id
     , com_ui_object_search_pkg.get_network_name(i_network_id => m.network_id) network_name
     , m.request_date
     , m.file_id
     , f.file_name
     , m.event_object_id
     , m.confirm_file_id
     , m.acquirer_ica
     , m.request_type
     , m.merchant_number
     , m.merchant_name
     , m.mcc
     , m.error_code_1
     , m.error_code_2
     , m.error_code_3
     , m.error_code_4
     , m.error_code_5
     , m.error_code_6
     , m.error_code_7
     , m.error_code_8
     , f.session_id
     , l.lang
  from mcw_abu_acq_msg m
     , prc_session_file f
     , com_language_vw l
 where f.id(+) = m.file_id
/
