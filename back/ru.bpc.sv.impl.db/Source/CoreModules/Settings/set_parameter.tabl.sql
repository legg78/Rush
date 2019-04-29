create table set_parameter
(
    id              number(8)
  , module_code     varchar2(3)
  , name            varchar2(200)
  , lowest_level    varchar2(8)
  , default_value   varchar2(200)
  , data_type       varchar2(8)
  , lov_id          number(4)
  , parent_id       number(8)
  , display_order   number(4)
)
/

comment on table set_parameter is 'System parameters dictionary'
/

comment on column set_parameter.id is 'Primary key'
/

comment on column set_parameter.module_code is 'Owner module code.'
/

comment on column set_parameter.name is 'Unique parameter system name.'
/

comment on column set_parameter.lowest_level is 'The lowest parameter level where value can be defined.'
/

comment on column set_parameter.default_value is 'Default value.'
/

comment on column set_parameter.data_type is 'Parameter value data type. Possible values: VARCHAR2, NUMBER, DATE.'
/

comment on column set_parameter.lov_id is 'Reference to query returning list of available values.'
/

comment on column set_parameter.parent_id is 'Reference to parent record. Using to organize parameter groups.'
/

comment on column set_parameter.display_order is 'Order to display parameter in user''s interface.'
/

alter table set_parameter add is_encrypted number(1)
/

comment on column set_parameter.is_encrypted is 'Flag that value is encrypred.'
/
