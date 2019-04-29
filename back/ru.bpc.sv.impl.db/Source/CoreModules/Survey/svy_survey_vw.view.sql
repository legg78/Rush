create or replace force view svy_survey_vw as
select s.id
     , s.seqnum
     , s.inst_id
     , s.entity_type
     , s.survey_number
     , s.status
     , s.start_date
     , s.end_date
  from svy_survey s
/
