create or replace force view acm_section_vw as
select a.id
     , a.parent_id
     , a.module_code
     , a.action
     , a.section_type
     , a.is_visible
     , a.display_order 
     , a.managed_bean_name
  from acm_section a
/