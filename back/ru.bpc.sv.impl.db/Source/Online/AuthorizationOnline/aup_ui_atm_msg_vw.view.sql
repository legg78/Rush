create or replace force view aup_ui_atm_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_AUTH_ID', l.lang)
     , 'AUP_ATM_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_AUTH_ID', l.lang)) 
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
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_TECH_ID', l.lang)
     , 'AUP_ATM_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_TECH_ID', l.lang)) 
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
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_MESSAGE_TYPE', l.lang)
     , 'AUP_ATM_MESSAGE_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_MESSAGE_TYPE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.MESSAGE_TYPE as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'MESSAGE_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_COLLECTION_ID', l.lang)
     , 'AUP_ATM_COLLECTION_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_COLLECTION_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.COLLECTION_ID as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'COLLECTION_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_TERMINAL_ID', l.lang)
     , 'AUP_ATM_TERMINAL_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_TERMINAL_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.TERMINAL_ID as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'TERMINAL_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_TIME_MARK', l.lang)
     , 'AUP_ATM_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_TIME_MARK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TIME_MARK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_TVN', l.lang)
     , 'AUP_ATM_TVN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_TVN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TVN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'TVN'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_MSG_COORD_NUM', l.lang)
     , 'AUP_ATM_MSG_COORD_NUM'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_MSG_COORD_NUM', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MSG_COORD_NUM as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'MSG_COORD_NUM'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_ATM_PART_TYPE', l.lang)
     , 'AUP_ATM_ATM_PART_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_ATM_PART_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ATM_PART_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'ATM_PART_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_ATM_TSN', l.lang)
     , 'AUP_ATM_TSN'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_ATM_TSN', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TSN as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_atm a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_ATM'
   and c.owner = USER
   and c.column_name = 'TSN'
order by oper_id, column_order
/