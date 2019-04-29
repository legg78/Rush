create table com_state_holiday
(
    id        number(4)
  , seqnum    number(4)
  , cycle_id  number(8)
  , inst_id   number(4)
)
/

comment on table com_state_holiday is 'State holidays dictionary.'
/

comment on column com_state_holiday.id is 'Primary key.'
/

comment on column com_state_holiday.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_state_holiday.cycle_id is 'Reference to cycle calculating holiday date.'
/

comment on column com_state_holiday.inst_id is 'Institution identifier.'
/