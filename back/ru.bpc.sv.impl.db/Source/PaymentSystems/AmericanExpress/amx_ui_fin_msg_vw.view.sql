create or replace force view amx_ui_fin_msg_vw
as
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ID', l.lang)
         , 'AMX_FIN_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.id as column_number_value
     , null as column_date_value
     , 1 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_STATUS', l.lang)
         , 'AMX_FIN_STATUS'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_STATUS', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.status as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 2 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'STATUS'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_INST_ID', l.lang)
         , 'AMX_FIN_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_INST_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.inst_id as column_number_value
     , null as column_date_value
     , 3 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'INST_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_NETWORK_ID', l.lang)
         , 'AMX_FIN_NETWORK_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_NETWORK_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.network_id as column_number_value
     , null as column_date_value
     , 4 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'NETWORK_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FILE_ID', l.lang)
         , 'AMX_FIN_FILE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FILE_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.file_id as column_number_value
     , null as column_date_value
     , 5 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FILE_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IS_INVALID', l.lang)
         , 'AMX_FIN_IS_INVALID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IS_INVALID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_invalid as column_number_value
     , null as column_date_value
     , 6 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_INVALID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IS_INCOMING', l.lang)
         , 'AMX_FIN_IS_INCOMING'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IS_INCOMING', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_incoming as column_number_value
     , null as column_date_value
     , 7 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_INCOMING'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IS_REVERSAL', l.lang)
         , 'AMX_FIN_IS_REVERSAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IS_REVERSAL', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_reversal as column_number_value
     , null as column_date_value
     , 8 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_REVERSAL'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IS_COLLECTION_ONLY', l.lang)
         , 'AMX_FIN_IS_COLLECTION_ONLY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IS_COLLECTION_ONLY', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_collection_only as column_number_value
     , null as column_date_value
     , 9 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_COLLECTION_ONLY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IS_REJECTED', l.lang)
         , 'AMX_FIN_IS_REJECTED'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IS_REJECTED', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_rejected as column_number_value
     , null as column_date_value
     , 10 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_REJECTED'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_REJECT_ID', l.lang)
         , 'AMX_FIN_REJECT_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_REJECT_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.reject_id as column_number_value
     , null as column_date_value
     , 11 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'REJECT_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_DISPUTE_ID', l.lang)
         , 'AMX_FIN_DISPUTE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_DISPUTE_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.dispute_id as column_number_value
     , null as column_date_value
     , 12 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DISPUTE_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IMPACT', l.lang)
         , 'AMX_FIN_IMPACT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IMPACT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.impact as column_number_value
     , null as column_date_value
     , 13 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IMPACT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MTID', l.lang)
         , 'AMX_FIN_MTID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MTID', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.mtid as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 14 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MTID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FUNC_CODE', l.lang)
         , 'AMX_FIN_FUNC_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FUNC_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.func_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 15 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FUNC_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_CARD_MASK', l.lang)
         , 'AMX_FIN_CARD_MASK'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_CARD_MASK', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.card_mask as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 16 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_MASK'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PROC_CODE', l.lang)
         , 'AMX_FIN_PROC_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PROC_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.proc_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 17 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PROC_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TRANS_AMOUNT', l.lang)
         , 'AMX_FIN_TRANS_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TRANS_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.trans_amount as column_number_value
     , null as column_date_value
     , 18 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TRANS_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_CURRENCY', l.lang)
         , 'AMX_FIN_FP_TRANS_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_CURRENCY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.fp_trans_currency as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 9 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_TRANS_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TRANS_DECIMALIZATION', l.lang)
         , 'AMX_FIN_TRANS_DECIMALIZATION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TRANS_DECIMALIZATION', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.trans_decimalization as column_number_value
     , null as column_date_value
     , 20 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TRANS_DECIMALIZATION'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TRANS_DATE', l.lang)
         , 'AMX_FIN_TRANS_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TRANS_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.trans_date as column_date_value
     , 21 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TRANS_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_CARD_EXPIR_DATE', l.lang)
         , 'AMX_FIN_CARD_EXPIR_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_CARD_EXPIR_DATE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.card_expir_date as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 22 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_EXPIR_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_CAPTURE_DATE', l.lang)
         , 'AMX_FIN_CAPTURE_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_CAPTURE_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.capture_date as column_date_value
     , 23 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CAPTURE_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MCC', l.lang)
         , 'AMX_FIN_MCC'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MCC', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.mcc as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 24 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MCC'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_1', l.lang)
         , 'AMX_FIN_PDC_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_1', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_1 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 25 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_1'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_2', l.lang)
         , 'AMX_FIN_PDC_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_2', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_2 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 26 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_2'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_3', l.lang)
         , 'AMX_FIN_PDC_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_3', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_3 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 27 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_3'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_4', l.lang)
         , 'AMX_FIN_PDC_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_4', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_4 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 28 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_4'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_5', l.lang)
         , 'AMX_FIN_PDC_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_5', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_5 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 29 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_5'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_6', l.lang)
         , 'AMX_FIN_PDC_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_6', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_6 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 30 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_6'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_7', l.lang)
         , 'AMX_FIN_PDC_7'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_7', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_7 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 31 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_7'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_8', l.lang)
         , 'AMX_FIN_PDC_8'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_8', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_8 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 32 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_8'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_9', l.lang)
         , 'AMX_FIN_PDC_9'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_9', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_9 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 33 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_9'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_10', l.lang)
         , 'AMX_FIN_PDC_10'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_10', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_10 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 34 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_10'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_11', l.lang)
         , 'AMX_FIN_PDC_11'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_11', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_11 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 35 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_11'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PDC_12', l.lang)
         , 'AMX_FIN_PDC_12'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PDC_12', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.pdc_12 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 36 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PDC_12'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_REASON_CODE', l.lang)
         , 'AMX_FIN_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_REASON_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.reason_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 37 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'REASON_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TRANSACTION_ID', l.lang)
         , 'AMX_FIN_TRANSACTION_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TRANSACTION_ID', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.transaction_id as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 38 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TRANSACTION_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IPN', l.lang)
         , 'AMX_FIN_IPN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IPN', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.ipn as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 39 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IPN'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_AIN', l.lang)
         , 'AMX_FIN_AIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_AIN', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.ain as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 40 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'AIN'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_APN', l.lang)
         , 'AMX_FIN_APN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_APN', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.apn as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 41 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'APN'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ARN', l.lang)
         , 'AMX_FIN_ARN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ARN', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.arn as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 42 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ARN'
union   
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_IIN', l.lang)
         , 'AMX_FIN_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_IIN', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.iin as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 43 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IIN'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_APPROVAL_CODE', l.lang)
         , 'AMX_FIN_APPROVAL_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_APPROVAL_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.approval_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 44 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'APPROVAL_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ECI', l.lang)
         , 'AMX_FIN_ECI'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ECI', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.eci as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 45 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ECI'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TERMINAL_NUMBER', l.lang)
         , 'AMX_FIN_TERMINAL_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TERMINAL_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.terminal_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 46 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TERMINAL_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_NUMBER', l.lang)
         , 'AMX_FIN_MERCHANT_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 47 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_NAME', l.lang)
         , 'AMX_FIN_MERCHANT_NAME'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_NAME', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_name as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 48 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_NAME'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_ADDR1', l.lang)
         , 'AMX_FIN_MERCHANT_ADDR1'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_ADDR1', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_addr1 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 49 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_ADDR1'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_ADDR2', l.lang)
         , 'AMX_FIN_MERCHANT_ADDR2'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_ADDR2', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_addr2 as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 50 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_ADDR2'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_CITY', l.lang)
         , 'AMX_FIN_MERCHANT_CITY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_CITY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_city as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 51 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_CITY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_POSTAL_CODE', l.lang)
         , 'AMX_FIN_MERCHANT_POSTAL_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_POSTAL_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_postal_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 52 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_POSTAL_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_COUNTRY', l.lang)
         , 'AMX_FIN_MERCHANT_COUNTRY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_COUNTRY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_country as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 53 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_COUNTRY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_REGION', l.lang)
         , 'AMX_FIN_MERCHANT_REGION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_REGION', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_region as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 54 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_REGION'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_AMOUNT', l.lang)
         , 'AMX_FIN_FP_TRANS_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.fp_trans_amount as column_number_value
     , null as column_date_value
     , 55 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_TRANS_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ISS_GROSS_STTL_AMOUNT', l.lang)
         , 'AMX_FIN_ISS_GROSS_STTL_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ISS_GROSS_STTL_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.iss_gross_sttl_amount as column_number_value
     , null as column_date_value
     , 56 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ISS_GROSS_STTL_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ISS_RATE_AMOUNT', l.lang)
         , 'AMX_FIN_ISS_RATE_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ISS_RATE_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.iss_rate_amount as column_number_value
     , null as column_date_value
     , 57 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ISS_RATE_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ISS_NET_STTL_AMOUNT', l.lang)
         , 'AMX_FIN_ISS_NET_STTL_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ISS_NET_STTL_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.iss_net_sttl_amount as column_number_value
     , null as column_date_value
     , 58 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ISS_NET_STTL_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ISS_STTL_CURRENCY', l.lang)
         , 'AMX_FIN_ISS_STTL_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ISS_STTL_CURRENCY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.iss_sttl_currency as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 59 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ISS_STTL_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ISS_STTL_DECIMALIZATION', l.lang)
         , 'AMX_FIN_ISS_STTL_DECIMALIZATION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ISS_STTL_DECIMALIZATION', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.iss_sttl_decimalization as column_number_value
     , null as column_date_value
     , 60 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ISS_STTL_DECIMALIZATION'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_DECIMALIZATION', l.lang)
         , 'AMX_FIN_FP_TRANS_DECIMALIZATION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_DECIMALIZATION', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.fp_trans_decimalization as column_number_value
     , null as column_date_value
     , 61 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_TRANS_DECIMALIZATION'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_AMOUNT', l.lang)
         , 'AMX_FIN_FP_PRES_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.fp_pres_amount as column_number_value
     , null as column_date_value
     , 62 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_PRES_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_CONVERSION_RATE', l.lang)
         , 'AMX_FIN_FP_PRES_CONVERSION_RATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_CONVERSION_RATE', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.fp_pres_conversion_rate as column_number_value
     , null as column_date_value
     , 63 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_PRES_CONVERSION_RATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_CURRENCY', l.lang)
         , 'AMX_FIN_FP_PRES_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_CURRENCY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.fp_pres_currency as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 64 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_PRES_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_DECIMALIZATION', l.lang)
         , 'AMX_FIN_FP_PRES_DECIMALIZATION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_PRES_DECIMALIZATION', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.fp_pres_decimalization as column_number_value
     , null as column_date_value
     , 65 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_PRES_DECIMALIZATION'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TRANS_CURRENCY', l.lang)
         , 'AMX_FIN_TRANS_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TRANS_CURRENCY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.trans_currency as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 66 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TRANS_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_MULTINATIONAL', l.lang)
         , 'AMX_FIN_MERCHANT_MULTINATIONAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_MULTINATIONAL', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_multinational as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 67 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_MULTINATIONAL'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ITEMIZED_DOC_CODE', l.lang)
         , 'AMX_FIN_ITEMIZED_DOC_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ITEMIZED_DOC_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.itemized_doc_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 68 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ITEMIZED_DOC_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ITEMIZED_DOC_REF_NUMBER', l.lang)
         , 'AMX_FIN_ITEMIZED_DOC_REF_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ITEMIZED_DOC_REF_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.itemized_doc_ref_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 69 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ITEMIZED_DOC_REF_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_EXT_PAYMENT_DATA', l.lang)
         , 'AMX_FIN_EXT_PAYMENT_DATA'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_EXT_PAYMENT_DATA', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.ext_payment_data as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 70 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EXT_PAYMENT_DATA'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MESSAGE_NUMBER', l.lang)
         , 'AMX_FIN_MESSAGE_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MESSAGE_NUMBER', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.message_number as column_number_value
     , null as column_date_value
     , 71 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MESSAGE_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_INVOICE_NUMBER', l.lang)
         , 'AMX_FIN_INVOICE_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_INVOICE_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.invoice_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 72 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'INVOICE_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_REJECT_REASON_CODE', l.lang)
         , 'AMX_FIN_REJECT_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_REJECT_REASON_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.reject_reason_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 73 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'REJECT_REASON_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_CHBCK_REASON_TEXT', l.lang)
         , 'AMX_FIN_CHBCK_REASON_TEXT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_CHBCK_REASON_TEXT', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.chbck_reason_text as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 74 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CHBCK_REASON_TEXT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_CHBCK_REASON_CODE', l.lang)
         , 'AMX_FIN_CHBCK_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_CHBCK_REASON_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.chbck_reason_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 75 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CHBCK_REASON_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_VALID_BILL_UNIT_CODE', l.lang)
         , 'AMX_FIN_VALID_BILL_UNIT_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_VALID_BILL_UNIT_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.valid_bill_unit_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 76 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'VALID_BILL_UNIT_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_STTL_DATE', l.lang)
         , 'AMX_FIN_STTL_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_STTL_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.sttl_date as column_date_value
     , 77 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'STTL_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FORW_INST_CODE', l.lang)
         , 'AMX_FIN_FORW_INST_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FORW_INST_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.forw_inst_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 78 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FORW_INST_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FEE_REASON_TEXT', l.lang)
         , 'AMX_FIN_FEE_REASON_TEXT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FEE_REASON_TEXT', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.fee_reason_text as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 79 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FEE_REASON_TEXT'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FEE_TYPE_CODE', l.lang)
         , 'AMX_FIN_FEE_TYPE_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FEE_TYPE_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.fee_type_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 80 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FEE_TYPE_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_RECEIVING_INST_CODE', l.lang)
         , 'AMX_FIN_RECEIVING_INST_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_RECEIVING_INST_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.receiving_inst_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 81 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'RECEIVING_INST_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_SEND_INST_CODE', l.lang)
         , 'AMX_FIN_SEND_INST_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_SEND_INST_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.send_inst_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 82 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'SEND_INST_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_SEND_PROC_CODE', l.lang)
         , 'AMX_FIN_SEND_PROC_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_SEND_PROC_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.send_proc_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 83 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'SEND_PROC_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_RECEIVING_PROC_CODE', l.lang)
         , 'AMX_FIN_RECEIVING_PROC_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_RECEIVING_PROC_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.receiving_proc_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 84 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'RECEIVING_PROC_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ISS_STTL_DATE', l.lang)
         , 'AMX_FIN_ISS_STTL_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ISS_STTL_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.iss_sttl_date as column_date_value
     , 85 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ISS_STTL_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MATCHING_KEY_TYPE', l.lang)
         , 'AMX_FIN_MATCHING_KEY_TYPE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MATCHING_KEY_TYPE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.matching_key_type as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 86 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MATCHING_KEY_TYPE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MATCHING_KEY', l.lang)
         , 'AMX_FIN_MATCHING_KEY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MATCHING_KEY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.matching_key as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 87 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MATCHING_KEY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_DATE', l.lang)
         , 'AMX_FIN_FP_TRANS_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_TRANS_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.fp_trans_date as column_date_value
     , 88 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_TRANS_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_ICC_PIN_INDICATOR', l.lang)
         , 'AMX_FIN_ICC_PIN_INDICATOR'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_ICC_PIN_INDICATOR', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.icc_pin_indicator as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 89 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ICC_PIN_INDICATOR'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_CARD_CAPABILITY', l.lang)
         , 'AMX_FIN_CARD_CAPABILITY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_CARD_CAPABILITY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.card_capability as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 90 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_CAPABILITY'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_NETWORK_PROC_DATE', l.lang)
         , 'AMX_FIN_NETWORK_PROC_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_NETWORK_PROC_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.network_proc_date as column_date_value
     , 91 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'NETWORK_PROC_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_PROGRAM_INDICATOR', l.lang)
         , 'AMX_FIN_PROGRAM_INDICATOR'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_PROGRAM_INDICATOR', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.program_indicator as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 92 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PROGRAM_INDICATOR'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_TAX_REASON_CODE', l.lang)
         , 'AMX_FIN_TAX_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_TAX_REASON_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.tax_reason_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 93 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TAX_REASON_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FP_NETWORK_PROC_DATE', l.lang)
         , 'AMX_FIN_FP_NETWORK_PROC_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FP_NETWORK_PROC_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.fp_network_proc_date as column_date_value
     , 94 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FP_NETWORK_PROC_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_FORMAT_CODE', l.lang)
         , 'AMX_FIN_FORMAT_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_FORMAT_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.format_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 95 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FORMAT_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MEDIA_CODE', l.lang)
         , 'AMX_FIN_MEDIA_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MEDIA_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.media_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 96 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MEDIA_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MESSAGE_SEQ_NUMBER', l.lang)
         , 'AMX_FIN_MESSAGE_SEQ_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MESSAGE_SEQ_NUMBER', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.message_seq_number as column_number_value
     , null as column_date_value
     , 97 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MESSAGE_SEQ_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_LOCATION_TEXT', l.lang)
         , 'AMX_FIN_MERCHANT_LOCATION_TEXT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('AMX_FIN_MERCHANT_LOCATION_TEXT', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_location_text as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 98 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from amx_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'AMX_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_LOCATION_TEXT'
/
