create or replace force view acq_ui_account_scheme_vw as
select 
    a.id
  , a.seqnum
  , a.inst_id
  , get_text('acq_account_scheme','label', a.id, b.lang) label
  , get_text('acq_account_scheme','description', a.id, b.lang) description  
  , b.lang
from acq_account_scheme a, com_language_vw b
/
