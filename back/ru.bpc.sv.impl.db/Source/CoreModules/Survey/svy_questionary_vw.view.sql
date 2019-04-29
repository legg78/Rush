create or replace force view svy_questionary_vw as
select q.id
     , q.part_key
     , q.seqnum
     , q.inst_id
     , q.split_hash
     , q.object_id
     , q.survey_id
     , q.questionary_number
     , q.status
     , q.creation_date
     , q.closure_date
  from svy_questionary q
/
