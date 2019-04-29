create or replace force view rpt_ui_run_parameter_vw as
select r.id
     , r.run_id
     , r.param_id
     , p.data_type
     , p.display_order
     , r.param_value
     , p.lov_id
     , get_text('RPT_PARAMETER', 'LABEL',       r.param_id, l.lang) label
     , get_text('RPT_PARAMETER', 'DESCRIPTION', r.param_id, l.lang) description
     , get_number_value(p.data_type, r.param_value) param_number_value
     , get_char_value  (p.data_type, r.param_value) param_char_value
     , get_date_value  (p.data_type, r.param_value) param_date_value
     , get_lov_value   (p.data_type, r.param_value, p.lov_id) param_lov_value
     , l.lang
     , p.selection_form
  from rpt_run_parameter r
     , rpt_parameter p
     , com_language_vw l
 where r.param_id = p.id
/