create table rcn_cbs_msg (
    id                        number(16)
  , part_key                  as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))  -- [@skip patch]
  , recon_type                varchar2(8)
  , msg_source                varchar2(8)
  , msg_date                  date
  , oper_id                   number(16)
  , recon_msg_id              number(16)
  , recon_status              varchar2(8)
  , recon_date                date
  , recon_inst_id             number(4)
  , oper_type                 varchar2(8)
  , msg_type                  varchar2(8)
  , sttl_type                 varchar2(8)
  , oper_date                 date
  , oper_amount               number(22, 4)
  , oper_currency             varchar2(3)
  , oper_request_amount       number(22, 4)
  , oper_request_currency     varchar2(3)
  , oper_surcharge_amount     number(22, 4)
  , oper_surcharge_currency   varchar2(3)
  , originator_refnum         varchar2(36)
  , network_refnum            varchar2(36)
  , acq_inst_bin              varchar2(12)
  , status                    varchar2(8)
  , is_reversal               number(1)
  , merchant_number           varchar2(15)
  , mcc                       varchar2(4)
  , merchant_name             varchar2(200)
  , merchant_street           varchar2(200)
  , merchant_city             varchar2(200)
  , merchant_region           varchar2(3)
  , merchant_country          varchar2(3)
  , merchant_postcode         varchar2(10)
  , terminal_type             varchar2(8)
  , terminal_number           varchar2(8)
  , acq_inst_id               number(4)
  , card_mask                 varchar2(24)
  , card_seq_number           number(3)
  , card_expir_date           date
  , card_country              varchar2(3)
  , iss_inst_id               number(4)
  , auth_code                 varchar2(6)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition rcn_cbs_msg_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))     -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/
comment on table rcn_cbs_msg is 'CBS reconciliation messages'
/
comment on column rcn_cbs_msg.id is 'Record identifier'
/
comment on column rcn_cbs_msg.recon_type is 'Reconciliation type. (Dictionary "RCNT").'
/
comment on column rcn_cbs_msg.msg_source is 'Message source. (Dictionary "RMSC").'
/
comment on column rcn_cbs_msg.msg_date is 'Message date and time inserted into the table.'
/
comment on column rcn_cbs_msg.oper_id is 'Reference to operation. Not empty if a message loaded from SV operations.'
/
comment on column rcn_cbs_msg.recon_msg_id is 'Reference to reconciled message.'
/
comment on column rcn_cbs_msg.recon_status is 'Reconciliation status. (Dictionary "RNST").'
/
comment on column rcn_cbs_msg.recon_date is 'Date and time of last reconciliation process on the message.'
/
comment on column rcn_cbs_msg.recon_inst_id is 'Reconciliation institution. For multi institution reconciliation.'
/
comment on column rcn_cbs_msg.oper_type is 'Operation type. (Dictionary "OPTP").'
/
comment on column rcn_cbs_msg.msg_type is 'Message type. (Dictionary "MSGT").'
/
comment on column rcn_cbs_msg.sttl_type is 'Settlement type. (Dictionary "STTT").'
/
comment on column rcn_cbs_msg.oper_date is 'Operation date.'
/
comment on column rcn_cbs_msg.oper_amount is 'Operation amount.'
/
comment on column rcn_cbs_msg.oper_currency is 'Operation currency.'
/
comment on column rcn_cbs_msg.oper_request_amount is 'Operation requested amount.'
/
comment on column rcn_cbs_msg.oper_request_currency is 'Operation requested amount currency.'
/
comment on column rcn_cbs_msg.oper_surcharge_amount is 'Operation surcharge amount.'
/
comment on column rcn_cbs_msg.oper_surcharge_currency is 'Operation surcharge amount currency.'
/
comment on column rcn_cbs_msg.originator_refnum is 'Reference number generated by originator of operation.'
/
comment on column rcn_cbs_msg.network_refnum is 'Reference number incoming from external network.'
/
comment on column rcn_cbs_msg.acq_inst_bin is 'Acquirer BIN.'
/
comment on column rcn_cbs_msg.status is 'Authorization status. (Dictionary "OPST").'
/
comment on column rcn_cbs_msg.is_reversal is 'Reversal indicator. 0 � operation is not reversal, 1 � operation is reversal.'
/
comment on column rcn_cbs_msg.merchant_number is 'ISO Merchant number'
/
comment on column rcn_cbs_msg.mcc is 'Merchant category code (MCC)'
/
comment on column rcn_cbs_msg.merchant_name is 'Merchant name'
/
comment on column rcn_cbs_msg.merchant_street is 'Merchant street'
/
comment on column rcn_cbs_msg.merchant_city is 'Merchant city'
/
comment on column rcn_cbs_msg.merchant_region is 'Merchant region'
/
comment on column rcn_cbs_msg.merchant_country is 'Merchant country'
/
comment on column rcn_cbs_msg.merchant_postcode is 'merchant postal code'
/
comment on column rcn_cbs_msg.terminal_type is 'Terminal type. (Dictionary "TRMT").'
/
comment on column rcn_cbs_msg.terminal_number is 'ISO Terminal number'
/
comment on column rcn_cbs_msg.acq_inst_id is 'Identifier of participant acquirer.'
/
comment on column rcn_cbs_msg.card_mask is 'Card mask'
/
comment on column rcn_cbs_msg.card_seq_number is 'Card sequential number'
/
comment on column rcn_cbs_msg.card_expir_date is 'Card expiration date'
/
comment on column rcn_cbs_msg.card_country is 'Card country'
/
comment on column rcn_cbs_msg.iss_inst_id is 'Identifier of participant institution.'
/
comment on column rcn_cbs_msg.auth_code is 'Authorisation code'
/
alter table rcn_cbs_msg modify (terminal_number varchar2(16))
/

