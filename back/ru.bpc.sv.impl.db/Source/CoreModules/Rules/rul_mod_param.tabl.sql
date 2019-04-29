create table rul_mod_param (
    id        number(8)
  , name      varchar2(200)
  , data_type varchar2(8)
  , lov_id    number(4)
)
/

comment on table rul_mod_param is 'Parameters which can be used in scales to parametrise attributes'
/

comment on column rul_mod_param.id is 'Parameter identifier'
/

comment on column rul_mod_param.name is 'Parameter name'
/

comment on column rul_mod_param.data_type is 'Parameter data type'
/

comment on column rul_mod_param.lov_id is 'List of Values identifier'
/