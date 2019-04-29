create or replace force view aci_ui_pos_fin_msg_vw as
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_ID', l.lang)
      , 'ACI_POS_FIN_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_ID', l.lang)
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
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_FILE_ID', l.lang)
      , 'ACI_POS_FIN_FILE_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_FILE_ID', l.lang)
    ) as name
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.file_id as column_number_value
    , to_date(null) as column_date_value
    , 2 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'FILE_ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_RECORD_NUMBER', l.lang)
      , 'ACI_POS_FIN_RECORD_NUMBER'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_RECORD_NUMBER', l.lang)
    ) as name
    , 'NUMBER' as data_type
    , to_char(null) as column_char_value
    , a.record_number as column_number_value
    , to_date(null) as column_date_value
    , 3 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'RECORD_NUMBER'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TRAN_CDE', l.lang)
      , 'ACI_POS_FIN_AUTHX_TRAN_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TRAN_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_tran_cde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 4 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TRAN_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TYP', l.lang)
      , 'ACI_POS_FIN_AUTHX_TYP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TYP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_typ as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 5 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TYP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_CRD_CARD_CRD_NUM', l.lang)
      , 'ACI_POS_FIN_HEADX_CRD_CARD_CRD_NUM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_CRD_CARD_CRD_NUM', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , iss_api_card_pkg.get_card_mask(nvl(d.card_number, a.headx_crd_card_crd_num)) as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 6 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , aci_card d
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_CRD_CARD_CRD_NUM'
    and a.id = d.id(+)
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_CRD_LN', l.lang)
      , 'ACI_POS_FIN_HEADX_CRD_LN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_CRD_LN', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_crd_ln as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 7 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_CRD_LN'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_CRD_FIID', l.lang)
      , 'ACI_POS_FIN_HEADX_CRD_FIID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_CRD_FIID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_crd_fiid as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 8 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_CRD_FIID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_TERM_LN', l.lang)
      , 'ACI_POS_FIN_HEADX_TERM_LN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_TERM_LN', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_term_ln as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 9 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_TERM_LN'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_TERM_FIID', l.lang)
      , 'ACI_POS_FIN_HEADX_TERM_FIID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_TERM_FIID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_term_fiid as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_TERM_FIID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_TERM_TERM_ID', l.lang)
      , 'ACI_POS_FIN_HEADX_TERM_TERM_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_TERM_TERM_ID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_term_term_id as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 11 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_TERM_TERM_ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_ACQ_INST_ID_NUM', l.lang)
      , 'ACI_POS_FIN_AUTHX_ACQ_INST_ID_NUM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_ACQ_INST_ID_NUM', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_acq_inst_id_num as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 12 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_ACQ_INST_ID_NUM'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_RTE_STAT', l.lang)
      , 'ACI_POS_FIN_AUTHX_RTE_STAT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_RTE_STAT', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_rte_stat as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 13 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_RTE_STAT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_RETL_KY_RDFKEY_ID', l.lang)
      , 'ACI_POS_FIN_HEADX_RETL_KY_RDFKEY_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_HEADX_RETL_KY_RDFKEY_ID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_retl_ky_rdfkey_id as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 14 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'HEADX_RETL_KY_RDFKEY_ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_SEQ_NUM', l.lang)
      , 'ACI_POS_FIN_AUTHX_SEQ_NUM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_SEQ_NUM', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_seq_num as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 15 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_SEQ_NUM'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TRAN_DAT', l.lang)
      , 'ACI_POS_FIN_AUTHX_TRAN_DAT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TRAN_DAT', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_tran_dat as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 16 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TRAN_DAT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_TYP', l.lang)
      , 'ACI_POS_FIN_AUTHX_TERM_TYP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_TYP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_term_typ as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 17 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TERM_TYP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_OWNER_NAME', l.lang)
      , 'ACI_POS_FIN_AUTHX_TERM_OWNER_NAME'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_OWNER_NAME', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_term_owner_name as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 18 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TERM_OWNER_NAME'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_NAME_LOC', l.lang)
      , 'ACI_POS_FIN_AUTHX_TERM_NAME_LOC'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_NAME_LOC', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_term_name_loc as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 19 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TERM_NAME_LOC'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_CITY', l.lang)
      , 'ACI_POS_FIN_AUTHX_TERM_CITY'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_CITY', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_term_city as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 20 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TERM_CITY'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_ST', l.lang)
      , 'ACI_POS_FIN_AUTHX_TERM_ST'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_ST', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_term_st as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 21 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TERM_ST'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_CNTRY_CDE', l.lang)
      , 'ACI_POS_FIN_AUTHX_TERM_CNTRY_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TERM_CNTRY_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_term_cntry_cde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 22 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TERM_CNTRY_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_ACCT', l.lang)
      , 'ACI_POS_FIN_AUTHX_ACCT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_ACCT', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_acct as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 23 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_ACCT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_AMT_1', l.lang)
      , 'ACI_POS_FIN_AUTHX_AMT_1'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_AMT_1', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_amt_1 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 24 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_AMT_1'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_AMT_2', l.lang)
      , 'ACI_POS_FIN_AUTHX_AMT_2'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_AMT_2', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_amt_2 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 25 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_AMT_2'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_ORIG_CRNCY_CDE', l.lang)
      , 'ACI_POS_FIN_AUTHX_ORIG_CRNCY_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_ORIG_CRNCY_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_orig_crncy_cde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 26 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_ORIG_CRNCY_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_AUTH_CRNCY_CD', l.lang)
      , 'ACI_POS_FIN_AUTHX_MULT_CRNCY_AUTH_CRNCY_CD'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_AUTH_CRNCY_CD', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_mult_crncy_auth_crncy_cd as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 27 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_MULT_CRNCY_AUTH_CRNCY_CD'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_AUTH_CONV_RAT', l.lang)
      , 'ACI_POS_FIN_AUTHX_MULT_CRNCY_AUTH_CONV_RAT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_AUTH_CONV_RAT', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_mult_crncy_auth_conv_rat as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 28 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_MULT_CRNCY_AUTH_CONV_RAT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_SETL_CRNCY_CD', l.lang)
      , 'ACI_POS_FIN_AUTHX_MULT_CRNCY_SETL_CRNCY_CD'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_SETL_CRNCY_CD', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_mult_crncy_setl_crncy_cd as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 29 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_MULT_CRNCY_SETL_CRNCY_CD'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_SETL_CONV_RAT', l.lang)
      , 'ACI_POS_FIN_AUTHX_MULT_CRNCY_SETL_CONV_RAT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_MULT_CRNCY_SETL_CONV_RAT', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_mult_crncy_setl_conv_rat as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 30 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_MULT_CRNCY_SETL_CONV_RAT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_PT_SRV_COND_CDE', l.lang)
      , 'ACI_POS_FIN_AUTHX_PT_SRV_COND_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_PT_SRV_COND_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_pt_srv_cond_cde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 31 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_PT_SRV_COND_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_PT_SRV_ENTRY_MDE', l.lang)
      , 'ACI_POS_FIN_AUTHX_PT_SRV_ENTRY_MDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_PT_SRV_ENTRY_MDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_pt_srv_entry_mde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 32 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_PT_SRV_ENTRY_MDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_RESP_CDE', l.lang)
      , 'ACI_POS_FIN_AUTHX_RESP_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_RESP_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_resp_cde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 33 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_RESP_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TRACK2', l.lang)
      , 'ACI_POS_FIN_AUTHX_TRACK2'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_POS_FIN_AUTHX_TRACK2', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.authx_track2 as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 34 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_pos_fin a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_POS_FIN'
    and c.column_name = 'AUTHX_TRACK2'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 130 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'BD'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 131 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'BE'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 132 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'B0'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 133 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'B1'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 134 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'B2'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 135 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'B3'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 136 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'B4'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 137 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'B5'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 138 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = '20'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 139 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'C0'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 140 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'C4'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 141 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'C5'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 142 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = '17'
union all
select
    decode(com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
      , 'BASE24TOKEN'||a.name
      , 'Token '||a.name
      , com_api_label_pkg.get_label_text('BASE24TOKEN'||a.name, l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.value as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 143 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_token a
    , com_language_vw l
where
    a.name = 'CH'
order by oper_id, column_order
/
