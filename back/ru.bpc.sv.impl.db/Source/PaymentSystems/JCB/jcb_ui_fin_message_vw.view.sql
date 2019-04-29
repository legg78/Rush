create or replace force view jcb_ui_fin_message_vw
as
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_ID', l.lang)
         , 'JCB_FIN_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_ID', l.lang)
       ) as name 
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
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCD_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'ID'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_STATUS', l.lang)
         , 'JCB_FIN_STATUS'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_STATUS', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.status as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'STATUS'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_INST_ID', l.lang)
         , 'JCB_FIN_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_INST_ID', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.inst_id as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'INST_ID'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_NETWORK_ID', l.lang)
         , 'JCB_FIN_NETWORK_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_NETWORK_ID', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.network_id as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'NETWORK_ID'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_FILE_ID', l.lang)
         , 'JCB_FIN_FILE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_FILE_ID', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.file_id as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'FILE_ID'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_IS_INCOMING', l.lang)
         , 'JCB_FIN_IS_INCOMING'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_IS_INCOMING', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_incoming as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_INCOMING'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_IS_REVERSAL', l.lang)
         , 'JCB_FIN_IS_REVERSAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_IS_REVERSAL', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_reversal as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_REVERSAL'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_IS_REJECTED', l.lang)
         , 'JCB_FIN_IS_REJECTED'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_IS_REJECTED', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_rejected as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IS_REJECTED'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_REJECT_ID', l.lang)
         , 'JCB_FIN_REJECT_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_REJECT_ID', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.reject_id as column_number_value
     , to_date(null) as column_date_value
     , 10 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'REJECT_ID'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DISPUTE_ID', l.lang)
         , 'JCB_FIN_DISPUTE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DISPUTE_ID', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.dispute_id as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DISPUTE_ID'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_IMPACT', l.lang)
         , 'JCB_FIN_IMPACT'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_IMPACT', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.impact as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'IMPACT'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_MTI', l.lang)
         , 'JCB_FIN_MTI'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_MTI', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.mti as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 15 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'MTI'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE024', l.lang)
         , 'JCB_FIN_DE024'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE024', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de024 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE024'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE002', l.lang)
         , 'JCB_FIN_DE002'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE002', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , iss_api_card_pkg.get_card_mask(d.card_number) as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 17 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , jcb_card d
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE002'
   and a.id = d.id(+)
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE003_1', l.lang)
         , 'JCB_FIN_DE003_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE003_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de003_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 18 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE003_1'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE003_2', l.lang)
         , 'JCB_FIN_DE003_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE003_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de003_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 19 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE003_2'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE003_3', l.lang)
         , 'JCB_FIN_DE003_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE003_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de003_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 20 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE003_3'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE004', l.lang)
         , 'JCB_FIN_DE004'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE004', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de004 as column_number_value
     , to_date(null) as column_date_value
     , 21 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE004'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE005', l.lang)
         , 'JCB_FIN_DE005'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE005', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de005 as column_number_value
     , to_date(null) as column_date_value
     , 22 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE005'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE006', l.lang)
         , 'JCB_FIN_DE006'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE006', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de006 as column_number_value
     , to_date(null) as column_date_value
     , 23 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE006'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE009', l.lang)
         , 'JCB_FIN_DE009'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE009', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de009 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 24 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE009'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE010', l.lang)
         , 'JCB_FIN_DE010'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE010', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de010 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE010'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE012', l.lang)
         , 'JCB_FIN_DE012'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE012', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.de012 as column_date_value
     , 26 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE012'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE014', l.lang)
         , 'JCB_FIN_DE014'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE014', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.de014 as column_date_value
     , 27 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE014'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE016', l.lang)
         , 'JCB_FIN_DE016'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE016', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.de014 as column_date_value
     , 28 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE016'
union   
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_1', l.lang)
         , 'JCB_FIN_DE022_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_1'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_2', l.lang)
         , 'JCB_FIN_DE022_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_2'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_3', l.lang)
         , 'JCB_FIN_DE022_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_3'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_4', l.lang)
         , 'JCB_FIN_DE022_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_4', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_4 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_4'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_5', l.lang)
         , 'JCB_FIN_DE022_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_5', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_5 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_5'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_6', l.lang)
         , 'JCB_FIN_DE022_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_6', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_6 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 34 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_6'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_7', l.lang)
         , 'JCB_FIN_DE022_7'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_7', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_7 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 35 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_7'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_8', l.lang)
         , 'JCB_FIN_DE022_8'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_8', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_8 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 36 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_8'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_9', l.lang)
         , 'JCB_FIN_DE022_9'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_9', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_9 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 37 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_9'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_10', l.lang)
         , 'JCB_FIN_DE022_10'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_10', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_10 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 38 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_10'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_11', l.lang)
         , 'JCB_FIN_DE022_11'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_11', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_11 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 39 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_11'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE022_12', l.lang)
         , 'JCB_FIN_DE022_12'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE022_12', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_12 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 40 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE022_12'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE023', l.lang)
         , 'JCB_FIN_DE023'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE023', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de023 as column_number_value
     , to_date(null) as column_date_value
     , 41 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE023'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE025', l.lang)
         , 'JCB_FIN_DE025'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE025', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de025 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 42 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE025'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE026', l.lang)
         , 'JCB_FIN_DE026'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE026', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de026 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 43 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE026'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE030_1', l.lang)
         , 'JCB_FIN_DE030_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE030_1', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de030_1 as column_number_value
     , to_date(null) as column_date_value
     , 44 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE030_1'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE030_2', l.lang)
         , 'JCB_FIN_DE030_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE030_2', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de030_2 as column_number_value
     , to_date(null) as column_date_value
     , 45 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE030_2'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE031', l.lang)
         , 'JCB_FIN_DE031'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE031', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de031 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 46 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE031'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE032', l.lang)
         , 'JCB_FIN_DE032'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE032', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de032 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 47 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE032'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE033', l.lang)
         , 'JCB_FIN_DE033'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE033', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de033 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 48 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE033'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE037', l.lang)
         , 'JCB_FIN_DE037'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE037', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de037 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 49 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE037'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE038', l.lang)
         , 'JCB_FIN_DE038'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE038', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de038 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 50 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE038'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE040', l.lang)
         , 'JCB_FIN_DE040'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE040', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de040 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 51 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE040'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE041', l.lang)
         , 'JCB_FIN_DE041'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE041', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de041 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 52 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE041'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE042', l.lang)
         , 'JCB_FIN_DE042'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE042', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de042 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 53 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE042'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE043_1', l.lang)
         , 'JCB_FIN_DE043_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE043_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 54 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE043_1'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE043_2', l.lang)
         , 'JCB_FIN_DE043_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE043_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 55 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE043_2'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE043_3', l.lang)
         , 'JCB_FIN_DE043_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE043_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 56 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE043_3'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE043_4', l.lang)
         , 'JCB_FIN_DE043_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE043_4', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_4 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 57 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE043_4'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE043_5', l.lang)
         , 'JCB_FIN_DE043_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE043_5', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_5 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 58 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE043_5'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE043_6', l.lang)
         , 'JCB_FIN_DE043_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE043_6', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_6 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 59 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE043_6'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE049', l.lang)
         , 'JCB_FIN_DE049'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE049', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de049 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 60 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE049'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE050', l.lang)
         , 'JCB_FIN_DE050'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE050', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de050 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 61 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE050'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE051', l.lang)
         , 'JCB_FIN_DE051'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE051', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de051 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 62 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE051'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE054', l.lang)
         , 'JCB_FIN_DE054'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE054', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de054 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 63 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE054'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE071', l.lang)
         , 'JCB_FIN_DE071'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE071', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de071 as column_number_value
     , to_date(null) as column_date_value
     , 65 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE071'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE072', l.lang)
         , 'JCB_FIN_DE072'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE072', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de072 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 66 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE072'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE093', l.lang)
         , 'JCB_FIN_DE093'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE093', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de093 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 68 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE093'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE094', l.lang)
         , 'JCB_FIN_DE094'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE094', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de094 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 69 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE094'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DE100', l.lang)
         , 'JCB_FIN_DE100'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DE100', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de100 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 71 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'DE100'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3001', l.lang)
         , 'JCB_FIN_P3001'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3001', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3001 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 73 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3001'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3002', l.lang)
         , 'JCB_FIN_P3002'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3002', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3002 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 74 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3002'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3003', l.lang)
         , 'JCB_FIN_P3003'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3003', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3003 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 75 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3003'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3005', l.lang)
         , 'JCB_FIN_P3005'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3005', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , to_char(a.p3005) as column_char_value
     , to_number(null) as column_number_value
     , null as column_date_value
     , 76 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3005'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3007_1', l.lang)
         , 'JCB_FIN_P3007_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3007_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3007_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 77 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3007_1'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3007_2', l.lang)
         , 'JCB_FIN_P3007_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3007_2', l.lang)
       ) as name 
     , 'DATE' as data_type
     , null as column_char_value
     , to_number(null) as column_number_value
     , to_date(a.p3007_2) as column_date_value
     , 78 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3007_1'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3008', l.lang)
         , 'JCB_FIN_P3008'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3008', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3008 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 79 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3008'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3009', l.lang)
         , 'JCB_FIN_P3009'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3009', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , null as column_char_value
     , to_number(a.p3009) as column_number_value
     , to_date(null) as column_date_value
     , 80 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3009'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3011', l.lang)
         , 'JCB_FIN_P3011'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3011', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3011 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 81 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3011'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3012', l.lang)
         , 'JCB_FIN_P3012'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3012', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3012 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 82 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3012'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3013', l.lang)
         , 'JCB_FIN_P3013'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3013', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3013 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 83 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3013'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3014', l.lang)
         , 'JCB_FIN_P3014'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3014', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3014 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 84 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3014'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3201', l.lang)
         , 'JCB_FIN_P3201'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3201', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3201 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 85 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3201'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3202', l.lang)
         , 'JCB_FIN_P3202'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3202', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3202 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 86 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3202'
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3203', l.lang)
         , 'JCB_FIN_P3203'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3203', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3203 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 87 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3203'   
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3205', l.lang)
         , 'JCB_FIN_P3205'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3205', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3205 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 88 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3205'   
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3206', l.lang)
         , 'JCB_FIN_P3206'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3206', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3206 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 89 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3206'   
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3207', l.lang)
         , 'JCB_FIN_P3207'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3207', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3207 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 90 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3207'   
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3208', l.lang)
         , 'JCB_FIN_P3208'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3208', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3208 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 91 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3208'   
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3209', l.lang)
         , 'JCB_FIN_P3209'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3209', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , null as column_char_value
     , to_number(a.p3209) as column_number_value
     , to_date(null) as column_date_value
     , 92 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3209'    
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3210', l.lang)
         , 'JCB_FIN_P3210'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3210', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3210 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 93 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3210'   
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3211', l.lang)
         , 'JCB_FIN_P3211'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3211', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3211 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 94 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3211'    
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3250', l.lang)
         , 'JCB_FIN_P3250'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3250', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , null as column_char_value
     , to_number(a.p3250) as column_number_value
     , to_date(null) as column_date_value
     , 95 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3250'    
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3251', l.lang)
         , 'JCB_FIN_P3251'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3251', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3251 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 96 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3251'    
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_P3302', l.lang)
         , 'JCB_FIN_P3302'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_P3302', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p3302 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 97 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'P3302'    
union
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F26', l.lang)
         , 'JCB_FIN_EMV_9F26'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F26', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f26 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 123 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F26'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F02', l.lang)
         , 'JCB_FIN_EMV_9F02'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F02', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f02 as column_number_value
     , to_date(null) as column_date_value
     , 124 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F02'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F27', l.lang)
         , 'JCB_FIN_EMV_9F27'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F27', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f27 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 125 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F27'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F10', l.lang)
         , 'JCB_FIN_EMV_9F10'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F10', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f10 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 126 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F10'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F36', l.lang)
         , 'JCB_FIN_EMV_9F36'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F36', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f36 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 127 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F36'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_95', l.lang)
         , 'JCB_FIN_EMV_95'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_95', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_95 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 128 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_95'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_82', l.lang)
         , 'JCB_FIN_EMV_82'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_82', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_82 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 129 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_82'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9A', l.lang)
         , 'JCB_FIN_EMV_9A'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9A', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.emv_9a as column_date_value
     , 130 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9A'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9C', l.lang)
         , 'JCB_FIN_EMV_9C'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9C', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9c as column_number_value
     , to_date(null) as column_date_value
     , 131 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9C'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F37', l.lang)
         , 'JCB_FIN_EMV_9F37'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F37', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f37 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 132 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F37'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_5F2A', l.lang)
         , 'JCB_FIN_EMV_5F2A'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_5F2A', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_5f2a as column_number_value
     , to_date(null) as column_date_value
     , 133 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_5F2A'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F33', l.lang)
         , 'JCB_FIN_EMV_9F33'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F33', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f33 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 134 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F33'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F34', l.lang)
         , 'JCB_FIN_EMV_9F34'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F34', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f34 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 135 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F34'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F1A', l.lang)
         , 'JCB_FIN_EMV_9F1A'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F1A', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f1a as column_number_value
     , to_date(null) as column_date_value
     , 136 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F1A'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F35', l.lang)
         , 'JCB_FIN_EMV_9F35'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F35', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f35 as column_number_value
     , to_date(null) as column_date_value
     , 137 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F35'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_4F', l.lang)
         , 'JCB_FIN_EMV_4F'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_4F', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_4f as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 138 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_4F'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_84', l.lang)
         , 'JCB_FIN_EMV_84'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_84', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_84 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 139 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_84'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F09', l.lang)
         , 'JCB_FIN_EMV_9F09'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F09', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f09 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 140 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F09'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F03', l.lang)
         , 'JCB_FIN_EMV_9F03'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F03', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f03 as column_number_value
     , to_date(null) as column_date_value
     , 141 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F03'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F1E', l.lang)
         , 'JCB_FIN_EMV_9F1E'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F1E', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f1e as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 142 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F1E'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F41', l.lang)
         , 'JCB_FIN_EMV_9F41'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_EMV_9F41', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f41 as column_number_value
     , to_date(null) as column_date_value
     , 143 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN_MESSAGE'
   and c.owner = user
   and c.column_name = 'EMV_9F41'
union 
select decode(
           com_api_label_pkg.get_label_text('JCB_FIN_DISPUTE_RN', l.lang)
         , 'JCB_FIN_DISPUTE_RN'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('JCB_FIN_DISPUTE_RN', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.dispute_rn as column_number_value
     , to_date(null) as column_date_value
     , 144 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from jcb_fin_message a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'JCB_FIN'
   and c.owner = user
   and c.column_name = 'DISPUTE_RN'
/
