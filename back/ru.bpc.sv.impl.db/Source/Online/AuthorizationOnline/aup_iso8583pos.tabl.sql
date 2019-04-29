create table aup_iso8583pos (
    auth_id               number(16)
    , part_key            as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id             varchar2(36)
    , iso_msg_type        number(4)
    , trace               varchar2(6)
    , proc_code           varchar2(6)
    , function_code       varchar2(3)
    , terminal_number     varchar2(8)
    , terminal_id         number(8)
    , bitmap              varchar2(16)
    , time_mark           varchar2(16)
    , local_date          date
    , rrn                 varchar2(12)
    , card_number         varchar2(24)
    , amount              number(22,4)
    , resp_code           varchar2(3)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                        -- [@skip patch]
(                                                                                          -- [@skip patch]
    partition aup_iso8583pos_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))     -- [@skip patch]
)                                                                                          -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_iso8583pos is 'Table is used to store ISO8583POS interchange data that belongs to authorizations'
/
comment on column aup_iso8583pos.tech_id is 'Technical message identifier.'
/
comment on column aup_iso8583pos.iso_msg_type is 'ISO8583 message type.'
/
comment on column aup_iso8583pos.trace is 'Trace (field 11 value)'
/
comment on column aup_iso8583pos.proc_code is 'Processing code (field 3 value).'
/
comment on column aup_iso8583pos.function_code is 'Function code (field 24 value).'
/
comment on column aup_iso8583pos.terminal_number is 'Terminal number of message origin (field 41 value).'
/
comment on column aup_iso8583pos.bitmap is 'Message bitmap.'
/
comment on column aup_iso8583pos.time_mark is 'Message time mark (it is used to match message with logs and to restore sequence of messages).'
/
comment on column aup_iso8583pos.local_date is 'Device date and time of message (field 12 value).'
/
comment on column aup_iso8583pos.rrn is 'Reference number (field 37 value).'
/
comment on column aup_iso8583pos.auth_id is 'Identifier of appropriate authorization.'
/
comment on column aup_iso8583pos.card_number is 'Card number (card mask is used for matching).'
/
comment on column aup_iso8583pos.amount is 'Operation amount(Field 4 value).'
/
comment on column aup_iso8583pos.resp_code is 'Response code that was sent in the message to POS.'
/
comment on column aup_iso8583pos.terminal_id is 'Terminal internal identifier.'
/

alter table aup_iso8583pos add currency varchar2(3)
/
alter table aup_iso8583pos add cnvt_amount number(22,4)
/
alter table aup_iso8583pos add cnvt_currency varchar2(3)
/
alter table aup_iso8583pos add cnvt_rate number
/
comment on column aup_iso8583pos.currency is 'Operation amount currency (Field 49 value).'
/
comment on column aup_iso8583pos.cnvt_amount is 'Converted operation amount'
/
comment on column aup_iso8583pos.cnvt_currency is 'Converted operation amount currency'
/
comment on column aup_iso8583pos.cnvt_rate is 'Conversion rate'
/
alter table aup_iso8583pos modify (terminal_number varchar2(16))
/


