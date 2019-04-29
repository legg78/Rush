create or replace force view frp_ui_suite_vw as
select 
    lang.lang
  , id
  , seqnum
  , entity_type
  , inst_id
  , get_text('frp_suite', 'label',       a.id, lang.lang) as label
  , get_text('frp_suite', 'description', a.id, lang.lang) as description
from frp_suite a, com_language_vw lang
/