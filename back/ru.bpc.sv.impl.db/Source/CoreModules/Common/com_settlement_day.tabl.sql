create table com_settlement_day
(
  id               number(8) not null
  , inst_id        number(4)
  , sttl_day       number(4)
  , sttl_date      date
  , open_timestamp timestamp
  , is_open        number(1)
  , seqnum         number(4)
)
/
comment on table com_settlement_day is 'Settlement days.'
/
comment on column com_settlement_day.id is 'Primary key.'
/
comment on column com_settlement_day.sttl_day is 'Settlement day number.'
/
comment on column com_settlement_day.sttl_date is 'Settlement day date equivalent'
/
comment on column com_settlement_day.open_timestamp is 'System timestamp when settlement day was opened'
/
comment on column com_settlement_day.is_open is 'Is settlement day open. Could be only one open day per institution'
/
comment on column com_settlement_day.inst_id is 'Institution identifier.'
/
comment on column com_settlement_day.seqnum is 'Sequential version of record'
/