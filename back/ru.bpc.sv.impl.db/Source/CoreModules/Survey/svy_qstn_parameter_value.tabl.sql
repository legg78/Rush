create table svy_qstn_parameter_value(
    id               number(12)
  , seqnum           number(4)
  , questionary_id   number(16)
  , param_id         number(8)   
  , param_value      varchar2(200)
  , seq_number       number(4)
)
/
comment on table svy_qstn_parameter_value is 'Questionnaires parameters values stored here.'
/
comment on column svy_qstn_parameter_value.id is 'Record identifier.'
/
comment on column svy_qstn_parameter_value.seqnum is 'Sequence number. Describe data version.'
/
comment on column svy_qstn_parameter_value.questionary_id is 'Questionary identifier.'
/
comment on column svy_qstn_parameter_value.param_id is 'Parameter identifier.'
/
comment on column svy_qstn_parameter_value.param_value is 'Parameter value.'
/
comment on column svy_qstn_parameter_value.seq_number is 'Sequental number of occurrence in questionary.'
/
