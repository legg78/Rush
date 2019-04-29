create table agr_rule
(
  id        number(16)                          not null,
  type_id   number(16)                          not null,
  param_id  number(16)                          not null,
  type      varchar2(10)                        not null,
  rounding  varchar2(10)
)
/

comment on table agr_rule is 'Aggregate rule'
/
comment on column agr_rule.id is 'Primary key'
/
comment on column agr_rule.type_id is 'Aggregate type'
/
comment on column agr_rule.param_id is 'Field id'
/
comment on column agr_rule.type is 'Aggregation type (m-master field, c- count -field, s- sum field, cc- currancy field)'
/
comment on column agr_rule.rounding is 'Rounding type'
/

