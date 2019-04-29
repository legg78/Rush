create or replace force view acm_user_role_vw
as
  select a.id
       , a.user_id
       , a.role_id
  from   acm_user_role a
/
