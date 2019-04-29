create or replace force view rul_ui_proc_param_vw as
select
    p.id
  , p.proc_id
  , p.param_name
  , nvl(p.lov_id, m.lov_id) as lov_id
  , p.display_order
  , p.is_mandatory
  , b.lang
  , nvl(get_text('rul_proc_param', 'name', p.id, b.lang)
      , get_text('rul_mod_param', 'short_description', p.param_id, b.lang)
  ) as label
  , nvl(get_text('rul_proc_param', 'description', p.id, b.lang)
      , get_text('rul_mod_param', 'description', p.param_id, b.lang)
  ) as description
  , data_type
  , param_id
from
    rul_proc_param  p
  , rul_mod_param   m
  , com_language_vw b
where
    p.param_id = m.id
/
