create table com_flexible_data
(
    id           number(16)
  , field_id     number(8)
  , seq_number   number(4)
  , object_id    number(16)
  , field_value  varchar2(200)
)
/

comment on table com_flexible_data is 'Flexible fields values.'
/

comment on column com_flexible_data.id is 'Primary key.'
/

comment on column com_flexible_data.field_id is 'Reference to flexible field.'
/

comment on column com_flexible_data.seq_number is 'Sequence number of field same type on one object.'
/

comment on column com_flexible_data.object_id is 'Reference to object.'
/

comment on column com_flexible_data.field_value is 'Value.'
/