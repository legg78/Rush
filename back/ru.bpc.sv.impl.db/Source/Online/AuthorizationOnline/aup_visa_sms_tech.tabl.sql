create table aup_visa_sms_tech (
    time_mark     varchar2(16)
  , part_key      as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
  , tech_id       varchar2(36)
  , iso_msg_type  number(4)
  , bitmap        varchar2(48)
  , ntwk_man_code number(3)
  , resp_code     varchar2(8)
  , trace         varchar2(6)
  , host_id       number(8)
  , refnum        varchar2(12)
  , trms_datetime number(10)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition aup_visa_sms_tech_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_visa_sms_tech.time_mark is 'Time of processing by switch'
/

comment on column aup_visa_sms_tech.tech_id is 'Technical identifier of message'
/
comment on column aup_visa_sms_tech.iso_msg_type is 'Type of the message (ISO or session control)'
/
comment on column aup_visa_sms_tech.bitmap is 'Message bitmap'
/
comment on column aup_visa_sms_tech.ntwk_man_code is 'Network management code, field 70'
/
comment on column aup_visa_sms_tech.resp_code is 'V.I.P. Response code, field 39'
/
comment on column aup_visa_sms_tech.trace is 'Trace number, field 11'
/
comment on column aup_visa_sms_tech.host_id is 'Host member id identifier for working network host'
/
comment on column aup_visa_sms_tech.refnum is 'Reference number, field 37'
/
comment on column aup_visa_sms_tech.trms_datetime is 'Transmission date and time, field 7'
/
