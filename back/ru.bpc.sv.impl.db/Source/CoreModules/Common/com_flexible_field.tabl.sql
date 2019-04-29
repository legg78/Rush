create table com_flexible_field (
    id              number(8)
  , entity_type     varchar2(8)
  , object_type     varchar2(8)
  , name            varchar2(200)
  , data_type       varchar2(8)
  , data_format     varchar2(200)
  , lov_id          number(8)
  , is_user_defined number(1)
  , inst_id         number(4)
  , default_value   varchar2(200)
)
/

comment on table com_flexible_field is 'Flexible fields. Additional atributes of business-entities. Could be defined by user.'
/

comment on column com_flexible_field.id is 'Primary key.'
/

comment on column com_flexible_field.entity_type is 'Business-entity type.'
/

comment on column com_flexible_field.object_type is 'Business-entity sub-type.'
/

comment on column com_flexible_field.name is 'Unique field name.'
/

comment on column com_flexible_field.data_type is 'Data type of field value.'
/

comment on column com_flexible_field.data_format is 'Data format for non-char data types.'
/

comment on column com_flexible_field.lov_id is 'Reference to list of values.'
/

comment on column com_flexible_field.is_user_defined is 'Field added by user and could be automaticaly added in application.'
/

comment on column com_flexible_field.inst_id is 'Insitution identifier.'
/

comment on column com_flexible_field.default_value is 'Default value of flexible field.'
/