create or replace force view rul_ui_name_format_vw as
select
    f.id
  , f.inst_id
  , f.seqnum
  , f.entity_type
  , f.name_length
  , f.pad_type
  , f.pad_string
  , f.check_algorithm
  , f.check_base_position
  , f.check_base_length
  , f.check_position
  , f.index_range_id
  , f.check_name
  , l.lang
  , com_api_i18n_pkg.get_text('rul_name_format', 'label', f.id, l.lang) label
from
    rul_name_format f
  , com_language_vw l
where
    f.inst_id in (select inst_id from acm_cu_inst_vw)
/
