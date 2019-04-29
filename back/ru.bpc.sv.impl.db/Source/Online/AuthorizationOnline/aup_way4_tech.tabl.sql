create table aup_way4_tech (
    time_mark         varchar2(16)
    , part_key        as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
    , tech_id         varchar2(36)
    , iso_msg_type    number(4)
    , bitmap          varchar2(32)
    , ntwk_man_code   number(3)
    , resp_code       varchar2(2)
    , trace           varchar2(6)
    , trms_date_time  date
    , host_id         number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition aup_way4_tech_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_way4_tech.bitmap is 'Message bitmap.'
/
comment on column aup_way4_tech.iso_msg_type is 'ISO8583 message type.'
/
comment on column aup_way4_tech.ntwk_man_code is 'Network management code (field 70).'
/
comment on column aup_way4_tech.resp_code is 'Response code (field 39).'
/
comment on column aup_way4_tech.tech_id is 'Technical identifier of message.'
/
comment on column aup_way4_tech.time_mark is 'Time point at which message was saved. It is used to reveal message order.'
/
comment on column aup_way4_tech.trace is 'Trace value for message (field 11).'
/
comment on column aup_way4_tech.trms_date_time is 'Message transmission date and time (field 7).'
/
comment on column aup_way4_tech.host_id is 'Host member id identifier for working network host.'
/
comment on table aup_way4_tech is 'Table is intended to store messages between WAY4 host and switch. Only technical messages are stored.'
/
