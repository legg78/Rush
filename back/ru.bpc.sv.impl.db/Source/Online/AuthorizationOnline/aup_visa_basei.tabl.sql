create table aup_visa_basei (
    auth_id                number(16)
    , part_key             as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id              varchar2(36)
    , iso_msg_type         number(4)
    , bitmap               varchar2(48)
    , time_mark            varchar2(16)
    , acq_inst_bin         varchar2(11)
    , terminal_number      varchar2(8)
    , merchant_number      varchar2(15)
    , refnum               varchar2(12)
    , resp_code            varchar2(2)
    , trms_datetime        date
    , trace                varchar2(6)
    , forw_inst_bin        varchar2(11)
    , network_id           varchar2(4)
    , auth_id_resp         varchar2(6)
    , hdr_src_station_id   varchar2(6)
    , hdr_dest_station_id  varchar2(6)
    , hdr_rtc_info         varchar2(2)
    , hdr_basei_flags      varchar2(4)
    , hdr_msg_status_flags varchar2(6)
    , hdr_batch_num        varchar2(2)
    , hdr_reserved         varchar2(6)
    , hdr_user_info        varchar2(2)
    , host_id              number(4)
    , icc_dataset_id       number(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_visa_basei_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table aup_visa_basei is 'Table is used to store history of messages between VISA network and switch. Only financial messages are stored'
/
comment on column aup_visa_basei.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_visa_basei.tech_id is 'Technical identifier of message'
/
comment on column aup_visa_basei.iso_msg_type is 'Message type defined by VISA BASEI protocol'
/
comment on column aup_visa_basei.bitmap is 'Message bitmap'
/
comment on column aup_visa_basei.time_mark is 'Time of processing by switch'
/
comment on column aup_visa_basei.acq_inst_bin is 'Acquirer BIN'
/
comment on column aup_visa_basei.terminal_number is 'ISO terminal number'
/
comment on column aup_visa_basei.merchant_number is 'ISO merchant number'
/
comment on column aup_visa_basei.refnum is 'Reference number'
/
comment on column aup_visa_basei.resp_code is 'Response code'
/
comment on column aup_visa_basei.forw_inst_bin is 'Forwarding institution identification code (field 33)'
/
comment on column aup_visa_basei.trace is 'Trace number (field 11)'
/
comment on column aup_visa_basei.trms_datetime is 'Transmission date and time (field 7)'
/
comment on column aup_visa_basei.network_id is 'Value from Field 63.1. Contains a code that specifies the network to be used for transmission of the message and determines the program rules that apply to the transaction'
/
comment on column aup_visa_basei.auth_id_resp is 'Field 38 value. Authorization identification response. The field is used in response messages only'
/
comment on column aup_visa_basei.hdr_basei_flags is 'Header field 8. Base 1 flags'
/
comment on column aup_visa_basei.hdr_batch_num is 'Header field 10. Batch number'
/
comment on column aup_visa_basei.hdr_dest_station_id is 'Header field 5. Destination station identifier'
/
comment on column aup_visa_basei.hdr_msg_status_flags is 'Header field 9. Message status flags'
/
comment on column aup_visa_basei.hdr_reserved is 'Header field 11. Reserved data'
/
comment on column aup_visa_basei.hdr_rtc_info is 'Header field 7. Round trip control information'
/
comment on column aup_visa_basei.hdr_src_station_id is 'Header field 6. Source station identifier'
/
comment on column aup_visa_basei.hdr_user_info is 'Header field 12. User information'
/
comment on column aup_visa_basei.host_id is 'Host member id identifier for working network host.'
/
comment on column aup_visa_basei.icc_dataset_id is 'ICC dataset identifier from request message.'
/
alter table aup_visa_basei  add (trans_id  number(15))
/
comment on column aup_visa_basei.trans_id is 'Transaction ID assigned by VISA (field 62.2).'
/
alter table aup_visa_basei  add (addl_resp_data  varchar2(25))
/
comment on column aup_visa_basei.addl_resp_data is 'Additional response data (Field 44).'
/
alter table aup_visa_basei  add (trans_amount number(22,4), billing_amount number(22,4), billing_rate number(22,4), trans_fee_amount number(22,4))
/
comment on column aup_visa_basei.trans_amount is 'Transaction amount (Field 4)'
/
comment on column aup_visa_basei.billing_amount is 'Cardholder billing amount (Field 6)'
/
comment on column aup_visa_basei.billing_rate is 'Cardholder billing conversion rate (Field 10)'
/
comment on column aup_visa_basei.trans_fee_amount is 'Transaction fee amount (Field 28)'
/
alter table aup_visa_basei add validation_code varchar2(4)
/
comment on column aup_visa_basei.validation_code is 'A unique value that Visa Europe includes as part of the Custom Payment Service programs in each Authorization Response to ensure that key authorization fields are preserved in the Clearing Record'
/
alter table aup_visa_basei add srv_indicator varchar2(1)
/
comment on column aup_visa_basei.srv_indicator is 'A code used to provide additional information regarding the disposition of the transaction'
/
alter table aup_visa_basei add ecommerce_indicator varchar2(1)
/
comment on column aup_visa_basei.ecommerce_indicator is 'The electronic commerce flag'
/
alter table aup_visa_basei add addl_amounts varchar2(120)
/
comment on column aup_visa_basei.addl_amounts is 'Additional amounts (Field 54)'
/
alter table aup_visa_basei modify (terminal_number varchar2(16))
/

