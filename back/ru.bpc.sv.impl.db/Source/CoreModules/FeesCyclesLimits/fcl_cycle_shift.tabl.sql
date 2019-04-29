create table fcl_cycle_shift
(
  id            number(8)                       not null,
  seqnum        number(3)                       not null,
  cycle_id      number(8),
  shift_type    varchar2(8),
  priority      number(4),
  shift_sign    number(1),
  length_type   varchar2(8),
  shift_length  number(4)
)
/

comment on table fcl_cycle_shift is 'Cycle displacements. Describe dificult rules of cycle calculation.'
/

comment on column fcl_cycle_shift.id is 'Primary key.'
/

comment on column fcl_cycle_shift.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_cycle_shift.cycle_id is 'Reference to cycle.'
/

comment on column fcl_cycle_shift.shift_type is 'Displacement type. (move on count days, move on first workday if holiday, move on nearest fixed day of week).'
/

comment on column fcl_cycle_shift.priority is 'Dispacement implementation order. Unique in one cycle.'
/

comment on column fcl_cycle_shift.shift_sign is 'Displacement sign. 1 - forward, -1 - backward, 0 - none.'
/

comment on column fcl_cycle_shift.length_type is 'Date calculation unit (Year, Month, Week, Day).'
/

comment on column fcl_cycle_shift.shift_length is 'Displacement length. Certain meaning depends on displacement type.'
/