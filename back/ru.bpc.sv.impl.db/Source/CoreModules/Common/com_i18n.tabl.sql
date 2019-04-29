create table com_i18n
(
    id           number(12)
  , lang         varchar2(8)
  , entity_type  varchar2(8)
  , table_name   varchar2(30)
  , column_name  varchar2(30)
  , object_id    number(16)
  , text         varchar2(4000)
)
/

comment on table com_i18n is 'Multi-language support table. Store descriptions of all business entities.'
/

comment on column com_i18n.id is 'Primary key.'
/
comment on column com_i18n.lang is 'Language code. Dictionary code - ''LANG''.'
/
comment on column com_i18n.entity_type is 'Type of entity - i18n value owner.'
/
comment on column com_i18n.table_name is 'Table name associated with entity.'
/
comment on column com_i18n.column_name is 'Virtual column name.'
/
comment on column com_i18n.object_id is 'Reference to entity object.'
/
comment on column com_i18n.text is 'Content of column in exact language.'
/
