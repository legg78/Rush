create or replace force view app_structure_vw as
select a.id
     , a.appl_type
     , a.element_id
     , a.parent_element_id
     , a.min_count
     , a.max_count
     , a.default_value
     , a.is_visible
     , a.is_updatable
     , a.display_order
     , a.is_info
     , a.lov_id
     , a.is_wizard
     , a.edit_form
     , a.is_parent_desc
     , a.is_insertable
  from app_structure a
/
