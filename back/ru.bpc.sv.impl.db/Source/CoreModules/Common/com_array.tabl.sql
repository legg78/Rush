create table com_array (
    id             number(8)
  , seqnum         number(4)
  , array_type_id  number(4)
  , inst_id        number(4)
)
/

comment on table com_array is 'Arrays.'
/

comment on column com_array.id is 'Primary key.'
/

comment on column com_array.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_array.array_type_id is 'Reference to array type.'
/

comment on column com_array.inst_id is 'Owner institution identifier.'
/

alter table com_array add (mod_id number(4))
/

comment on column com_array.mod_id is 'Modifier identifier (for dynamic array).'
/

alter table com_array add (agent_id number(8))
/

comment on column com_array.agent_id is 'Agent identifier.'
/

alter table com_array add (is_private number(1))
/

comment on column com_array.is_private is 'Option if array is private.'
/

