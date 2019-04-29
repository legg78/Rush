create or replace force view rpt_ui_parameter_vw as
select id
     , seqnum
     , report_id
     , param_name
     , data_type
     , default_value
     , is_mandatory
     , display_order
     , lov_id
     , get_text('RPT_PARAMETER','LABEL',       p.id, l.lang) label
     , get_text('RPT_PARAMETER','DESCRIPTION', p.id, l.lang) description
     , get_number_value(p.data_type, p.default_value) default_number_value
     , get_char_value  (p.data_type, p.default_value) default_char_value
     , get_date_value  (p.data_type, p.default_value) default_date_value
     , get_lov_value   (p.data_type, p.default_value, p.lov_id) default_lov_value
     , l.lang
     , p.selection_form
  from rpt_parameter p
     , com_language_vw l
  where param_name is not null   
/