create or replace force view aup_ui_svip_msg_vw
as
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_TECH_ID', l.lang)
     , 'AUP_SVIP_TECH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_TECH_ID', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TECH_ID as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 1 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'TECH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_ENTITY_TYPE', l.lang)
     , 'AUP_SVIP_ENTITY_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_ENTITY_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ENTITY_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'ENTITY_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_OBJECT_ID', l.lang)
     , 'AUP_SVIP_OBJECT_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_OBJECT_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.OBJECT_ID as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'OBJECT_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_AUTH_ID', l.lang)
     , 'AUP_SVIP_AUTH_ID'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_AUTH_ID', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.AUTH_ID as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'AUTH_ID'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_TIME_MARK', l.lang)
     , 'AUP_SVIP_TIME_MARK'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_TIME_MARK', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.TIME_MARK as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'TIME_MARK'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_MESSAGE_NAME', l.lang)
     , 'AUP_SVIP_MESSAGE_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_MESSAGE_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.MESSAGE_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'MESSAGE_NAME'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_ORIGINATOR_NAME', l.lang)
     , 'AUP_SVIP_ORIGINATOR_NAME'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_ORIGINATOR_NAME', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.ORIGINATOR_NAME as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'ORIGINATOR_NAME'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_NETWORK_REF_IDENT', l.lang)
     , 'AUP_SVIP_NETWORK_REF_IDENT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_NETWORK_REF_IDENT', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.NETWORK_REF_IDENT as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'NETWORK_REF_IDENT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_CLIENT_ID_TYPE', l.lang)
     , 'AUP_SVIP_CLIENT_ID_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_CLIENT_ID_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CLIENT_ID_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'CLIENT_ID_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_CLIENT_ID_VALUE', l.lang)
     , 'AUP_SVIP_CLIENT_ID_VALUE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_CLIENT_ID_VALUE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.CLIENT_ID_VALUE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'CLIENT_ID_VALUE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_OPER_TYPE', l.lang)
     , 'AUP_SVIP_OPER_TYPE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_OPER_TYPE', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.OPER_TYPE as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'OPER_TYPE'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_OPER_REASON', l.lang)
     , 'AUP_SVIP_OPER_REASON'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_OPER_REASON', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.OPER_REASON as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'OPER_REASON'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_CLIENT_DT', l.lang)
     , 'AUP_SVIP_CLIENT_DT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_CLIENT_DT', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.CLIENT_DT as column_date_value
     , 13 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'CLIENT_DT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_OPER_AMOUNT', l.lang)
     , 'AUP_SVIP_OPER_AMOUNT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_OPER_AMOUNT', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.OPER_AMOUNT as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'OPER_AMOUNT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_OPER_CURRENCY', l.lang)
     , 'AUP_SVIP_OPER_CURRENCY'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_OPER_CURRENCY', l.lang)) 
       as name 
     , 'VARCHAR2' as data_type
     , a.OPER_CURRENCY as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'OPER_CURRENCY'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_HOST_DT', l.lang)
     , 'AUP_SVIP_HOST_DT'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_HOST_DT', l.lang)) 
       as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.HOST_DT as column_date_value
     , 16 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'HOST_DT'
union 
select  decode(com_api_label_pkg.get_label_text('AUP_SVIP_STATUS_CODE', l.lang)
     , 'AUP_SVIP_STATUS_CODE'
     , substr(c.comments,1,instr(c.comments||'.','.'))
     , com_api_label_pkg.get_label_text('AUP_SVIP_STATUS_CODE', l.lang)) 
       as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.STATUS_CODE as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.auth_id as oper_id
     , a.message_name as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
  from aup_svip a
     , com_language_vw l
     , all_col_comments c
 where c.table_name='AUP_SVIP'
   and c.owner = USER
   and c.column_name = 'STATUS_CODE'
order by oper_id, column_order
/