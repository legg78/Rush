create table aup_ekassir
  (
    auth_id       number(16,0),
    part_key      as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual,  -- [@skip patch]
    original_id   number(16,0),
    tech_id       varchar2(36 byte),
    payment_id    varchar2(36 byte),
    time_mark     varchar2(16 byte),
    auth_message  varchar2(8 byte),
    device_id     number,
    resp_code     varchar2(6 byte)
  )
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                 -- [@skip patch]
(                                                                                   -- [@skip patch]
    partition aup_ekassir_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                   -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_ekassir is 'Table is used to store history of messages between ekassir service and switch. Only financial messages are stored'
/

comment on column aup_ekassir.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_ekassir.tech_id is 'Technical identifier of message'
/
comment on column aup_ekassir.payment_id is 'Indentifier of the payment in the eKassir'
/
comment on column aup_ekassir.time_mark is 'Time of processing by switch'
/
comment on column aup_ekassir.auth_message is 'Message function of authorization state M'
/
comment on column aup_ekassir.device_id is 'The commuunication device identifier'
/
comment on column aup_ekassir.original_id is 'The identifier of original authorization'
/
comment on column aup_ekassir.resp_code is 'Response code'
/
