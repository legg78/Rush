create or replace force view aci_ui_atm_setl_msg_vw as
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_ID', l.lang)
      , 'ACI_ATM_SETL_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_ID', l.lang)
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_FILE_ID', l.lang)
      , 'ACI_ATM_SETL_FILE_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_FILE_ID', l.lang)
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'FILE_ID'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_RECORD_NUMBER', l.lang)
      , 'ACI_ATM_SETL_RECORD_NUMBER'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_RECORD_NUMBER', l.lang)
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'RECORD_NUMBER'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_DAT_TIM', l.lang)
      , 'ACI_ATM_SETL_HEADX_DAT_TIM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_DAT_TIM', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_dat_tim as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_DAT_TIM'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_REC_TYP', l.lang)
      , 'ACI_ATM_SETL_HEADX_REC_TYP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_REC_TYP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_rec_typ as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_REC_TYP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_AUTH_PPD', l.lang)
      , 'ACI_ATM_SETL_HEADX_AUTH_PPD'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_AUTH_PPD', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_auth_ppd as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_AUTH_PPD'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_TERM_LN', l.lang)
      , 'ACI_ATM_SETL_HEADX_TERM_LN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_TERM_LN', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_term_ln as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_TERM_LN'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_TERM_FIID', l.lang)
      , 'ACI_ATM_SETL_HEADX_TERM_FIID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_TERM_FIID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_term_fiid as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_TERM_FIID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_TERM_TERM_ID', l.lang)
      , 'ACI_ATM_SETL_HEADX_TERM_TERM_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_TERM_TERM_ID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_term_term_id as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_TERM_TERM_ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_LN', l.lang)
      , 'ACI_ATM_SETL_HEADX_CRD_LN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_LN', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_crd_ln as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_CRD_LN'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_FIID', l.lang)
      , 'ACI_ATM_SETL_HEADX_CRD_FIID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_FIID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_crd_fiid as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_CRD_FIID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_PAN', l.lang)
      , 'ACI_ATM_SETL_HEADX_CRD_PAN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_PAN', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , iss_api_card_pkg.get_card_mask(nvl(d.card_number, a.headx_crd_pan)) as column_char_value
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
    aci_atm_setl a
    , aci_card d
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_CRD_PAN'
    and a.id = d.id(+)
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_MBR_NUM', l.lang)
      , 'ACI_ATM_SETL_HEADX_CRD_MBR_NUM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_CRD_MBR_NUM', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_crd_mbr_num as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_CRD_MBR_NUM'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_BRANCH_ID', l.lang)
      , 'ACI_ATM_SETL_HEADX_BRANCH_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_BRANCH_ID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_branch_id as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_BRANCH_ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_REGION_ID', l.lang)
      , 'ACI_ATM_SETL_HEADX_REGION_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HEADX_REGION_ID', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.headx_region_id as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'HEADX_REGION_ID'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_ADMIN_DAT', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_ADMIN_DAT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_ADMIN_DAT', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_admin_dat as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_ADMIN_DAT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_ADMIN_TIM', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_ADMIN_TIM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_ADMIN_TIM', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_admin_tim as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_ADMIN_TIM'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_ADMIN_CDE', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_ADMIN_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_ADMIN_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_admin_cde as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_ADMIN_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_DEP', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_NUM_DEP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_DEP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_num_dep as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_NUM_DEP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_DEP', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_AMT_DEP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_DEP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_amt_dep as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_AMT_DEP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_DEP', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_AMT_DEP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_DEP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_amt_dep as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_AMT_DEP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_CMRCL_DEP', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_NUM_CMRCL_DEP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_CMRCL_DEP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_num_cmrcl_dep as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_NUM_CMRCL_DEP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_CMRCL_DEP', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_AMT_CMRCL_DEP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_CMRCL_DEP', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_amt_cmrcl_dep as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_AMT_CMRCL_DEP'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_PAY', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_NUM_PAY'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_PAY', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_num_pay as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_NUM_PAY'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_PAY', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_AMT_PAY'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_PAY', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_amt_pay as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_AMT_PAY'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_MSG', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_NUM_MSG'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_MSG', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_num_msg as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_NUM_MSG'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_CHK', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_NUM_CHK'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_CHK', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_num_chk as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_NUM_CHK'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_CHK', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_AMT_CHK'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_AMT_CHK', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_amt_chk as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_AMT_CHK'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_LOGONLY', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_NUM_LOGONLY'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_NUM_LOGONLY', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_num_logonly as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_NUM_LOGONLY'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_TTL_ENV', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_TTL_ENV'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_TTL_ENV', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_ttl_env as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_TTL_ENV'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_CRDS_RET', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_CRDS_RET'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_CRDS_RET', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_crds_ret as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_CRDS_RET'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_SETL_CRNCY_CDE', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_SETL_CRNCY_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_SETL_CRNCY_CDE', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_setl_crncy_cde as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_SETL_CRNCY_CDE'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_TIM_OFST', l.lang)
      , 'ACI_ATM_SETL_TERM_SETL_TIM_OFST'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_TERM_SETL_TIM_OFST', l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_tim_ofst as column_char_value
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
    aci_atm_setl a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL'
    and c.column_name = 'TERM_SETL_TIM_OFST'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CONTENTS'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_CONTENTS'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CONTENTS'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_contents as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+50 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_CONTENTS'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_BEG_CASH'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_BEG_CASH'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_BEG_CASH'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_beg_cash as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+51 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_BEG_CASH'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CASH_INCR'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_CASH_INCR'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CASH_INCR'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_cash_incr as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+52 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_CASH_INCR'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CASH_DECR'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_CASH_DECR'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CASH_DECR'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_cash_decr as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+53 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_CASH_DECR'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CASH_OUT'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_CASH_OUT'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CASH_OUT'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_cash_out as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+54 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_CASH_OUT'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_END_CASH'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_END_CASH'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_END_CASH'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_end_cash as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+55 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_END_CASH'
union all
select
    decode(com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CRNCY_CDE'||to_char(a.hopr_num), l.lang)
      , 'ACI_ATM_SETL_HOPR_CRNCY_CDE'||to_char(a.hopr_num)
      , 'Hopper ' || a.hopr_num || ' - ' || substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_SETL_HOPR_CRNCY_CDE'||to_char(a.hopr_num), l.lang)
    ) as name
    , 'VARCHAR2' as data_type
    , a.term_setl_hopr_crncy_cde as column_char_value
    , to_number(null) as column_number_value
    , to_date(null) as column_date_value
    , 10*a.hopr_num+56 as column_order
    , a.id as oper_id
    , l.lang
    , 1 as column_level
    , null as lov_id
    , null as dict_code
    , to_number(null) tech_id
from
    aci_atm_setl_hopr a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_SETL_HOPR'
    and c.column_name = 'TERM_SETL_HOPR_CRNCY_CDE'
order by oper_id, column_order
/
