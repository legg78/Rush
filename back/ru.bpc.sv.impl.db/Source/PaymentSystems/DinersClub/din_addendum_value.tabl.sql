create table din_addendum_value(
    id                           number(16)
  , addendum_id                  number(16)
  , field_name                   varchar2(10)
  , field_value                  varchar2(200)
)
/

comment on table din_addendum_value is 'Diners Club addendum values (by fields)'
/
comment on column din_addendum_value.id is 'Primary key'
/
comment on column din_addendum_value.addendum_id is 'Reference (foreign key) to parent table DIN_ADDENDUM'
/
comment on column din_addendum_value.field_name is 'Field name in according to the Diners Club specification'
/
comment on column din_addendum_value.field_value is 'Field value'
/
