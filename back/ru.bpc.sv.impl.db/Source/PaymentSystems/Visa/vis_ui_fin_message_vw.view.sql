create or replace force view vis_ui_fin_message_vw
as
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ID', l.lang)
     , 'VIS_FIN_MESSAGE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ID', l.lang)) 
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
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ID'
 union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_STATUS', l.lang)
     , 'VIS_FIN_MESSAGE_STATUS'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_STATUS', l.lang)) 
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
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'STATUS'
 union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_FILE_ID', l.lang)
     , 'VIS_FIN_MESSAGE_FILE_ID'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_FILE_ID', l.lang)) 
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
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FILE_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_BATCH_ID', l.lang)
     , 'VIS_FIN_MESSAGE_BATCH_ID'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_BATCH_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.BATCH_ID as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'BATCH_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FILE_STTL_DATE', l.lang)
     , 'VIS_FILE_STTL_DATE'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FILE_STTL_DATE', l.lang)) 
       as name     
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , f.STTL_DATE as column_date_value     
     , 5 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_file f
     , com_language_vw l
     , all_col_comments c
 where a.file_id = f.id
   and c.table_name='VIS_FILE'
   and c.owner = USER
   and c.column_name = 'STTL_DATE'   
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_RECORD_NUMBER', l.lang)
     , 'VIS_FIN_MESSAGE_RECORD_NUMBER'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_RECORD_NUMBER', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.RECORD_NUMBER as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'RECORD_NUMBER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_REVERSAL', l.lang)
     , 'VIS_FIN_MESSAGE_IS_REVERSAL'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_REVERSAL', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_REVERSAL as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_REVERSAL'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_INCOMING', l.lang)
     , 'VIS_FIN_MESSAGE_IS_INCOMING'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_INCOMING', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_INCOMING as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_INCOMING'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_RETURNED', l.lang)
     , 'VIS_FIN_MESSAGE_IS_RETURNED'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_RETURNED', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_RETURNED as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_RETURNED'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_INVALID', l.lang)
     , 'VIS_FIN_MESSAGE_IS_INVALID'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_IS_INVALID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_INVALID as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'IS_INVALID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_DISPUTE_ID', l.lang)
     , 'VIS_FIN_MESSAGE_DISPUTE_ID'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_DISPUTE_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.DISPUTE_ID as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'DISPUTE_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_RRN', l.lang)
     , 'VIS_FIN_MESSAGE_RRN'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_RRN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RRN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'RRN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INST_ID', l.lang)
     , 'VIS_FIN_MESSAGE_INST_ID'
     --, substr(c.comments,1,instr(c.comments||'.','.'))
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.INST_ID as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'INST_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NETWORK_ID', l.lang)
     , 'VIS_FIN_MESSAGE_NETWORK_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NETWORK_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.NETWORK_ID as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'NETWORK_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANS_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_TRANS_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANS_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRANS_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRANS_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANS_CODE_QUALIFIER', l.lang)
     , 'VIS_FIN_MESSAGE_TRANS_CODE_QUALIFIER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANS_CODE_QUALIFIER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRANS_CODE_QUALIFIER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRANS_CODE_QUALIFIER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_ID', l.lang)
     , 'VIS_FIN_MESSAGE_CARD_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.CARD_ID as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_MASK', l.lang)
     , 'VIS_FIN_MESSAGE_CARD_MASK'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_MASK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CARD_MASK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_MASK'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_HASH', l.lang)
     , 'VIS_FIN_MESSAGE_CARD_HASH'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_HASH', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.CARD_HASH as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_HASH'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_OPER_AMOUNT', l.lang)
     , 'VIS_FIN_MESSAGE_OPER_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_OPER_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.OPER_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'OPER_AMOUNT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_OPER_CURRENCY', l.lang)
     , 'VIS_FIN_MESSAGE_OPER_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_OPER_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.OPER_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'OPER_CURRENCY'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_OPER_DATE', l.lang)
     , 'VIS_FIN_MESSAGE_OPER_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_OPER_DATE', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.OPER_DATE as column_date_value
     , 22 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'OPER_DATE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_STTL_AMOUNT', l.lang)
     , 'VIS_FIN_MESSAGE_STTL_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_STTL_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.STTL_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'STTL_AMOUNT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_STTL_CURRENCY', l.lang)
     , 'VIS_FIN_MESSAGE_STTL_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_STTL_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.STTL_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'STTL_CURRENCY'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NETWORK_AMOUNT', l.lang)
     , 'VIS_FIN_MESSAGE_NETWORK_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NETWORK_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.NETWORK_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'NETWORK_AMOUNT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NETWORK_CURRENCY', l.lang)
     , 'VIS_FIN_MESSAGE_NETWORK_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NETWORK_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.NETWORK_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'NETWORK_CURRENCY'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_FLOOR_LIMIT_IND', l.lang)
     , 'VIS_FIN_MESSAGE_FLOOR_LIMIT_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_FLOOR_LIMIT_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FLOOR_LIMIT_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FLOOR_LIMIT_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_EXEPT_FILE_IND', l.lang)
     , 'VIS_FIN_MESSAGE_EXEPT_FILE_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_EXEPT_FILE_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.EXEPT_FILE_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 28 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'EXEPT_FILE_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PCAS_IND', l.lang)
     , 'VIS_FIN_MESSAGE_PCAS_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PCAS_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PCAS_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PCAS_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ARN', l.lang)
     , 'VIS_FIN_MESSAGE_ARN'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ARN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ARN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ARN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACQUIRER_BIN', l.lang)
     , 'VIS_FIN_MESSAGE_ACQUIRER_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACQUIRER_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACQUIRER_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ACQUIRER_BIN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACQ_BUSINESS_ID', l.lang)
     , 'VIS_FIN_MESSAGE_ACQ_BUSINESS_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACQ_BUSINESS_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACQ_BUSINESS_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ACQ_BUSINESS_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_NAME', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_NAME'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_CITY', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_CITY'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_CITY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_CITY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 34 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_CITY'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_COUNTRY', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_COUNTRY'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_COUNTRY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_COUNTRY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 35 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_COUNTRY'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_POSTAL_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_POSTAL_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_POSTAL_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_POSTAL_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 36 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_POSTAL_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_REGION', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_REGION'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_REGION', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_REGION as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 37 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_REGION'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_STREET', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_STREET'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_STREET', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_STREET as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 38 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_STREET'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MCC', l.lang)
     , 'VIS_FIN_MESSAGE_MCC'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MCC', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MCC as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 39 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MCC'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_REQ_PAY_SERVICE', l.lang)
     , 'VIS_FIN_MESSAGE_REQ_PAY_SERVICE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_REQ_PAY_SERVICE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.REQ_PAY_SERVICE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 40 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'REQ_PAY_SERVICE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_USAGE_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_USAGE_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_USAGE_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.USAGE_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 41 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'USAGE_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_REASON_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_REASON_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_REASON_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.REASON_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 42 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'REASON_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SETTLEMENT_FLAG', l.lang)
     , 'VIS_FIN_MESSAGE_SETTLEMENT_FLAG'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SETTLEMENT_FLAG', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.SETTLEMENT_FLAG as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 43 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'SETTLEMENT_FLAG'
union all
select  decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_CHAR_IND', l.lang)
     , 'VIS_FIN_MESSAGE_AUTH_CHAR_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_CHAR_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AUTH_CHAR_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 44 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AUTH_CHAR_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_AUTH_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AUTH_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 45 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AUTH_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_POS_TERMINAL_CAP', l.lang)
     , 'VIS_FIN_MESSAGE_POS_TERMINAL_CAP'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_POS_TERMINAL_CAP', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.POS_TERMINAL_CAP as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 46 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'POS_TERMINAL_CAP'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INTER_FEE_IND', l.lang)
     , 'VIS_FIN_MESSAGE_INTER_FEE_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INTER_FEE_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.INTER_FEE_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 47 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'INTER_FEE_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRDH_ID_METHOD', l.lang)
     , 'VIS_FIN_MESSAGE_CRDH_ID_METHOD'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRDH_ID_METHOD', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CRDH_ID_METHOD as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 48 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CRDH_ID_METHOD'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_COLLECT_ONLY_FLAG', l.lang)
     , 'VIS_FIN_MESSAGE_COLLECT_ONLY_FLAG'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_COLLECT_ONLY_FLAG', l.lang)) 
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
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'COLLECT_ONLY_FLAG'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_POS_ENTRY_MODE', l.lang)
     , 'VIS_FIN_MESSAGE_POS_ENTRY_MODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_POS_ENTRY_MODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.POS_ENTRY_MODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 50 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'POS_ENTRY_MODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CENTRAL_PROC_DATE', l.lang)
     , 'VIS_FIN_MESSAGE_CENTRAL_PROC_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CENTRAL_PROC_DATE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CENTRAL_PROC_DATE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 51 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CENTRAL_PROC_DATE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_REIMBURST_ATTR', l.lang)
     , 'VIS_FIN_MESSAGE_REIMBURST_ATTR'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_REIMBURST_ATTR', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.REIMBURST_ATTR as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 52 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'REIMBURST_ATTR'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISS_WORKST_BIN', l.lang)
     , 'VIS_FIN_MESSAGE_ISS_WORKST_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISS_WORKST_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ISS_WORKST_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 53 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ISS_WORKST_BIN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACQ_WORKST_BIN', l.lang)
     , 'VIS_FIN_MESSAGE_ACQ_WORKST_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACQ_WORKST_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACQ_WORKST_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 54 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ACQ_WORKST_BIN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CHARGEBACK_REF_NUM', l.lang)
     , 'VIS_FIN_MESSAGE_CHARGEBACK_REF_NUM'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CHARGEBACK_REF_NUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CHARGEBACK_REF_NUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 55 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CHARGEBACK_REF_NUM'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_DOCUM_IND', l.lang)
     , 'VIS_FIN_MESSAGE_DOCUM_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_DOCUM_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.DOCUM_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 56 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'DOCUM_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MEMBER_MSG_TEXT', l.lang)
     , 'VIS_FIN_MESSAGE_MEMBER_MSG_TEXT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MEMBER_MSG_TEXT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MEMBER_MSG_TEXT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 57 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MEMBER_MSG_TEXT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SPEC_COND_IND', l.lang)
     , 'VIS_FIN_MESSAGE_SPEC_COND_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SPEC_COND_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.SPEC_COND_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 58 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'SPEC_COND_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_FEE_PROGRAM_IND', l.lang)
     , 'VIS_FIN_MESSAGE_FEE_PROGRAM_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_FEE_PROGRAM_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.FEE_PROGRAM_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 59 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FEE_PROGRAM_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISSUER_CHARGE', l.lang)
     , 'VIS_FIN_MESSAGE_ISSUER_CHARGE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISSUER_CHARGE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ISSUER_CHARGE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 60 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ISSUER_CHARGE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_NUMBER', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_NUMBER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 61 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_NUMBER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TERMINAL_NUMBER', l.lang)
     , 'VIS_FIN_MESSAGE_TERMINAL_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TERMINAL_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERMINAL_NUMBER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 62 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERMINAL_NUMBER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NATIONAL_REIMB_FEE', l.lang)
     , 'VIS_FIN_MESSAGE_NATIONAL_REIMB_FEE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_NATIONAL_REIMB_FEE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.NATIONAL_REIMB_FEE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 63 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'NATIONAL_REIMB_FEE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ELECTR_COMM_IND', l.lang)
     , 'VIS_FIN_MESSAGE_ELECTR_COMM_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ELECTR_COMM_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ELECTR_COMM_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 64 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ELECTR_COMM_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SPEC_CHARGEBACK_IND', l.lang)
     , 'VIS_FIN_MESSAGE_SPEC_CHARGEBACK_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SPEC_CHARGEBACK_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.SPEC_CHARGEBACK_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 65 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'SPEC_CHARGEBACK_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INTERFACE_TRACE_NUM', l.lang)
     , 'VIS_FIN_MESSAGE_INTERFACE_TRACE_NUM'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INTERFACE_TRACE_NUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.INTERFACE_TRACE_NUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 66 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'INTERFACE_TRACE_NUM'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_UNATT_ACCEPT_TERM_IND', l.lang)
     , 'VIS_FIN_MESSAGE_UNATT_ACCEPT_TERM_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_UNATT_ACCEPT_TERM_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.UNATT_ACCEPT_TERM_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 67 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'UNATT_ACCEPT_TERM_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PREPAID_CARD_IND', l.lang)
     , 'VIS_FIN_MESSAGE_PREPAID_CARD_IND'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PREPAID_CARD_IND', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PREPAID_CARD_IND as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 68 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PREPAID_CARD_IND'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SERVICE_DEVELOPMENT', l.lang)
     , 'VIS_FIN_MESSAGE_SERVICE_DEVELOPMENT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_SERVICE_DEVELOPMENT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.SERVICE_DEVELOPMENT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 69 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'SERVICE_DEVELOPMENT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AVS_RESP_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_AVS_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AVS_RESP_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AVS_RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 70 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AVS_RESP_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_SOURCE_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_AUTH_SOURCE_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_SOURCE_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AUTH_SOURCE_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 71 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AUTH_SOURCE_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PURCH_ID_FORMAT', l.lang)
     , 'VIS_FIN_MESSAGE_PURCH_ID_FORMAT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PURCH_ID_FORMAT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PURCH_ID_FORMAT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 72 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PURCH_ID_FORMAT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACCOUNT_SELECTION', l.lang)
     , 'VIS_FIN_MESSAGE_ACCOUNT_SELECTION'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ACCOUNT_SELECTION', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACCOUNT_SELECTION as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 73 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ACCOUNT_SELECTION'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INSTALLMENT_PAY_COUNT', l.lang)
     , 'VIS_FIN_MESSAGE_INSTALLMENT_PAY_COUNT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_INSTALLMENT_PAY_COUNT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.INSTALLMENT_PAY_COUNT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 74 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'INSTALLMENT_PAY_COUNT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PURCH_ID', l.lang)
     , 'VIS_FIN_MESSAGE_PURCH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PURCH_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.PURCH_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 75 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PURCH_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CASHBACK', l.lang)
     , 'VIS_FIN_MESSAGE_CASHBACK'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CASHBACK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CASHBACK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 76 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CASHBACK'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CHIP_COND_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_CHIP_COND_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CHIP_COND_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CHIP_COND_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 77 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CHIP_COND_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_POS_ENVIRONMENT', l.lang)
     , 'VIS_FIN_MESSAGE_POS_ENVIRONMENT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_POS_ENVIRONMENT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.POS_ENVIRONMENT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 78 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'POS_ENVIRONMENT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANSACTION_TYPE', l.lang)
     , 'VIS_FIN_MESSAGE_TRANSACTION_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANSACTION_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRANSACTION_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 79 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRANSACTION_TYPE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_SEQ_NUMBER', l.lang)
     , 'VIS_FIN_MESSAGE_CARD_SEQ_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_SEQ_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CARD_SEQ_NUMBER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 80 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_SEQ_NUMBER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TERMINAL_PROFILE', l.lang)
     , 'VIS_FIN_MESSAGE_TERMINAL_PROFILE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TERMINAL_PROFILE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERMINAL_PROFILE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 81 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERMINAL_PROFILE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_UNPREDICT_NUMBER', l.lang)
     , 'VIS_FIN_MESSAGE_UNPREDICT_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_UNPREDICT_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.UNPREDICT_NUMBER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 82 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'UNPREDICT_NUMBER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_APPL_TRANS_COUNTER', l.lang)
     , 'VIS_FIN_MESSAGE_APPL_TRANS_COUNTER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_APPL_TRANS_COUNTER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.APPL_TRANS_COUNTER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 83 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'APPL_TRANS_COUNTER'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_APPL_INTERCH_PROFILE', l.lang)
     , 'VIS_FIN_MESSAGE_APPL_INTERCH_PROFILE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_APPL_INTERCH_PROFILE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.APPL_INTERCH_PROFILE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 84 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'APPL_INTERCH_PROFILE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM', l.lang)
     , 'VIS_FIN_MESSAGE_CRYPTOGRAM'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CRYPTOGRAM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 85 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CRYPTOGRAM'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TERM_VERIF_RESULT', l.lang)
     , 'VIS_FIN_MESSAGE_TERM_VERIF_RESULT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TERM_VERIF_RESULT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TERM_VERIF_RESULT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 86 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TERM_VERIF_RESULT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM_AMOUNT', l.lang)
     , 'VIS_FIN_MESSAGE_CRYPTOGRAM_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM_AMOUNT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CRYPTOGRAM_AMOUNT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 87 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CRYPTOGRAM_AMOUNT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_VERIF_RESULT', l.lang)
     , 'VIS_FIN_MESSAGE_CARD_VERIF_RESULT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_VERIF_RESULT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CARD_VERIF_RESULT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 88 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_VERIF_RESULT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISSUER_APPL_DATA', l.lang)
     , 'VIS_FIN_MESSAGE_ISSUER_APPL_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISSUER_APPL_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ISSUER_APPL_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 89 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ISSUER_APPL_DATA'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISSUER_SCRIPT_RESULT', l.lang)
     , 'VIS_FIN_MESSAGE_ISSUER_SCRIPT_RESULT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_ISSUER_SCRIPT_RESULT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ISSUER_SCRIPT_RESULT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 90 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'ISSUER_SCRIPT_RESULT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_EXPIR_DATE', l.lang)
     , 'VIS_FIN_MESSAGE_CARD_EXPIR_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CARD_EXPIR_DATE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CARD_EXPIR_DATE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 91 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CARD_EXPIR_DATE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM_VERSION', l.lang)
     , 'VIS_FIN_MESSAGE_CRYPTOGRAM_VERSION'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM_VERSION', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CRYPTOGRAM_VERSION as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 92 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CRYPTOGRAM_VERSION'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CVV2_RESULT_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_CVV2_RESULT_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CVV2_RESULT_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CVV2_RESULT_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 93 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CVV2_RESULT_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_RESP_CODE', l.lang)
     , 'VIS_FIN_MESSAGE_AUTH_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_AUTH_RESP_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.AUTH_RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 94 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'AUTH_RESP_CODE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM_INFO_DATA', l.lang)
     , 'VIS_FIN_MESSAGE_CRYPTOGRAM_INFO_DATA'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_CRYPTOGRAM_INFO_DATA', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CRYPTOGRAM_INFO_DATA as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 95 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'CRYPTOGRAM_INFO_DATA'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANSACTION_ID', l.lang)
     , 'VIS_FIN_MESSAGE_TRANSACTION_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_TRANSACTION_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TRANSACTION_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 96 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'TRANSACTION_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_VERIF_VALUE', l.lang)
     , 'VIS_FIN_MESSAGE_MERCHANT_VERIF_VALUE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_MERCHANT_VERIF_VALUE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MERCHANT_VERIF_VALUE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 97 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'MERCHANT_VERIF_VALUE'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_HOST_INST_ID', l.lang)
     , 'VIS_FIN_MESSAGE_HOST_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_HOST_INST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.HOST_INST_ID as column_number_value
     , to_date(null) as column_date_value
     , 98 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'HOST_INST_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PROC_BIN', l.lang)
     , 'VIS_FIN_MESSAGE_PROC_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_MESSAGE_PROC_BIN', l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.PROC_BIN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 99 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PROC_BIN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_FEE_INTERCHANGE_AMOUNT', l.lang)
     , 'VIS_FIN_FEE_INTERCHANGE_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_FEE_INTERCHANGE_AMOUNT', l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.fee_interchange_amount / power(10, com_api_currency_pkg.get_currency_exponent(a.sttl_currency)) as column_number_value
     , to_date(null) as column_date_value
     , 100 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FEE_INTERCHANGE_AMOUNT'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_FEE_INTERCHANGE_SIGN', l.lang)
     , 'VIS_FIN_FEE_INTERCHANGE_SIGN'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_FEE_INTERCHANGE_SIGN', l.lang)) as name
     , 'VARCHAR2' as data_type
     , decode(a.fee_interchange_sign, -1, get_article_text('SIGN0001', get_user_lang), 1, get_article_text('SIGN0003', get_user_lang)) as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 101 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'FEE_INTERCHANGE_SIGN'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_PROGRAM_ID', l.lang)
     , 'VIS_FIN_PROGRAM_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_PROGRAM_ID', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.program_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 102 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'PROGRAM_ID'
union all
select decode(com_api_label_pkg.get_label_text('VIS_FIN_DCC_INDICATOR', l.lang)
     , 'VIS_FIN_DCC_INDICATOR'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VIS_FIN_DCC_INDICATOR', l.lang)) as name
     , 'VARCHAR2' as data_type
     , get_article_text(i_article => case a.dcc_indicator
                                     when '0' then 'BOOL0000'
                                     when '1' then 'BOOL0001'
                                     end
                       , i_lang    => get_user_lang
                       ) as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 103 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'DCC_INDICATOR'   
union all
select decode(com_api_label_pkg.get_label_text('AGENT_UNIQUE_ID', l.lang)
     , 'AGENT_UNIQUE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('AGENT_UNIQUE_ID', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.agent_unique_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 104 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'AGENT_UNIQUE_ID'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('BUSINESS_FORMAT_CODE', l.lang)
     , 'BUSINESS_FORMAT_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('BUSINESS_FORMAT_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.business_format_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 105 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'BUSINESS_FORMAT_CODE'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('MESSAGE_REASON_CODE', l.lang)
     , 'MESSAGE_REASON_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('MESSAGE_REASON_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.message_reason_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 106 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'MESSAGE_REASON_CODE'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('DISPUTE_CONDITION', l.lang)
     , 'DISPUTE_CONDITION'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('DISPUTE_CONDITION', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.dispute_condition as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 107 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'DISPUTE_CONDITION'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('VROL_FINANCIAL_ID', l.lang)
     , 'VROL_FINANCIAL_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VROL_FINANCIAL_ID', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.vrol_financial_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 108 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'VROL_FINANCIAL_ID'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('VROL_CASE_NUMBER', l.lang)
     , 'VROL_CASE_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VROL_CASE_NUMBER', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.vrol_case_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 109 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'VROL_CASE_NUMBER'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('VROL_BUNDLE_NUMBER', l.lang)
     , 'VROL_BUNDLE_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('VROL_BUNDLE_NUMBER', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.vrol_bundle_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 110 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'VROL_BUNDLE_NUMBER'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('CLIENT_CASE_NUMBER', l.lang)
     , 'CLIENT_CASE_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('CLIENT_CASE_NUMBER', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.client_case_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 111 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'CLIENT_CASE_NUMBER'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('DISPUTE_STATUS', l.lang)
     , 'DISPUTE_STATUS'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('DISPUTE_STATUS', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.dispute_status as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 112 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'DISPUTE_STATUS'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('PAYMENT_ACC_REF', l.lang)
     , 'PAYMENT_ACC_REF'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('PAYMENT_ACC_REF', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.payment_acc_ref as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 113 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'PAYMENT_ACC_REF'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('TOKEN_REQUESTOR_ID', l.lang)
     , 'TOKEN_REQUESTOR_ID'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('TOKEN_REQUESTOR_ID', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t.token_requestor_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 114 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr4 t
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR4'
   and c.owner = USER
   and c.column_name = 'TOKEN_REQUESTOR_ID'
   and a.id = t.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('PASSENGER_NAME', l.lang)
     , 'PASSENGER_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('PASSENGER_NAME', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.passenger_name as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 115 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'PASSENGER_NAME'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('DEPARTURE_DATE', l.lang)
     , 'DEPARTURE_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('DEPARTURE_DATE', l.lang)) as name
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , t3.departure_date as column_date_value
     , 116 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'DEPARTURE_DATE'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('ORIG_CITY_AIRPORT_CODE', l.lang)
     , 'ORIG_CITY_AIRPORT_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('ORIG_CITY_AIRPORT_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.orig_city_airport_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 117 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'ORIG_CITY_AIRPORT_CODE'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('CARRIER_CODE_1', l.lang)
     , 'CARRIER_CODE_1'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('CARRIER_CODE_1', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.carrier_code_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 118 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'CARRIER_CODE_1'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('SERVICE_CLASS_CODE_1', l.lang)
     , 'SERVICE_CLASS_CODE_1'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('SERVICE_CLASS_CODE_1', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.service_class_code_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 119 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'SERVICE_CLASS_CODE_1'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('STOP_OVER_CODE_1', l.lang)
     , 'STOP_OVER_CODE_1'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('STOP_OVER_CODE_1', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.stop_over_code_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 120 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'STOP_OVER_CODE_1'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('DEST_CITY_AIRPORT_CODE_1', l.lang)
     , 'DEST_CITY_AIRPORT_CODE_1'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('DEST_CITY_AIRPORT_CODE_1', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.dest_city_airport_code_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 121 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'DEST_CITY_AIRPORT_CODE_1'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('TRAVEL_AGENCY_CODE', l.lang)
     , 'TRAVEL_AGENCY_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('TRAVEL_AGENCY_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.travel_agency_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 122 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'TRAVEL_AGENCY_CODE'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('TRAVEL_AGENCY_NAME', l.lang)
     , 'TRAVEL_AGENCY_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('TRAVEL_AGENCY_NAME', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.travel_agency_name as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 123 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'TRAVEL_AGENCY_NAME'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('RESTRICT_TICKET_INDICATOR', l.lang)
     , 'RESTRICT_TICKET_INDICATOR'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('RESTRICT_TICKET_INDICATOR', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.restrict_ticket_indicator as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 124 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'RESTRICT_TICKET_INDICATOR'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('FARE_BASIS_CODE_1', l.lang)
     , 'FARE_BASIS_CODE_1'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('FARE_BASIS_CODE_1', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.fare_basis_code_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 125 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'FARE_BASIS_CODE_1'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('COMP_RESERV_SYSTEM', l.lang)
     , 'COMP_RESERV_SYSTEM'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('COMP_RESERV_SYSTEM', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.comp_reserv_system as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 126 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'COMP_RESERV_SYSTEM'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('FLIGHT_NUMBER_1', l.lang)
     , 'FLIGHT_NUMBER_1'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('FLIGHT_NUMBER_1', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.flight_number_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 127 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'FLIGHT_NUMBER_1'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('CREDIT_REASON_INDICATOR', l.lang)
     , 'CREDIT_REASON_INDICATOR'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('CREDIT_REASON_INDICATOR', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.credit_reason_indicator as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 128 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'CREDIT_REASON_INDICATOR'
   and a.id = t3.id(+)   
union all
select decode(com_api_label_pkg.get_label_text('TICKET_CHANGE_INDICATOR', l.lang)
     , 'TICKET_CHANGE_INDICATOR'
     , substr(c.comments,1,instr(c.comments||'.','.')-1)
     , com_api_label_pkg.get_label_text('TICKET_CHANGE_INDICATOR', l.lang)) as name
     , 'VARCHAR2' as data_type
     , t3.ticket_change_indicator as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 129 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , vis_tcr3 t3
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_TCR3'
   and c.owner = USER
   and c.column_name = 'TICKET_CHANGE_INDICATOR'
   and a.id = t3.id(+)   
union all
select nvl(substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('RECIPIENT_NAME', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.recipient_name as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 130 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_FIN_MESSAGE'
   and c.owner = USER
   and c.column_name = 'RECIPIENT_NAME'
union all
select nvl(substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('TERMINAL_TRANS_DATE', l.lang)
       ) as name 
     , 'DATE' as data_type
     , a.recipient_name as column_char_value
     , to_number(null) as column_number_value
     , a.terminal_trans_date as column_date_value
     , 131 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name  = 'VIS_FIN_MESSAGE'
   and c.owner       = USER
   and c.column_name = 'TERMINAL_TRANS_DATE'
union all
select nvl(substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('CONV_DATE', l.lang)
       ) as name 
     , 'DATE' as data_type
     , a.recipient_name as column_char_value
     , to_number(null) as column_number_value
     , a.terminal_trans_date as column_date_value
     , 132 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name  = 'VIS_FIN_MESSAGE'
   and c.owner       = USER
   and c.column_name = 'CONV_DATE'
order by oper_id, column_order
/
