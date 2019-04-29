create or replace force view cmp_ui_fin_message_vw
as
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ID', l.lang)
     , 'CMP_FIN_MESSAGE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ID', l.lang)) 
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
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ID'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_STATUS', l.lang)
     , 'CMP_FIN_MESSAGE_STATUS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_STATUS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.STATUS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'STATUS'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_FILE_ID', l.lang)
     , 'CMP_FIN_MESSAGE_FILE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_FILE_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.FILE_ID as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FILE_ID'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_IS_REVERSAL', l.lang)
     , 'CMP_FIN_MESSAGE_IS_REVERSAL'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_IS_REVERSAL', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_REVERSAL as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_REVERSAL'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_IS_INCOMING', l.lang)
     , 'CMP_FIN_MESSAGE_IS_INCOMING'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_IS_INCOMING', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_INCOMING as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_INCOMING'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_IS_INVALID', l.lang)
     , 'CMP_FIN_MESSAGE_IS_INVALID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_IS_INVALID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_INVALID as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_INVALID'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_INST_ID', l.lang)
     , 'CMP_FIN_MESSAGE_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_INST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.INST_ID as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'INST_ID'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_NETWORK_ID', l.lang)
     , 'CMP_FIN_MESSAGE_NETWORK_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_NETWORK_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.NETWORK_ID as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'NETWORK_ID'
union   
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_TYPE', l.lang)
     , 'CMP_FIN_MESSAGE_TRAN_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRAN_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRAN_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_CODE', l.lang)
     , 'CMP_FIN_MESSAGE_TRAN_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRAN_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRAN_CODE'
union   
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_HOST_INST_ID', l.lang)
     , 'CMP_FIN_MESSAGE_HOST_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_HOST_INST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.HOST_INST_ID as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'HOST_INST_ID'
union
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CARD_ID', l.lang)
     , 'CMP_FIN_MESSAGE_CARD_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CARD_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.CARD_ID as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_ID'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CARD_MASK', l.lang)
     , 'CMP_FIN_MESSAGE_CARD_MASK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CARD_MASK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CARD_MASK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_MASK'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CARD_HASH', l.lang)
     , 'CMP_FIN_MESSAGE_CARD_HASH'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CARD_HASH', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.CARD_HASH as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_HASH'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_EXP_DATE', l.lang)
     , 'CMP_FIN_MESSAGE_EXP_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_EXP_DATE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.EXP_DATE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'EXP_DATE'
union
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_TIME', l.lang)
     , 'CMP_FIN_MESSAGE_ORIG_TIME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_TIME', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.ORIG_TIME as column_date_value
     , 19 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ORIG_TIME'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_AMOUNT', l.lang)
     , 'CMP_FIN_MESSAGE_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CURRENCY', l.lang)
     , 'CMP_FIN_MESSAGE_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CURRENCY'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_RECONCIL_AMOUNT', l.lang)
     , 'CMP_FIN_MESSAGE_RECONCIL_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_RECONCIL_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.RECONCIL_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'RECONCIL_AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_RECONCIL_CURRENCY', l.lang)
     , 'CMP_FIN_MESSAGE_RECONCIL_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_RECONCIL_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RECONCIL_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'RECONCIL_CURRENCY'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_AMOUNT', l.lang)
     , 'CMP_FIN_MESSAGE_ORIG_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.ORIG_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ORIG_AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_CURRENCY', l.lang)
     , 'CMP_FIN_MESSAGE_ORIG_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ORIG_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ORIG_CURRENCY'
union   
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ARN', l.lang)
     , 'CMP_FIN_MESSAGE_ARN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ARN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ARN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ARN'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_AID', l.lang)
     , 'CMP_FIN_MESSAGE_AID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_AID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AID'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_OWNER', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_OWNER'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_OWNER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_OWNER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_OWNER'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_CITY', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_CITY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_CITY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_CITY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_CITY'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_COUNTRY', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_COUNTRY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_COUNTRY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_COUNTRY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_COUNTRY'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_MERCHANT_TERM_ZIP', l.lang)
     , 'CMP_FIN_MESSAGE_MERCHANT_TERM_ZIP'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_MERCHANT_TERM_ZIP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_ZIP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_ZIP'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_NAME', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_NAME'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_RETAILER_NAME', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_RETAILER_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_RETAILER_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.EXT_TERM_RETAILER_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 34 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'EXT_TERM_RETAILER_NAME'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_MCC', l.lang)
     , 'CMP_FIN_MESSAGE_MCC'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_MCC', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MCC as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 35 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MCC'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_NETWORK', l.lang)
     , 'CMP_FIN_MESSAGE_NETWORK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_NETWORK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.NETWORK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 36 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'NETWORK'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_FI_NAME', l.lang)
     , 'CMP_FIN_MESSAGE_ORIG_FI_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_ORIG_FI_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ORIG_FI_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 37 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ORIG_FI_NAME'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_DEST_FI_NAME', l.lang)
     , 'CMP_FIN_MESSAGE_DEST_FI_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_DEST_FI_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.DEST_FI_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 38 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'DEST_FI_NAME'
union
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_RRN', l.lang)
     , 'CMP_FIN_MESSAGE_RRN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_RRN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FINAL_RRN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 39 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FINAL_RRN'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_ENTRY_CAPS', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_ENTRY_CAPS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_ENTRY_CAPS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_ENTRY_CAPS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 40 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_ENTRY_CAPS'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_PIN_PRESENCE', l.lang)
     , 'CMP_FIN_MESSAGE_PIN_PRESENCE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_PIN_PRESENCE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.PIN_PRESENCE as column_number_value
     , to_date(null) as column_date_value
     , 41 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PIN_PRESENCE'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_NUMBER', l.lang)
     , 'CMP_FIN_MESSAGE_TRAN_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRAN_NUMBER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 42 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRAN_NUMBER'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_POS_CONDITION', l.lang)
     , 'CMP_FIN_MESSAGE_POS_CONDITION'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_POS_CONDITION', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.POS_CONDITION as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 43 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'POS_CONDITION'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_POS_ENTRY_MODE', l.lang)
     , 'CMP_FIN_MESSAGE_POS_ENTRY_MODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_POS_ENTRY_MODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.POS_ENTRY_MODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 44 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'POS_ENTRY_MODE'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_ENTRY_CAPS', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_ENTRY_CAPS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_ENTRY_CAPS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_ENTRY_CAPS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 45 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_ENTRY_CAPS'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_APPROVAL_CODE', l.lang)
     , 'CMP_FIN_MESSAGE_APPROVAL_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_APPROVAL_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.APPROVAL_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 46 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'APPROVAL_CODE'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_CLASS', l.lang)
     , 'CMP_FIN_MESSAGE_TERM_CLASS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TERM_CLASS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_CLASS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 47 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_CLASS'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_CLASS', l.lang)
     , 'CMP_FIN_MESSAGE_TRAN_CLASS'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_TRAN_CLASS', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRAN_CLASS as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 48 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRAN_CLASS'
union 
select  decode(com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_COLLECT_ONLY_FLAG', l.lang)
     , 'CMP_FIN_MESSAGE_COLLECT_ONLY_FLAG'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('CMP_FIN_MESSAGE_COLLECT_ONLY_FLAG', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.COLLECT_ONLY_FLAG as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 49 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cmp_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='CMP_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'COLLECT_ONLY_FLAG'
/
