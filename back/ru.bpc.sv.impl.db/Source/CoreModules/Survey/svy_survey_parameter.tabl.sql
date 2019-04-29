create table svy_survey_parameter(
    id               number(12)
  , survey_id        number(8)
  , param_id         number(8)   
)
/
comment on table svy_survey_parameter is 'List of associations between surveys and parameters..'
/
comment on column svy_survey_parameter.id is 'Association identifier. Primary key.'
/
comment on column svy_survey_parameter.survey_id is 'Survey identifier.'
/
comment on column svy_survey_parameter.param_id is 'Parameter identifier.'
/
