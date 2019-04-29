create or replace force view mup_ui_fin_msg_vw
as
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_ID', l.lang)
         , 'MUP_FIN_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_ID', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'ID'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_STATUS', l.lang)
         , 'MUP_FIN_STATUS'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_STATUS', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'STATUS'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_INST_ID', l.lang)
         , 'MUP_FIN_INST_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_INST_ID', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'INST_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_NETWORK_ID', l.lang)
         , 'MUP_FIN_NETWORK_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_NETWORK_ID', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'NETWORK_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_FILE_ID', l.lang)
         , 'MUP_FIN_FILE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_FILE_ID', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'FILE_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_IS_INCOMING', l.lang)
         , 'MUP_FIN_IS_INCOMING'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_IS_INCOMING', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'IS_INCOMING'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_IS_REVERSAL', l.lang)
         , 'MUP_FIN_IS_REVERSAL'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_IS_REVERSAL', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'IS_REVERSAL'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_IS_REJECTED', l.lang)
         , 'MUP_FIN_IS_REJECTED'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_IS_REJECTED', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'IS_REJECTED'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_REJECT_ID', l.lang)
         , 'MUP_FIN_REJECT_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_REJECT_ID', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'REJECT_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_IS_FPD_MATCHED', l.lang)
         , 'MUP_FIN_IS_FPD_MATCHED'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_IS_FPD_MATCHED', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_fpd_matched as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'IS_FPD_MATCHED'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_FPD_ID', l.lang)
         , 'MUP_FIN_FPD_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_FPD_ID', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.fpd_id as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'FPD_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DISPUTE_ID', l.lang)
         , 'MUP_FIN_DISPUTE_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DISPUTE_ID', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DISPUTE_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_IMPACT', l.lang)
         , 'MUP_FIN_IMPACT'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_IMPACT', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'IMPACT'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_MTI', l.lang)
         , 'MUP_FIN_MTI'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_MTI', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'MTI'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE024', l.lang)
         , 'MUP_FIN_DE024'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE024', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE024'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE002', l.lang)
         , 'MUP_FIN_DE002'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE002', l.lang)
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
  from mup_fin a
     , mup_card d
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE002'
   and a.id = d.id(+)
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE003_1', l.lang)
         , 'MUP_FIN_DE003_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE003_1', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE003_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE003_2', l.lang)
         , 'MUP_FIN_DE003_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE003_2', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE003_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE003_3', l.lang)
         , 'MUP_FIN_DE003_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE003_3', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE003_3'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE004', l.lang)
         , 'MUP_FIN_DE004'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE004', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE004'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE005', l.lang)
         , 'MUP_FIN_DE005'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE005', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE005'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE006', l.lang)
         , 'MUP_FIN_DE006'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE006', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE006'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE009', l.lang)
         , 'MUP_FIN_DE009'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE009', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE009'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE010', l.lang)
         , 'MUP_FIN_DE010'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE010', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE010'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE012', l.lang)
         , 'MUP_FIN_DE012'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE012', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE012'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE014', l.lang)
         , 'MUP_FIN_DE014'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE014', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE014'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_1', l.lang)
         , 'MUP_FIN_DE022_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 28 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_2', l.lang)
         , 'MUP_FIN_DE022_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 29 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_3', l.lang)
         , 'MUP_FIN_DE022_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 30 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_3'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_4', l.lang)
         , 'MUP_FIN_DE022_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_4', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_4 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 31 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_4'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_5', l.lang)
         , 'MUP_FIN_DE022_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_5', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_5 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 32 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_5'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_6', l.lang)
         , 'MUP_FIN_DE022_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_6', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de022_6 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 33 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_6'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_7', l.lang)
         , 'MUP_FIN_DE022_7'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_7', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_7'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_8', l.lang)
         , 'MUP_FIN_DE022_8'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_8', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_8'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_9', l.lang)
         , 'MUP_FIN_DE022_9'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_9', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_9'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_10', l.lang)
         , 'MUP_FIN_DE022_10'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_10', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_10'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE022_11', l.lang)
         , 'MUP_FIN_DE022_11'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE022_11', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE022_11'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE023', l.lang)
         , 'MUP_FIN_DE023'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE023', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de023 as column_number_value
     , to_date(null) as column_date_value
     , 40 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE023'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE025', l.lang)
         , 'MUP_FIN_DE025'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE025', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de025 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 41 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE025'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE026', l.lang)
         , 'MUP_FIN_DE026'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE026', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de026 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 42 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE026'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE030_1', l.lang)
         , 'MUP_FIN_DE030_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE030_1', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de030_1 as column_number_value
     , to_date(null) as column_date_value
     , 43 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE030_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE030_2', l.lang)
         , 'MUP_FIN_DE030_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE030_2', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.de030_2 as column_number_value
     , to_date(null) as column_date_value
     , 44 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE030_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE031', l.lang)
         , 'MUP_FIN_DE031'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE031', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de031 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 45 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE031'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE032', l.lang)
         , 'MUP_FIN_DE032'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE032', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de032 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 46 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE032'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE033', l.lang)
         , 'MUP_FIN_DE033'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE033', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de033 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 47 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE033'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE037', l.lang)
         , 'MUP_FIN_DE037'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE037', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de037 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 48 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE037'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE038', l.lang)
         , 'MUP_FIN_DE038'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE038', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de038 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 49 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE038'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE040', l.lang)
         , 'MUP_FIN_DE040'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE040', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de040 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 50 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE040'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE041', l.lang)
         , 'MUP_FIN_DE041'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE041', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de041 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 51 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE041'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE042', l.lang)
         , 'MUP_FIN_DE042'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE042', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de042 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 52 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE042'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE043_1', l.lang)
         , 'MUP_FIN_DE043_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE043_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 53 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE043_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE043_2', l.lang)
         , 'MUP_FIN_DE043_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE043_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 54 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE043_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE043_3', l.lang)
         , 'MUP_FIN_DE043_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE043_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 55 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE043_3'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE043_4', l.lang)
         , 'MUP_FIN_DE043_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE043_4', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_4 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 56 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE043_4'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE043_5', l.lang)
         , 'MUP_FIN_DE043_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE043_5', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_5 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 57 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE043_5'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE043_6', l.lang)
         , 'MUP_FIN_DE043_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE043_6', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de043_6 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 58 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE043_6'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE049', l.lang)
         , 'MUP_FIN_DE049'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE049', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de049 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 59 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE049'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE050', l.lang)
         , 'MUP_FIN_DE050'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE050', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de050 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 60 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE050'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE051', l.lang)
         , 'MUP_FIN_DE051'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE051', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de051 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 61 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE051'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE054', l.lang)
         , 'MUP_FIN_DE054'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE054', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de054 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 62 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE054'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE063', l.lang)
         , 'MUP_FIN_DE063'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE063', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de063 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 64 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE063'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE071', l.lang)
         , 'MUP_FIN_DE071'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE071', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE071'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE072', l.lang)
         , 'MUP_FIN_DE072'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE072', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE072'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE073', l.lang)
         , 'MUP_FIN_DE073'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE073', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.de073 as column_date_value
     , 67 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE073'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE093', l.lang)
         , 'MUP_FIN_DE093'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE093', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE093'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE094', l.lang)
         , 'MUP_FIN_DE094'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE094', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE094'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE095', l.lang)
         , 'MUP_FIN_DE095'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE095', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.de095 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 70 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE095'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DE100', l.lang)
         , 'MUP_FIN_DE100'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DE100', l.lang)
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
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DE100'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0025_1', l.lang)
         , 'MUP_FIN_P0025_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0025_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0025_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 75 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0025_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0025_2', l.lang)
         , 'MUP_FIN_P0025_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0025_2', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.p0025_2 as column_date_value
     , 76 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0025_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0137', l.lang)
         , 'MUP_FIN_P0137'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0137', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0137 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 79 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0137'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0148', l.lang)
         , 'MUP_FIN_P0148'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0148', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0148 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 80 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0148'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0146', l.lang)
         , 'MUP_FIN_P0146'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0146', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0146 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 81 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0146'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0149_1', l.lang)
         , 'MUP_FIN_P0149_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0149_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0149_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 83 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0149_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0149_2', l.lang)
         , 'MUP_FIN_P0149_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0149_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0149_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 84 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0149_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2158_1', l.lang)
         , 'MUP_FIN_P2158_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2158_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2158_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 85 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2158_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2158_2', l.lang)
         , 'MUP_FIN_P2158_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2158_2', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.p2158_2 as column_date_value
     , 86 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2158_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2158_3', l.lang)
         , 'MUP_FIN_P2158_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2158_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2158_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 87 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2158_3'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2158_4', l.lang)
         , 'MUP_FIN_P2158_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2158_4', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2158_4 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 88 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2158_4'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2158_5', l.lang)
         , 'MUP_FIN_P2158_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2158_5', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2158_5 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 89 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2158_5'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2158_6', l.lang)
         , 'MUP_FIN_P2158_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2158_6', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2158_6 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 90 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2158_6'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2159_1', l.lang)
         , 'MUP_FIN_P2159_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2159_1', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2159_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 95 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2159_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2159_2', l.lang)
         , 'MUP_FIN_P2159_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2159_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2159_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 96 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2159_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2159_3', l.lang)
         , 'MUP_FIN_P2159_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2159_3', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2159_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 97 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2159_3'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2159_4', l.lang)
         , 'MUP_FIN_P2159_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2159_4', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.p2159_4 as column_date_value
     , 98 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2159_4'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2159_5', l.lang)
         , 'MUP_FIN_P2159_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2159_5', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2159_5 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 99 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2159_5'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2159_6', l.lang)
         , 'MUP_FIN_P2159_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2159_6', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.p2159_6 as column_date_value
     , 100 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2159_6'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0165', l.lang)
         , 'MUP_FIN_P0165'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0165', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0165 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 103 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0165'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0190', l.lang)
         , 'MUP_FIN_P0190'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0190', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0190 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 104 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0190'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0198', l.lang)
         , 'MUP_FIN_P0198'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0198', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0198 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 105 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0198'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0228', l.lang)
         , 'MUP_FIN_P0228'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0228', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.p0228 as column_number_value
     , to_date(null) as column_date_value
     , 106 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0228'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0261', l.lang)
         , 'MUP_FIN_P0261'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0261', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0261 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 112 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0261'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0262', l.lang)
         , 'MUP_FIN_P0262'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0262', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.p0262 as column_number_value
     , to_date(null) as column_date_value
     , 113 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0262'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0265', l.lang)
         , 'MUP_FIN_P0265'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0265', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0265 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 115 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0265'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0266', l.lang)
         , 'MUP_FIN_P0266'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0266', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0266 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 116 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0266'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0267', l.lang)
         , 'MUP_FIN_P0267'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0267', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0267 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 117 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0267'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0268_1', l.lang)
         , 'MUP_FIN_P0268_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0268_1', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.p0268_1 as column_number_value
     , to_date(null) as column_date_value
     , 118 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0268_1'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0268_2', l.lang)
         , 'MUP_FIN_P0268_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0268_2', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0268_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 119 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0268_2'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P0375', l.lang)
         , 'MUP_FIN_P0375'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P0375', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p0375 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 120 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P0375'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2002', l.lang)
         , 'MUP_FIN_P2002'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2002', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2002 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 121 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2002'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2063', l.lang)
         , 'MUP_FIN_P2063'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2063', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.p2063 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 122 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2063'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_IS_FSUM_MATCHED', l.lang)
         , 'MUP_FIN_IS_FSUM_MATCHED'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_IS_FSUM_MATCHED', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.is_fsum_matched as column_number_value
     , to_date(null) as column_date_value
     , 123 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'IS_FSUM_MATCHED'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_FSUM_ID', l.lang)
         , 'MUP_FIN_FSUM_ID'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_FSUM_ID', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.fsum_id as column_number_value
     , to_date(null) as column_date_value
     , 124 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'FSUM_ID'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F26', l.lang)
         , 'MUP_FIN_EMV_9F26'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F26', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f26 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 125 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F26'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F02', l.lang)
         , 'MUP_FIN_EMV_9F02'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F02', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f02 as column_number_value
     , to_date(null) as column_date_value
     , 126 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F02'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F27', l.lang)
         , 'MUP_FIN_EMV_9F27'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F27', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f27 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 127 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F27'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F10', l.lang)
         , 'MUP_FIN_EMV_9F10'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F10', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f10 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 128 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F10'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F36', l.lang)
         , 'MUP_FIN_EMV_9F36'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F36', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f36 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 129 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F36'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_95', l.lang)
         , 'MUP_FIN_EMV_95'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_95', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_95 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 130 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_95'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_82', l.lang)
         , 'MUP_FIN_EMV_82'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_82', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_82 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 131 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_82'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9A', l.lang)
         , 'MUP_FIN_EMV_9A'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9A', l.lang)
       ) as name 
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.emv_9a as column_date_value
     , 132 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9A'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9C', l.lang)
         , 'MUP_FIN_EMV_9C'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9C', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9c as column_number_value
     , to_date(null) as column_date_value
     , 133 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9C'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F37', l.lang)
         , 'MUP_FIN_EMV_9F37'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F37', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f37 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 134 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F37'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_5F2A', l.lang)
         , 'MUP_FIN_EMV_5F2A'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_5F2A', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_5f2a as column_number_value
     , to_date(null) as column_date_value
     , 135 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_5F2A'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F33', l.lang)
         , 'MUP_FIN_EMV_9F33'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F33', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f33 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 136 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F33'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F34', l.lang)
         , 'MUP_FIN_EMV_9F34'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F34', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f34 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 137 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F34'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F1A', l.lang)
         , 'MUP_FIN_EMV_9F1A'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F1A', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f1a as column_number_value
     , to_date(null) as column_date_value
     , 138 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F1A'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F35', l.lang)
         , 'MUP_FIN_EMV_9F35'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F35', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f35 as column_number_value
     , to_date(null) as column_date_value
     , 139 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F35'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F53', l.lang)
         , 'MUP_FIN_EMV_9F53'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F53', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f53 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 140 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F53'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_84', l.lang)
         , 'MUP_FIN_EMV_84'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_84', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_84 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 145 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_84'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F09', l.lang)
         , 'MUP_FIN_EMV_9F09'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F09', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f09 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 146 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F09'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F03', l.lang)
         , 'MUP_FIN_EMV_9F03'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F03', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f03 as column_number_value
     , to_date(null) as column_date_value
     , 147 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F03'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F1E', l.lang)
         , 'MUP_FIN_EMV_9F1E'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F1E', l.lang)
       ) as name 
     , 'VARCHAR2' as data_type
     , a.emv_9f1e as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 148 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F1E'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F41', l.lang)
         , 'MUP_FIN_EMV_9F41'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_EMV_9F41', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.emv_9f41 as column_number_value
     , to_date(null) as column_date_value
     , 149 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'EMV_9F41'
union all 
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_DISPUTE_RN', l.lang)
         , 'MUP_FIN_DISPUTE_RN'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_DISPUTE_RN', l.lang)
       ) as name 
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.dispute_rn as column_number_value
     , to_date(null) as column_date_value
     , 149 as column_order 
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id 
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'DISPUTE_RN'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2097_1', l.lang)
         , 'MUP_FIN_P2097_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2097_1', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2097_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 150 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2097_1'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2097_2', l.lang)
         , 'MUP_FIN_P2097_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2097_2', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2097_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 150 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2097_2'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_1', l.lang)
         , 'MUP_FIN_P2001_1'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_1', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2001_1 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 151 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_1'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_2', l.lang)
         , 'MUP_FIN_P2001_2'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_2', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2001_2 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 152 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_2'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_3', l.lang)
         , 'MUP_FIN_P2001_3'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_3', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2001_3 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 153 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_3'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_4', l.lang)
         , 'MUP_FIN_P2001_4'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_4', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2001_4 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 154 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_4'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_5', l.lang)
         , 'MUP_FIN_P2001_5'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_5', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , to_number(a.p2001_5) as column_number_value
     , to_date(null) as column_date_value
     , 155 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_5'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_6', l.lang)
         , 'MUP_FIN_P2001_6'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_6', l.lang)
       ) as name
     , 'NUMBER' as data_type
     , null as column_char_value
     , to_number(a.p2001_6) as column_number_value
     , to_date(null) as column_date_value
     , 156 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_6'
union all
select decode(
           com_api_label_pkg.get_label_text('MUP_FIN_P2001_7', l.lang)
         , 'MUP_FIN_P2001_7'
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('MUP_FIN_P2001_7', l.lang)
       ) as name
     , 'VARCHAR2' as data_type
     , a.p2001_7 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 157 as column_order
     , a.id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mup_fin a
     , com_language_vw l
     , all_col_comments c
 where c.table_name = 'MUP_FIN'
   and c.owner = user
   and c.column_name = 'P2001_7'
order by oper_id, column_order
/
