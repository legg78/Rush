create table agr_value
(
  id        number(16)                          not null,
  type_id   number(16)                          not null,
  count     number(9),
  value     number(22,4),
  currency  varchar2(3)
)
/



comment on table agr_value is 'Aggregare value'
/
comment on column agr_value.id is 'Primary key'
/
comment on column agr_value.type_id is 'Aggregate type'
/
comment on column agr_value.count is 'Count'
/
comment on column agr_value.value is 'Sum'
/
comment on column agr_value.currency is 'Currency'
/
 