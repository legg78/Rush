create table aup_mastercard (
    auth_id            number(16) not null
    , part_key         as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id          varchar2(36) not null
    , iso_msg_type     number(4) not null
    , trace            varchar2(6) not null
    , trms_datetime    date not null
    , time_mark        varchar2(16) not null
    , bitmap           varchar2(32) not null
    , proc_code        varchar2(6)
    , resp_code        varchar2(2)
    , sttl_date        number(4)
    , fin_ntwk_code    varchar2(3)
    , banknet_ref_num  varchar2(9)
    , acq_inst_bin     varchar2(11)
    , forw_inst_bin    varchar2(11)
    , host_id          number(4)
    , billing_rate     varchar2(8)
    , sttl_rate        varchar2(8)
    , de48_bitmap      varchar2(32)
    , advice_datetime  date
    , payment_trx_type varchar2(3)
    , pin_service_code varchar2(2)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_mastercard_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_mastercard is 'Table is used to store history of messages between MasterCard network and switch. Only financial messages are stored.'
/
comment on column aup_mastercard.auth_id is 'Identifier authorization that causes message.'
/
comment on column aup_mastercard.banknet_ref_num is 'Banknet reference number. Contents of DE63(subfield 2).'
/
comment on column aup_mastercard.bitmap is 'Message bitmap.'
/
comment on column aup_mastercard.fin_ntwk_code is 'Financial network code (specific service identifier). Contents of DE63(subfield 1).'
/
comment on column aup_mastercard.iso_msg_type is 'Message type defined by MasterCard protocol.'
/
comment on column aup_mastercard.proc_code is 'Processing code (field 3 value).'
/
comment on column aup_mastercard.resp_code is 'Response code that was assigned to message (DE39).'
/
comment on column aup_mastercard.sttl_date is 'Settlement date of message (DE15).'
/
comment on column aup_mastercard.tech_id is 'Technical identifier of message.'
/
comment on column aup_mastercard.time_mark is 'Time of processing by switch.'
/
comment on column aup_mastercard.trace is 'Trace value (field 11).'
/
comment on column aup_mastercard.trms_datetime is 'Transmission date and time (field 7).'
/
comment on column aup_mastercard.acq_inst_bin is 'Acquiring Institution ID Code (field 32 value).'
/
comment on column aup_mastercard.forw_inst_bin is 'Forwarding Institution ID Code (field 33 value).'
/
comment on column aup_mastercard.host_id is 'Host member id identifier for working network host.'
/
comment on column aup_mastercard.billing_rate is 'Conversion rate, cardholder billing (DE10).'
/
comment on column aup_mastercard.sttl_rate is 'Conversion rate, settlement (DE9).'
/
comment on column aup_mastercard.de48_bitmap is 'Additional data (DE48) bitmap.'
/
comment on column aup_mastercard.advice_datetime is 'Authorization system advice date and time (DE48.15).'
/
comment on column aup_mastercard.payment_trx_type is 'Payment Transaction Type Indicator identifies the type of Payment Transaction taking place (DE48.77).'
/
comment on column aup_mastercard.pin_service_code is 'PIN Service Code indicates the results of PIN processing by the Authorization System (DE48.80).'
/

alter table aup_mastercard add retrieval_ref_num varchar2(12)
/
comment on column aup_mastercard.retrieval_ref_num is 'Retrieval Reference Number (DE37).'
/
alter table aup_mastercard add tcc varchar2(1)
/
comment on column aup_mastercard.tcc is 'Transaction Category Code (DE48.1).'
/
alter table aup_mastercard add eci varchar2(3)
/
comment on column aup_mastercard.eci is 'Electronic Commerce Indicators (DE48.42).'
/
alter table aup_mastercard add ms_cmpl_stat_ind varchar2(1)
/
comment on column aup_mastercard.ms_cmpl_stat_ind IS  'Magnetic Stripe Compliance Status Indicator (DE48.88).'
/
alter table aup_mastercard add ms_cmpl_err_ind varchar2(1)
/
comment on column aup_mastercard.ms_cmpl_err_ind IS  'Magnetic Stripe Compliance Error Indicator (DE48.89).'
/
alter table aup_mastercard add fin_ntwk_code_de48_63 varchar2(3)
/
comment on column aup_mastercard.fin_ntwk_code_de48_63 IS  'Financial network code. (DE48.63.1).'
/
alter table aup_mastercard add banknet_ref_num_de48_63 varchar2(9)
/
comment on column aup_mastercard.banknet_ref_num_de48_63 IS  'Banknet reference number.(DE48.63.2).'
/
alter table aup_mastercard add sttl_date_de48_63 number(4,0)
/
comment on column aup_mastercard.sttl_date_de48_63 IS  'Settlement date of message. (DE48.63.3).'
/
alter table aup_mastercard add member_defined_data varchar2(200)
/
comment on column aup_mastercard.member_defined_data IS  'Member-defined Data. (DE124).'
/
alter table aup_mastercard add advice_reason_code number(4,0)
/
comment on column aup_mastercard.advice_reason_code IS  'Advice reason code. (DE60.1).'
/
alter table aup_mastercard add cvm varchar2(1)
/
comment on column aup_mastercard.cvm IS  'Cardholder vrification method. (DE48.20).'
/
alter table aup_mastercard add auth_code varchar2(6)
/
comment on column aup_mastercard.auth_code IS  'Authentication code. (DE38).'
/
alter table aup_mastercard add (trans_amount number(22,4), trans_fee_amount number(22,4))
/
comment on column aup_mastercard.trans_amount is 'Transaction amount (DE4)'
/
comment on column aup_mastercard.trans_fee_amount is 'Transaction fee amount (DE28)'
/
alter table aup_mastercard add txn_repl_amount NUMBER(12)
/
alter table aup_mastercard add bin_repl_amount NUMBER(12)
/
comment on column aup_mastercard.txn_repl_amount is 'Actual Amount, Transaction (DE95.1)'
/
comment on column aup_mastercard.bin_repl_amount is 'Actual Amount, Cardholder Billing (DE95.3)'
/
alter table aup_mastercard add txn_currency number(3)
/
comment on column aup_mastercard.txn_currency is 'Currency Code, Transaction (DE49)'
/
alter table aup_mastercard add bin_currency number(3)
/
comment on column aup_mastercard.bin_currency is 'Currency Code, Cardholder Billing (DE51)'
/
alter table aup_mastercard add bin_req_amount number(12)
/
comment on column aup_mastercard.bin_req_amount is 'Amount, Cardholder Billing (DE6)'
/
alter table aup_mastercard rename column trans_amount to txn_req_amount
/
alter table aup_mastercard add addr_verif_req number(2)
/
comment on column aup_mastercard.addr_verif_req is 'Address Verification Service Request Indicator (DE48.82)'
/
alter table aup_mastercard add record_data varchar2(999)
/
comment on column aup_mastercard.record_data is 'Record Data (DE120)'
/
alter table aup_mastercard modify member_defined_data varchar2(299)
/
alter table aup_mastercard add ucaf varchar2(32)
/
comment on column aup_mastercard.ucaf is 'Universal Cardholder Authentication Field (DE48.43)'
/
alter table aup_mastercard modify iso_msg_type null
/
alter table aup_mastercard modify trace null
/
alter table aup_mastercard modify trms_datetime null
/
alter table aup_mastercard modify time_mark null
/
alter table aup_mastercard modify bitmap null
/
alter table aup_mastercard add card_country_code number(3)
/
comment on column aup_mastercard.card_country_code is 'PAN Country Code (DE20)'
/
alter table aup_mastercard add on_behalf_serv varchar2(40)
/
comment on column aup_mastercard.on_behalf_serv is 'On-behalf Services (DE48.71)'
/
alter table aup_mastercard add promotion_code varchar2(6)
/
comment on column aup_mastercard.promotion_code is 'Promotion code (DE48.95)'
/
alter table aup_mastercard add orig_trms_datetime date
/
comment on column aup_mastercard.orig_trms_datetime is 'Original Transmission date and time (DE90.3)'
/
