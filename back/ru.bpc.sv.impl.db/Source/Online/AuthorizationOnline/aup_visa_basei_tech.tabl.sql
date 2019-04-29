create table aup_visa_basei_tech (
    time_mark           varchar2(16)
    , part_key          as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
    , tech_id           varchar2(36)
    , iso_msg_type      number(4)
    , bitmap            varchar2(48)
    , refnum            varchar2(12)
    , ntwk_man_code     number(3)
    , resp_code         varchar2(2)
    , trace             varchar2(6)
    , host_id           number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                    -- [@skip patch]
(                                                                                      -- [@skip patch]
    partition aup_visa_basei_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                      -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_visa_basei_tech.tech_id is 'Technical identifier of message'
/
comment on column aup_visa_basei_tech.iso_msg_type is 'Message type defined by VISA protocol.'
/
comment on column aup_visa_basei_tech.bitmap is 'Message bitmap.'
/
comment on column aup_visa_basei_tech.time_mark is 'Time of processing by switch.'
/
comment on column aup_visa_basei_tech.refnum is 'Reference number'
/
comment on column aup_visa_basei_tech.ntwk_man_code is 'Network management code.'
/
comment on column aup_visa_basei_tech.resp_code is 'Response code'
/
comment on column aup_visa_basei_tech.trace is 'Trace number (field 11)'
/
comment on column aup_visa_basei_tech.host_id is 'Host member id identifier for working network host.'
/