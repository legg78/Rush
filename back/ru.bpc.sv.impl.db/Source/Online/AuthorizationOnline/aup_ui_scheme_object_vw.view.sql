create or replace force view aup_ui_scheme_object_vw as
select id
     , seqnum
     , scheme_id
     , entity_type
     , object_id
     , start_date
     , end_date
  from aup_scheme_object
/