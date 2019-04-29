create table agr_param_value
(
  id        number(16)                          not null,
  type_id   number(16)                          not null,
  value_id  number(16)                          not null,
  param_id  number(16)                          not null,
  value     varchar2(200)                       not null
)
/
comment on table agr_param_value is 'Value for Aggregation parameter'
/
comment on column agr_param_value.id is 'Primary key'
/
comment on column agr_param_value.type_id is 'Aggregate type'
/
comment on column agr_param_value.value_id is 'Value key'
/
comment on column agr_param_value.param_id is 'Field id'
/
comment on column agr_param_value.value is 'value'
/
 