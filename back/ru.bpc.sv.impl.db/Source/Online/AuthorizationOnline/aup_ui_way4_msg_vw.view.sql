create or replace force view aup_ui_way4_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_AUTH_ID', l.lang)
     , 'AUP_WAY4_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_AUTH_ID', l.lang)) 
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
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_TECH_ID', l.lang)
     , 'AUP_WAY4_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_TECH_ID', l.lang)) 
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
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_ISO_MSG_TYPE', l.lang)
     , 'AUP_WAY4_ISO_MSG_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_ISO_MSG_TYPE', l.lang)) 
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
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'ISO_MSG_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_BITMAP', l.lang)
     , 'AUP_WAY4_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_TIME_MARK', l.lang)
     , 'AUP_WAY4_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_TIME_MARK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TIME_MARK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_ACQ_INST_BIN', l.lang)
     , 'AUP_WAY4_ACQ_INST_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_ACQ_INST_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACQ_INST_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'ACQ_INST_BIN'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_REFNUM', l.lang)
     , 'AUP_WAY4_REFNUM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_REFNUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.REFNUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'REFNUM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_RESP_CODE', l.lang)
     , 'AUP_WAY4_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_RESP_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'RESP_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_TRMS_DATE_TIME', l.lang)
     , 'AUP_WAY4_TRMS_DATE_TIME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_TRMS_DATE_TIME', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.TRMS_DATE_TIME as column_date_value
     , 9 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'TRMS_DATE_TIME'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_TRACE', l.lang)
     , 'AUP_WAY4_TRACE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_TRACE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRACE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'TRACE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_FORW_INST_BIN', l.lang)
     , 'AUP_WAY4_FORW_INST_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_FORW_INST_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FORW_INST_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'FORW_INST_BIN'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_HOST_ID', l.lang)
     , 'AUP_WAY4_HOST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_HOST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.HOST_ID as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'HOST_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_ORIGINAL_DATA', l.lang)
     , 'AUP_WAY4_ORIGINAL_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_ORIGINAL_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ORIGINAL_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'ORIGINAL_DATA'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_DE47_BITMAP', l.lang)
     , 'AUP_WAY4_DE47_BITMAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_DE47_BITMAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.DE47_BITMAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'DE47_BITMAP'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_TXN_SRC_CHANNEL', l.lang)
     , 'AUP_WAY4_TXN_SRC_CHANNEL'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_TXN_SRC_CHANNEL', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TXN_SRC_CHANNEL as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'TXN_SRC_CHANNEL'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_REQ_AMOUNT', l.lang)
     , 'AUP_WAY4_REQ_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_REQ_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.REQ_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'REQ_AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_STTL_AMOUNT', l.lang)
     , 'AUP_WAY4_STTL_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_STTL_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.STTL_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'STTL_AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_BILLING_AMOUNT', l.lang)
     , 'AUP_WAY4_BILLING_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_BILLING_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.BILLING_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'BILLING_AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_WAY4_COUNTRY', l.lang)
     , 'AUP_WAY4_COUNTRY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_WAY4_COUNTRY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.country as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_way4 a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_WAY4'
   and c.owner = USER
   and c.column_name = 'COUNTRY'
order by oper_id, column_order
/