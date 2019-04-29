create table aup_iso8583bic (
    auth_id               number(16)
    , part_key            as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id             varchar2(36)
    , iso_msg_type        number(4)
    , trace               varchar2(6)
    , proc_code           varchar2(6)
    , function_code       varchar2(3)
    , terminal_number     varchar2(8)
    , terminal_id         number(16)
    , bitmap              varchar2(32)
    , time_mark           varchar2(16)
    , local_date          date
    , sttl_date           date
    , capture_date        date
    , tokens              varchar2(4000)
    , rrn                 varchar2(12)
    , card_number         varchar2(24)
    , amount              number(22,4)
    , resp_code           varchar2(3)
    , direction           number(1)
    , host_id             number(8)
    , device_id           number(8)
    , trans_date          date
    , merchant_id         varchar2(15)
    , auth_id_resp        varchar2(6)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition aup_iso8583bic_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_iso8583bic is 'Table is used to store ISO8583BIC interchange data that belongs to authorizations'
/
comment on column aup_iso8583bic.tech_id is 'Technical message identifier.'
/
comment on column aup_iso8583bic.iso_msg_type is 'ISO8583 message type.'
/
comment on column aup_iso8583bic.trace is 'Trace (field 11 value)'
/
comment on column aup_iso8583bic.proc_code is 'Processing code (field 3 value).'
/
comment on column aup_iso8583bic.function_code is 'Function code (field 24 value).'
/
comment on column aup_iso8583bic.terminal_number is 'Terminal number of message origin (field 41 value).'
/
comment on column aup_iso8583bic.terminal_id is 'Terminal internal identifier.'
/
comment on column aup_iso8583bic.bitmap is 'Message bitmap.'
/
comment on column aup_iso8583bic.time_mark is 'Message time mark (it is used to match message with logs and to restore sequence of messages).'
/
comment on column aup_iso8583bic.local_date is 'Device date and time of message (field 12 value).'
/
comment on column aup_iso8583bic.rrn is 'Reference number (field 37 value).'
/
comment on column aup_iso8583bic.auth_id is 'Identifier of appropriate authorization.'
/
comment on column aup_iso8583bic.card_number is 'Card number (card mask is used for matching).'
/
comment on column aup_iso8583bic.amount is 'Operation amount(Field 4 value).'
/
comment on column aup_iso8583bic.resp_code is 'Response code that was sent in the message to originator.'
/
comment on column aup_iso8583bic.direction is 'Direction of the message: 1-incoming, 2-outgoing.'
/
comment on column aup_iso8583bic.host_id is 'The operational host identifier.'
/
comment on column aup_iso8583bic.device_id is 'The operational device identifier.'
/
comment on column aup_iso8583bic.trans_date is 'Date of the transaction.'
/
comment on column aup_iso8583bic.merchant_id is 'Identifier of the merchant.'
/
comment on column aup_iso8583bic.auth_id_resp is 'Authorization identifier response (field 38 value).'
/
comment on column aup_iso8583bic.sttl_date is 'Settlement date (field 15 value).'
/
comment on column aup_iso8583bic.capture_date is 'Capture date (field 17 value).'
/
comment on column aup_iso8583bic.tokens is 'Tokens (field 63 value).'
/
alter table aup_iso8583bic modify resp_code varchar2(8)
/
alter table aup_iso8583bic add product number(1)
/
comment on column aup_iso8583bic.resp_code is 'Response code that was sent in the message to originator.'
/
comment on column aup_iso8583bic.product is 'Product indicator.'
/
alter table aup_iso8583bic add card_seq_number varchar2(6 byte)
/
comment on column aup_iso8583bic.card_seq_number is 'Card sequence number (field 23 value).'
/
alter table aup_iso8583bic add pos_cond_code varchar2(2 byte)
/
comment on column aup_iso8583bic.pos_cond_code is 'Point of Service Condition Code (field 25 value).'
/
alter table aup_iso8583bic modify (terminal_number varchar2(16))
/

