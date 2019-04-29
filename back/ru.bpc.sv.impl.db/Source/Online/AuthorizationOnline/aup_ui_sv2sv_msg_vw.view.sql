create or replace force view aup_ui_sv2sv_msg_vw as
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_AUTH_ID', l.lang)
           , 'AUP_SV2SV_AUTH_ID'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_AUTH_ID', l.lang)) as name
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
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'AUTH_ID'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_TECH_ID', l.lang)
           , 'AUP_SV2SV_TECH_ID'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_TECH_ID', l.lang)) as name
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
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'TECH_ID'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_HOST_ID', l.lang)
           , 'AUP_SV2SV_HOST_ID'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_HOST_ID', l.lang)) as name
  , 'NUMBER' as data_type
  , to_char(null) as column_char_value
  , a.host_id as column_number_value
  , to_date(null) as column_date_value
  , 3 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'HOST_ID'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_ISO_MSG_TYPE', l.lang)
           , 'AUP_SV2SV_ISO_MSG_TYPE'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_ISO_MSG_TYPE', l.lang)) as name
  , 'NUMBER' as data_type
  , to_char(null) as column_char_value
  , a.iso_msg_type as column_number_value
  , to_date(null) as column_date_value
  , 4 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'ISO_MSG_TYPE'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_DIRECTION', l.lang)
           , 'AUP_SV2SV_DIRECTION'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_DIRECTION', l.lang)) as name
  , 'NUMBER' as data_type
  , to_char(null) as column_char_value
  , a.direction as column_number_value
  , to_date(null) as column_date_value
  , 5 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'DIRECTION'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_BITMAP', l.lang)
           , 'AUP_SV2SV_BITMAP'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_BITMAP', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.bitmap as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 6 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'BITMAP'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_TIME_MARK', l.lang)
           , 'AUP_SV2SV_TIME_MARK'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_TIME_MARK', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.time_mark as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 7 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'TIME_MARK'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_PROCESSING_CODE', l.lang)
           , 'AUP_SV2SV_PROCESSING_CODE'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_PROCESSING_CODE', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.processing_code as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 8 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'PROCESSING_CODE'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_TRACE', l.lang)
           , 'AUP_SV2SV_TRACE'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_TRACE', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.trace as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 9 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'TRACE'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_TRANS_DATE', l.lang)
           , 'AUP_SV2SV_TRANS_DATE'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_TRANS_DATE', l.lang)) as name
  , 'DATE' as data_type
  , to_char(null) as column_char_value
  , to_number(null) as column_number_value
  , a.trans_date as column_date_value
  , 10 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'TRANS_DATE'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_STTL_DATE', l.lang)
           , 'AUP_SV2SV_STTL_DATE'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_STTL_DATE', l.lang)) as name
  , 'DATE' as data_type
  , to_char(null) as column_char_value
  , to_number(null) as column_number_value
  , a.sttl_date as column_date_value
  , 11 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'STTL_DATE'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_MCC', l.lang)
           , 'AUP_SV2SV_MCC'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_MCC', l.lang)) as name
  , 'NUMBER' as data_type
  , to_char(null) as column_char_value
  , a.mcc as column_number_value
  , to_date(null) as column_date_value
  , 12 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'MCC'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_ACQ_INST_ID', l.lang)
           , 'AUP_SV2SV_ACQ_INST_ID'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_ACQ_INST_ID', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.acq_inst_id as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 13 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'ACQ_INST_ID'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_REFNUM', l.lang)
           , 'AUP_SV2SV_REFNUM'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_REFNUM', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.refnum as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 14 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'REFNUM'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_AUTH_ID_RESP', l.lang)
           , 'AUP_SV2SV_AUTH_ID_RESP'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_AUTH_ID_RESP', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.auth_id_resp as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 15 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'AUTH_ID_RESP'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_RESP_CODE', l.lang)
           , 'AUP_SV2SV_RESP_CODE'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_RESP_CODE', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.resp_code as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 16 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , 'RS2S' as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'RESP_CODE'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_TERMINAL_ID', l.lang)
           , 'AUP_SV2SV_TERMINAL_ID'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_TERMINAL_ID', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.terminal_id as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 17 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'TERMINAL_ID'
union
select
    decode(com_api_label_pkg.get_label_text('AUP_SV2SV_MERCHANT_ID', l.lang)
           , 'AUP_SV2SV_MERCHANT_ID'
           , substr(c.comments, 1, instr(c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text('AUP_SV2SV_MERCHANT_ID', l.lang)) as name
  , 'VARCHAR2' as data_type
  , a.merchant_id as column_char_value
  , to_number(null) as column_number_value
  , to_date(null) as column_date_value
  , 18 as column_order
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , l.lang
  , 1 as column_level
  , null as lov_id
  , null as dict_code
from
    aup_sv2sv a
  , com_language_vw  l
  , all_col_comments c
where
    c.table_name  = 'AUP_SV2SV' and
    c.owner       = user        and
    c.column_name = 'MERCHANT_ID'
order by
    oper_id
  , column_order
/