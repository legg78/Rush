create or replace force view svy_survey_parameter_vw as
select sp.id
     , sp.survey_id
     , sp.param_id
  from svy_survey_parameter sp
/
