create table prc_parameter (
    id                  number(8)
  , param_name          varchar2(30)
  , data_type           varchar2(8)
  , lov_id              number(4)
)
/
comment on table prc_parameter is 'List of parameters of processes procedures'
/
comment on column prc_parameter.id is 'Record identifier'
/
comment on column prc_parameter.param_name is 'Parameter name'
/
comment on column prc_parameter.data_type is 'Parameter data type (dttp dictionary)'
/
comment on column prc_parameter.lov_id is 'List of values identifier'
/
alter table prc_parameter add parent_id number(8)
/
comment on column prc_parameter.parent_id is 'Identifier of parent parameter'
/
