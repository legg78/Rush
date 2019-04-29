create or replace force view acm_privilege_vw
(   id
  , name
  , section_id
  , module_code
  , is_active
)
as
select a.id
     , a.name
     , a.section_id
     , a.module_code
     , a.is_active       
  from acm_privilege a
/
