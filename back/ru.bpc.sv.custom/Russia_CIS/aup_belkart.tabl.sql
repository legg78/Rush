create table aup_belkart (
    tech_id                 varchar2(36)
    , iso_msg_type          number(4)
    , time_mark             varchar2(16)
    , bitmap                varchar2(32)
    , resp_code             varchar2(3)
    , ntwk_man_code         number(3)
    , trace                 varchar2(6)
    , trms_datetime         date
    , host_id               number(4)
    , proc_code             varchar2(6)
    , ref_num               varchar2(12)
    , auth_id               number(16)
    , acq_inst_id           varchar2(11)
    , fwd_inst_id           varchar2(11)
    , card_num              varchar2(24)
    , req_amount            varchar2(12)
    , bill_amount           varchar2(12)
    , bill_rate             number
    , acptr_term_id         varchar2(8)
    , acptr_id              varchar2(15)
    , acptr_name_location   varchar2(99)
    , crncy_code_trns       number(3)
    , crncy_code_ch_bill    number(3)
    , dest_inst_id          varchar2(11)
    , src_inst_id           varchar2(11)
    , bill_details          varchar2(25)
    , getter_inst_id        varchar2(11)
    , account_id            varchar2(28)
    , trns_desc             varchar2(100)
    , fee_amount            varchar2(204)
    , data_record           varchar2(999)
    , part_key              as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_belkart_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on column aup_belkart.tech_id is 'Technical identifier of message'
/
comment on column aup_belkart.iso_msg_type is 'Message type defined by Belkart protocol.'
/
comment on column aup_belkart.time_mark is 'Time of processing by switch.'
/
comment on column aup_belkart.bitmap is 'Message bitmap.'
/
comment on column aup_belkart.resp_code is 'Response code'
/
comment on column aup_belkart.ntwk_man_code is 'Network management code.'
/
comment on column aup_belkart.trace is 'Trace number'
/
comment on column aup_belkart.trms_datetime is 'Transmission time'
/
comment on column aup_belkart.host_id is 'Host member id identifier for working network host.'
/
comment on column aup_belkart.proc_code is 'Processing Code'
/
comment on column aup_belkart.ref_num is 'Retrieval Reference Number'
/
comment on column aup_belkart.auth_id is 'Authentification ID'
/
comment on column aup_belkart.acq_inst_id is 'Acquiring Institution ID'
/
comment on column aup_belkart.fwd_inst_id is 'Forwarding Institution ID'
/
comment on column aup_belkart.card_num is 'Card Number'
/
comment on column aup_belkart.req_amount is 'Requested Amount'
/
comment on column aup_belkart.bill_amount is 'Cardholder Billing Amount'
/
comment on column aup_belkart.bill_rate is 'Billing Rate'
/
comment on column aup_belkart.acptr_term_id is 'Acceptor Terminal ID'
/
comment on column aup_belkart.acptr_id is 'Acceptor ID'
/
comment on column aup_belkart.acptr_name_location is 'Acceptor Name and Location'
/
comment on column aup_belkart.crncy_code_trns is 'Currency Code for Transaction'
/
comment on column aup_belkart.crncy_code_ch_bill is 'Currency Code for Card Holder Billing'
/
comment on column aup_belkart.dest_inst_id is 'Destination Institution ID'
/
comment on column aup_belkart.src_inst_id is 'Source Institution ID'
/
comment on column aup_belkart.bill_details is 'Billing Details'
/
comment on column aup_belkart.getter_inst_id is 'Getting Institution ID'
/
comment on column aup_belkart.account_id is 'Account ID'
/
comment on column aup_belkart.trns_desc is 'Transaction Description'
/
comment on column aup_belkart.fee_amount is 'Fee Amount'
/
comment on column aup_belkart.data_record is 'Data Record'
/
alter table aup_belkart add (direction number(1))
/
comment on column aup_belkart.direction is 'Direction of the message (1 - In, 0 - Out)'
/
alter table aup_belkart add (confirm_code varchar2(6))
/
comment on column aup_belkart.confirm_code is 'Confirmation Code [Fld 38]'
/

