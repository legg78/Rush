create or replace force view acm_user_group_vw as
select u.id
     , u.user_id
     , u.group_id
  from acm_user_group u
/
