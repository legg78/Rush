create table aup_belkart_tech (
    tech_id             varchar2(36)
    , part_key          as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS') + ( time_mark / (24 * 60 * 60 * 1000000) )) virtual  -- [@skip patch]
    , iso_msg_type      number(4)
    , time_mark         varchar2(16)
    , bitmap            varchar2(32)
    , resp_code         varchar2(3)
    , ntwk_man_code     number(3)
    , trace             varchar2(6)
    , trms_datetime     date
    , host_id           number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_belkart_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on column aup_belkart_tech.tech_id is 'Technical identifier of message'
/
comment on column aup_belkart_tech.iso_msg_type is 'Message type defined by Belkart protocol.'
/
comment on column aup_belkart_tech.time_mark is 'Time of processing by switch.'
/
comment on column aup_belkart_tech.bitmap is 'Message bitmap.'
/
comment on column aup_belkart_tech.resp_code is 'Response code'
/
comment on column aup_belkart_tech.ntwk_man_code is 'Network management code.'
/
comment on column aup_belkart_tech.trace is 'Trace number'
/
comment on column aup_belkart_tech.trms_datetime is 'Transmission time'
/
comment on column aup_belkart_tech.host_id is 'Host member id identifier for working network host.'
/
