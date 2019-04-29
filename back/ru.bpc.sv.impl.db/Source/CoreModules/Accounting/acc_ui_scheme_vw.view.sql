create or replace force view acc_ui_scheme_vw as
select
    a.id
  , a.seqnum
  , a.inst_id
  , get_text('acc_scheme', 'name', a.id, l.lang) name
  , get_text('acc_scheme', 'description', a.id, l.lang) description
  , l.lang
from
    acc_scheme_vw a
  , com_language_vw l
where
    a.inst_id in (select inst_id from acm_cu_inst_vw)
/
