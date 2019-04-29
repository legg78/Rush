create table aup_visa_sms (
    auth_id              number(16)
  , part_key             as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , tech_id              varchar2(36)
  , host_id              number(8)
  , iso_msg_type         number(4)
  , bitmap               varchar2(48)
  , time_mark            varchar2(16)
  , trms_datetime        number(10)
  , trace                varchar2(6)
  , cond_code            number(2)
  , acq_inst_id          varchar2(11)
  , forw_inst_id         varchar2(11)
  , resp_code            varchar2(8)
  , refnum               varchar2(12)
  , auth_id_resp         varchar2(6)
  , terminal_id          varchar2(8)
  , merchant_id          varchar2(15)
  , icc_dataset_id       number(1)
  , trans_id             number(15)
  , network_id           number(4)
  , fpi                  varchar2(3)
  , hdr_text_format      varchar2(2)
  , hdr_dest_station_id  varchar2(6)
  , hdr_src_station_id   varchar2(6)
  , hdr_rtc_info         varchar2(2)
  , hdr_basei_flags      varchar2(4)
  , hdr_msg_status_flags varchar2(6)
  , hdr_batch_num        varchar2(2)
  , hdr_reserved         varchar2(6)
  , hdr_user_info        varchar2(2)
  , trans_date           date
  , processing_code      varchar2(6)
  , sttl_date            number(4)
  , acq_inst_cc          number(3)
  , addl_data            varchar2(510)
  , pos_geogr_data       varchar2(14)
  , cps_bitmap           varchar2(16)
  , sms_bitmap           varchar2(6)
  , msg_reason_code      number(4)
  , orgdata              varchar2(42)
  , pos_entry_mode       number(3)
  , addl_pos_data        varchar2(12)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                  -- [@skip patch]
(                                                                                    -- [@skip patch]
    partition aup_visa_sms_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                    -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_visa_sms.auth_id is 'Identifier authorization that causes message'
/

comment on column aup_visa_sms.tech_id is 'Technical identifier of message'
/
comment on column aup_visa_sms.host_id is 'Host member id identifier for working network host'
/
comment on column aup_visa_sms.iso_msg_type is 'Message type defined by V.I.P. protocol'
/
comment on column aup_visa_sms.bitmap is 'Message bitmap'
/
comment on column aup_visa_sms.time_mark is 'Time of processing by switch'
/
comment on column aup_visa_sms.trms_datetime is 'Transmission date and time, field 7'
/
comment on column aup_visa_sms.trace is 'Trace number, field 11'
/
comment on column aup_visa_sms.cond_code is 'Point-of-Service Condition Code, field 25, used for separation of normal and exception messages'
/
comment on column aup_visa_sms.acq_inst_id is 'Acquirer institution id, field 32'
/
comment on column aup_visa_sms.forw_inst_id is 'Forwarding institution id, field 33'
/
comment on column aup_visa_sms.resp_code is 'V.I.P. Response code, field 39'
/
comment on column aup_visa_sms.refnum is 'Reference number, field 37'
/
comment on column aup_visa_sms.auth_id_resp is 'Authorization identification response, field 38'
/
comment on column aup_visa_sms.terminal_id is 'Card Acceptor Terminal Id, field 41'
/
comment on column aup_visa_sms.merchant_id is 'Card Acceptor Id, field 42'
/
comment on column aup_visa_sms.icc_dataset_id is 'Type of ICC data, field 55.1'
/
comment on column aup_visa_sms.trans_id is 'Transaction Id, field 62.2'
/
comment on column aup_visa_sms.network_id is 'Network Id, field 63.1'
/
comment on column aup_visa_sms.fpi is 'Fee Prgoram Indicator, field 63.19'
/
comment on column aup_visa_sms.hdr_text_format is 'Text format, header field 3'
/
comment on column aup_visa_sms.hdr_dest_station_id is 'Destination station identifier, header field 5'
/
comment on column aup_visa_sms.hdr_src_station_id is 'Source station identifier, header field 6'
/
comment on column aup_visa_sms.hdr_rtc_info is 'Round trip control information, header field 7'
/
comment on column aup_visa_sms.hdr_basei_flags is 'Base 1 flags, header field 8'
/
comment on column aup_visa_sms.hdr_msg_status_flags is 'Message status flags, header field 9'
/
comment on column aup_visa_sms.hdr_batch_num is 'Batch number, header field 10'
/
comment on column aup_visa_sms.hdr_reserved is 'Reserved data, header field 11'
/
comment on column aup_visa_sms.hdr_user_info is 'User information, header field 12'
/
comment on column aup_visa_sms.trans_date is 'Local transaction date and time, fields 12, 13.'
/
comment on column aup_visa_sms.processing_code is 'Processing code, field 3.'
/
comment on column aup_visa_sms.sttl_date  is 'Settlement data, field 15.'
/
comment on column aup_visa_sms.acq_inst_cc is 'Acquiring institution country code, field 19.'
/
comment on column aup_visa_sms.addl_data is 'Additional data, field 48.'
/
comment on column aup_visa_sms.pos_geogr_data is 'PoS Geographic data, field 59.'
/
comment on column aup_visa_sms.cps_bitmap is 'Field 62 bitmap.'
/
comment on column aup_visa_sms.sms_bitmap is 'Field 63 bitmap.'
/
comment on column aup_visa_sms.msg_reason_code is 'Message reason code, field 63.3.'
/
comment on column aup_visa_sms.orgdata  is 'Original data, field 90.'
/
comment on column aup_visa_sms.pos_entry_mode is 'Point-of-Service Entry Mode, field 22.'
/
comment on column aup_visa_sms.addl_pos_data is 'Additional Point-of-Service data, field 60.'
/
alter table aup_visa_sms  add (trans_amount number(22,4), billing_amount number(22,4), billing_rate number(22,4), trans_fee_amount number(22,4))
/
comment on column aup_visa_sms.trans_amount is 'Transaction amount (Field 4)'
/
comment on column aup_visa_sms.billing_amount is 'Cardholder billing amount (Field 6)'
/
comment on column aup_visa_sms.billing_rate is 'Cardholder billing conversion rate (Field 10)'
/
comment on column aup_visa_sms.trans_fee_amount is 'Transaction fee amount (Field 28)'
/
