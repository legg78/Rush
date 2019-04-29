create or replace force view app_element_vw as
select e.id
     , e.element_type
     , e.name
     , e.data_type
     , e.min_length
     , e.max_length
     , e.min_value
     , e.max_value
     , e.lov_id
     , e.default_value
     , e.is_multilang
     , e.entity_type
     , e.edit_form
  from app_element e
/