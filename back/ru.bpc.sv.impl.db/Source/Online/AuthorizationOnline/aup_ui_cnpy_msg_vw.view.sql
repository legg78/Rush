create or replace force view aup_ui_cnpy_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_CNPY_AUTH_ID', l.lang)
     , 'AUP_CNPY_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CNPY_AUTH_ID', l.lang)) 
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
  from aup_cnpy a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CNPY'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CNPY_TECH_ID', l.lang)
     , 'AUP_CNPY_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CNPY_TECH_ID', l.lang)) 
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
  from aup_cnpy a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CNPY'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CNPY_TIME_MARK', l.lang)
     , 'AUP_CNPY_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CNPY_TIME_MARK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TIME_MARK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cnpy a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CNPY'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_CNPY_RESP_CODE', l.lang)
     , 'AUP_CNPY_RESP_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_CNPY_RESP_CODE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.RESP_CODE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_cnpy a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_CNPY'
   and c.owner = USER
   and c.column_name = 'RESP_CODE'
order by oper_id, column_order
/