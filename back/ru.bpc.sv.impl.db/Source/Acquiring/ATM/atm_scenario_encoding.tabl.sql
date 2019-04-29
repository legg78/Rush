create table atm_scenario_encoding (
    id                number(4)
  , seqnum            number(4)
  , atm_scenario_id   number(4)
  , lang              varchar2(8)
  , reciept_encoding  varchar2(200)
  , screen_encoding   varchar2(200)
)
/
comment on table atm_scenario_encoding is 'Aviable encodings for ATM scenario.'
/
comment on column atm_scenario_encoding.id is 'Primary key.'
/
comment on column atm_scenario_encoding.seqnum is 'Sequence number. Describe data version.'
/
comment on column atm_scenario_encoding.atm_scenario_id is 'ATM scenario id.'
/
comment on column atm_scenario_encoding.lang is 'Language.'
/
comment on column atm_scenario_encoding.reciept_encoding is 'Encoding for ATM reciept.'
/
comment on column atm_scenario_encoding.screen_encoding is 'Encoding for ATM screen.'
/