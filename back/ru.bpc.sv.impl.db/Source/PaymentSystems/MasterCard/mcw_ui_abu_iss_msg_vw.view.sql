create or replace force view mcw_ui_abu_iss_msg_vw as
select m.id
     , m.status
     , m.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => m.inst_id) inst_name
     , m.network_id
     , com_ui_object_search_pkg.get_network_name(i_network_id => m.network_id) network_name
     , m.proc_date
     , m.file_id
     , f.file_name
     , m.event_object_id
     , m.confirm_file_id
     , m.issuer_ica
     , iss_api_token_pkg.decode_card_number(i_card_number => m.old_card_number) as old_card_number
     , iss_api_card_pkg.get_card_mask(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => m.old_card_number)) as old_card_mask
     , m.old_expiration_date
     , iss_api_token_pkg.decode_card_number(i_card_number => m.new_card_number) as new_card_number
     , iss_api_card_pkg.get_card_mask(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => m.new_card_number)) as new_card_mask
     , m.new_expiration_date
     , m.reason_code
     , m.error_code_1
     , m.error_code_2
     , m.error_code_3
     , m.error_code_4
     , m.error_code_5
     , f.session_id
     , l.lang
  from mcw_abu_iss_msg m
     , prc_session_file f
     , com_language_vw l
 where f.id(+) = m.file_id
/
