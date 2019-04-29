create or replace force view acm_ui_section_vw
as
select a.id
     , a.parent_id
     , a.action
     , a.section_type
     , get_text('acm_section', 'caption', a.id, b.lang) as caption
     , b.lang
     , a.display_order
     , a.managed_bean_name
     , a.is_visible
  from acm_section a
     , com_language_vw b
/
