create or replace force view mcw_abu_acq_msg_vw as 
select id
     , split_hash
     , status
     , inst_id
     , network_id
     , request_date
     , file_id
     , event_object_id
     , confirm_file_id
     , acquirer_ica
     , request_type
     , merchant_number
     , merchant_name
     , mcc
     , error_code_1
     , error_code_2
     , error_code_3
     , error_code_4
     , error_code_5
     , error_code_6
     , error_code_7
     , error_code_8
  from mcw_abu_acq_msg
/
