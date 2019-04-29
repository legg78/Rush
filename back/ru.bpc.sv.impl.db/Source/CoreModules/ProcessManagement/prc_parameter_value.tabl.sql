create table prc_parameter_value (
    id               number(8) not null
    , container_id   number(8)
    , param_id       number(8)
    , param_value    varchar2(2000)
)
/
comment on table prc_parameter_value is 'List of values for the parameters processes'
/
comment on column prc_parameter_value.id is 'Record identifier'
/
comment on column prc_parameter_value.container_id is 'Identifier of container'
/
comment on column prc_parameter_value.param_id is 'Parameter identifier'
/
comment on column prc_parameter_value.param_value is 'Parameters value'
/
