create or replace force view acm_user_vw
as
  select a.id
       , a.name
       , a.person_id
       , a.status
       , a.inst_id
       , a.password_change_needed
       , a.creation_date
       , a.auth_scheme
  from   acm_user a
/

