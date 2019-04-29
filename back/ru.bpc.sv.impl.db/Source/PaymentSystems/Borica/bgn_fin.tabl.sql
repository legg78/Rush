create table bgn_fin(  
    id                          number(16)
  , file_id                     number(16)
  , status                      varchar2(8)
  , is_reversal                 number(1)
  , dispute_id                  number(16)
  , inst_id                     number(4)
  , network_id                  number(4)
  , is_incoming                 number(1)
  , package_id                  number(12)
  , record_type                 varchar2(3)
  , record_number               number(6)
  , transaction_date            date
  , transaction_type            number(2)
  , is_reject                   varchar2(1)
  , is_finance                  number(1)
  , card_mask                   varchar2(24)
  , card_seq_number             number(3)
  , card_expire_date            number(4)
  , card_type                   varchar2(3)
  , acquirer_amount             number(18)
  , acquirer_currency           number(3)
  , network_amount              number(18)
  , network_currency            number(3)
  , card_amount                 number(18)
  , card_currency               number(3)
  , auth_code                   varchar2(6)
  , trace_number                number(6)
  , retrieval_refnum            varchar2(12)
  , merchant_number             varchar2(15)
  , merchant_name               varchar2(25)
  , merchant_city               varchar2(13)
  , mcc                         number(4)
  , terminal_number             varchar2(8)
  , pos_entry_mode              number(4)
  , ain                         number(11)
  , auth_indicator              varchar2(1)
  , transaction_number          varchar2(20)
  , validation_code             varchar2(4)
  , market_data_id              varchar2(1)
  , add_response_data           number(1)
  , reject_code                 varchar2(4)
  , response_code               varchar2(2)
  , reject_text                 varchar2(52)
  , is_offline                  number(1)
  , pos_text                    varchar2(40)
  , result_code                 varchar2(1)
  , terminal_cap                varchar2(6)
  , terminal_result             varchar2(10)
  , unpred_number               varchar2(8)
  , terminal_seq_number         varchar2(8)
  , derivation_key_index        varchar2(2)
  , crypto_version              varchar2(2)
  , card_result                 varchar2(6)
  , app_crypto                  varchar2(16)
  , app_trans_counter           varchar2(4)
  , app_interchange_profile     varchar2(4)
  , iss_script1_result          varchar2(10)
  , iss_script2_result          varchar2(10)
  , terminal_country            number(3)
  , terminal_date               number(6)
  , auth_response_code          varchar2(2)
  , other_amount                number(12)
  , trans_type_1                number(2)
  , terminal_type               varchar2(2)
  , trans_category              varchar2(1)
  , trans_seq_counter           number(8)
  , crypto_info_data            varchar2(2)
  , dedicated_filename          varchar2(32)
  , iss_app_data                varchar2(64)
  , cvm_result                  varchar2(6)
  , terminal_app_version        varchar2(4)
  , sttl_date                   number(4)
  , network_data                varchar2(50)
  , cashback_acq_amount         number(18)
  , cashback_acq_currency       number(3)
  , cashback_net_amount         number(18)
  , cashback_net_currency       number(3)
  , cashback_card_amount        number(18)
  , cashback_card_currency      number(3)
  , term_type                   varchar2(2)
  , terminal_subtype            varchar2(2)
  , trans_type_2                varchar2(2)
  , cashm_refnum                varchar2(22)
  , sttl_amount                 number(18)
  , interbank_fee_amount        number(18)
  , bank_card_id                number(5)
  , ecommerce                   number(3)
  , transaction_amount          number(18)
  , transaction_currency        number(3)
  , original_trans_number       varchar2(20)
  , account_number              varchar2(22)
  , report_period               number(4)
  , withdrawal_number           number(5)
  , period_amount               number(12)
  , card_subtype                number(2)
  , issuer_code                 number(5)
  , card_acc_number             varchar2(22)
  , add_acc_number              varchar2(22)
  , atm_bank_code               varchar2(3)
  , deposit_number              varchar2(22)
  , loaded_amount_atm           number(9)
  , is_fullload                 number(1)
  , total_amount_atm            number(9)
  , total_amount_tandem         number(9)
  , withdrawal_count            number(5)
  , receipt_count               number(5)
  , message_type                varchar2(6)
  , stan                        varchar2(6)
  , incident_cause              number(4)
)  
/

comment on table bgn_fin is 'BORICA messages'
/

comment on column bgn_fin.id is 'Primary key. Equal to opr_operation.id'
/

comment on column bgn_fin.file_id is 'Reference to bgn_file'
/

comment on column bgn_fin.status is 'Message status'
/

comment on column bgn_fin.is_reversal is 'Reversal flag'
/

comment on column bgn_fin.dispute_id is 'Reference to the dispute message group'
/

comment on column bgn_fin.inst_id is 'Instisution identifier'
/

comment on column bgn_fin.network_id is 'Network identifier'
/

comment on column bgn_fin.is_incoming is '1 - incoming message, 0 - outgoing message'
/

comment on column bgn_fin.package_id is 'Reference to bgn_package (FO only)'
/

comment on column bgn_fin.record_type is 'Record type (EO, QO); message code (FO)'
/

comment on column bgn_fin.record_number is 'Sequence number of record (EO, QO, FO)'
/

comment on column bgn_fin.transaction_date is 'Transaction date (EO, QO, FO)'
/

comment on column bgn_fin.transaction_type is 'Transaction type (EO, QO); operation type (FO)'
/

comment on column bgn_fin.is_reject is 'Reject indication (EO, QO)'
/

comment on column bgn_fin.is_finance is 'Financial transaction (EO)'
/

comment on column bgn_fin.card_mask is 'Masked card number'
/

comment on column bgn_fin.card_seq_number is 'Card sequence number'
/

comment on column bgn_fin.card_expire_date is 'Card expire date'
/

comment on column bgn_fin.card_type is 'Card type (EO, FO)'
/

comment on column bgn_fin.acquirer_amount is 'Transaction amount in acquirer currency (EO)'
/

comment on column bgn_fin.acquirer_currency is 'Acquirer currency code (EO)'
/

comment on column bgn_fin.network_amount is 'Transaction amount in network currency (EO)'
/

comment on column bgn_fin.network_currency is 'Network currency code (EO)'
/

comment on column bgn_fin.card_amount is 'Transaction amount in card currency (EO)'
/

comment on column bgn_fin.card_currency is 'Card currency code (EO)'
/

comment on column bgn_fin.auth_code is 'Authorization Identification Response (EO, QO); authorization code (FO);'
/

comment on column bgn_fin.trace_number is 'System Trace Audit Number (EO, QO)'
/

comment on column bgn_fin.retrieval_refnum is 'Retrieval Reference Number (EO)'
/

comment on column bgn_fin.merchant_number is 'Card Acceptor Identification Code (EO, QO)'
/

comment on column bgn_fin.merchant_name is 'Card Acceptor Name (EO, QO)'
/

comment on column bgn_fin.merchant_city is 'Card Acceptor Location (QO, EO)'
/

comment on column bgn_fin.mcc is 'Merchant’s Type (EO, QO); Merchant’s category (FO)'
/

comment on column bgn_fin.terminal_number is 'Card Acceptor Terminal Identification (EO, QO); Terminal ID (FO);'
/

comment on column bgn_fin.pos_entry_mode is 'Point of Service Entry Mode (EO, QO)'
/

comment on column bgn_fin.ain is 'Acquiring Inst. Identification Code (EO, QO)'
/

comment on column bgn_fin.auth_indicator is 'Authorization Characteristics Indicator (EO); Indicator for balance during auth request (FO)'
/

comment on column bgn_fin.transaction_number is 'Transaction Identifie (EO); unique transaction id (QO); transaction''s registration number (FO)'
/

comment on column bgn_fin.validation_code is 'Validation Code (EO)'
/

comment on column bgn_fin.market_data_id is 'Market-specific Data Identifier (EO)'
/

comment on column bgn_fin.add_response_data is 'Additional Response data (EO); Aggregated transaction indicator (FO);'
/

comment on column bgn_fin.reject_code is 'Reject code subfield (EO); Code for cancelation of payment (FO);'
/

comment on column bgn_fin.response_code is 'Response code subfield (EO)'
/

comment on column bgn_fin.reject_text is 'Text information about cause of reject subfield (EO)'
/

comment on column bgn_fin.is_offline is 'Offline indicator (EO)'
/

comment on column bgn_fin.pos_text is 'Additional POS Information (EO); Text reference (FO);'
/

comment on column bgn_fin.result_code is 'CVV/CVC Results Code (EO)'
/

comment on column bgn_fin.terminal_cap is 'Terminal Capabilities (EO)'
/

comment on column bgn_fin.terminal_result is 'Terminal Verification Results (EO)'
/

comment on column bgn_fin.unpred_number is 'Unpredictable number (EO)'
/

comment on column bgn_fin.terminal_seq_number is 'Terminal Serial Number (EO)'
/

comment on column bgn_fin.derivation_key_index is 'Derivation Key Index (EO)'
/

comment on column bgn_fin.crypto_version is 'Cryptogram Verson Number (EO)'
/

comment on column bgn_fin.card_result is 'Card Verification Results (EO)'
/

comment on column bgn_fin.app_crypto is 'Application Cryptogram (EO)'
/

comment on column bgn_fin.app_trans_counter is 'Application Transaction Counter (EO)'
/

comment on column bgn_fin.app_interchange_profile is 'Application Interchange Profile (EO)'
/

comment on column bgn_fin.iss_script1_result is 'Issuer Script 1 Results (EO)'
/

comment on column bgn_fin.iss_script2_result is 'Issuer Script 2 Results (EO)'
/

comment on column bgn_fin.terminal_country is 'Terminal Country Code (EO)'
/

comment on column bgn_fin.terminal_date is 'Terminal Transaction Date (EO)'
/

comment on column bgn_fin.auth_response_code is 'Authorisation Response Code (EO)'
/

comment on column bgn_fin.other_amount is 'Amount, Other (EO)'
/

comment on column bgn_fin.trans_type_1 is 'Transaction Type (EO)'
/

comment on column bgn_fin.terminal_type is 'Terminal Type (EO. FO); Terminal Type and Capability (QO)'
/

comment on column bgn_fin.trans_category is 'Transaction Category Code (EO)'
/

comment on column bgn_fin.trans_seq_counter is 'Transaction Sequency Counter (EO)'
/

comment on column bgn_fin.crypto_info_data is 'Cryptogram Information Data (EO)'
/

comment on column bgn_fin.dedicated_filename is 'Dedicated File Name (EO)'
/

comment on column bgn_fin.iss_app_data is 'Issuer Application Data (EO)'
/

comment on column bgn_fin.cvm_result is 'CVM results (EO)'
/

comment on column bgn_fin.terminal_app_version is 'Terminal Application Version (EO)'
/

comment on column bgn_fin.sttl_date is 'Date, settlement (EO)'
/

comment on column bgn_fin.network_data is 'Network Data (EO)'
/

comment on column bgn_fin.cashback_acq_amount is 'Caschback amount in acquirer currency (EO)'
/

comment on column bgn_fin.cashback_acq_currency is 'Acquirer currency code of cashback (EO)'
/

comment on column bgn_fin.cashback_net_amount is 'Cashback amount in network currency (EO)'
/

comment on column bgn_fin.cashback_net_currency is 'Network currency code of cashback (EO)'
/

comment on column bgn_fin.cashback_card_amount is 'Cashback amount in card currency (EO)'
/

comment on column bgn_fin.cashback_card_currency is 'Card currency code of cashback (EO)'
/

comment on column bgn_fin.term_type is 'Terminal type (EO field 74)'
/

comment on column bgn_fin.terminal_subtype is 'Terminal subtype (EO, FO)'
/

comment on column bgn_fin.trans_type_2 is 'Transaction type (EO field 76)'
/

comment on column bgn_fin.cashm_refnum is 'Reference number of transaction during cash-m (EO)'
/

comment on column bgn_fin.sttl_amount is 'Settlement amount (QO)'
/

comment on column bgn_fin.interbank_fee_amount is 'Interbank fee (QO)'
/

comment on column bgn_fin.bank_card_id is 'Bank card identificator (QO)'
/

comment on column bgn_fin.ecommerce is 'Electronic Commerce Indicator (QO, FO)'
/

comment on column bgn_fin.transaction_amount is 'Transaction amount (QO); Processed amount (FO)'
/

comment on column bgn_fin.transaction_currency is 'Transaction currency (QO)'
/

comment on column bgn_fin.original_trans_number is 'Unique id of original transaction (QO)'
/

comment on column bgn_fin.account_number is 'Account indicator (FO)'
/

comment on column bgn_fin.report_period is 'Reporting period (FO)'
/

comment on column bgn_fin.withdrawal_number is 'Withdrawal number (FO)'
/

comment on column bgn_fin.period_amount is 'Sum for the period (FO)'
/

comment on column bgn_fin.card_subtype is 'Card subtype (FO)'
/

comment on column bgn_fin.issuer_code is 'Card issuer (FO)'
/

comment on column bgn_fin.card_acc_number is 'Card account (FO)'
/

comment on column bgn_fin.add_acc_number is 'Additional account (FO)'
/

comment on column bgn_fin.atm_bank_code is 'ATM’s bank code (FO)'
/

comment on column bgn_fin.deposit_number is 'Deposit’s reference (FO)'
/

comment on column bgn_fin.loaded_amount_atm is 'Amount loaded in ATM (BGN) (FO)'
/

comment on column bgn_fin.is_fullload is 'Full load indicator (FO)'
/

comment on column bgn_fin.total_amount_atm is 'Total amount (ATM) (FO)'
/

comment on column bgn_fin.total_amount_tandem is 'Total amount (TANDEM) (FO)'
/

comment on column bgn_fin.withdrawal_count is 'Number of withdrawals (FO)'
/

comment on column bgn_fin.receipt_count is 'Number of printed receipts (FO)'
/

comment on column bgn_fin.message_type is 'Message type (FO)'
/

comment on column bgn_fin.stan is 'STAN (FO)'
/

comment on column bgn_fin.incident_cause is 'Cause of incident (FO)'
/

alter table bgn_fin add host_inst_id number(4)
/

comment on column bgn_fin.host_inst_id is 'Host institution id'
/

alter table bgn_fin add file_record_number number(8)
/

comment on column bgn_fin.file_record_number is 'Record number in prc_file_raw_data'
/

comment on column bgn_fin.interbank_fee_amount is 'Interbank fee (QO, FO)'
/

alter table bgn_fin add is_invalid number(1)
/

comment on column bgn_fin.is_invalid is 'Is record invalid'
/

alter table bgn_fin add oper_id number(16)
/

comment on column bgn_fin.oper_id is 'Operation id'
/
comment on column bgn_fin.stan is 'System Trace Audit Number (FO, QO, EO)'
/
comment on column bgn_fin.trace_number is 'Same as stan'
/
