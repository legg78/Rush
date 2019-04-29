create or replace force view acm_role_privilege_vw
as
  select a.id
       , a.role_id
       , a.priv_id
       , a.limit_id
       , a.filter_limit_id
  from   acm_role_privilege a
/
