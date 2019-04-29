create or replace force view aut_ui_auth_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ID', l.lang)
     , 'AUT_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ID', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ID as column_number_value
     , to_date(null) as column_date_value
     , 1 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ID'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_RESP_CODE', l.lang)
     , 'AUT_AUTH_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_RESP_CODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'RESP_CODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_PROC_TYPE', l.lang)
     , 'AUT_AUTH_PROC_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_PROC_TYPE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.PROC_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'PROC_TYPE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_PROC_MODE', l.lang)
     , 'AUT_AUTH_PROC_MODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_PROC_MODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.PROC_MODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'PROC_MODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_IS_ADVICE', l.lang)
     , 'AUT_AUTH_IS_ADVICE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_IS_ADVICE', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_ADVICE as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'IS_ADVICE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_IS_REPEAT', l.lang)
     , 'AUT_AUTH_IS_REPEAT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_IS_REPEAT', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_REPEAT as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'IS_REPEAT'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_IS_COMPLETED', l.lang)
     , 'AUT_AUTH_IS_COMPLETED'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_IS_COMPLETED', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.IS_COMPLETED as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'IS_COMPLETED'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_BIN_AMOUNT', l.lang)
     , 'AUT_AUTH_BIN_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_BIN_AMOUNT', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.BIN_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'BIN_AMOUNT'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_BIN_CURRENCY', l.lang)
     , 'AUT_AUTH_BIN_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_BIN_CURRENCY', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.BIN_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'BIN_CURRENCY'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_BIN_CNVT_RATE', l.lang)
     , 'AUT_AUTH_BIN_CNVT_RATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_BIN_CNVT_RATE', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.BIN_CNVT_RATE as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'BIN_CNVT_RATE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_AMOUNT', l.lang)
     , 'AUT_AUTH_NETWORK_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_AMOUNT', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.NETWORK_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'NETWORK_AMOUNT'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_CURRENCY', l.lang)
     , 'AUT_AUTH_NETWORK_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_CURRENCY', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.NETWORK_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'NETWORK_CURRENCY'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_CNVT_DATE', l.lang)
     , 'AUT_AUTH_NETWORK_CNVT_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_CNVT_DATE', l.lang))
       as name
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.NETWORK_CNVT_DATE as column_date_value
     , 13 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'NETWORK_CNVT_DATE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_CNVT_RATE', l.lang)
     , 'AUT_AUTH_NETWORK_CNVT_RATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_NETWORK_CNVT_RATE', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.NETWORK_CNVT_RATE as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'NETWORK_CNVT_RATE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ACCOUNT_CNVT_RATE', l.lang)
     , 'AUT_AUTH_ACCOUNT_CNVT_RATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ACCOUNT_CNVT_RATE', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ACCOUNT_CNVT_RATE as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ACCOUNT_CNVT_RATE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_PARENT_ID', l.lang)
     , 'AUT_AUTH_PARENT_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_PARENT_ID', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.PARENT_ID as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'PARENT_ID'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ADDR_VERIF_RESULT', l.lang)
     , 'AUT_AUTH_ADDR_VERIF_RESULT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ADDR_VERIF_RESULT', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.ADDR_VERIF_RESULT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ADDR_VERIF_RESULT'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ISS_NETWORK_DEVICE_ID', l.lang)
     , 'AUT_AUTH_ISS_NETWORK_DEVICE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ISS_NETWORK_DEVICE_ID', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ISS_NETWORK_DEVICE_ID as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ISS_NETWORK_DEVICE_ID'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ACQ_DEVICE_ID', l.lang)
     , 'AUT_AUTH_ACQ_DEVICE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ACQ_DEVICE_ID', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ACQ_DEVICE_ID as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ACQ_DEVICE_ID'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ACQ_RESP_CODE', l.lang)
     , 'AUT_AUTH_ACQ_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ACQ_RESP_CODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.ACQ_RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ACQ_RESP_CODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ACQ_DEVICE_PROC_RESULT', l.lang)
     , 'AUT_AUTH_ACQ_DEVICE_PROC_RESULT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ACQ_DEVICE_PROC_RESULT', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.ACQ_DEVICE_PROC_RESULT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ACQ_DEVICE_PROC_RESULT'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CAT_LEVEL', l.lang)
     , 'AUT_AUTH_CAT_LEVEL'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CAT_LEVEL', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CAT_LEVEL as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CAT_LEVEL'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CARD_DATA_INPUT_CAP', l.lang)
     , 'AUT_AUTH_CARD_DATA_INPUT_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CARD_DATA_INPUT_CAP', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CARD_DATA_INPUT_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CARD_DATA_INPUT_CAP'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_AUTH_CAP', l.lang)
     , 'AUT_AUTH_CRDH_AUTH_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_AUTH_CAP', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CRDH_AUTH_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CRDH_AUTH_CAP'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CARD_CAPTURE_CAP', l.lang)
     , 'AUT_AUTH_CARD_CAPTURE_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CARD_CAPTURE_CAP', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CARD_CAPTURE_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CARD_CAPTURE_CAP'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_TERMINAL_OPERATING_ENV', l.lang)
     , 'AUT_AUTH_TERMINAL_OPERATING_ENV'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_TERMINAL_OPERATING_ENV', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.TERMINAL_OPERATING_ENV as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'TERMINAL_OPERATING_ENV'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_PRESENCE', l.lang)
     , 'AUT_AUTH_CRDH_PRESENCE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_PRESENCE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CRDH_PRESENCE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CRDH_PRESENCE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CARD_PRESENCE', l.lang)
     , 'AUT_AUTH_CARD_PRESENCE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CARD_PRESENCE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CARD_PRESENCE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 28 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CARD_PRESENCE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CARD_DATA_INPUT_MODE', l.lang)
     , 'AUT_AUTH_CARD_DATA_INPUT_MODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CARD_DATA_INPUT_MODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CARD_DATA_INPUT_MODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CARD_DATA_INPUT_MODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_AUTH_METHOD', l.lang)
     , 'AUT_AUTH_CRDH_AUTH_METHOD'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_AUTH_METHOD', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CRDH_AUTH_METHOD as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CRDH_AUTH_METHOD'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_AUTH_ENTITY', l.lang)
     , 'AUT_AUTH_CRDH_AUTH_ENTITY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CRDH_AUTH_ENTITY', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CRDH_AUTH_ENTITY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CRDH_AUTH_ENTITY'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CARD_DATA_OUTPUT_CAP', l.lang)
     , 'AUT_AUTH_CARD_DATA_OUTPUT_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CARD_DATA_OUTPUT_CAP', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CARD_DATA_OUTPUT_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CARD_DATA_OUTPUT_CAP'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_TERMINAL_OUTPUT_CAP', l.lang)
     , 'AUT_AUTH_TERMINAL_OUTPUT_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_TERMINAL_OUTPUT_CAP', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.TERMINAL_OUTPUT_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'TERMINAL_OUTPUT_CAP'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_PIN_CAPTURE_CAP', l.lang)
     , 'AUT_AUTH_PIN_CAPTURE_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_PIN_CAPTURE_CAP', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.PIN_CAPTURE_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 34 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'PIN_CAPTURE_CAP'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_PIN_PRESENCE', l.lang)
     , 'AUT_AUTH_PIN_PRESENCE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_PIN_PRESENCE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.PIN_PRESENCE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 35 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'PIN_PRESENCE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CVV2_PRESENCE', l.lang)
     , 'AUT_AUTH_CVV2_PRESENCE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CVV2_PRESENCE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CVV2_PRESENCE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 36 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CVV2_PRESENCE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CVC_INDICATOR', l.lang)
     , 'AUT_AUTH_CVC_INDICATOR'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CVC_INDICATOR', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CVC_INDICATOR as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 37 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CVC_INDICATOR'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_POS_ENTRY_MODE', l.lang)
     , 'AUT_AUTH_POS_ENTRY_MODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_POS_ENTRY_MODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.POS_ENTRY_MODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 38 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'POS_ENTRY_MODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_POS_COND_CODE', l.lang)
     , 'AUT_AUTH_POS_COND_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_POS_COND_CODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.POS_COND_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 39 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'POS_COND_CODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_EMV_DATA', l.lang)
     , 'AUT_AUTH_EMV_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_EMV_DATA', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.EMV_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 40 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'EMV_DATA'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ATC', l.lang)
     , 'AUT_AUTH_ATC'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ATC', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.ATC as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 41 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ATC'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_TVR', l.lang)
     , 'AUT_AUTH_TVR'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_TVR', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.TVR as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 42 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'TVR'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CVR', l.lang)
     , 'AUT_AUTH_CVR'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CVR', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CVR as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 43 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CVR'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_ADDL_DATA', l.lang)
     , 'AUT_AUTH_ADDL_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_ADDL_DATA', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.ADDL_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 44 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'ADDL_DATA'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_SERVICE_CODE', l.lang)
     , 'AUT_AUTH_SERVICE_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_SERVICE_CODE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.SERVICE_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 45 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'SERVICE_CODE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_DEVICE_DATE', l.lang)
     , 'AUT_AUTH_DEVICE_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_DEVICE_DATE', l.lang))
       as name
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.DEVICE_DATE as column_date_value
     , 46 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'DEVICE_DATE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CVV2_RESULT', l.lang)
     , 'AUT_AUTH_CVV2_RESULT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CVV2_RESULT', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CVV2_RESULT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 47 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CVV2_RESULT'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CERTIFICATE_METHOD', l.lang)
     , 'AUT_AUTH_CERTIFICATE_METHOD'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CERTIFICATE_METHOD', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CERTIFICATE_METHOD as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 48 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CERTIFICATE_METHOD'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CERTIFICATE_TYPE', l.lang)
     , 'AUT_AUTH_CERTIFICATE_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CERTIFICATE_TYPE', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CERTIFICATE_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 49 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CERTIFICATE_TYPE'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_MERCHANT_CERTIF', l.lang)
     , 'AUT_AUTH_MERCHANT_CERTIF'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_MERCHANT_CERTIF', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.MERCHANT_CERTIF as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 50 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'MERCHANT_CERTIF'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_CARDHOLDER_CERTIF', l.lang)
     , 'AUT_AUTH_CARDHOLDER_CERTIF'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_CARDHOLDER_CERTIF', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.CARDHOLDER_CERTIF as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 51 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'CARDHOLDER_CERTIF'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_UCAF_INDICATOR', l.lang)
     , 'AUT_AUTH_UCAF_INDICATOR'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_UCAF_INDICATOR', l.lang))
       as name
     , 'VARCHAR2' as data_type
     , a.UCAF_INDICATOR as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 52 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'UCAF_INDICATOR'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_IS_EARLY_EMV', l.lang)
     , 'AUT_AUTH_IS_EARLY_EMV'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_IS_EARLY_EMV', l.lang))
       as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_EARLY_EMV as column_number_value
     , to_date(null) as column_date_value
     , 53 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'IS_EARLY_EMV'
union
select  decode(com_api_label_pkg.get_label_text('AUT_AUTH_AUTH_PURPOSE_ID', l.lang)
     , 'AUT_AUTH_AUTH_PURPOSE_ID'
     , substr(c.comments, 1, instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUT_AUTH_AUTH_PURPOSE_ID', l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.auth_purpose_id as column_number_value
     , to_date(null) as column_date_value
     , 54 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from aut_auth a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AUT_AUTH'
   and c.owner = USER
   and c.column_name = 'AUTH_PURPOSE_ID'
union
    select com_api_label_pkg.get_label_text('TAGS', l.lang) as name
         , to_char(null) as data_type
         , to_char(null) as column_char_value
         , to_number(null) as column_number_value
         , to_date(null) as column_date_value
         , 500 as column_order
         , a.id as oper_id
         , l.lang
         , 0 as column_level
         , null as lov_id
         , null as dict_code
         , to_number(null) tech_id
      from aut_auth a, com_language_vw l
    union
    select get_text(
               i_table_name   => 'aup_tag'
             , i_column_name  => 'name'
             , i_object_id    => n.id
             , i_lang         => l.lang
           )
               as name
         , 'VARCHAR2' as data_type
         , to_char(v.tag_value) as column_char_value
         , to_number(null) as column_number_value
         , to_date(null) as column_date_value
         , 1000 as column_order
         , v.auth_id as oper_id
         , l.lang
         , 1 as column_level
         , null as lov_id
         , null as dict_code
         , to_number(null) tech_id
      from aup_tag n, com_language_vw l, aup_tag_value v
     where v.tag_id = n.tag
order by oper_id, column_order
/
