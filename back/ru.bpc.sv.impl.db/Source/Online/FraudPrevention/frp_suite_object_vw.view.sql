create or replace force view frp_suite_object_vw as
select id
     , seqnum
     , suite_id
     , entity_type
     , object_id
     , start_date
     , end_date
  from frp_suite_object
/