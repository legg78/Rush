create table cmp_fin_message (
    id                           number(16) not null
    , part_key                   as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
    , mtid                       number(4)
    , file_id                    number(16)
    , inst_id                    number(4)
    , network_id                 number(4)
    , host_inst_id               number(4)
    , msg_number                 number(8)
    , is_reversal                number(1)
    , is_incoming                number(1)
    , is_rejected                number(1)
    , is_invalid                 number(1)
    , card_id                    number(12)
    , card_mask                  varchar2(24)
    , card_hash                  number(12)
    , tran_code                  varchar2(4)
    , conversion_rate            number(1)
    , ext_stan                   varchar2(6)
    , orig_time                  date
    , capability                 varchar2(12)
    , tran_type                  varchar2(4)
    , tran_class                 varchar2(3)
    , term_class                 varchar2(3)
    , mcc                        varchar2(4)
    , arn                        varchar2(23)
    , ext_fid                    varchar2(11)
    , tran_number                varchar2(36)
    , approval_code              varchar2(8)
    , term_name                  varchar2(16)
    , term_retailer_name         varchar2(16)
    , ext_term_retailer_name     varchar2(16)
    , term_city                  varchar2(200)
    , term_location              varchar2(50)
    , term_owner                 varchar2(90)
    , term_country               varchar2(3)
    , term_zip                   varchar2(10)
    , exp_date                   varchar2(6)
    , amount                     number(12)
    , reconcil_amount            number(12)
    , orig_amount                number(12)
    , currency                   varchar2(3)
    , reconcil_currency          varchar2(3)
    , orig_currency              varchar2(3)
    , pay_amount                 number(12)
    , pay_currency               varchar2(3)
    , term_inst_id               varchar2 (11)
    , status                     varchar2(8)
    , network                    varchar2(2)
    , host_net_id                varchar2(4)
    , ext_tran_attr              varchar2(1000)
    , term_inst_country          varchar2(3)
    , pos_condition              varchar2(9)
    , pos_entry_mode             varchar2(3)
    , pin_presence               number(1)
    , term_entry_caps            varchar2(9)
    , host_time                  date
    , ext_ps_fields              varchar2(1000)
    , term_contactless_capable   varchar2(1)
    , final_rrn                  varchar2(36)
    , from_acct_type             varchar2(2)
    , aid                        varchar2(6)
    , orig_fi_name               varchar2(100)
    , dest_fi_name               varchar2(100)
    , clear_date                 date
    , card_member                varchar2(3)
    , icc_term_caps              varchar2(9)
    , icc_tvr                    varchar2(10)
    , icc_random                 varchar2(8)
    , icc_term_sn                varchar2(8)
    , icc_issuer_data            varchar2(64)
    , icc_cryptogram             varchar2(16)
    , icc_app_tran_count         varchar2(10)
    , icc_term_tran_count        varchar2(10)
    , icc_app_profile            varchar2(9)
    , icc_iad                    varchar2(32)
    , icc_tran_type              varchar2(2)
    , icc_term_country           varchar2(9)
    , icc_tran_date              date
    , icc_amount                 varchar2(12)
    , icc_currency               varchar2(9)
    , icc_cb_amount              varchar2(12)
    , icc_crypt_inform_data      varchar2(9)
    , icc_cvm_res                varchar2(9)
    , icc_card_member            varchar2(9)
    , emv_data_exists            number(1)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition cmp_fin_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))            -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table cmp_fin_message is 'Compass Plus financial mesages(1240 first presentment)'
/

comment on column cmp_fin_message.id is 'Primary key. Message identifier'
/
comment on column cmp_fin_message.mtid is 'Message type'
/
comment on column cmp_fin_message.file_id is 'Reference to clearing file'
/
comment on column cmp_fin_message.inst_id is 'Institution identifier'
/
comment on column cmp_fin_message.network_id is 'Network identifier'
/
comment on column cmp_fin_message.host_inst_id is 'Host identifier'
/
comment on column cmp_fin_message.msg_number is 'Message Number'
/
comment on column cmp_fin_message.is_reversal is 'Reversal indicator'
/
comment on column cmp_fin_message.is_incoming is '0 - incoming file, 1 � outgoing file'
/
comment on column cmp_fin_message.is_incoming is '1 � rejected message'
/
comment on column cmp_fin_message.is_invalid is '1 � invalid message'
/
comment on column cmp_fin_message.tran_code is 'Transaction code'
/
comment on column cmp_fin_message.conversion_rate is 'Rate'
/
comment on column cmp_fin_message.ext_stan is 'System Trace Audit Number'
/
comment on column cmp_fin_message.orig_time is 'Date and time of initiation of the transaction sender'
/
comment on column cmp_fin_message.tran_type is 'Type of transaction'
/
comment on column cmp_fin_message.term_class is 'Class terminal 1 � ATM; 2 � POS; 3 � CRT; 4 � VTBI'
/
comment on column cmp_fin_message.tran_class is 'Class transaction 1 � ATM; 2 � POS; 3 � CRT; 4 � VTBI'
/
comment on column cmp_fin_message.mcc is 'Mcc'
/
comment on column cmp_fin_message.arn is 'Acquirer Reference Number'
/
comment on column cmp_fin_message.ext_fid is 'Forwarding Institution ID'
/
comment on column cmp_fin_message.tran_number is 'Transaction number'
/
comment on column cmp_fin_message.approval_code is 'Approval code'
/
comment on column cmp_fin_message.term_name is 'Name (number) terminal'
/
comment on column cmp_fin_message.term_retailer_name is 'Merchant ID-owner of the terminal'
/
comment on column cmp_fin_message.ext_term_retailer_name is 'Merchant ID-owner of the terminal to transmit'
/
comment on column cmp_fin_message.term_city is 'City ??terminal'
/
comment on column cmp_fin_message.term_location is 'Location'
/
comment on column cmp_fin_message.term_owner is 'Owner of the terminal'
/
comment on column cmp_fin_message.term_country is 'Country terminal'
/
comment on column cmp_fin_message.term_zip is 'Postcode'
/
comment on column cmp_fin_message.exp_date is 'Expiration date'
/
comment on column cmp_fin_message.amount is 'Transaction amount in currency clearing bank'
/
comment on column cmp_fin_message.orig_amount is 'The original amount of the transaction'
/
comment on column cmp_fin_message.currency is 'Transaction currency'
/
comment on column cmp_fin_message.orig_currency is 'Original transaction currency'
/
comment on column cmp_fin_message.term_inst_id is 'Institution acquirer'
/
comment on column cmp_fin_message.status is 'Status messages'
/
comment on column cmp_fin_message.is_rejected is 'Rejected indicator'
/
comment on column cmp_fin_message.card_id is 'Reference to card dictionary.'
/
comment on column cmp_fin_message.card_mask is 'Masked card number'
/
comment on column cmp_fin_message.card_hash is 'Card number hash value'
/
comment on column cmp_fin_message.network is 'Network'
/
comment on column cmp_fin_message.host_net_id is 'Id network host'
/
comment on column cmp_fin_message.ext_tran_attr is 'Additional transaction attributes for the external network'
/
comment on column cmp_fin_message.term_inst_country is 'Country acquirer'
/
comment on column cmp_fin_message.pos_condition is 'POS Condition Code'
/
comment on column cmp_fin_message.pos_entry_mode is 'POS Entry Mode'
/
comment on column cmp_fin_message.pin_presence is 'Transaction with PIN'
/
comment on column cmp_fin_message.term_entry_caps is 'Terminal Card Data Entry Capabilities'
/
comment on column cmp_fin_message.host_time is 'Date and time of the transaction in the time zone of the host'
/
comment on column cmp_fin_message.ext_ps_fields is 'Information about ISO-message fields'
/
comment on column cmp_fin_message.term_contactless_capable is 'Features contactless card reader'
/
comment on column cmp_fin_message.final_rrn is 'Final RRN'
/
comment on column cmp_fin_message.from_acct_type is 'Account type source: 0 - None, 1 - Checking, Savings-11, 31 - Credit, 91 - Bonus'
/
comment on column cmp_fin_message.aid is 'Acquirer identifier'
/
comment on column cmp_fin_message.orig_fi_name is 'Institution name source in association'
/
comment on column cmp_fin_message.dest_fi_name is 'Name of the recipient institution in association'
/
comment on column cmp_fin_message.clear_date is 'Operating day clearing'
/
comment on column cmp_fin_message.card_member is 'Cardholder number'
/
comment on column cmp_fin_message.icc_term_caps is 'Terminal capabilities bitmap'
/
comment on column cmp_fin_message.icc_tvr is 'Terminal verification results bitmap'
/
comment on column cmp_fin_message.icc_random is 'Unpredictable number'
/
comment on column cmp_fin_message.icc_term_sn is 'Terminal serial number'
/
comment on column cmp_fin_message.icc_issuer_data is 'Issuer discretionary data'
/
comment on column cmp_fin_message.icc_cryptogram is 'Cryptogram (ARQC or TC or AAC)'
/
comment on column cmp_fin_message.icc_app_tran_count is 'Application transaction counter (ATC)'
/
comment on column cmp_fin_message.icc_term_tran_count is 'Terminal transaction counter'
/
comment on column cmp_fin_message.icc_app_profile is 'Application interchange profile bitmap'
/
comment on column cmp_fin_message.icc_iad is 'Issuer authentication data'
/
comment on column cmp_fin_message.icc_tran_type is 'Transaction type (first 2 digits of processing code) as used in cryptogram'
/
comment on column cmp_fin_message.icc_term_country is 'Terminal country code, as used in cryptogram'
/
comment on column cmp_fin_message.icc_tran_date is 'Terminal transaction date, as used in cryptogram'
/
comment on column cmp_fin_message.icc_amount is 'Currency code, as used in cryptogram'
/
comment on column cmp_fin_message.icc_currency is 'Transaction amount, as used in cryptogram'
/
comment on column cmp_fin_message.icc_cb_amount is 'Transaction cash back amount, as used in cryptogram'
/
comment on column cmp_fin_message.icc_crypt_inform_data is 'Cryptogram Information Data'
/
comment on column cmp_fin_message.icc_cvm_res is 'Cardholder Verification Method Result'
/
comment on column cmp_fin_message.icc_card_member is 'PAN Sequence Number, EMV Tag 5F34'
/
comment on column cmp_fin_message.emv_data_exists is '1 - EMV data exists in auth, 0 - EMV data is null'
/

alter table cmp_fin_message add (collect_only_flag varchar2(1))
/
comment on column cmp_fin_message.collect_only_flag is 'Collection-only flag.'
/

alter table cmp_fin_message drop column mtid
/

comment on column cmp_fin_message.is_incoming is '0 - incoming message, 1 - outgoing message'
/
comment on column cmp_fin_message.is_rejected is 'Rejected indicator'
/
comment on column cmp_fin_message.is_invalid is '1 - invalid message'
/
comment on column cmp_fin_message.term_city is 'City of terminal'
/
comment on column cmp_fin_message.term_class is 'Class terminal 1 - ATM; 2 - POS; 3 - CRT; 4 - VTBI'
/
comment on column cmp_fin_message.tran_class is 'Class transaction 1 - ATM; 2 - POS; 3 - CRT; 4 - VTBI'
/
comment on column cmp_fin_message.mcc is 'MCC'
/
comment on column cmp_fin_message.reconcil_amount is 'Reconcillation amount'
/
comment on column cmp_fin_message.reconcil_currency is 'Reconcillation currency'
/
comment on column cmp_fin_message.collect_only_flag is 'Collection-only flag'
/
comment on column cmp_fin_message.card_id is 'Reference to card dictionary'
/
comment on column cmp_fin_message.is_incoming is 'Incoming/Outgouing message flag 1- incoming, 0- outgoing'
/
comment on column cmp_fin_message.is_invalid is 'Is financial message loaded with errors'
/

alter table cmp_fin_message add (icc_respcode varchar2(2))
/
comment on column cmp_fin_message.icc_respcode is 'Response code.'
/
alter table cmp_fin_message add (service_code varchar2(3))
/
comment on column cmp_fin_message.service_code is 'Card service code.'
/
alter table cmp_fin_message modify ext_ps_fields varchar2(4000)
/
alter table cmp_fin_message modify ext_ps_fields varchar2(2000)
/
comment on column cmp_fin_message.pay_amount is 'Destination Amount in Billing Currency'
/
comment on column cmp_fin_message.pay_currency is '3 - digit Destination Currency ISO alpha code'
/
