create or replace force view frp_ui_case_vw as
select
    lang
  , id
  , seqnum
  , inst_id
  , hist_depth
  , get_text('frp_case', 'label',       a.id, lang.lang) as label
  , get_text('frp_case', 'description', a.id, lang.lang) as description
from frp_case a, com_language_vw lang
/