create or replace force view din_ui_fin_message_vw
as
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_ID', l.lang)
         , 'DIN_FIN_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_ID', l.lang)
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
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_STATUS', l.lang)
         , 'DIN_FIN_STATUS'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_STATUS', l.lang)
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
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'STATUS'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_FILE_ID', l.lang)
         , 'DIN_FIN_FILE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_FILE_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.file_id as column_number_value
     , null as column_date_value
     , 3 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FILE_ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_RECORD_NUMBER', l.lang)
         , 'DIN_FIN_RECORD_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_RECORD_NUMBER', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.record_number as column_number_value
     , null as column_date_value
     , 4 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'RECORD_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_BATCH_ID', l.lang)
         , 'DIN_FIN_BATCH_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_BATCH_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.batch_id as column_number_value
     , null as column_date_value
     , 5 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'BATCH_ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_SEQUENTIAL_NUMBER', l.lang)
         , 'DIN_FIN_SEQUENTIAL_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_SEQUENTIAL_NUMBER', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.sequential_number as column_number_value
     , null as column_date_value
     , 6 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'SEQUENTIAL_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_IS_INCOMING', l.lang)
         , 'DIN_FIN_IS_INCOMING'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_IS_INCOMING', l.lang)
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
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_INCOMING'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_IS_REJECTED', l.lang)
         , 'DIN_FIN_IS_REJECTED'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_IS_REJECTED', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_rejected as column_number_value
     , null as column_date_value
     , 8 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_REJECTED'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_IS_REVERSAL', l.lang)
         , 'DIN_FIN_IS_REVERSAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_IS_REVERSAL', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_reversal as column_number_value
     , null as column_date_value
     , 9 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_REVERSAL'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_IS_INVALID', l.lang)
         , 'DIN_FIN_IS_INVALID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_IS_INVALID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.is_invalid as column_number_value
     , null as column_date_value
     , 10 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_INVALID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_NETWORK_ID', l.lang)
         , 'DIN_FIN_NETWORK_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_NETWORK_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.network_id as column_number_value
     , null as column_date_value
     , 11 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'NETWORK_ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_INST_ID', l.lang)
         , 'DIN_FIN_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_INST_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.inst_id as column_number_value
     , null as column_date_value
     , 12 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'INST_ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_SENDING_INSTITUTION', l.lang)
         , 'DIN_FIN_SENDING_INSTITUTION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_SENDING_INSTITUTION', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.sending_institution as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 13 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'SENDING_INSTITUTION'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_RECEIVING_INSTITUTION', l.lang)
         , 'DIN_FIN_RECEIVING_INSTITUTION'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_RECEIVING_INSTITUTION', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.receiving_institution as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 14 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'RECEIVING_INSTITUTION'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_DISPUTE_ID', l.lang)
         , 'DIN_FIN_DISPUTE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_DISPUTE_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.dispute_id as column_number_value
     , null as column_date_value
     , 15 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DISPUTE_ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_ORIGINATOR_REFNUM', l.lang)
         , 'DIN_FIN_ORIGINATOR_REFNUM'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_ORIGINATOR_REFNUM', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.originator_refnum as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 16 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ORIGINATOR_REFNUM'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_NETWORK_REFNUM', l.lang)
         , 'DIN_FIN_NETWORK_REFNUM'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_NETWORK_REFNUM', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.network_refnum as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 17 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'NETWORK_REFNUM'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CARD_ID', l.lang)
         , 'DIN_FIN_CARD_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CARD_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.card_id as column_number_value
     , null as column_date_value
     , 18 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_ID'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_TYPE_OF_CHARGE', l.lang)
         , 'DIN_FIN_TYPE_OF_CHARGE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_TYPE_OF_CHARGE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.type_of_charge as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 19 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TYPE_OF_CHARGE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CHARGE_TYPE', l.lang)
         , 'DIN_FIN_CHARGE_TYPE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CHARGE_TYPE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.charge_type as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 20 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CHARGE_TYPE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_DATE_TYPE', l.lang)
         , 'DIN_FIN_DATE_TYPE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_DATE_TYPE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.date_type as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 21 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DATE_TYPE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CHARGE_DATE', l.lang)
         , 'DIN_FIN_CHARGE_DATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CHARGE_DATE', l.lang)
       ) as name
     , 'DATE' as data_type
     , null as column_char_value
     , null as column_number_value
     , a.charge_date as column_date_value
     , 22 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CHARGE_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_AUTH_CODE', l.lang)
         , 'DIN_FIN_AUTH_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_AUTH_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.auth_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 23 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'AUTH_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_ACTION_CODE', l.lang)
         , 'DIN_FIN_ACTION_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_ACTION_CODE', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.action_code as column_number_value
     , null as column_date_value
     , 24 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ACTION_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_OPER_AMOUNT', l.lang)
         , 'DIN_FIN_OPER_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_OPER_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.oper_amount as column_number_value
     , null as column_date_value
     , 25 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'OPER_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_OPER_CURRENCY', l.lang)
         , 'DIN_FIN_OPER_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_OPER_CURRENCY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.oper_currency as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 26 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'OPER_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_STTL_AMOUNT', l.lang)
         , 'DIN_FIN_STTL_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_STTL_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.sttl_amount as column_number_value
     , null as column_date_value
     , 27 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'STTL_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_STTL_CURRENCY', l.lang)
         , 'DIN_FIN_STTL_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_STTL_CURRENCY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.sttl_currency as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 28 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'STTL_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MCC', l.lang)
         , 'DIN_FIN_MCC'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MCC', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.mcc as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 29 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MCC'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_NUMBER', l.lang)
         , 'DIN_FIN_MERCHANT_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 30 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_NAME', l.lang)
         , 'DIN_FIN_MERCHANT_NAME'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_NAME', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_name as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 31 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_NAME'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_CITY', l.lang)
         , 'DIN_FIN_MERCHANT_CITY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_CITY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_city as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 32 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_CITY'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_COUNTRY', l.lang)
         , 'DIN_FIN_MERCHANT_COUNTRY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_COUNTRY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_country as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 33 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_COUNTRY'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_STATE', l.lang)
         , 'DIN_FIN_MERCHANT_STATE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_STATE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_state as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 34 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_STATE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_STREET', l.lang)
         , 'DIN_FIN_MERCHANT_STREET'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_STREET', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_street as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 35 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_STREET'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_POSTAL_CODE', l.lang)
         , 'DIN_FIN_MERCHANT_POSTAL_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_POSTAL_CODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_postal_code as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 36 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_POSTAL_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_PHONE', l.lang)
         , 'DIN_FIN_MERCHANT_PHONE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_PHONE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.merchant_phone as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 37 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_PHONE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_INTERNATIONAL_CODE', l.lang)
         , 'DIN_FIN_MERCHANT_INTERNATIONAL_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_MERCHANT_INTERNATIONAL_CODE', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.merchant_international_code as column_number_value
     , null as column_date_value
     , 38 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MERCHANT_INTERNATIONAL_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_PROGRAM_TRANSACTION_AMOUNT', l.lang)
         , 'DIN_FIN_PROGRAM_TRANSACTION_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_PROGRAM_TRANSACTION_AMOUNT', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.program_transaction_amount as column_number_value
     , null as column_date_value
     , 39 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'PROGRAM_TRANSACTION_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_TAX_AMOUNT1', l.lang)
         , 'DIN_FIN_TAX_AMOUNT1'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_TAX_AMOUNT1', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.tax_amount1 as column_number_value
     , null as column_date_value
     , 40 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TAX_AMOUNT1'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_TAX_AMOUNT2', l.lang)
         , 'DIN_FIN_TAX_AMOUNT2'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_TAX_AMOUNT2', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , a.tax_amount2 as column_number_value
     , null as column_date_value
     , 41 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'TAX_AMOUNT2'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_ORIGINAL_DOCUMENT_NUMBER', l.lang)
         , 'DIN_FIN_ORIGINAL_DOCUMENT_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_ORIGINAL_DOCUMENT_NUMBER', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.original_document_number as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 42 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ORIGINAL_DOCUMENT_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CRDH_PRESENCE', l.lang)
         , 'DIN_FIN_CRDH_PRESENCE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CRDH_PRESENCE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.crdh_presence as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 43 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CRDH_PRESENCE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CARD_PRESENCE', l.lang)
         , 'DIN_FIN_CARD_PRESENCE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CARD_PRESENCE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.card_presence as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 44 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_PRESENCE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CARD_DATA_INPUT_MODE', l.lang)
         , 'DIN_FIN_CARD_DATA_INPUT_MODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CARD_DATA_INPUT_MODE', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.card_data_input_mode as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 45 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_DATA_INPUT_MODE'
union
select decode(
           com_api_label_pkg.get_label_text('DIN_FIN_CARD_DATA_INPUT_CAPABILITY', l.lang)
         , 'DIN_FIN_CARD_DATA_INPUT_CAPABILITY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text('DIN_FIN_CARD_DATA_INPUT_CAPABILITY', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.card_data_input_capability as column_char_value
     , null as column_number_value
     , null as column_date_value
     , 46 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , null as tech_id
  from din_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'DIN_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'CARD_DATA_INPUT_CAPABILITY'
/
 