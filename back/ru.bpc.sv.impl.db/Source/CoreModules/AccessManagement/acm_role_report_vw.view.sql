create or replace force view acm_role_report_vw as
select a.id
     , a.role_id
     , a.object_id
     , a.entity_type
from acm_role_object_vw a
where a.entity_type = 'ENTTREPT'
/
