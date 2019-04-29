create or replace force view aci_ui_atm_cash_msg_vw as
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_ID', l.lang)
      , 'ACI_ATM_CASH_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_ID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'ID'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_FILE_ID', l.lang)
      , 'ACI_ATM_CASH_FILE_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_FILE_ID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'FILE_ID'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_RECORD_NUMBER', l.lang)
      , 'ACI_ATM_CASH_RECORD_NUMBER'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_RECORD_NUMBER', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'RECORD_NUMBER'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_DAT_TIM', l.lang)
      , 'ACI_ATM_CASH_HEADX_DAT_TIM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_DAT_TIM', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_DAT_TIM'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_REC_TYP', l.lang)
      , 'ACI_ATM_CASH_HEADX_REC_TYP'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_REC_TYP', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_REC_TYP'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_AUTH_PPD', l.lang)
      , 'ACI_ATM_CASH_HEADX_AUTH_PPD'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_AUTH_PPD', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_AUTH_PPD'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_TERM_LN', l.lang)
      , 'ACI_ATM_CASH_HEADX_TERM_LN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_TERM_LN', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_TERM_LN'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_TERM_FIID', l.lang)
      , 'ACI_ATM_CASH_HEADX_TERM_FIID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_TERM_FIID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_TERM_FIID'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_TERM_TERM_ID', l.lang)
      , 'ACI_ATM_CASH_HEADX_TERM_TERM_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_TERM_TERM_ID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_TERM_TERM_ID'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_LN', l.lang)
      , 'ACI_ATM_CASH_HEADX_CRD_LN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_LN', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_CRD_LN'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_FIID', l.lang)
      , 'ACI_ATM_CASH_HEADX_CRD_FIID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_FIID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_CRD_FIID'
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_PAN', l.lang)
      , 'ACI_ATM_CASH_HEADX_CRD_PAN'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_PAN', l.lang)
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
    aci_atm_cash a
    , aci_card d
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_CRD_PAN'
    and a.id = d.id(+)
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_MBR_NUM', l.lang)
      , 'ACI_ATM_CASH_HEADX_CRD_MBR_NUM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_CRD_MBR_NUM', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_CRD_MBR_NUM'    
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_BRANCH_ID', l.lang)
      , 'ACI_ATM_CASH_HEADX_BRANCH_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_BRANCH_ID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_BRANCH_ID' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_REGION_ID', l.lang)
      , 'ACI_ATM_CASH_HEADX_REGION_ID'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_HEADX_REGION_ID', l.lang)
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'HEADX_REGION_ID' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_ADMIN_DAT', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_ADMIN_DAT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_ADMIN_DAT', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_admin_dat as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_ADMIN_DAT' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_ADMIN_TIM', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_ADMIN_TIM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_ADMIN_TIM', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_admin_tim as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_ADMIN_TIM' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_ADMIN_CDE', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_ADMIN_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_ADMIN_CDE', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_admin_cde as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_ADMIN_CDE' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_HOPR_NUMM', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_HOPR_NUMM'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_HOPR_NUMM', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_hopr_num as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_HOPR_NUM' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_HOPR_CONTENTS', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_HOPR_CONTENTS'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_HOPR_CONTENTS', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_hopr_contents as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_HOPR_CONTENTS' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_AMT', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_AMT'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_AMT', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_amt as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_AMT' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_CRNCY_CDE', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_CRNCY_CDE'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_CRNCY_CDE', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_crncy_cde as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_CRNCY_CDE' 
union all 
select 
    decode(com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_TIM_OFST', l.lang)
      , 'ACI_ATM_CASH_TERM_CASH_TIM_OFST'
      , substr(c.comments,1,instr(c.comments||'.','.'))
      , com_api_label_pkg.get_label_text('ACI_ATM_CASH_TERM_CASH_TIM_OFST', l.lang)
    ) as name 
    , 'VARCHAR2' as data_type
    , a.term_cash_tim_ofst as column_char_value
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
    aci_atm_cash a
    , com_language_vw l
    , user_col_comments c
where
    c.table_name='ACI_ATM_CASH'
    and c.column_name = 'TERM_CASH_TIM_OFST'
order by oper_id, column_order
/