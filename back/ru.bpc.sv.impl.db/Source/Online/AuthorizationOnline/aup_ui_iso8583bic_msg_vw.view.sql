create or replace force view aup_ui_iso8583bic_msg_vw
as
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_AUTH_ID', l.lang)
            , 'AUP_ISO8583BIC_AUTH_ID'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_AUTH_ID', l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.auth_id as column_number_value
     , to_date(null) as column_date_value
     , 1 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'AUTH_ID'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TECH_ID', l.lang)
            , 'AUP_ISO8583BIC_TECH_ID'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TECH_ID', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.tech_id as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 2 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'TECH_ID'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_ISO_MSG_TYPE', l.lang)
            , 'AUP_ISO8583BIC_ISO_MSG_TYPE'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_ISO_MSG_TYPE', l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.iso_msg_type as column_number_value
     , to_date(null) as column_date_value
     , 3 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'ISO_MSG_TYPE'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TRACE', l.lang)
            , 'AUP_ISO8583BIC_TRACE'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TRACE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.trace as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 4 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'TRACE'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_PROC_CODE', l.lang)
            , 'AUP_ISO8583BIC_PROC_CODE'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_PROC_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.proc_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 5 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'PROC_CODE'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_FUNCTION_CODE', l.lang)
            , 'AUP_ISO8583BIC_FUNCTION_CODE'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_FUNCTION_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.function_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 25 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'FUNCTION_CODE'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TERMINAL_NUMBER', l.lang)
            , 'AUP_ISO8583BIC_TERMINAL_NUMBER'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TERMINAL_NUMBER', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.terminal_number as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 6 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'TERMINAL_NUMBER'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TERMINAL_ID', l.lang)
            , 'AUP_ISO8583BIC_TERMINAL_ID'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TERMINAL_ID', l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.terminal_id as column_number_value
     , to_date(null) as column_date_value
     , 7 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'TERMINAL_ID'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_BITMAP', l.lang)
            , 'AUP_ISO8583BIC_BITMAP'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_BITMAP', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.bitmap as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 8 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'BITMAP'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TIME_MARK', l.lang)
            , 'AUP_ISO8583BIC_TIME_MARK'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_TIME_MARK', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.time_mark as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 9 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'TIME_MARK'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_LOCAL_DATE', l.lang)
            , 'AUP_ISO8583BIC_LOCAL_DATE'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.', '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_LOCAL_DATE', l.lang)) as name
     , 'DATE' as data_type
     , to_char(null) as column_char_value
     , to_number(null) as column_number_value
     , a.local_date as column_date_value
     , 10 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'LOCAL_DATE'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_RRN', l.lang)
            , 'AUP_ISO8583BIC_RRN'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.'
                         , '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_RRN', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.rrn as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 11 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'RRN'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_CARD_NUMBER', l.lang)
            , 'AUP_ISO8583BIC_CARD_NUMBER'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.'
                         , '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_CARD_NUMBER', l.lang)) as name
     , 'VARCHAR2' as data_type
     , iss_api_card_pkg.get_card_mask(a.card_number) as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 12 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'CARD_NUMBER'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_AMOUNT', l.lang)
            , 'AUP_ISO8583BIC_AMOUNT'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.'
                         , '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_AMOUNT', l.lang)) as name
     , 'NUMBER' as data_type
     , to_char(null) as column_char_value
     , a.amount as column_number_value
     , to_date(null) as column_date_value
     , 13 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'AMOUNT'
union
select decode(com_api_label_pkg.get_label_text('AUP_ISO8583BIC_RESP_CODE', l.lang)
            , 'AUP_ISO8583BIC_RESP_CODE'
            , substr(c.comments
                   , 1
                   , instr(c.comments || '.'
                         , '.'))
            , com_api_label_pkg.get_label_text('AUP_ISO8583BIC_RESP_CODE', l.lang)) as name
     , 'VARCHAR2' as data_type
     , a.resp_code as column_char_value
     , to_number(null) as column_number_value
     , to_date(null) as column_date_value
     , 14 as column_order
     , a.auth_id as oper_id
     , a.tech_id as tech_id
     , l.lang
     , 1 as column_level
     , null as lov_id
     , null as dict_code
from   aup_iso8583bic   a
     , com_language_vw  l
     , all_col_comments c
where  c.table_name = 'AUP_ISO8583BIC'
       and c.owner = user
       and c.column_name = 'RESP_CODE'
order  by oper_id
        , column_order
/