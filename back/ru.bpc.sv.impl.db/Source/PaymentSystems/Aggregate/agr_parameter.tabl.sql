create table agr_parameter
(
  id         number(16)                         not null,
  name       varchar2(200)                      not null,
  table_name varchar2(200)                      not null,
  field      varchar2(200)                      not null,
  type       varchar2(1)                        not null,
  parent_id  number(16),
  flag       number(1)
)
/


alter table agr_parameter  add (network_id  number(4))
/

comment on table agr_parameter is 'Aggregation table-field list'
/
comment on column agr_parameter.id is 'Primary key.'
/

comment on column agr_parameter.name is 'Parameter name'
/

comment on column agr_parameter.table_name is 'Table name'
/

comment on column agr_parameter.field is 'Field name'
/

comment on column agr_parameter.type is 'Field type'
/

comment on column agr_parameter.parent_id is 'Parent table link'
/

comment on column agr_parameter.flag is 'Field property (0- operation id, 1- institution id, 2 - network id field)'
/

comment on column agr_parameter.network_id is 'Network id'
/
 