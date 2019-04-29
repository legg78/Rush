create or replace force view cup_ui_fin_message_vw
as
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.id as column_number_value
     , to_date(null) as column_date_value
     , 1 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANS_CURRENCY'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_TRANS_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANS_CURRENCY'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.trans_currency as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'TRANS_CURRENCY'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_SYS_TRACE_NUM'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_SYS_TRACE_NUM'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_SYS_TRACE_NUM'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.sys_trace_num as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'SYS_TRACE_NUM'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_AUTH_RESP_CODE'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_AUTH_RESP_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_AUTH_RESP_CODE'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.auth_resp_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'AUTH_RESP_CODE'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANSMISSION_DATE_TIME'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_TRANSMISSION_DATE_TIME'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANSMISSION_DATE_TIME'
             , i_lang => l.lang)) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.transmission_date_time as column_date_value
     , 5 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'TRANSMISSION_DATE_TIME'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ACQUIRER_IIN'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_ACQUIRER_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ACQUIRER_IIN'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.acquirer_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'ACQUIRER_IIN'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_FORWARDING_IIN'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_FORWARDING_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_FORWARDING_IIN'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.forwarding_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'FORWARDING_IIN'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MCC'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_MCC'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MCC'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.mcc as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'MCC'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TERMINAL_NUMBER'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_TERMINAL_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TERMINAL_NUMBER'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.terminal_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'TERMINAL_NUMBER'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MERCHANT_NUMBER'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_MERCHANT_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MERCHANT_NUMBER'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.merchant_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'MERCHANT_NUMBER'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MERCHANT_NAME'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_MERCHANT_NAME'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MERCHANT_NAME'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.merchant_name as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'MERCHANT_NAME'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ORIG_TRANS_DATA'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_ORIG_TRANS_DATA'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ORIG_TRANS_DATA'
             , i_lang => l.lang)) as name 
     , 'DUMMY' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'ORIG_TRANS_DATA'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_REASON_CODE'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_REASON_CODE'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.reason_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'REASON_CODE'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_DOUBLE_MESSAGE_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_DOUBLE_MESSAGE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_DOUBLE_MESSAGE_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.double_message_id as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'DOUBLE_MESSAGE_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_CUPS_REF_NUM'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_CUPS_REF_NUM'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_CUPS_REF_NUM'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.cups_ref_num as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'CUPS_REF_NUM'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_RECEIVING_IIN'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_RECEIVING_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_RECEIVING_IIN'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.receiving_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'RECEIVING_IIN'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ISSUER_IIN'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_ISSUER_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ISSUER_IIN'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.issuer_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'ISSUER_IIN'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_CUPS_NOTICE'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_CUPS_NOTICE'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_CUPS_NOTICE'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.cups_notice as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'CUPS_NOTICE'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANS_INIT_CHANNEL'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_TRANS_INIT_CHANNEL'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANS_INIT_CHANNEL'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.trans_init_channel as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'TRANS_INIT_CHANNEL'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANS_FEATURES_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_TRANS_FEATURES_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_TRANS_FEATURES_ID'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.trans_features_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'TRANS_FEATURES_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_LOCAL'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_LOCAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_LOCAL'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.local as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'LOCAL'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_STATUS'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_STATUS'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_STATUS'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.status as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'STATUS'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_REVERSAL'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_IS_REVERSAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_REVERSAL'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_reversal as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'IS_REVERSAL'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_INCOMING'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_IS_INCOMING'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_INCOMING'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_incoming as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'IS_INCOMING'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_REJECTED'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_IS_REJECTED'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_REJECTED'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_rejected as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'IS_REJECTED'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_INVALID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_IS_INVALID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_IS_INVALID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_invalid as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'IS_INVALID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_INST_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_INST_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.inst_id as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'INST_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_NETWORK_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_NETWORK_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_NETWORK_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.network_id as column_number_value
     , to_date(null) as column_date_value
     , 28 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'NETWORK_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_HOST_INST_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_HOST_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_HOST_INST_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.host_inst_id as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'HOST_INST_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_COLLECT_ONLY_FLAG'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_COLLECT_ONLY_FLAG'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_COLLECT_ONLY_FLAG'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.collect_only_flag as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'COLLECT_ONLY_FLAG'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_FILE_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_FILE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_FILE_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.file_id as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'FILE_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MSG_NUMBER'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_MSG_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MSG_NUMBER'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.msg_number as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'MSG_NUMBER'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MERCHANT_COUNTRY'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_MERCHANT_COUNTRY'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_MERCHANT_COUNTRY'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.merchant_country as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'MERCHANT_COUNTRY'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ORIGINAL_ID'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_ORIGINAL_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_ORIGINAL_ID'
             , i_lang => l.lang)) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.original_id as column_number_value
     , to_date(null) as column_date_value
     , 34 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'ORIGINAL_ID'
 union all
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_POS_COND_CODE'
             , i_lang => l.lang)
         , 'CUP_FIN_MESSAGE_POS_COND_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FIN_MESSAGE_POS_COND_CODE'
             , i_lang => l.lang)) as name 
     , 'VARCHAR2' as data_type
     , a.pos_cond_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 35 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
 where c.table_name = 'CUP_FIN_MESSAGE'   
   and c.column_name = 'POS_COND_CODE'
 union all
select case when q.name is null or q.name = 'B2B_BUSINESS_TYPE'
            then substr(c.comments, 1, instr(c.comments || '.', '.'))
            else q.name
            end as name
     , 'VARCHAR2' as data_type
     , a.b2b_business_type as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 36 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
     ,(select l.lang, com_api_label_pkg.get_label_text(i_name => 'B2B_BUSINESS_TYPE', i_lang => l.lang) as name from com_language_vw l)q
 where c.table_name  = 'CUP_FIN_MESSAGE'
   and c.column_name = 'B2B_BUSINESS_TYPE'
   and q.lang        = l.lang
 union all
select case when q.name is null or q.name = 'B2B_PAYMENT_MEDIUM'
            then substr(c.comments, 1, instr(c.comments || '.', '.'))
            else q.name
            end as name
     , 'VARCHAR2' as data_type
     , a.b2b_payment_medium as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 37 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
     ,(select l.lang, com_api_label_pkg.get_label_text(i_name => 'B2B_PAYMENT_MEDIUM', i_lang => l.lang) as name from com_language_vw l)q
 where c.table_name  = 'CUP_FIN_MESSAGE'
   and c.column_name = 'B2B_PAYMENT_MEDIUM'
   and q.lang = l.lang
 union all
select case when q.name is null or q.name = 'QRC_VOUCHER_NUMBER'
            then substr(c.comments, 1, instr(c.comments || '.', '.'))
            else q.name
            end as name
     , 'VARCHAR2' as data_type
     , a.qrc_voucher_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 38 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
     ,(select l.lang, com_api_label_pkg.get_label_text(i_name => 'QRC_VOUCHER_NUMBER', i_lang => l.lang) as name from com_language_vw l)q
 where c.table_name  = 'CUP_FIN_MESSAGE'
   and c.column_name = 'QRC_VOUCHER_NUMBER'
   and q.lang = l.lang
 union all
select case when q.name is null or q.name = 'PAYMENT_FACILITATOR_ID'
            then substr(c.comments, 1, instr(c.comments || '.', '.'))
            else q.name
            end as name
     , 'VARCHAR2' as data_type
     , a.payment_facilitator_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 39 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fin_message a
     , com_language_vw l
     , user_col_comments c
     ,(select l.lang, com_api_label_pkg.get_label_text(i_name => 'PAYMENT_FACILITATOR_ID', i_lang => l.lang) as name from com_language_vw l)q
 where c.table_name  = 'CUP_FIN_MESSAGE'
   and c.column_name = 'PAYMENT_FACILITATOR_ID'
   and q.lang = l.lang
/
