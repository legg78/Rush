create or replace force view app_ui_element_vw as
select a.id
     , a.element_type
     , a.name
     , a.data_type
     , a.min_length
     , a.max_length
     , a.min_value
     , a.max_value
     , a.lov_id
     , a.default_value
     , a.is_multilang
     , a.entity_type
     , a.edit_form
     , get_text('app_element', 'caption', a.id, b.lang) label
     , get_number_value(a.data_type, a.default_value) default_number_value
     , get_char_value(a.data_type, a.default_value) default_char_value
     , get_date_value(a.data_type, a.default_value) default_date_value
     , get_lov_value(a.data_type, a.default_value, a.lov_id) default_lov_value
     , b.lang
  from app_element a
     , com_language_vw b
union all
select c.id
     , 'SIMPLE' element_type
     , c.name
     , c.data_type
     , 0 min_length
     , decode(c.data_type,'DTTPCHAR',200,'DTTPNMBR',16) max_length
     , null min_value
     , null max_value
     , null lov_id
     , null default_value
     , 0 is_multilang
     , c.entity_type
     , to_char(null) edit_form
     , get_text ('com_flexible_field'
               , 'label'
               , c.id
               , l.lang) label
     , to_number(null) default_number_value
     , to_char(null) default_char_value
     , to_date(null) default_date_value
     , to_char(null) default_lov_value
     , l.lang
  from com_flexible_field c
     , com_language_vw l
/
