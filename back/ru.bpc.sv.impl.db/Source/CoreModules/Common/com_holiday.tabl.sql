create table com_holiday
(
    id            number(4)
  , seqnum        number(4)
  , holiday_date  date
  , inst_id       number(4)
)
/

comment on table com_holiday is 'Holidays.'
/

comment on column com_holiday.id is 'Primary key.'
/

comment on column com_holiday.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_holiday.holiday_date is 'Holiday date.'
/

comment on column com_holiday.inst_id is 'Institution identifier.'
/