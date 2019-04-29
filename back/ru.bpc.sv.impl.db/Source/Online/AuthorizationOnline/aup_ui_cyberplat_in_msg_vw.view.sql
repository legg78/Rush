create or replace force view aup_ui_cyberplat_in_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_AUTH_ID', l.lang)
     , 'AUP_CYBERPLAT_IN_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_AUTH_ID', l.lang)) 
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
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_TECH_ID', l.lang)
     , 'AUP_CYBERPLAT_IN_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_TECH_ID', l.lang)) 
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
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_ACTION', l.lang)
     , 'AUP_CYBERPLAT_IN_ACTION'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_ACTION', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ACTION as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'ACTION'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_SUBSCR_NUMBER', l.lang)
     , 'AUP_CYBERPLAT_IN_SUBSCR_NUMBER'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_SUBSCR_NUMBER', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.SUBSCR_NUMBER as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'SUBSCR_NUMBER'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_PMT_TYPE', l.lang)
     , 'AUP_CYBERPLAT_IN_PMT_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_PMT_TYPE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.PMT_TYPE as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'PMT_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_AMOUNT', l.lang)
     , 'AUP_CYBERPLAT_IN_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_RECEIPT', l.lang)
     , 'AUP_CYBERPLAT_IN_RECEIPT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_RECEIPT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RECEIPT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'RECEIPT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_MES', l.lang)
     , 'AUP_CYBERPLAT_IN_MES'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_MES', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.MES as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'MES'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_ADDL', l.lang)
     , 'AUP_CYBERPLAT_IN_ADDL'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_ADDL', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ADDL as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'ADDL'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_CODE', l.lang)
     , 'AUP_CYBERPLAT_IN_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_CODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.CODE as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'CODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_OPER_DATE', l.lang)
     , 'AUP_CYBERPLAT_IN_OPER_DATE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_OPER_DATE', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.OPER_DATE as column_date_value
     , 11 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'OPER_DATE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_AUTHCODE', l.lang)
     , 'AUP_CYBERPLAT_IN_AUTHCODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_AUTHCODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.AUTHCODE as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'AUTHCODE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_TIME_MARK', l.lang)
     , 'AUP_CYBERPLAT_IN_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_TIME_MARK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TIME_MARK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_IS_RESPONSE', l.lang)
     , 'AUP_CYBERPLAT_IN_IS_RESPONSE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_IS_RESPONSE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.IS_RESPONSE as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'IS_RESPONSE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_DEVICE_ID', l.lang)
     , 'AUP_CYBERPLAT_IN_DEVICE_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CYBERPLAT_IN_DEVICE_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.DEVICE_ID as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cyberplat_in a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CYBERPLAT_IN'
   and c.owner = USER
   and c.column_name = 'DEVICE_ID'
order by oper_id, column_order
/