create table aup_fimi
  (
    auth_id       number(16,0),
    part_key      as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual, -- [@skip patch]
    original_id   number(16,0),
    tech_id       varchar2(36 byte),
    payment_id    varchar2(36 byte),
    time_mark     varchar2(16 byte),
    auth_message  varchar2(8 byte),
    device_id     number,
    resp_code     varchar2(6 byte)
  )
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))              -- [@skip patch]
(                                                                                -- [@skip patch]
    partition aup_fimi_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_fimi.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_fimi.tech_id is 'Technical identifier of message'
/
comment on column aup_fimi.payment_id is 'Indentifier of the payment in the eKassir'
/
comment on column aup_fimi.time_mark is 'Time of processing by switch'
/
comment on column aup_fimi.auth_message is 'Message function of authorization state M'
/
comment on column aup_fimi.device_id is 'The commuunication device identifier'
/
comment on column aup_fimi.original_id is 'The identifier of original authorization'
/
comment on column aup_fimi.resp_code is 'Response code'
/
comment on table aup_fimi is 'Table is used to store history of messages between fimi service and switch. Only financial messages are stored'
/
alter table aup_fimi modify device_id number(16, 0)
/
alter table aup_fimi add  operation_id number(16,0)
/
comment on column aup_fimi.operation_id is 'Currient operation id'
/
alter table aup_fimi add  session_id number(16,0)
/
comment on column aup_fimi.session_id is 'Currient session id'
/
alter table aup_fimi add  card_number varchar2(24)
/
comment on column aup_fimi.card_number is 'Card number value'
/

