create or replace force view mcw_abu_iss_msg_vw as
select id
     , split_hash
     , status
     , inst_id
     , network_id
     , proc_date
     , file_id
     , event_object_id
     , confirm_file_id
     , issuer_ica
     , iss_api_token_pkg.decode_card_number(i_card_number => old_card_number) as old_card_number
     , old_expiration_date
     , iss_api_token_pkg.decode_card_number(i_card_number => new_card_number) as new_card_number
     , new_expiration_date
     , reason_code
     , error_code_1
     , error_code_2
     , error_code_3
     , error_code_4
     , error_code_5
  from mcw_abu_iss_msg
/
