create table opr_operation (
    id                          number(16)
    , part_key                  as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))  -- [@skip patch]
    , session_id                number(16)
    , is_reversal               number(1)
    , original_id               number(16)
    , oper_type                 varchar2(8)
    , oper_reason               varchar2(8)
    , msg_type                  varchar2(8)
    , status                    varchar2(8)
    , status_reason             varchar2(8)
    , sttl_type                 varchar2(8)
    , terminal_type             varchar2(8)
    , acq_inst_bin              varchar2(12)
    , forw_inst_bin             varchar2(12)
    , merchant_number           varchar2(15)
    , terminal_number           varchar2(8)
    , merchant_name             varchar2(200)
    , merchant_street           varchar2(200)
    , merchant_city             varchar2(200)
    , merchant_region           varchar2(3)
    , merchant_country          varchar2(3)
    , merchant_postcode         varchar2(10)
    , mcc                       varchar2(4)
    , originator_refnum         varchar2(36)
    , network_refnum            varchar2(36)
    , oper_count                number(16)
    , oper_request_amount       number(22,4)
    , oper_amount_algorithm     varchar2(8)
    , oper_amount               number(22,4)
    , oper_currency             varchar2(3)
    , oper_cashback_amount      number(22,4)
    , oper_replacement_amount   number(22,4)
    , oper_surcharge_amount     number(22,4)
    , oper_date                 date
    , host_date                 date
    , unhold_date               date
    , match_status              varchar2(8)
    , sttl_amount               number(22, 4)
    , sttl_currency             varchar2(3)
    , dispute_id                number(16)
    , payment_order_id          number(16)
    , payment_host_id           number(4)
    , forced_processing         number(1)
    , match_id                  number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition opr_operation_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/
comment on table opr_operation is 'Operations list'
/
comment on column opr_operation.id is 'Record identifier'
/
comment on column opr_operation.session_id is 'Identifier of session which message was created'
/
comment on column opr_operation.is_reversal is 'Reversal indicator'
/
comment on column opr_operation.original_id is 'Reference to original operation in case of reversal'
/
comment on column opr_operation.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column opr_operation.oper_reason is 'Operation reason (fee type or adjustment type)'
/
comment on column opr_operation.msg_type is 'Message type (MSGT dictionary)'
/
comment on column opr_operation.status is 'Authorisation status (OPST dictionary)'
/
comment on column opr_operation.status_reason is 'Authorisation status reason (OPSR dictionary)'
/
comment on column opr_operation.sttl_type is 'Settlement type (STTT dictionary)'
/
comment on column opr_operation.terminal_type is 'Terminal type (TRMT dictionary)'
/
comment on column opr_operation.acq_inst_bin is 'Acquirer institution BIN'
/
comment on column opr_operation.forw_inst_bin is 'Forwarding institution BIN'
/
comment on column opr_operation.merchant_number is 'ISO Merchant number'
/
comment on column opr_operation.terminal_number is 'ISO Terminal number'
/
comment on column opr_operation.merchant_name is 'Merchant name'
/
comment on column opr_operation.merchant_street is 'Merchant street'
/
comment on column opr_operation.merchant_city is 'Merchant city'
/
comment on column opr_operation.merchant_region is 'Merchant region'
/
comment on column opr_operation.merchant_country is 'Merchant country'
/
comment on column opr_operation.merchant_postcode is 'merchant postal code'
/
comment on column opr_operation.mcc is 'Merchant category code (MCC)'
/
comment on column opr_operation.originator_refnum is 'Reference number generated by originator of operation'
/
comment on column opr_operation.network_refnum is 'Reference number to send to the network'
/
comment on column opr_operation.oper_count is 'Operation count'
/
comment on column opr_operation.oper_request_amount is 'Operation requested amount in operation currency'
/
comment on column opr_operation.oper_amount_algorithm is 'Operation amount algorithm'
/
comment on column opr_operation.oper_amount is 'Operation amount  in operation currency'
/
comment on column opr_operation.oper_currency is 'Operation currency'
/
comment on column opr_operation.oper_cashback_amount is 'Cashback amount  in operation currency'
/
comment on column opr_operation.oper_replacement_amount is 'Replacement amount  in operation currency (in case of reversal)'
/
comment on column opr_operation.oper_surcharge_amount is 'Surcharge amount  in operation currency'
/
comment on column opr_operation.oper_date is 'Operation date (local device date)'
/
comment on column opr_operation.host_date is 'Source system date (host date)'
/
comment on column opr_operation.match_status is 'Status of matching on this operation (MTST dictionary)'
/
comment on column opr_operation.sttl_amount is 'Settlement amount'
/
comment on column opr_operation.sttl_currency is 'Settlement currency'
/
comment on column opr_operation.dispute_id is 'Identifier of dispute which message involved in'
/
comment on column opr_operation.payment_order_id is 'Identifier of payment order'
/
comment on column opr_operation.payment_host_id is 'Host using as gateway to implement payment order.'
/
comment on column opr_operation.forced_processing is 'Indicator which shows necessity to process operations in case operator decision is required due to response code'
/
comment on column opr_operation.unhold_date is 'Date when authorization should be automatically unholded'
/
comment on column opr_operation.match_id is 'Link between authorizations and presentment.'
/
alter table opr_operation add proc_mode varchar2(8)
/
comment on column opr_operation.proc_mode is 'Mode of authorisation processing (AUPM dictionary)'
/

alter table opr_operation add (clearing_sequence_num  number(2))
/
alter table opr_operation add (clearing_sequence_count  number(2))
/
comment on column opr_operation.clearing_sequence_num is 'Multiple Clearing Sequence Number'
/
comment on column opr_operation.clearing_sequence_count is 'Multiple Clearing Sequence Count'
/
alter table opr_operation modify terminal_number varchar2(16)
/
alter table opr_operation add (incom_sess_file_id  number(16))
/
comment on column opr_operation.incom_sess_file_id is 'Reference to the incoming file from which the operation was created'
/
alter table opr_operation add (fee_amount  number(22,4))
/
alter table opr_operation add (fee_currency  varchar2(3))
/
comment on column opr_operation.fee_amount is 'Interchange fee amount'
/
comment on column opr_operation.fee_currency is 'Interchange fee currency'
/
alter table opr_operation add (sttl_date date)
/
comment on column opr_operation.sttl_date is 'Settlement date'
/
alter table opr_operation add (acq_sttl_date date)
/
comment on column opr_operation.acq_sttl_date is 'Settlement date on the acquirer side - for them-on-them operations in switching solutions'
/
alter table opr_operation add (total_amount number(22,4))
/
comment on column opr_operation.total_amount is 'Total amount of Incremental Preauthorization Transactions'
/
