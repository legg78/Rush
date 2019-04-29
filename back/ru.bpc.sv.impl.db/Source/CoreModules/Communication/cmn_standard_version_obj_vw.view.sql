create or replace force view cmn_standard_version_obj_vw as
select id
     , entity_type
     , object_id
     , version_id
     , start_date
  from cmn_standard_version_obj
/
