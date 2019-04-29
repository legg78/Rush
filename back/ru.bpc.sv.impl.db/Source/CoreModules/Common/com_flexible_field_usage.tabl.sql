create table com_flexible_field_usage (
    id        number(8)
  , field_id  number(8)
  , seqnum    number(4)
  , usage     varchar2(8)
)
/
comment on table com_flexible_field_usage is 'Flexible fields usage.'
/
comment on column com_flexible_field_usage.id is 'Primary key.'
/
comment on column com_flexible_field_usage.id is 'Flexible field ID.'
/
comment on column com_flexible_field_usage.id is 'Sequence number.'
/
comment on column com_flexible_field_usage.id is 'Dictionary article FFUS.'
/
