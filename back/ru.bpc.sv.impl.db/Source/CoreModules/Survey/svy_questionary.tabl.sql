create table svy_questionary(
    id                 number(16)
  , part_key           as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) 
  , seqnum             number(4)
  , inst_id            number(4)
  , split_hash         number(4) 
  , object_id          number(16)
  , survey_id          number(8)  
  , questionary_number varchar2(200)
  , status             varchar2(8)
  , creation_date      date 
  , closure_date       date 
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
  partition svy_questionary_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/
comment on table svy_questionary is 'Questionnaires stored here.'
/ 
comment on column svy_questionary.id is 'Questionary identifier. Primary key.'
/
comment on column svy_questionary.seqnum is 'Sequence number. Describe data version.'
/
comment on column svy_questionary.inst_id is 'Institution identifier'
/
comment on column svy_questionary.split_hash is 'Hash value to split processing.'
/
comment on column svy_questionary.object_id is 'Object identifier.'
/
comment on column svy_questionary.survey_id is 'Survey identifier.'
/
comment on column svy_questionary.questionary_number is 'Questionary number.'
/
comment on column svy_questionary.status is 'Questionary status. Distionary QRST.'
/
comment on column svy_questionary.creation_date is 'Creation date.'
/
comment on column svy_questionary.closure_date is 'Closure date.'
/
