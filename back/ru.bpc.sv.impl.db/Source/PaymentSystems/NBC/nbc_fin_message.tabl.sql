create table nbc_fin_message(
    id                      number(16)
  , split_hash              number(4)  
  , status                  varchar2(8)
  , mti                     varchar2(4)
  , file_id                 number(16)
  , record_number           number(8)
  , is_reversal             number(1)
  , is_incoming             number(1)
  , is_invalid              number(1)
  , original_id             number(16)
  , dispute_id              number(16)
  , inst_id                 number(4)
  , network_id              number(4)
  , msg_file_type           varchar2(2)
  , participant_type        varchar2(3)  
  , record_type             varchar2(4)
  , card_mask               varchar2(19) --card_number
  , card_hash               number(12)
  , proc_code               varchar2(6)
  , nbc_resp_code           varchar2(2)
  , acq_resp_code           varchar2(2)
  , iss_resp_code           varchar2(2)
  , bnb_resp_code           varchar2(2)
  , dispute_trans_result    varchar2(2)    
  , trans_amount            number(22,4)
  , sttl_amount             number(22,4)
  , crdh_bill_amount        number(22,4)
  , crdh_bill_fee           number(22,4)
  , settl_rate              number(22,4)
  , crdh_bill_rate          number(22,4)
  , system_trace_number     varchar2(6)
  , local_trans_time        varchar2(6)
  , local_trans_date        date
  , settlement_date         date
  , merchant_type           varchar2(4) --mcc
  , trans_fee_amount        number(22,4)
  , acq_inst_code           varchar2(7)
  , iss_inst_code           varchar2(7)
  , bnb_inst_code           varchar2(7)
  , rrn                     varchar2(12)
  , auth_number             varchar2(6)
  , resp_code               varchar2(2)
  , terminal_id             varchar2(8)
  , trans_currency          varchar2(3)
  , settl_currency          varchar2(3)
  , crdh_bill_currency      varchar2(3)
  , from_account_id         varchar2(28)
  , to_account_id           varchar2(28)
  , nbc_fee                 number(22,4)
  , acq_fee                 number(22,4)
  , iss_fee                 number(22,4)
  , bnb_fee                 number(22,4)
)
/

comment on table nbc_fin_message is 'NBC financial mesages'
/
comment on column nbc_fin_message.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table'
/
comment on column nbc_fin_message.split_hash is 'Hash value to split further processing'
/
comment on column nbc_fin_message.status is 'Message status'
/
comment on column nbc_fin_message.mti is 'The Message Type Identifier'
/
comment on column nbc_fin_message.file_id is 'Reference to clearing file'
/
comment on column nbc_fin_message.record_number is 'Number of record in clearing file'
/
comment on column nbc_fin_message.is_reversal is 'Reversal flag'
/
comment on column nbc_fin_message.is_incoming is 'Incoming/Outgouing message flag. 1- incoming, 0- outgoing'
/
comment on column nbc_fin_message.is_invalid is 'Is financial message loaded with errors'
/
comment on column nbc_fin_message.original_id is 'Reference to original operation'
/
comment on column nbc_fin_message.dispute_id is 'Reference to the dispute message group'
/
comment on column nbc_fin_message.inst_id is 'Institution identifier'
/
comment on column nbc_fin_message.network_id is 'Payment network identifier'
/
comment on column nbc_fin_message.msg_file_type is 'Type of file: RF/DF'
/
comment on column nbc_fin_message.participant_type is 'Participant type: ISS/ACQ/BNB'
/
comment on column nbc_fin_message.record_type is 'Indicates the type of record'
/
comment on column nbc_fin_message.card_mask is 'Masked card number'
/
comment on column nbc_fin_message.card_hash is 'Card number hash value'
/
comment on column nbc_fin_message.proc_code is 'Processing code of the transaction'
/
comment on column nbc_fin_message.nbc_resp_code is 'NBC Response Code'
/
comment on column nbc_fin_message.acq_resp_code is 'Get from RF of Acquirer Bank'
/
comment on column nbc_fin_message.iss_resp_code is 'Get from RF of Issuer Bank'
/
comment on column nbc_fin_message.bnb_resp_code is 'Get from RF of Beneficiary Bank'
/
comment on column nbc_fin_message.dispute_trans_result is 'Dispute transaction Result from ISS'
/
comment on column nbc_fin_message.trans_amount is 'Transaction Amount'
/
comment on column nbc_fin_message.sttl_amount is 'Settlement Amount'
/
comment on column nbc_fin_message.crdh_bill_amount is 'Cardholder Billing Amount'
/
comment on column nbc_fin_message.crdh_bill_fee is 'Cardholder Billing Fee'
/
comment on column nbc_fin_message.settl_rate is 'Settlement Conversion Rate'
/
comment on column nbc_fin_message.crdh_bill_rate is 'Cardholder Billing Conversion Rate'
/
comment on column nbc_fin_message.system_trace_number is 'System Trace Number'
/
comment on column nbc_fin_message.local_trans_time is 'Local Transaction Time'
/
comment on column nbc_fin_message.local_trans_date is 'Local Transaction Date'
/
comment on column nbc_fin_message.settlement_date is 'Settlement Date'
/
comment on column nbc_fin_message.merchant_type is 'Merchant Type. ATM transaction – 6011, POS transaction - 6012'
/
comment on column nbc_fin_message.trans_fee_amount is 'Transaction Amount Fee'
/
comment on column nbc_fin_message.acq_inst_code is 'Acquiring Institution Code'
/
comment on column nbc_fin_message.iss_inst_code is 'Issuer Institution Code'
/
comment on column nbc_fin_message.bnb_inst_code is 'Beneficiary Institution Code'
/
comment on column nbc_fin_message.rrn is 'Retrieval Reference Number'
/
comment on column nbc_fin_message.auth_number is 'Authorization Number'
/
comment on column nbc_fin_message.resp_code is 'Response Code'
/
comment on column nbc_fin_message.terminal_id is 'Card Acceptor Terminal Identification'
/
comment on column nbc_fin_message.trans_currency is 'Transaction Currency Code'
/
comment on column nbc_fin_message.settl_currency is 'Settlement Currency Code'
/
comment on column nbc_fin_message.crdh_bill_currency is 'Cardholder Billing Currency Code'
/
comment on column nbc_fin_message.from_account_id is 'From Account Identification'
/
comment on column nbc_fin_message.to_account_id is 'To Account Identification'
/
comment on column nbc_fin_message.nbc_fee is 'NBC Fee'
/
comment on column nbc_fin_message.acq_fee is 'Acquirer Fee'
/
comment on column nbc_fin_message.iss_fee is 'Issuer Fee'
/
comment on column nbc_fin_message.bnb_fee is 'Beneficiary Fee'
/

alter table nbc_fin_message add (add_party_type varchar2(3))
/
comment on column nbc_fin_message.add_party_type is 'Additional participant type for BNB operations: ISS/ACQ/BNB'
/ 
alter table nbc_fin_message modify from_account_id varchar2(30)
/
alter table nbc_fin_message modify to_account_id varchar2(30)
/
alter table nbc_fin_message modify from_account_id varchar2(32)
/
alter table nbc_fin_message modify to_account_id varchar2(32)
/
