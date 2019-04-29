create table aup_iso8583cbs(
    auth_id          number(16)
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
  , mcc              varchar2(4)
  , acq_inst_bin     varchar2(11)
  , refnum           varchar2(12)
  , auth_id_resp     varchar2(6)
  , resp_code        varchar2(8)
  , terminal_id      varchar2(8)
  , merchant_id      varchar2(15)
  , fraud_data       varchar2(25)
  , iss_inst_id      number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_iso8583cbs_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table aup_iso8583cbs is 'Table is used to store history of messages between abs and svfe. Only financial messages are stored'
/
comment on column aup_iso8583cbs.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_iso8583cbs.tech_id is 'Technical identifier of message'
/
comment on column aup_iso8583cbs.host_id is 'Host member id identifier for working network host'
/
comment on column aup_iso8583cbs.iso_msg_type is 'Message type defined by iso8583cbs protocol'
/
comment on column aup_iso8583cbs.direction is 'Direction of the message (1 - incoming/0 - outgoing)'
/
comment on column aup_iso8583cbs.bitmap is 'Message bitmap'
/
comment on column aup_iso8583cbs.time_mark is 'Time of processing by switch'
/
comment on column aup_iso8583cbs.processing_code is 'Processing code, field 3'
/
comment on column aup_iso8583cbs.trace is 'Trace number, field 11'
/
comment on column aup_iso8583cbs.trans_date is 'Local transaction date and time, field 12'
/
comment on column aup_iso8583cbs.sttl_date is 'Settlemeent date, field 15'
/
comment on column aup_iso8583cbs.mcc is 'Merchant category code, field 18'
/
comment on column aup_iso8583cbs.acq_inst_bin is 'Acquirer institution BIN, field 32'
/
comment on column aup_iso8583cbs.refnum is 'Reference number, field 37'
/
comment on column aup_iso8583cbs.auth_id_resp is 'Authorization identification response, field 38'
/
comment on column aup_iso8583cbs.resp_code is 'Response code, field 39'
/
comment on column aup_iso8583cbs.terminal_id is 'Card acceptor terminal id, field 41'
/
comment on column aup_iso8583cbs.merchant_id is 'Card acceptor id, field 42'
/
comment on column aup_iso8583cbs.fraud_data is 'Fraud information, field 48'
/
comment on column aup_iso8583cbs.iss_inst_id is 'Issuer institution ID, field 100'
/
alter table aup_iso8583cbs add function_code varchar2(3)
/
alter table aup_iso8583cbs add terminal_number varchar2(8)
/
alter table aup_iso8583cbs add local_date date
/
alter table aup_iso8583cbs add rrn varchar2(12)
/
alter table aup_iso8583cbs add card_number varchar2(24)
/
alter table aup_iso8583cbs add amount number(22,4)
/
comment on column aup_iso8583cbs.function_code is 'Function code'
/
comment on column aup_iso8583cbs.terminal_number is 'Terminal number of message origin'
/
comment on column aup_iso8583cbs.local_date is 'Device date and time of message'
/
comment on column aup_iso8583cbs.rrn is 'Reference number'
/
comment on column aup_iso8583cbs.card_number is 'Card number (card mask is used for matching)'
/
comment on column aup_iso8583cbs.amount is 'Operation amount'
/
alter table aup_iso8583cbs add acq_inst_id number(4)
/
comment on column aup_iso8583cbs.acq_inst_id is 'Acquirer institution ID'
/
alter table aup_iso8583cbs modify acq_inst_id varchar2(11)
/
alter table aup_iso8583cbs modify (terminal_number varchar2(16))
/

