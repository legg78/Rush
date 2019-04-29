create or replace force view aup_ui_mastercard_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_AUTH_ID', l.lang)
     , 'AUP_MASTERCARD_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_AUTH_ID', l.lang)) 
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
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_TECH_ID', l.lang)
     , 'AUP_MASTERCARD_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_TECH_ID', l.lang)) 
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
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_ISO_MSG_TYPE', l.lang)
     , 'AUP_MASTERCARD_ISO_MSG_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_ISO_MSG_TYPE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ISO_MSG_TYPE as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'ISO_MSG_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_TRACE', l.lang)
     , 'AUP_MASTERCARD_TRACE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_TRACE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRACE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'TRACE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_TRMS_DATETIME', l.lang)
     , 'AUP_MASTERCARD_TRMS_DATETIME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_TRMS_DATETIME', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.TRMS_DATETIME as column_date_value
     , 5 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'TRMS_DATETIME'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_TIME_MARK', l.lang)
     , 'AUP_MASTERCARD_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_TIME_MARK', l.lang)) 
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
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_BITMAP', l.lang)
     , 'AUP_MASTERCARD_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_PROC_CODE', l.lang)
     , 'AUP_MASTERCARD_PROC_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_PROC_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PROC_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'PROC_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_RESP_CODE', l.lang)
     , 'AUP_MASTERCARD_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_RESP_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'RESP_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_STTL_DATE', l.lang)
     , 'AUP_MASTERCARD_STTL_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_STTL_DATE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.STTL_DATE as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'STTL_DATE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_FIN_NTWK_CODE', l.lang)
     , 'AUP_MASTERCARD_FIN_NTWK_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_FIN_NTWK_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FIN_NTWK_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'FIN_NTWK_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_BANKNET_REF_NUM', l.lang)
     , 'AUP_MASTERCARD_BANKNET_REF_NUM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_BANKNET_REF_NUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.BANKNET_REF_NUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'BANKNET_REF_NUM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_ACQ_INST_BIN', l.lang)
     , 'AUP_MASTERCARD_ACQ_INST_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_ACQ_INST_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACQ_INST_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'ACQ_INST_BIN'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_FORW_INST_BIN', l.lang)
     , 'AUP_MASTERCARD_FORW_INST_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_FORW_INST_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FORW_INST_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'FORW_INST_BIN'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_HOST_ID', l.lang)
     , 'AUP_MASTERCARD_HOST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_HOST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.HOST_ID as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'HOST_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_BILLING_RATE', l.lang)
     , 'AUP_MASTERCARD_BILLING_RATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_BILLING_RATE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.BILLING_RATE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'BILLING_RATE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_STTL_RATE', l.lang)
     , 'AUP_MASTERCARD_STTL_RATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_STTL_RATE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.STTL_RATE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'STTL_RATE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_DE48_BITMAP', l.lang)
     , 'AUP_MASTERCARD_DE48_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_DE48_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.DE48_BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'DE48_BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_ADVICE_DATETIME', l.lang)
     , 'AUP_MASTERCARD_ADVICE_DATETIME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_ADVICE_DATETIME', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.ADVICE_DATETIME as column_date_value
     , 19 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'ADVICE_DATETIME'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_PAYMENT_TRX_TYPE', l.lang)
     , 'AUP_MASTERCARD_PAYMENT_TRX_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_PAYMENT_TRX_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PAYMENT_TRX_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'PAYMENT_TRX_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_PIN_SERVICE_CODE', l.lang)
     , 'AUP_MASTERCARD_PIN_SERVICE_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_PIN_SERVICE_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PIN_SERVICE_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'PIN_SERVICE_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_RETRIEVAL_REF_NUM', l.lang)
     , 'AUP_MASTERCARD_RETRIEVAL_REF_NUM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_RETRIEVAL_REF_NUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RETRIEVAL_REF_NUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'RETRIEVAL_REF_NUM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_TCC', l.lang)
     , 'AUP_MASTERCARD_TCC'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_TCC', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TCC as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'TCC'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_ECI', l.lang)
     , 'AUP_MASTERCARD_ECI'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_ECI', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ECI as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'ECI'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_MS_CMPL_STAT_IND', l.lang)
     , 'AUP_MASTERCARD_MS_CMPL_STAT_IND'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_MS_CMPL_STAT_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MS_CMPL_STAT_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'MS_CMPL_STAT_IND'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_MS_CMPL_ERR_IND', l.lang)
     , 'AUP_MASTERCARD_MS_CMPL_ERR_IND'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_MS_CMPL_ERR_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MS_CMPL_ERR_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'MS_CMPL_ERR_IND'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_FIN_NTWK_CODE_DE48_63', l.lang)
     , 'AUP_MASTERCARD_FIN_NTWK_CODE_DE48_63'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_FIN_NTWK_CODE_DE48_63', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FIN_NTWK_CODE_DE48_63 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'FIN_NTWK_CODE_DE48_63'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_BANKNET_REF_NUM_DE48_63', l.lang)
     , 'AUP_MASTERCARD_BANKNET_REF_NUM_DE48_63'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_BANKNET_REF_NUM_DE48_63', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.BANKNET_REF_NUM_DE48_63 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 28 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'BANKNET_REF_NUM_DE48_63'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_STTL_DATE_DE48_63', l.lang)
     , 'AUP_MASTERCARD_STTL_DATE_DE48_63'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_STTL_DATE_DE48_63', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.STTL_DATE_DE48_63 as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'STTL_DATE_DE48_63'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_MEMBER_DEFINED_DATA', l.lang)
     , 'AUP_MASTERCARD_MEMBER_DEFINED_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_MEMBER_DEFINED_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MEMBER_DEFINED_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'MEMBER_DEFINED_DATA'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_ADVICE_REASON_CODE', l.lang)
     , 'AUP_MASTERCARD_ADVICE_REASON_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_ADVICE_REASON_CODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ADVICE_REASON_CODE as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'ADVICE_REASON_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_CVM', l.lang)
     , 'AUP_MASTERCARD_CVM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_CVM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CVM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'CVM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_MASTERCARD_AUTH_CODE', l.lang)
     , 'AUP_MASTERCARD_AUTH_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_MASTERCARD_AUTH_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AUTH_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_mastercard a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_MASTERCARD'
   and c.owner = USER
   and c.column_name = 'AUTH_CODE'
order by oper_id, column_order
/