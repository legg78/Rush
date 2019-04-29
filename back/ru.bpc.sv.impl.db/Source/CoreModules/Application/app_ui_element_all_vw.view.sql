create or replace force view app_ui_element_all_vw as
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
  from app_element_all_vw a
/