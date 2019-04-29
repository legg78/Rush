create table com_flexible_field_standard(
    id           number(8)
  , field_id     number(8)
  , seqnum	     number(4)
  , standard_id	 number(4)
)
/
comment on table com_flexible_field_standard is 'Flexible fields standards'
/
comment on column com_flexible_field_standard.id is 'Primary key'
/
comment on column com_flexible_field_standard.field_id is 'Flexible field ID (com_flexible_field.id)'
/
comment on column com_flexible_field_standard.seqnum is 'Sequential number'
/
comment on column com_flexible_field_standard.standard_id is 'Standard ID (cmn_standard.id)'
/
