create table din_message_field(
    function_code                varchar2(2)
  , field_name                   varchar2(8)
  , field_number                 number(4)
  , format                       varchar2(8)
  , field_length                 number(4)
  , is_mandatory                 number(1)
  , default_value                varchar2(200)
  , emv_tag                      varchar2(6)
  , description                  varchar2(200)
)
/

comment on table din_message_field is 'Diners Club reference table with fields of different message types'
/
comment on column din_message_field.function_code is 'Function code [FUNCD], it defines message type uniquely so that may be used as its synonym'
/
comment on column din_message_field.field_name is 'Field name in according to the specification'
/
comment on column din_message_field.field_number is 'Field number in message of associated type'
/
comment on column din_message_field.format is 'Data format (DTTP dictionary)'
/
comment on column din_message_field.field_length is 'Length of a field'
/
comment on column din_message_field.is_mandatory is 'Mandatory flag'
/
comment on column din_message_field.default_value is 'Default field value for mandatory fields'
/
comment on column din_message_field.emv_tag is 'EMV tag that is associated with a field (applicable only for addendum message with function code XM). Foreign key to the field EMV_TAG.tag'
/
comment on column din_message_field.description is 'Field description'
/
