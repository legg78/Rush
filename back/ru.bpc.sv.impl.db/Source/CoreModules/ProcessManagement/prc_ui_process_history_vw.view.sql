create or replace force view prc_ui_process_history_vw as
select
    a.id
  , a.session_id
  , b.id as param_id
  , b.param_name
  , b.data_type
  , b.lov_id
  , a.param_value
  , get_text('prc_parameter', 'label', b.id, l.lang) param_label
  , get_text('prc_parameter', 'description', b.id, l.lang) param_desc
  , get_number_value(b.data_type, a.param_value) param_number_value
  , get_char_value  (b.data_type, a.param_value) param_char_value
  , get_date_value  (b.data_type, a.param_value) param_date_value
  , get_lov_value   (b.data_type, a.param_value, b.lov_id) param_lov_value
  , l.lang
from
    prc_process_history a
  , (
        select id, param_name, data_type, lov_id from prc_parameter
        union all
        select id, param_name, data_type, lov_id from rpt_parameter
    ) b
  , com_language_vw l
where
    a.param_id = b.id
/
