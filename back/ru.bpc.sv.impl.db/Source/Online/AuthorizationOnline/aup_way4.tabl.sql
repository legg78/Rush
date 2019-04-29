create table aup_way4 (
    auth_id          number(16)
    , part_key       as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id        varchar2(36)
    , iso_msg_type   number(4)
    , bitmap         varchar2(32)
    , time_mark      varchar2(16)
    , acq_inst_bin   varchar2(11)
    , refnum         varchar2(12)
    , resp_code      varchar2(2)
    , trms_date_time date
    , trace          varchar2(6)
    , forw_inst_bin  varchar2(11)
    , host_id        number(4)
    , original_data  varchar2(42)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_way4_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))         -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_way4 is 'Table is intended to store messages between WAY4 host and switch. Only financial messages are stored.'
/
comment on column aup_way4.acq_inst_bin is 'Acquiring institution identifier inside network (field 32).'
/
comment on column aup_way4.auth_id is 'Identifier of authorization to which message belongs.'
/
comment on column aup_way4.bitmap is 'Message bitmap.'
/
comment on column aup_way4.forw_inst_bin is 'Forwarding institution identifier inside network (field 33).'
/
comment on column aup_way4.iso_msg_type is 'ISO8583 message type.'
/
comment on column aup_way4.refnum is 'RRN value (field 37).'
/
comment on column aup_way4.resp_code is 'Response code (field 39).'
/
comment on column aup_way4.tech_id is 'Technical system identifier of message.'
/
comment on column aup_way4.time_mark is 'Time point at which message was saved. It is used to reveal message order.'
/
comment on column aup_way4.trace is 'Trace value for message (field 11).'
/
comment on column aup_way4.trms_date_time is 'Message transmission date and time (field 7).'
/
comment on column aup_way4.host_id is 'Host member id identifier for working network host.'
/
comment on column aup_way4.original_data is 'Original Data Elements (field 90)'
/

alter table aup_way4 add de47_bitmap varchar2(32)
/
alter table aup_way4 add txn_src_channel varchar2(1)
/
comment on column aup_way4.de47_bitmap is 'Field 47 bitmap.'
/
comment on column aup_way4.txn_src_channel is 'Operation source channel identifier.'
/
alter table aup_way4 add req_amount number(22,4)
/
alter table aup_way4 add sttl_amount number(22,4)
/
alter table aup_way4 add billing_amount number(22,4)
/
comment on column aup_way4.req_amount is 'Actual Amount, Transaction (field 95.1)'
/
comment on column aup_way4.sttl_amount is 'Actual Amount, Settlement (field 95.2)'
/
comment on column aup_way4.billing_amount is 'Actual Amount, Cardholder Billing (field 95.3)'
/
alter table aup_way4 add country varchar2(3)
/
comment on column aup_way4.country is 'Country code'
/
alter table aup_way4 add (trans_amount number(22,4), trans_fee_amount number(22,4))
/
comment on column aup_way4.trans_amount is 'Transaction amount (Field 4)'
/
comment on column aup_way4.trans_fee_amount is 'Transaction fee amount (Field 28)'
/
alter table aup_way4 add (txn_currency number(3), bin_req_amount number(12), bin_currency number(3))
/
comment on column aup_way4.txn_currency is 'Currency Code, Transaction (DE49)'
/
comment on column aup_way4.bin_req_amount is 'Amount, Cardholder Billing (DE6)'
/
comment on column aup_way4.bin_currency is 'Currency Code, Cardholder Billing (DE51)'
/
alter table aup_way4 add payment_trx_type varchar2(3)
/
comment on column aup_way4.payment_trx_type is 'MasterCard Payment Transaction Type Indicator (DE48 PDS77)'
/
alter table aup_way4 add auth_id_resp varchar2(6)
/
comment on column aup_way4.auth_id_resp is 'Authorisation Identification Response (DE38)'
/
alter table aup_way4 add ext_ntwk_ref varchar2(15)
/
comment on column aup_way4.ext_ntwk_ref is 'External Network Reference (DE47 TAG925)'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'AUP_WAY4' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table aup_way4 add (part_key as (to_date(substr(lpad(to_char(auth_id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column aup_way4.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
