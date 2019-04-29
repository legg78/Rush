create table aup_epay
  (
    auth_id         NUMBER(16,0)
  , part_key        as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , tech_id         varchar2(36 byte)
  , iso_msg_type    number(4,0)
  , bitmap          varchar2(48 byte)
  , de48_bitmap     varchar2(48 byte)
  , time_mark       varchar2(16 byte)
  , proc_code       varchar2(6 byte)
  , auth_id_resp    varchar2(6 byte)
  , resp_code       varchar2(2 byte)
  , trns_datetime   date
  , trms_datetime   date
  , trace           varchar2(6 byte)
  )
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_epay_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on column aup_epay.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_epay.tech_id is  'Technical identifier of message'
/
comment on column aup_epay.iso_msg_type is 'Message type defined by VISA BASEI protocol'
/
comment on column aup_epay.bitmap is 'Message bitmap'
/
comment on column aup_epay.de48_bitmap is '48th field tags bitmap'
/
comment on column aup_epay.time_mark is 'Time of processing by switch'
/
comment on column aup_epay.auth_id_resp is 'Field 38 value. Authorization identification response. The field is used in response messages only'
/
comment on column aup_epay.resp_code is 'Response code'
/
comment on column aup_epay.proc_code is 'Processing code'
/
comment on column aup_epay.trms_datetime is 'Transmission date and time (field 7)'
/
comment on column aup_epay.trns_datetime is 'Local transaction date and time (field 12)'
/
comment on column aup_epay.trace is 'Trace number (field 11)'
/
comment on table aup_epay is 'Table is used to store history of messages between E-Pay and switch'
/
alter table aup_epay rename column trms_datetime to transmission_date
/
alter table aup_epay rename column trns_datetime to local_date
/
alter table aup_epay add (rrn varchar2(12 byte))
/
comment on column aup_epay.rrn is 'Retrieval reference number'
/
alter table aup_epay add (direction varchar2(1 byte) default '-')
/
alter table aup_epay add (card_number varchar2(24 char))
/
comment on column aup_epay.card_number is 'Card number'
/
alter table aup_epay add (terminal_id varchar2(8 byte))
/
comment on column aup_epay.terminal_id is 'Terminal Id'
/
alter table aup_epay add (merchant_id varchar2(15 byte))
/
comment on column aup_epay.merchant_id is 'Merchant Id'
/
