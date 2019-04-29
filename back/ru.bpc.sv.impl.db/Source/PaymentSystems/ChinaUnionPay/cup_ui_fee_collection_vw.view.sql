create or replace force view cup_ui_fee_collection_vw as
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_ID'
             , i_lang => l.lang)
         , 'CUP_FEE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_ID'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.id as column_number_value
     , to_date(null) as column_date_value
     , 1 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'ID'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_FEE_TYPE'
             , i_lang => l.lang)
         , 'CUP_FEE_FEE_TYPE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_FEE_TYPE'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.fee_type as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'FEE_TYPE'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_ACQUIRER_IIN'
             , i_lang => l.lang)
         , 'CUP_FEE_ACQUIRER_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_ACQUIRER_IIN'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.acquirer_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'ACQUIRER_IIN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_FORWARDING_IIN'
             , i_lang => l.lang)
         , 'CUP_FEE_FORWARDING_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_FORWARDING_IIN'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.forwarding_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'FORWARDING_IIN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_TRANSMISSION_DATE_TIME'
             , i_lang => l.lang)
         , 'CUP_FEE_TRANSMISSION_DATE_TIME'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_TRANSMISSION_DATE_TIME'
             , i_lang => l.lang)) as name
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.transmission_date_time as column_date_value
     , 5 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'TRANSMISSION_DATE_TIME'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_PAN'
             , i_lang => l.lang)
         , 'CUP_FEE_PAN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_PAN'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.pan as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'PAN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_MERCHANT_NUMBER'
             , i_lang => l.lang)
         , 'CUP_FEE_MERCHANT_NUMBER'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_MERCHANT_NUMBER'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.merchant_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'MERCHANT_NUMBER'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_AUTH_RESP_CODE'
             , i_lang => l.lang)
         , 'CUP_FEE_AUTH_RESP_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_AUTH_RESP_CODE'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.auth_resp_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'AUTH_RESP_CODE'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_IS_REVERSAL'
             , i_lang => l.lang)
         , 'CUP_FEE_IS_REVERSAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_IS_REVERSAL'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_reversal as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'IS_REVERSAL'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_TRANS_TYPE_ID'
             , i_lang => l.lang)
         , 'CUP_FEE_TRANS_TYPE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_TRANS_TYPE_ID'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.trans_type_id as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'TRANS_TYPE_ID'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_RECEIVING_IIN'
             , i_lang => l.lang)
         , 'CUP_FEE_RECEIVING_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_RECEIVING_IIN'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , a.receiving_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'RECEIVING_IIN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_ISSUER_IIN'
             , i_lang => l.lang)
         , 'CUP_FEE_ISSUER_IIN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_ISSUER_IIN'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , a.issuer_iin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'ISSUER_IIN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_STTL_CURRENCY'
             , i_lang => l.lang)
         , 'CUP_FEE_STTL_CURRENCY'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_STTL_CURRENCY'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , a.sttl_currency as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'STTL_CURRENCY'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_STTL_AMOUNT'
             , i_lang => l.lang)
         , 'CUP_FEE_STTL_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_STTL_AMOUNT'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.sttl_sign as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'STTL_SIGN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_STTL_AMOUNT'
             , i_lang => l.lang)
         , 'CUP_FEE_STTL_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_STTL_AMOUNT'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.sttl_amount as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'STTL_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_INTERCHANGE_FEE_SIGN'
             , i_lang => l.lang)
         , 'CUP_FEE_INTERCHANGE_FEE_SIGN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_INTERCHANGE_FEE_SIGN'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.interchange_fee_sign as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'INTERCHANGE_FEE_SIGN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_INTERCHANGE_FEE_AMOUNT'
             , i_lang => l.lang)
         , 'CUP_FEE_INTERCHANGE_FEE_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_INTERCHANGE_FEE_AMOUNT'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.interchange_fee_amount as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'INTERCHANGE_FEE_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_REIMBURSEMENT_FEE_SIGN'
             , i_lang => l.lang)
         , 'CUP_FEE_REIMBURSEMENT_FEE_SIGN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_REIMBURSEMENT_FEE_SIGN'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.reimbursement_fee_sign as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'REIMBURSEMENT_FEE_SIGN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_REIMBURSEMENT_FEE_AMOUNT'
             , i_lang => l.lang)
         , 'CUP_FEE_REIMBURSEMENT_FEE_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_REIMBURSEMENT_FEE_AMOUNT'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.reimbursement_fee_amount as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'REIMBURSEMENT_FEE_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_SERVICE_FEE_SIGN'
             , i_lang => l.lang)
         , 'CUP_FEE_SERVICE_FEE_SIGN'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_SERVICE_FEE_SIGN'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.service_fee_sign as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'SERVICE_FEE_SIGN'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_SERVICE_FEE_AMOUNT'
             , i_lang => l.lang)
         , 'CUP_FEE_SERVICE_FEE_AMOUNT'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_SERVICE_FEE_AMOUNT'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.service_fee_amount as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'SERVICE_FEE_AMOUNT'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_FIN_MSG_ID'
             , i_lang => l.lang)
         , 'CUP_FEE_FIN_MSG_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_FIN_MSG_ID'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.fin_msg_id as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'FIN_MSG_ID'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_MATCH_STATUS'
             , i_lang => l.lang)
         , 'CUP_FEE_MATCH_STATUS'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_MATCH_STATUS'
             , i_lang => l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.match_status as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'MATCH_STATUS'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_INST_ID'
             , i_lang => l.lang)
         , 'CUP_FEE_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_INST_ID'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.inst_id as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'INST_ID'
union
select decode(
           com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_REASON_CODE'
             , i_lang => l.lang)
         , 'CUP_FEE_REASON_CODE'
         , substr(c.comments, 1, instr(c.comments || '.', '.') - 1)
         , com_api_label_pkg.get_label_text(
               i_name => 'CUP_FEE_REASON_CODE'
             , i_lang => l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.reason_code as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order
     , a.fin_msg_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from cup_fee   a
     , com_language_vw   l
     , user_col_comments c
 where c.table_name = 'CUP_FEE'
   and c.column_name = 'REASON_CODE'
/
