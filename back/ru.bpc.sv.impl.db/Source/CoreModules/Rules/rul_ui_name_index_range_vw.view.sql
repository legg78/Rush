create or replace force view rul_ui_name_index_range_vw as
select 
    a.id
  , a.inst_id
  , a.entity_type
  , a.algorithm
  , a.low_value
  , a.high_value
  , a.current_value
  , l.lang
  , com_api_i18n_pkg.get_text('rul_name_index_range', 'name', a.id, l.lang) as name
from
    rul_name_index_range a
  , com_language_vw l
where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
