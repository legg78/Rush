create table aup_sv2sv (
    auth_id            number(16)
    , part_key         as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id          varchar2(36)
    , host_id          number(4)
    , iso_msg_type     number(4)
    , direction        number(1)
    , bitmap           varchar2(32)
    , time_mark        varchar2(16)
    , processing_code  varchar2(6)
    , trace            varchar2(6)
    , trans_date       date
    , sttl_date        date
    , mcc              number(4)
    , acq_inst_id      varchar2(11)
    , refnum           varchar2(12)
    , auth_id_resp     varchar2(6)
    , resp_code        varchar2(8)
    , terminal_id      varchar2(8)
    , merchant_id      varchar2(15)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))               -- [@skip patch]
(                                                                                 -- [@skip patch]
    partition aup_sv2sv_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                 -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_sv2sv is 'Table is used to store history of messages between visa network and switch. Only financial messages are stored'
/
comment on column aup_sv2sv.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_sv2sv.tech_id is 'Technical identifier of message'
/
comment on column aup_sv2sv.host_id is 'Host member id identifier for working network host'
/
comment on column aup_sv2sv.iso_msg_type is 'Message type defined by sv2sv protocol'
/
comment on column aup_sv2sv.direction is 'Direction of the message (1 - incoming/0 - outgoing)'
/
comment on column aup_sv2sv.bitmap is 'Message bitmap'
/
comment on column aup_sv2sv.time_mark is 'Time of processing by switch'
/
comment on column aup_sv2sv.processing_code is 'Processing code, field 3'
/
comment on column aup_sv2sv.trace is 'Trace number, field 11'
/
comment on column aup_sv2sv.trans_date is 'Local transaction date and time, field 12'
/
comment on column aup_sv2sv.sttl_date is 'Settlemeent date, field 15'
/
comment on column aup_sv2sv.mcc is 'Merchant category code, field 18'
/
comment on column aup_sv2sv.acq_inst_id is 'Acquirer institution id, field 32'
/
comment on column aup_sv2sv.refnum is 'Reference number, field 37'
/
comment on column aup_sv2sv.auth_id_resp is 'Authorization identification response, field 38'
/
comment on column aup_sv2sv.resp_code is 'SV2SV response code, field 39'
/
comment on column aup_sv2sv.terminal_id is 'Card acceptor terminal id, field 41'
/
comment on column aup_sv2sv.merchant_id is 'Card acceptor id, field 42'
/
