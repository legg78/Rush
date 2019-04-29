create table aup_mastercard_tech (
    time_mark        varchar2(16) not null
    , part_key       as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
    , tech_id        varchar2(36) not null
    , iso_msg_type   number(4) not null
    , trace          varchar2(6) not null
    , trms_datetime  date not null
    , bitmap         varchar2(32) not null
    , ntwk_man_code  number(3)
    , host_id        number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                         -- [@skip patch]
(                                                                                           -- [@skip patch]
    partition aup_mastercard_tech_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                           -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_mastercard_tech.bitmap is 'Message bitmap.'
/
comment on column aup_mastercard_tech.iso_msg_type is 'Message type defined by MasterCard protocol.'
/
comment on column aup_mastercard_tech.ntwk_man_code is 'network management code. Contents of DE70.'
/
comment on column aup_mastercard_tech.tech_id is 'Technical identifier of message.'
/
comment on column aup_mastercard_tech.time_mark is 'Time of processing by switch.'
/
comment on column aup_mastercard_tech.trace is 'Trace value (field 11).'
/
comment on column aup_mastercard_tech.trms_datetime is 'Transmission date and time (field 7).'
/
comment on column aup_mastercard_tech.host_id is 'Host member id identifier for working network host.'
/
