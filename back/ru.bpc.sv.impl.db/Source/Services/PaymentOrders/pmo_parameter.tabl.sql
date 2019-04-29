create table pmo_parameter (
    id         number(8)
  , seqnum     number(4)
  , param_name varchar2(200)
  , data_type  varchar2(8)
  , lov_id     number(4)
  , pattern    varchar2(200)
  , tag_id     number(8)
)
/

comment on table pmo_parameter is 'Payment order parameters'
/

comment on column pmo_parameter.id is 'Primary key'
/
comment on column pmo_parameter.seqnum is 'Data version sequence number'
/
comment on column pmo_parameter.param_name is 'Parameter system name'
/
comment on column pmo_parameter.data_type is 'Data type'
/
comment on column pmo_parameter.lov_id is 'List of avalable values'
/
comment on column pmo_parameter.pattern is 'Parameter value validation pattern (regular expressions)'
/
comment on column pmo_parameter.tag_id is 'Reference to authorization tag'
/
alter table pmo_parameter add param_function varchar2(2000)
/
comment on column pmo_parameter.param_function is 'Function used to calculate a parameter value when this parameter is being added to a payment order. Such functions are grouped into package pmo_api_param_function_pkg.'
/