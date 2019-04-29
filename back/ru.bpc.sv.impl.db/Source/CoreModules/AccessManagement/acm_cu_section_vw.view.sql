create or replace force view acm_cu_section_vw as
select a.id
     , a.parent_id
     , a.action
     , a.section_type
     , get_text('acm_section', 'caption', a.id, b.lang) as caption
     , b.lang
     , a.is_visible
     , a.display_order
     , a.managed_bean_name
  from acm_section a
     , com_language_vw b
 where a.id in (
        select d.id
          from acm_section d
        connect by d.id = prior d.parent_id
          start with d.id in (select c.section_id from acm_cu_privilege_vw c)
       )
   and a.is_visible = get_true
/
