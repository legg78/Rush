create table din_addendum_field(
    function_code                varchar2(2)
  , field_name                   varchar2(8)
  , field_number                 number(4)
  , format                       varchar2(8)
  , field_length                 number(4)
  , description                  varchar2(200)
  , emv_tag                      varchar2(6)
)
/

comment on table din_addendum_field is 'Diners Club reference table with fields of different addendum types'
/
comment on column din_addendum_field.function_code is 'Function code [FUNCD]'
/
comment on column din_addendum_field.field_name is 'Field name in according to the specification'
/
comment on column din_addendum_field.field_number is 'Field number in addendum message of associated addendum type'
/
comment on column din_addendum_field.format is 'Data format (DTTP dictionary)'
/
comment on column din_addendum_field.field_length is 'Length of a field'
/
comment on column din_addendum_field.description is 'Field description'
/
comment on column din_addendum_field.emv_tag is 'EMV tag that is associated with a field (applicable only for addendum type with function code XM). Foreign key to the field EMV_TAG.tag'
/

alter table din_addendum_field add (default_value varchar2(200))
/
comment on column din_addendum_field.default_value is 'Default field value for mandatory fields'
/

comment on table din_addendum_field is 'Obsolete, may be deleted'
/
