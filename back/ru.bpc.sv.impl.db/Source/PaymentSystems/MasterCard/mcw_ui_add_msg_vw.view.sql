create or replace force view mcw_ui_add_msg_vw as
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_ID', l.lang)
      , 'MCW_ADD_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_ID', l.lang)
    ) as name 
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.id as column_number_value
    , to_date(null) as column_date_value
    , 1 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'ID'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_FIN_ID', l.lang)
      , 'MCW_ADD_FIN_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_FIN_ID', l.lang)
    ) as name 
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.fin_id as column_number_value
    , to_date(null) as column_date_value
    , 2 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'FIN_ID'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_IS_INCOMING', l.lang)
      , 'MCW_ADD_IS_INCOMING'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_IS_INCOMING', l.lang)
    ) as name 
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.is_incoming as column_number_value
    , to_date(null) as column_date_value
    , 3 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'IS_INCOMING'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_MTI', l.lang)
      , 'MCW_ADD_MTI'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_MTI', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.mti as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 4 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'MTI'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE024', l.lang)
      , 'MCW_ADD_DE024'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE024', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de024 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 5 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE024'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE071', l.lang)
      , 'MCW_ADD_DE071'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE071', l.lang)
    ) as name 
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.de071 as column_number_value
    , to_date(null) as column_date_value
    , 6 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE071'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE032', l.lang)
      , 'MCW_ADD_DE032'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE032', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de032 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 7 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE032'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE033', l.lang)
      , 'MCW_ADD_DE033'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE033', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de033 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 8 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE033'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE063', l.lang)
      , 'MCW_ADD_DE063'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE063', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de063 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 9 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE063'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE093', l.lang)
      , 'MCW_ADD_DE093'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE093', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de093 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE093'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE094', l.lang)
      , 'MCW_ADD_DE094'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE094', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de094 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 11 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE094'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_DE100', l.lang)
      , 'MCW_ADD_DE100'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_DE100', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.de100 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 12 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'DE100'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_P0501_1', l.lang)
      , 'MCW_ADD_P0501_1'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_P0501_1', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.p0501_1 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 13 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'P0501_1'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_P0501_2', l.lang)
      , 'MCW_ADD_P0501_2'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_P0501_2', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.p0501_2 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 14 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'P0501_2'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_P0501_3', l.lang)
      , 'MCW_ADD_P0501_3'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_P0501_3', l.lang)
    ) as name 
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.p0501_3 as column_number_value
    , to_date(null) as column_date_value
    , 15 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'P0501_3'
union all
select 
    decode(com_api_label_pkg.get_label_text('MCW_ADD_P0501_4', l.lang)
      , 'MCW_ADD_P0501_4'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('MCW_ADD_P0501_4', l.lang)
    ) as name 
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.p0501_4 as column_number_value
    , to_date(null) as column_date_value
    , 16 as column_order 
    , a.fin_id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id 
    , null as dict_code
    , to_number(null) tech_id
from
    mcw_add a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='MCW_ADD'
    and c.column_name = 'P0501_4'
union all
select decode(com_api_label_pkg.get_label_text('MCW_ADD_P0715', l.lang)
            , 'MCW_ADD_P0715'
            , substr(c.comments, 1, instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('MCW_ADD_P0715', l.lang)
       ) as name
     , 'CHAR' as data_type
     , a.p0715 as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 16 as column_order
     , a.fin_id as oper_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
     , to_number(null) tech_id
  from mcw_add a
     , com_language_vw l
     , user_col_comments c
 where c.table_name  = 'MCW_ADD'
   and c.column_name = 'P0715'
/
