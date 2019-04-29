create table aup_iso8583bic_tech (
    time_mark             varchar2(16)
    , part_key            as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
    , tech_id             varchar2(36)
    , iso_msg_type        number(4)
    , trace               varchar2(6)
    , proc_code           varchar2(6)
    , terminal_number     varchar2(8)
    , bitmap              varchar2(32)
    , local_date          date
    , resp_code           varchar2(3)
    , terminal_id         number(8)
    , ntwk_man_code       varchar2(6)
    , direction           number(1)
    , device_id           number(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                         -- [@skip patch]
(                                                                                           -- [@skip patch]
    partition aup_iso8583bic_tech_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                           -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_iso8583bic_tech is 'Table is used to store ISO8583BIC interchange data that doesn''t belong to authorizations'
/
comment on column aup_iso8583bic_tech.bitmap is 'Message bitmap.'
/
comment on column aup_iso8583bic_tech.iso_msg_type is 'ISO8583 message type.'
/
comment on column aup_iso8583bic_tech.proc_code is 'Processing code (field 3 value).'
/
comment on column aup_iso8583bic_tech.tech_id is 'Technical message identifier.'
/
comment on column aup_iso8583bic_tech.terminal_number is 'Terminal number of message origin (field 41 value).'
/
comment on column aup_iso8583bic_tech.time_mark is 'Message time mark (it is used to match message with logs and to restore sequence of messages).'
/
comment on column aup_iso8583bic_tech.trace is 'Trace (field 11 value)'
/
comment on column aup_iso8583bic_tech.ntwk_man_code is 'Network International Identifier (Field 70).'
/
comment on column aup_iso8583bic_tech.local_date is 'Device date and time of message (field 12 value).'
/
comment on column aup_iso8583bic_tech.resp_code is 'Response code that was sent in the message to POS.'
/
comment on column aup_iso8583bic_tech.terminal_id is 'Terminal identifier.'
/
comment on column aup_iso8583bic_tech.device_id is 'Device identifier.'
/
alter table aup_iso8583bic_tech modify resp_code varchar2(8)
/
comment on column aup_iso8583bic_tech.direction is 'Message direction: 1 - incoming, 2 - outgoing.'
/
alter table aup_iso8583bic_tech modify (terminal_number varchar2(16))
/

