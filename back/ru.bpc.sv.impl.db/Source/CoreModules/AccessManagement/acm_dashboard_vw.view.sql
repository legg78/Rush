create or replace force view acm_dashboard_vw as
select id
     , seqnum
     , user_id
     , inst_id
     , is_shared
  from acm_dashboard
/