create or replace force view acm_cu_role_vw as
 select role_id
   from acm_user_role_vw
  where user_id = get_user_id()
  union
 select child_role_id
   from acm_role_role_vw
connect by prior parent_role_id = child_role_id
  start with parent_role_id in (select i.role_id
                                  from acm_user_role_vw i
                                 where i.user_id = get_user_id())
/
