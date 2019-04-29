create table cmn_parameter (
    id                  number(8)
    , standard_id       number(4)
    , name              varchar2(200)
    , entity_type       varchar2(8)
    , data_type         varchar2(8)
    , lov_id            number(4)
    , default_value     varchar2(200)
    , xml_default_value clob
    , scale_id          number(4)
)
/
comment on table cmn_parameter is 'List of parameters describing communication standard.'
/
comment on column cmn_parameter.id is 'Primary key.'
/
comment on column cmn_parameter.standard_id is 'Reference to communication standard.'
/
comment on column cmn_parameter.name is 'Parameter name.'
/
comment on column cmn_parameter.entity_type is 'Level which parameter value will be defined on'
/
comment on column cmn_parameter.data_type is 'Data type.'
/
comment on column cmn_parameter.lov_id is 'List of possible values.'
/
comment on column cmn_parameter.default_value is 'Parameter default value.'
/
comment on column cmn_parameter.xml_default_value is 'Default value if parameter is XML type.'
/
comment on column cmn_parameter.scale_id is 'Scale of parameter value modification.'
/
alter table cmn_parameter add pattern varchar2(200)
/
comment on column cmn_parameter.pattern is 'Value pattern'
/
