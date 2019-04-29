create table cmn_parameter_value (
    id                  number(8)
  , param_id            number(8)
  , standard_id         number(4)
  , version_id          number(4)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , param_value         varchar2(200)
  , xml_value           clob
  , mod_id              number(4)
)
/
comment on table cmn_parameter_value is 'Communication parameter values.'
/
comment on column cmn_parameter_value.id is 'Primary key.'
/
comment on column cmn_parameter_value.param_id is 'Parameter identifier.'
/
comment on column cmn_parameter_value.standard_id is 'Reference to communication standard.'
/
comment on column cmn_parameter_value.version_id is 'Standard version.'
/
comment on column cmn_parameter_value.entity_type is 'Entity type (Network, Device, Profile).'
/
comment on column cmn_parameter_value.object_id is 'Object identifier.'
/
comment on column cmn_parameter_value.param_value is 'Parameter value.'
/
comment on column cmn_parameter_value.xml_value is 'Parameter value of CLOB datatype. Contain XML structure.'
/
comment on column cmn_parameter_value.mod_id is 'Modifier identifier'
/