create or replace force view aup_ui_visa_sms_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_AUTH_ID', l.lang)
     , 'AUP_VISA_SMS_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_AUTH_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.AUTH_ID as column_number_value
     , to_date(null) as column_date_value
     , 1 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TECH_ID', l.lang)
     , 'AUP_VISA_SMS_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TECH_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TECH_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HOST_ID', l.lang)
     , 'AUP_VISA_SMS_HOST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HOST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.HOST_ID as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HOST_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ISO_MSG_TYPE', l.lang)
     , 'AUP_VISA_SMS_ISO_MSG_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ISO_MSG_TYPE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ISO_MSG_TYPE as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ISO_MSG_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_BITMAP', l.lang)
     , 'AUP_VISA_SMS_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TIME_MARK', l.lang)
     , 'AUP_VISA_SMS_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TIME_MARK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TIME_MARK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRMS_DATETIME', l.lang)
     , 'AUP_VISA_SMS_TRMS_DATETIME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRMS_DATETIME', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.TRMS_DATETIME as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TRMS_DATETIME'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRACE', l.lang)
     , 'AUP_VISA_SMS_TRACE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRACE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRACE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TRACE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_COND_CODE', l.lang)
     , 'AUP_VISA_SMS_COND_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_COND_CODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.COND_CODE as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'COND_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ACQ_INST_ID', l.lang)
     , 'AUP_VISA_SMS_ACQ_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ACQ_INST_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACQ_INST_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ACQ_INST_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_FORW_INST_ID', l.lang)
     , 'AUP_VISA_SMS_FORW_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_FORW_INST_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FORW_INST_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'FORW_INST_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_RESP_CODE', l.lang)
     , 'AUP_VISA_SMS_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_RESP_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'RESP_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_REFNUM', l.lang)
     , 'AUP_VISA_SMS_REFNUM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_REFNUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.REFNUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'REFNUM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_AUTH_ID_RESP', l.lang)
     , 'AUP_VISA_SMS_AUTH_ID_RESP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_AUTH_ID_RESP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AUTH_ID_RESP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'AUTH_ID_RESP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TERMINAL_ID', l.lang)
     , 'AUP_VISA_SMS_TERMINAL_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TERMINAL_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERMINAL_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TERMINAL_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_MERCHANT_ID', l.lang)
     , 'AUP_VISA_SMS_MERCHANT_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_MERCHANT_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'MERCHANT_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ICC_DATASET_ID', l.lang)
     , 'AUP_VISA_SMS_ICC_DATASET_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ICC_DATASET_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ICC_DATASET_ID as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ICC_DATASET_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRANS_ID', l.lang)
     , 'AUP_VISA_SMS_TRANS_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRANS_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.TRANS_ID as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TRANS_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_NETWORK_ID', l.lang)
     , 'AUP_VISA_SMS_NETWORK_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_NETWORK_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.NETWORK_ID as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'NETWORK_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_FPI', l.lang)
     , 'AUP_VISA_SMS_FPI'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_FPI', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FPI as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'FPI'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_TEXT_FORMAT', l.lang)
     , 'AUP_VISA_SMS_HDR_TEXT_FORMAT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_TEXT_FORMAT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_TEXT_FORMAT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_TEXT_FORMAT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_DEST_STATION_ID', l.lang)
     , 'AUP_VISA_SMS_HDR_DEST_STATION_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_DEST_STATION_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_DEST_STATION_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_DEST_STATION_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_SRC_STATION_ID', l.lang)
     , 'AUP_VISA_SMS_HDR_SRC_STATION_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_SRC_STATION_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_SRC_STATION_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_SRC_STATION_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_RTC_INFO', l.lang)
     , 'AUP_VISA_SMS_HDR_RTC_INFO'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_RTC_INFO', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_RTC_INFO as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_RTC_INFO'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_BASEI_FLAGS', l.lang)
     , 'AUP_VISA_SMS_HDR_BASEI_FLAGS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_BASEI_FLAGS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_BASEI_FLAGS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_BASEI_FLAGS'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_MSG_STATUS_FLAGS', l.lang)
     , 'AUP_VISA_SMS_HDR_MSG_STATUS_FLAGS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_MSG_STATUS_FLAGS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_MSG_STATUS_FLAGS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_MSG_STATUS_FLAGS'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_BATCH_NUM', l.lang)
     , 'AUP_VISA_SMS_HDR_BATCH_NUM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_BATCH_NUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_BATCH_NUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_BATCH_NUM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_RESERVED', l.lang)
     , 'AUP_VISA_SMS_HDR_RESERVED'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_RESERVED', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_RESERVED as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 28 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_RESERVED'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_USER_INFO', l.lang)
     , 'AUP_VISA_SMS_HDR_USER_INFO'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_HDR_USER_INFO', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.HDR_USER_INFO as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'HDR_USER_INFO'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRANS_DATE', l.lang)
     , 'AUP_VISA_SMS_TRANS_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_TRANS_DATE', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.TRANS_DATE as column_date_value
     , 30 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'TRANS_DATE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_PROCESSING_CODE', l.lang)
     , 'AUP_VISA_SMS_PROCESSING_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_PROCESSING_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PROCESSING_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'PROCESSING_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_STTL_DATE', l.lang)
     , 'AUP_VISA_SMS_STTL_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_STTL_DATE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.STTL_DATE as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'STTL_DATE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ACQ_INST_CC', l.lang)
     , 'AUP_VISA_SMS_ACQ_INST_CC'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ACQ_INST_CC', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ACQ_INST_CC as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ACQ_INST_CC'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ADDL_DATA', l.lang)
     , 'AUP_VISA_SMS_ADDL_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ADDL_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ADDL_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 34 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ADDL_DATA'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_POS_GEOGR_DATA', l.lang)
     , 'AUP_VISA_SMS_POS_GEOGR_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_POS_GEOGR_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.POS_GEOGR_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 35 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'POS_GEOGR_DATA'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_CPS_BITMAP', l.lang)
     , 'AUP_VISA_SMS_CPS_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_CPS_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CPS_BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 36 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'CPS_BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_SMS_BITMAP', l.lang)
     , 'AUP_VISA_SMS_SMS_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_SMS_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.SMS_BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 37 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'SMS_BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_MSG_REASON_CODE', l.lang)
     , 'AUP_VISA_SMS_MSG_REASON_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_MSG_REASON_CODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.MSG_REASON_CODE as column_number_value
     , to_date(null) as column_date_value
     , 38 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'MSG_REASON_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ORGDATA', l.lang)
     , 'AUP_VISA_SMS_ORGDATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ORGDATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ORGDATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 39 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ORGDATA'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_POS_ENTRY_MODE', l.lang)
     , 'AUP_VISA_SMS_POS_ENTRY_MODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_POS_ENTRY_MODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.POS_ENTRY_MODE as column_number_value
     , to_date(null) as column_date_value
     , 40 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'POS_ENTRY_MODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_VISA_SMS_ADDL_POS_DATA', l.lang)
     , 'AUP_VISA_SMS_ADDL_POS_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_VISA_SMS_ADDL_POS_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ADDL_POS_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 41 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_visa_sms a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_VISA_SMS'
   and c.owner = USER
   and c.column_name = 'ADDL_POS_DATA'
order by oper_id, column_order
/