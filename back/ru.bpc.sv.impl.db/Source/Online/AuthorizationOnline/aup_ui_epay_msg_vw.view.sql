create or replace force view aup_ui_epay_msg_vw
as
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_AUTH_ID', l.lang),
           'AUP_EPAY_AUTH_ID', substr(c.comments, 1, instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_AUTH_ID', l.lang)
       ) as name,
       'NUMBER' as data_type,
       to_char(null) as column_char_value,
       a.auth_id as column_number_value,
       to_date(null) as column_date_value,
       1 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'AUTH_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_TECH_ID', l.lang),
           'AUP_EPAY_TECH_ID', substr(c.comments, 1, instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_TECH_ID', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.tech_id as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       2 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'TECH_ID'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_ISO_MSG_TYPE', l.lang),
           'AUP_EPAY_ISO_MSG_TYPE', substr(c.comments,
                                           1,
                                           instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_ISO_MSG_TYPE', l.lang)
       ) as name,
       'NUMBER' as data_type,
       to_char(null) as column_char_value,
       a.iso_msg_type as column_number_value,
       to_date(null) as column_date_value,
       3 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'ISO_MSG_TYPE'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_BITMAP', l.lang),
           'AUP_EPAY_BITMAP', substr(c.comments, 1, instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_BITMAP', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.bitmap as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       4 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'BITMAP'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_DE48_BITMAP', l.lang),
           'AUP_EPAY_DE48_BITMAP', substr(c.comments,
                                          1,
                                          instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_DE48_BITMAP', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.de48_bitmap as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       5 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'DE48_BITMAP'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_TIME_MARK', l.lang),
           'AUP_EPAY_TIME_MARK', substr(c.comments, 1, instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_TIME_MARK', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.time_mark as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       6 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'TIME_MARK'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_PROC_CODE', l.lang),
           'AUP_EPAY_PROC_CODE', substr(c.comments, 1, instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_PROC_CODE', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.proc_code as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       7 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'PROC_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_AUTH_ID_RESP', l.lang),
           'AUP_EPAY_AUTH_ID_RESP', substr(c.comments,
                                           1,
                                           instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_AUTH_ID_RESP', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.auth_id_resp as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       8 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'AUTH_ID_RESP'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_RESP_CODE', l.lang),
           'AUP_EPAY_RESP_CODE', substr(c.comments, 1, instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_RESP_CODE', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.resp_code as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       9 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'RESP_CODE'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_TRNS_DATETIME', l.lang),
           'AUP_EPAY_TRNS_DATETIME', substr(c.comments,
                                            1,
                                            instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_TRNS_DATETIME', l.lang)
       ) as name,
       'DATE' as data_type,
       to_char(null) as column_char_value,
       to_number(null) as column_number_value,
       a.local_date as column_date_value,
       10 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'LOCAL_DATE'
union
select decode(
           com_api_label_pkg.get_label_text('AUP_EPAY_TRMS_DATETIME', l.lang),
           'AUP_EPAY_TRMS_DATETIME', substr(c.comments,
                                            1,
                                            instr(c.comments || '.', '.')),
           com_api_label_pkg.get_label_text('AUP_EPAY_TRMS_DATETIME', l.lang)
       ) as name,
       'DATE' as data_type,
       to_char(null) as column_char_value,
       to_number(null) as column_number_value,
       a.transmission_date as column_date_value,
       11 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'TRANSMISSION_DATE'
union
select decode(com_api_label_pkg.get_label_text('AUP_EPAY_TRACE', l.lang),
              'AUP_EPAY_TRACE', substr(c.comments, 1, instr(c.comments || '.', '.')),
              com_api_label_pkg.get_label_text('AUP_EPAY_TRACE', l.lang)
       ) as name,
       'VARCHAR2' as data_type,
       a.trace as column_char_value,
       to_number(null) as column_number_value,
       to_date(null) as column_date_value,
       12 as column_order,
       a.auth_id as oper_id,
       a.tech_id as tech_id,
       l.lang,
       1 as column_level,
       null as lov_id,
       null as dict_code
  from aup_epay a, com_language_vw l, all_col_comments c
 where c.table_name = 'AUP_EPAY'
   and c.owner = user
   and c.column_name = 'TRACE'
order by oper_id, column_order
/