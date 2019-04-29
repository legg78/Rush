create table aup_atm_tech (
    terminal_id         number(8)
  , time_mark           timestamp
  , tech_id             varchar2(36)
  , message_type        number(2)
  , last_oper_id        number(16)
)
/

comment on table aup_atm_tech is 'Table is used to store status messages coming from the ATM.'
/
comment on column aup_atm_tech.terminal_id is 'Identifier of terminal that initiates status message.'
/
comment on column aup_atm_tech.time_mark is 'Time of processing by switch.'
/
comment on column aup_atm_tech.tech_id is 'Technical identifier of message.'
/
comment on column aup_atm_tech.message_type is 'Identifier message class and message sub-class.'
/
comment on column aup_atm_tech.last_oper_id is 'Last operation ID.'
/
