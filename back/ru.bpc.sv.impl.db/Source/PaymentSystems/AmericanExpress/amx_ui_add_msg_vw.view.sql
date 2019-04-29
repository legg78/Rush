create or replace force view amx_ui_add_msg_vw as
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_ID', l.lang)
         , 'AMX_ADD_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.id as column_number_value
     , null as column_date_value
     , 1 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_FIN_ID', l.lang)
         , 'AMX_ADD_FIN_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_FIN_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.fin_id as column_number_value
     , null as column_date_value
     , 2 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'FIN_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_FILE_ID', l.lang)
         , 'AMX_ADD_FILE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_FILE_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.file_id as column_number_value
     , null as column_date_value
     , 3 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'FILE_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_IS_INCOMING', l.lang)
         , 'AMX_ADD_IS_INCOMING'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_IS_INCOMING', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_incoming as column_number_value
     , null as column_date_value
     , 4 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'IS_INCOMING'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_MTID', l.lang)
         , 'AMX_ADD_MTID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_MTID', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.mtid as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 5 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'MTID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_ADDENDA_TYPE', l.lang)
         , 'AMX_ADD_ADDENDA_TYPE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_ADDENDA_TYPE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.addenda_type as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 6 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'ADDENDA_TYPE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_FORMAT_CODE', l.lang)
         , 'AMX_ADD_FORMAT_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_FORMAT_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.format_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 7 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'FORMAT_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_MESSAGE_SEQ_NUMBER', l.lang)
         , 'AMX_ADD_MESSAGE_SEQ_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_MESSAGE_SEQ_NUMBER', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.message_seq_number as column_number_value
     , null as column_date_value
     , 8 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'MESSAGE_SEQ_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_TRANSACTION_ID', l.lang)
         , 'AMX_ADD_TRANSACTION_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_TRANSACTION_ID', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.transaction_id as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 9 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'TRANSACTION_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_MESSAGE_NUMBER', l.lang)
         , 'AMX_ADD_MESSAGE_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_MESSAGE_NUMBER', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.message_number as column_number_value
     , null as column_date_value
     , 10 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'MESSAGE_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_REJECT_REASON_CODE', l.lang)
         , 'AMX_ADD_REJECT_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_REJECT_REASON_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.reject_reason_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 11 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD'
   and c.owner = user
   and c.column_name = 'REJECT_REASON_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_ICC_VERSION_NAME', l.lang)
         , 'AMX_ADD_CHIP_ICC_VERSION_NAME'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_ICC_VERSION_NAME', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.icc_version_name as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 12 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'ICC_VERSION_NAME'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_ICC_VERSION_NUMBER', l.lang)
         , 'AMX_ADD_CHIP_ICC_VERSION_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_ICC_VERSION_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.icc_version_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 13 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'ICC_VERSION_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F26', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F26'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F26', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_9f26 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 14 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F26'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F10', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F10'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F10', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_9f10 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 15 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F10'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F37', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F37'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F37', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_9f37 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 16 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F37'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F36', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F36'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F36', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_9f36 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 17 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F36'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_95', l.lang)
         , 'AMX_ADD_CHIP_EMV_95'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_95', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_95 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 18 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_95'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9A', l.lang)
         , 'AMX_ADD_CHIP_EMV_9A'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9A', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.emv_9a as column_date_value
     , 19 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9A'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9C', l.lang)
         , 'AMX_ADD_CHIP_EMV_9C'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9C', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.emv_9c as column_number_value
     , null as column_date_value
     , 20 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9C'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F02', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F02'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F02', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.emv_9f02 as column_number_value
     , null as column_date_value
     , 21 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F02'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_5F2A', l.lang)
         , 'AMX_ADD_CHIP_EMV_5F2A'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_5F2A', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.emv_5f2a as column_number_value
     , null as column_date_value
     , 22 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_5F2A'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F1A', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F1A'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F1A', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.emv_9f1a as column_number_value
     , null as column_date_value
     , 23 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F1A'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_82', l.lang)
         , 'AMX_ADD_CHIP_EMV_82'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_82', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_82 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 24 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_82'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F03', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F03'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F03', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.emv_9f03 as column_number_value
     , null as column_date_value
     , 25 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F03'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_5F34', l.lang)
         , 'AMX_ADD_CHIP_EMV_5F34'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_5F34', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.emv_5f34 as column_number_value
     , null as column_date_value
     , 26 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_5F34'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F27', l.lang)
         , 'AMX_ADD_CHIP_EMV_9F27'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_ADD_CHIP_EMV_9F27', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.emv_9f27 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 27 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_char(a.id) as tech_id
  from amx_add_chip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_ADD_CHIP'
   and c.owner = user
   and c.column_name = 'EMV_9F27'
/
