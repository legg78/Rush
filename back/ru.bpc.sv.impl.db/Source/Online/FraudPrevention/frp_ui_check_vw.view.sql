create or replace force view frp_ui_check_vw as
select
    lang.lang
  , id
  , seqnum
  , case_id
  , check_type
  , alert_type
  , expression
  , risk_score
  , risk_matrix_id
  , get_text('frp_check', 'label',       a.id, lang.lang) label
  , get_text('frp_check', 'description', a.id, lang.lang) description
from frp_check a, com_language_vw lang
/