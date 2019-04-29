create table svy_survey(
    id             number(8)
  , seqnum         number(4)
  , inst_id        number(4)
  , entity_type    varchar2(8)
  , survey_number  varchar2(200)
  , status         varchar2(8)
  , start_date     date 
  , end_date       date 
)
/
comment on table svy_survey is 'Surveys stored here.'
/ 
comment on column svy_survey.id is 'Survey identifier. Primary key.'
/
comment on column svy_survey.seqnum is 'Sequence number. Describe data version.'
/
comment on column svy_survey.inst_id is 'Institution identifier'
/
comment on column svy_survey.entity_type is 'Business-entity type.'
/
comment on column svy_survey.survey_number is 'Survey number'
/
comment on column svy_survey.status is 'Survey status. Dictionary SYST.'
/
comment on column svy_survey.start_date is 'Start date when survey is activated.'
/
comment on column svy_survey.end_date is 'End date when survey is deactivated.'
/
