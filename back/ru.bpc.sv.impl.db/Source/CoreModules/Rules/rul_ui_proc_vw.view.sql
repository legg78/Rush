create or replace force view rul_ui_proc_vw as
select
    p.id
  , p.proc_name
  , p.category
  , l.lang
  , get_text('rul_proc', 'name', p.id, l.lang) name
  , get_text('rul_proc', 'description', p.id, l.lang) description
from
    rul_proc p
  , com_language_vw l
/
