create or replace force view acm_cu_process_vw as
select a.role_id
     , c.name as role_name
     , a.object_id as process_id
  from acm_role_object_vw a
     , (select i.role_id from acm_user_role_vw i where i.user_id = get_user_id
        union
        select child_role_id
          from acm_role_role_vw rr
        connect by prior parent_role_id =  child_role_id
        start with parent_role_id in (select i.role_id from acm_user_role_vw i where i.user_id = get_user_id )
       ) b
     , acm_role_vw c
     , prc_process_vw d
 where a.entity_type  = 'ENTTPRCS'
   and a.role_id      = b.role_id
   and a.role_id      = c.id
   and d.is_container = get_true
   and a.object_id    = d.id
/
