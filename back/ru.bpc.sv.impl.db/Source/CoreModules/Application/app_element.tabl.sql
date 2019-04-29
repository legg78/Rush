create table app_element
(
    id                  number(8)
  , element_type        varchar2(8)
  , name                varchar2(200)
  , data_type           varchar2(30)
  , min_length          number(4)
  , max_length          number(4)
  , min_value           varchar2(200)
  , max_value           varchar2(200)
  , lov_id              number(4)
  , default_value       varchar2(200)
  , is_multilang        number(1)
  , entity_type         varchar2(8)
  , edit_form           varchar2(200)
)
/

comment on table app_element is 'Elements of application structure, fields and blocks.'
/

comment on column app_element.id is 'Primary key.'
/
comment on column app_element.element_type is 'Type of element - block or field'
/
comment on column app_element.name is 'Unique element name.'
/
comment on column app_element.data_type is 'Field data type (VARCHAR2, DATE, NUMBER).'
/
comment on column app_element.min_length is 'Minumum value length.'
/
comment on column app_element.max_length is 'Maximum value length.'
/
comment on column app_element.min_value is 'Minimum value.'
/
comment on column app_element.max_value is 'Maximum value.'
/
comment on column app_element.lov_id is 'Reference to list of possible values.'
/
comment on column app_element.default_value is 'Default value.'
/
comment on column app_element.is_multilang is 'Element could have multi-language value.'
/
comment on column app_element.entity_type is 'Entity represented by complex element.'
/
comment on column app_element.edit_form is 'Custom visual form for editing application complex element'
/
