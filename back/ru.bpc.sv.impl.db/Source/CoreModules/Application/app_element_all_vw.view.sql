create or replace force view app_element_all_vw as
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
     , null inst_id
  from app_element a
union all
select c.id
     , 'SIMPLE' element_type
     , c.name
     , c.data_type
     , 0 min_length
     , decode(c.data_type,'DTTPCHAR',200,'DTTPNMBR',16) max_length
     , null min_value
     , null max_value
     , c.lov_id lov_id
     , null default_value
     , 0 is_multilang
     , c.entity_type
     , null edit_form
     , c.inst_id
  from com_flexible_field c
/
