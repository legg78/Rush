create or replace force view vis_ui_retrieval_vw as
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ID', l.lang)
     , 'VIS_RETRIEVAL_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ID', l.lang)) 
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
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ID'
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_FILE_ID', l.lang)
     , 'VIS_RETRIEVAL_FILE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_FILE_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.file_id as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'FILE_ID'
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REQ_ID', l.lang)
     , 'VIS_RETRIEVAL_REQ_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REQ_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.req_id as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'REQ_ID'  
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_PURCHASE_DATE', l.lang)
     , 'VIS_RETRIEVAL_PURCHASE_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_PURCHASE_DATE', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.purchase_date as column_date_value
     , 4 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'PURCHASE_DATE'
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_SOURCE_AMOUNT', l.lang)
     , 'VIS_RETRIEVAL_SOURCE_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_SOURCE_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.source_amount as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'SOURCE_AMOUNT'       
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_SOURCE_CURRENCY', l.lang)
     , 'VIS_RETRIEVAL_SOURCE_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_SOURCE_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.source_currency as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'SOURCE_CURRENCY'
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_COUNTRY_CODE', l.lang)
     , 'VIS_RETRIEVAL_COUNTRY_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_COUNTRY_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.country_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'COUNTRY_CODE'   
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_STATE_PROVINCE', l.lang)
     , 'VIS_RETRIEVAL_STATE_PROVINCE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_STATE_PROVINCE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.state_province as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'STATE_PROVINCE'   
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REASON_CODE', l.lang)
     , 'VIS_RETRIEVAL_REASON_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REASON_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.reason_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'REASON_CODE' 
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_NATIONAL_REIMB_FEE', l.lang)
     , 'VIS_RETRIEVAL_NATIONAL_REIMB_FEE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_NATIONAL_REIMB_FEE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.national_reimb_fee as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'NATIONAL_REIMB_FEE'    
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ATM_ACCOUNT_SEL', l.lang)
     , 'VIS_RETRIEVAL_ATM_ACCOUNT_SEL'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ATM_ACCOUNT_SEL', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.atm_account_sel as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ATM_ACCOUNT_SEL' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REIMB_FLAG', l.lang)
     , 'VIS_RETRIEVAL_REIMB_FLAG'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REIMB_FLAG', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.reimb_flag as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'REIMB_FLAG' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_FAX_NUMBER', l.lang)
     , 'VIS_RETRIEVAL_FAX_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_FAX_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.fax_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'FAX_NUMBER' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REQ_FULFILL_METHOD', l.lang)
     , 'VIS_RETRIEVAL_REQ_FULFILL_METHOD'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_REQ_FULFILL_METHOD', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.req_fulfill_method as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'REQ_FULFILL_METHOD' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_USED_FULFILL_METHOD', l.lang)
     , 'VIS_RETRIEVAL_USED_FULFILL_METHOD'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_USED_FULFILL_METHOD', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.used_fulfill_method as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'USED_FULFILL_METHOD' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_RFC_BIN', l.lang)
     , 'VIS_RETRIEVAL_ISS_RFC_BIN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_RFC_BIN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.iss_rfc_bin as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ISS_RFC_BIN'      
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_RFC_SUBADDR', l.lang)
     , 'VIS_RETRIEVAL_ISS_RFC_SUBADDR'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_RFC_SUBADDR', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.iss_rfc_subaddr as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ISS_RFC_SUBADDR' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_BILLING_CURRENCY', l.lang)
     , 'VIS_RETRIEVAL_ISS_BILLING_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_BILLING_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.iss_billing_currency as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ISS_BILLING_CURRENCY' 
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_BILLING_AMOUNT', l.lang)
     , 'VIS_RETRIEVAL_ISS_BILLING_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_BILLING_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.iss_billing_amount as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ISS_BILLING_AMOUNT' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_TRANS_ID', l.lang)
     , 'VIS_RETRIEVAL_TRANS_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_TRANS_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.trans_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'TRANS_ID' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_EXCLUDED_TRANS_ID_REASON', l.lang)
     , 'VIS_RETRIEVAL_EXCLUDED_TRANS_ID_REASON'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_EXCLUDED_TRANS_ID_REASON', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.excluded_trans_id_reason as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'EXCLUDED_TRANS_ID_REASON' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_CRS_CODE', l.lang)
     , 'VIS_RETRIEVAL_CRS_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_CRS_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.crs_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'CRS_CODE' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_MULTIPLE_CLEARING_SEQN', l.lang)
     , 'VIS_RETRIEVAL_MULTIPLE_CLEARING_SEQN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_MULTIPLE_CLEARING_SEQN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.multiple_clearing_seqn as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'MULTIPLE_CLEARING_SEQN' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_PRODUCT_CODE', l.lang)
     , 'VIS_RETRIEVAL_PRODUCT_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_PRODUCT_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.product_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'PRODUCT_CODE' 
union  
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_CONTACT_INFO', l.lang)
     , 'VIS_RETRIEVAL_CONTACT_INFO'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_CONTACT_INFO', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.contact_info as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'CONTACT_INFO' 
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_INST_ID', l.lang)
     , 'VIS_RETRIEVAL_ISS_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ISS_INST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.iss_inst_id as column_number_value
     , to_date(null) as column_date_value
     , 26 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ISS_INST_ID' 
union 
select  decode(com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ACQ_INST_ID', l.lang)
     , 'VIS_RETRIEVAL_ACQ_INST_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('VIS_RETRIEVAL_ACQ_INST_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.acq_inst_id as column_number_value
     , to_date(null) as column_date_value
     , 27 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from vis_retrieval a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='VIS_RETRIEVAL'
   and c.owner = USER
   and c.column_name = 'ACQ_INST_ID' 
/
