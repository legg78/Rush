create table vis_fraud (
   id                             number(16)
 , file_id                        number(16)
 , rec_no                         number(8)
 , batch_file_id                  number(12)
 , batch_rec_no                   number(8)
 , fraud_msg_ref                  number(12)
 , reject_msg_no                  number(12)
 , dispute_id                     number(16)
 , delete_flag                    number(1)
 , is_rejected                    number(1)
 , is_incoming                    number(1)
 , status                         varchar2(8)
 , inst_id                        number(4)
 , agent_id                       number(8)
 , dest_bin                       varchar2(6)
 , source_bin                     varchar2(6)
 , account_number                 varchar2(32)
 , arn                            varchar2(23)
 , acq_business_id                varchar2(8)
 , response_code                  varchar2(2)
 , purchase_date                  date
 , mcc                            varchar2(4)
 , state_province                 varchar2(3)
 , fraud_amount                   number(12)
 , fraud_currency                 varchar2(3)
 , vic_processing_date            date
 , iss_gen_auth                   varchar2(8)
 , notification_code              varchar2(8)
 , account_seq_number             varchar2(4)
 , fraud_type                     varchar2(8)
 , card_expir_date                varchar2(4)
 , fraud_inv_status               varchar2(2)
 , reimburst_attr                 varchar2(1)
 , addendum_present               number(1)
 , transaction_id                 varchar2(15)
 , excluded_trans_id_reason       varchar2(1)
 , multiple_clearing_seqn         varchar2(2)
 , merchant_number                varchar2(15)
 , merchant_name                  varchar2(25)
 , merchant_city                  varchar2(13)
 , merchant_country               varchar2(3)
 , merchant_postal_code           varchar2(10)
 , terminal_number                varchar2(8)
 , travel_agency_id               varchar2(8)
 , auth_code                      varchar2(6)
 , crdh_id_method                 number(1)
 , pos_entry_mode                 varchar2(2)
 , pos_terminal_cap               varchar2(8)
 , card_capability                varchar2(1)
 , crdh_activated_term_ind        varchar2(1)
 , electr_comm_ind                varchar2(1)
 , iss_inst_id                    number(4)   
 , acq_inst_id                    number(4)     
 , cashback_ind                   varchar2(1)
 , cashback                       varchar2(9)
 , last_update                    date
 , reserved                       varchar2(1)
)
/

comment on table vis_fraud is 'VISA Fraud reporting system support table. It holds incoming/outgoing TC40 transactions TCR0 and TCR2.'
/
comment on column vis_fraud.id is 'Primary Key.'
/
comment on column vis_fraud.file_id is 'Reference to clearing file.'
/
comment on column vis_fraud.rec_no  is 'Number of record in clearing file.'
/
comment on column vis_fraud.batch_file_id is 'Identifier of batch in clearing file.'
/
comment on column vis_fraud.batch_rec_no  is 'Number of record in batch.'
/
comment on column vis_fraud.fraud_msg_ref is ''
/
comment on column vis_fraud.reject_msg_no is 'Number of the corresponding VISA Rejection Message (field BO_UTRNNO at VISA_REJECT table)'
/
comment on column vis_fraud.dispute_id    is 'Reference to the dispute message group.'
/
comment on column vis_fraud.delete_flag   is 'Delete Flag. 0 - actual record, 1 - the record marked for delete, 2 - delete and rollback.'
/
comment on column vis_fraud.is_rejected   is '1 for rejected messages, else 0.'
/
comment on column vis_fraud.is_incoming   is 'Incoming/Outgouing message flag. 1- incoming, 0- outgoing.'
/
comment on column vis_fraud.status        is 'Message status.'
/
comment on column vis_fraud.inst_id       is 'Institution identifier.'
/
comment on column vis_fraud.agent_id      is 'Agent Institution identifier.'
/
comment on column vis_fraud.dest_bin      is 'Destination BIN. Always required. Always 400050 for outgoing files.'
/
comment on column vis_fraud.source_bin    is 'Source BIN. Always required.'
/
comment on column vis_fraud.account_number  is 'Account Number (PAN). Always required'
/
comment on column vis_fraud.arn             is 'Acquiring reference number.'
/
comment on column vis_fraud.acq_business_id is 'Acquirer business identifier.'
/
comment on column vis_fraud.response_code   is 'Response Code. Empty for outgoing message.'
/
comment on column vis_fraud.purchase_date   is 'Purchase Date.'
/
comment on column vis_fraud.mcc             is 'Merchant category code.'
/
comment on column vis_fraud.state_province  is 'Merchant State/Province Code. Otherwise spaces.'
/
comment on column vis_fraud.fraud_amount    is 'Source Amount.'
/
comment on column vis_fraud.fraud_currency  is 'Source Currency Code.'
/
comment on column vis_fraud.vic_processing_date is 'VIC Processing Date. Data Source TC 05/07 TCR0 Pos 164-167 Central Processing Date.'
/
comment on column vis_fraud.iss_gen_auth        is 'Issuer Generated Authorization.  Data source: member. Valid values: Y - Issuer authorized transaction; X - Transaction authorized but not by issuer; N - transaction not authorized. NULL value if no data.'
/
comment on column vis_fraud.notification_code   is 'Notification Code. Always required. Data source: member. Valid values: 1 - addition; 2 - addition of subsequent identical (duplicate) transaction; 3 - change; 4 - delete; 5 - reactivate.'
/
comment on column vis_fraud.account_seq_number  is 'Account Sequence Number. Data surce: member'
/
comment on column vis_fraud.fraud_type          is 'Fraud Type'
/
comment on column vis_fraud.card_expir_date     is 'Card expiration date. (YYMM)'
/
comment on column vis_fraud.fraud_inv_status    is 'Fraud Investigative Status.'
/
comment on column vis_fraud.reimburst_attr      is 'Reimbursement attribute.'
/
comment on column vis_fraud.addendum_present    is 'Addendum Present. 1 if TCR2 data present, else 0.'
/
comment on column vis_fraud.transaction_id      is 'Transaction Identifier'
/
comment on column vis_fraud.excluded_trans_id_reason  is 'Excluded Transaction Identifier Reason'
/
comment on column vis_fraud.multiple_clearing_seqn    is 'Multiple Clearing Sequence Number'
/
comment on column vis_fraud.merchant_number           is 'Card Acceptor ID (Merchant ISO number).'
/
comment on column vis_fraud.merchant_name             is 'Merchant name.'
/
comment on column vis_fraud.merchant_city             is 'Merchant city.'
/
comment on column vis_fraud.merchant_country          is 'Merchant country code (3 digits ISO code).'
/
comment on column vis_fraud.merchant_postal_code      is 'Merchant postal code.'
/
comment on column vis_fraud.terminal_number           is 'Terminal ISO ID.'
/
comment on column vis_fraud.travel_agency_id          is 'Travel Agency ID. Data Source TC 05/07 TCR3 Pos 84-91.'
/
comment on column vis_fraud.auth_code                 is 'Authorization code.'
/
comment on column vis_fraud.crdh_id_method            is 'Cardholder ID method.'
/
comment on column vis_fraud.pos_entry_mode            is 'POS entry mode.'
/
comment on column vis_fraud.pos_terminal_cap          is 'POS terminal capability.'
/
comment on column vis_fraud.card_capability           is 'Card Capability.'
/
comment on column vis_fraud.crdh_activated_term_ind   is 'Cardholder Activated Terminal Indicator. Data Source TC 05/07 TCR1 Pos 124.'
/
comment on column vis_fraud.electr_comm_ind    is 'Mail/Telephone or Electronic commerce Indicator.'
/
comment on column vis_fraud.iss_inst_id        is 'ID of the issuing financial institution the record belongs to. '
/
comment on column vis_fraud.acq_inst_id        is 'ID of the acquiring financial institution the record belongs to.'
/
comment on column vis_fraud.cashback_ind       is 'Cashback Indicator: Y - cashback, N - no cashback. May be spaces. Data Source shown as TC 05/07 TCR1 Pos 158-166, it is cashback amount, may be <> 0?.'
/
comment on column vis_fraud.cashback           is 'Cashback.'
/
comment on column vis_fraud.last_update        is 'Date of last update.'
/
comment on column vis_fraud.reserved           is 'Reserved. Position 150 length 1. To designate to the Fraud Reporting System that the fraud transaction is a Convenience Check, this field must contain "C", else space.'
/
alter table vis_fraud modify crdh_id_method varchar2(1)
/
alter table vis_fraud add (agent_unique_id varchar2(5))
/
comment on column vis_fraud.agent_unique_id    is 'Agent Unique ID'
/
alter table vis_fraud add (payment_account_ref varchar2(29))
/
comment on column vis_fraud.payment_account_ref is 'Payment Account Reference'
/
alter table vis_fraud add (network_id number(4))
/
comment on column vis_fraud.network_id          is 'Payment network identifier'
/
alter table vis_fraud add (host_inst_id number(4))
/
comment on column vis_fraud.host_inst_id        is 'Host institution identifier'
/
alter table vis_fraud add (proc_bin varchar2(6))
/
comment on column vis_fraud.proc_bin            is 'Processing BIN'
/
