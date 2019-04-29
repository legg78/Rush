create or replace force view acm_dashboard_user_vw as
select id
     , seqnum
     , dashboard_id
     , user_id
     , is_default
  from acm_dashboard_user
/