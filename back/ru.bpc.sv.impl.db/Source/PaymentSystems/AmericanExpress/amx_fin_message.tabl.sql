create table amx_fin_message (
    id                           number(16) not null
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
    , dispute_id                 number(16)    
    , transaction_id             number(15)
    , card_id                    number(12)
    , card_mask                  varchar2(24)
    , card_hash                  number(12)
    , proc_code                  varchar2(6)
    , trans_amount               number(15)
    , trans_date                 date
    , card_expir_date            varchar2(4)
    , capture_date               date
    , mcc                        varchar2(4)
    , point_srv_data_code        varchar2(12)
    , func_code                  varchar2(3)
    , msg_reason_code            varchar2(4)
    , approval_code_length       number(1)
    , iss_sttl_date              date
    , eci                        varchar2(2)
    , original_trans_amount      number(15)
    , ain                        varchar2(11)
    , apn                        varchar2(11)
    , arn                        varchar2(23)
    , approval_code              varchar2(6)
    , terminal_number            varchar2(8)
    , merchant_number            varchar2(15)
    , merchant_name              varchar2(38)
    , merchant_addr1             varchar2(38)
    , merchant_addr2             varchar2(38)
    , merchant_city              varchar2(21)
    , merchant_postcode          varchar2(15)
    , merchant_country           varchar2(3)
    , merchant_region            varchar2(3)
    , iss_gross_sttl_amount      number(15)
    , iss_rate_amount            number(15)
    , matching_key_type          varchar2(2)
    , matching_key               varchar2(21)
    , iss_net_sttl_amount        number(15)
    , iss_net_sttl_currency      varchar2(3)
    , iss_net_sttl_decimalization number(1)
    , original_trans_currency    varchar2(3)
    , original_trans_decimalization number(1)
    , original_amount            number(15)
    , original_conversion_rate   number(8)
    , original_currency          varchar2(3)
    , original_decimalization    number(1)
    , merchant_multinational     varchar2(1)
    , trans_currency             varchar2(3)
    , add_amount_eff_type1       varchar2(1)
    , add_amount1                number(15)
    , add_amount_type1           varchar2(3)
    , add_amount_eff_type2       varchar2(1)
    , add_amount2                number(15)
    , add_amount_type2           varchar2(3)
    , add_amount_eff_type3       varchar2(1)
    , add_amount3                number(15)
    , add_amount_type3           varchar2(3)
    , add_amount_eff_type4       varchar2(1)
    , add_amount4                number(15)
    , add_amount_type4           varchar2(3)
    , add_amount_eff_type5       varchar2(1)
    , add_amount5                number(15)
    , add_amount_type5           varchar2(3)
    , alternate_merchant_code    varchar2(15)
    , alternate_mrch_code_length number(2)
    , original_trans_date        date
    , icc                        varchar2(2)
    , card_capability            varchar2(1)
    , net_proc_date              date
    , trans_decimalization       number(1)
    , prg_indicator              varchar2(2)
    , tax_reason_code            varchar2(2)
    , original_net_proc_date     date
    , format_code                varchar2(2)
    , iin                        varchar2(11)
    , media_code                 varchar2(2)
    , msg_seq_number             number(3)
    , merchant_location          varchar2(40)
    , itemized_doc_code          varchar2(2)
    , itemized_doc_ref_number    varchar2(23)
    , ext_payment_data           number(2)
    , ipn                        varchar2(11)
    , invoice_number             varchar2(30)
    , reject_reason_code         varchar2(40)
    , status                     varchar2(8)
    , chback_reason_code         varchar2(4)
    , acq_sttl_amount            number(15)
    , acq_sttl_currency          varchar2(3)
    , acq_sttl_decimalization    number(1)
    , chback_reason_text         varchar2(95)
    , reject_message_id          number(16)    
    , impact                     number(1) 
    , originator_refnum          varchar2(36)
)
/
comment on table amx_fin_message is 'AMEX financial mesages(1240 first and second presentment)'
/
comment on column amx_fin_message.id is 'Primary key. Message identifier'
/
comment on column amx_fin_message.mtid is 'Message type'
/
comment on column amx_fin_message.file_id is 'Reference to clearing file'
/
comment on column amx_fin_message.inst_id is 'Institution identifier'
/
comment on column amx_fin_message.network_id is 'Network identifier'
/
comment on column amx_fin_message.transaction_id is 'Transaction identifier'
/
comment on column amx_fin_message.proc_code is 'Processing Code'
/
comment on column amx_fin_message.trans_amount is 'Transaction Amount'
/
comment on column amx_fin_message.trans_date is 'Transaction Date'
/
comment on column amx_fin_message.card_expir_date is 'Card Expiration Date'
/
comment on column amx_fin_message.capture_date is 'Capture Date'
/
comment on column amx_fin_message.mcc is 'Merchant Category Code'
/
comment on column amx_fin_message.point_srv_data_code is 'Point of Service Data Code'
/
comment on column amx_fin_message.func_code is 'Function Code'
/
comment on column amx_fin_message.msg_reason_code is 'Message Reason Code'
/
comment on column amx_fin_message.approval_code_length is 'Approval code length'
/
comment on column amx_fin_message.iss_sttl_date is 'Issuer Settlement Date'
/
comment on column amx_fin_message.eci is 'Electronic Commerce Indicator (ECI)'
/
comment on column amx_fin_message.original_trans_amount is 'First Presentment Transaction Amount'
/
comment on column amx_fin_message.ain is 'Acquiring Institution Identification (AIN) Code'
/
comment on column amx_fin_message.apn is 'Acquiring Institution Processor Identifier (APN)'
/
comment on column amx_fin_message.arn is 'Acquirer Reference Number (ARN)'
/
comment on column amx_fin_message.approval_code is 'Approval Code'
/
comment on column amx_fin_message.terminal_number is 'Card Acceptor Terminal Identification'
/
comment on column amx_fin_message.merchant_number is 'Card Acceptor Identification Code'
/
comment on column amx_fin_message.merchant_name is 'Card Acceptor Name'
/
comment on column amx_fin_message.merchant_addr1 is 'Card Acceptor Address Line 1'
/
comment on column amx_fin_message.merchant_addr2 is 'Card Acceptor Address Line 2'
/
comment on column amx_fin_message.merchant_city is 'Card Acceptor City'
/
comment on column amx_fin_message.merchant_postcode is 'Card Acceptor Postal Code'
/
comment on column amx_fin_message.merchant_country is 'Card Acceptor Country Code'
/
comment on column amx_fin_message.merchant_region is 'Card Acceptor Region Code'
/
comment on column amx_fin_message.iss_gross_sttl_amount is 'Issuer Gross Settlement Amount'
/
comment on column amx_fin_message.iss_rate_amount is 'Issuers/Network Rate Amount'
/
comment on column amx_fin_message.matching_key_type is 'Matching Key Type'
/
comment on column amx_fin_message.matching_key is 'Matching Key'
/
comment on column amx_fin_message.iss_net_sttl_amount is 'Issuer Net Settlement Amount'
/
comment on column amx_fin_message.iss_net_sttl_currency is 'Issuer Settlement Currency Code'
/
comment on column amx_fin_message.iss_net_sttl_decimalization is 'Issuer Settlement Decimalization'
/
comment on column amx_fin_message.original_trans_currency is 'First Presentment Transaction Currency Code'
/
comment on column amx_fin_message.original_trans_decimalization is 'Transaction Decimalization or First Presentment Transaction Decimalization'
/
comment on column amx_fin_message.original_amount is 'First Presentment Presentment Amount'
/
comment on column amx_fin_message.original_conversion_rate is 'First Presentment Transaction To Present-ment Conversion Rate'
/
comment on column amx_fin_message.original_currency is 'First Presentment Presentment Currency Code'
/
comment on column amx_fin_message.original_decimalization is 'First Presentment Presentment Decimalization'
/
comment on column amx_fin_message.merchant_multinational is 'Card Acceptor Multinational Indicator'
/
comment on column amx_fin_message.trans_currency is 'Transaction Currency Code'
/
comment on column amx_fin_message.add_amount_eff_type1 is 'Additional Amount Accounting Effect Type Code 1'
/
comment on column amx_fin_message.add_amount1 is 'Additional Amount 1'
/
comment on column amx_fin_message.add_amount_type1 is 'Additional Amount Type 1'
/
comment on column amx_fin_message.add_amount_eff_type2 is 'Additional Amount Accounting Effect Type Code 2'
/
comment on column amx_fin_message.add_amount2 is 'Additional Amount 2'
/
comment on column amx_fin_message.add_amount_type2 is 'Additional Amount Type 2'
/
comment on column amx_fin_message.add_amount_eff_type3 is 'Additional Amount Accounting Effect Type Code 3'
/
comment on column amx_fin_message.add_amount3 is 'Additional Amount 3'
/
comment on column amx_fin_message.add_amount_type3 is 'Additional Amount Type 3'
/
comment on column amx_fin_message.add_amount_eff_type4 is 'Additional Amount Accounting Effect Type Code 4'
/
comment on column amx_fin_message.add_amount4 is 'Additional Amount 4'
/
comment on column amx_fin_message.add_amount_type4 is 'Additional Amount Type 4'
/
comment on column amx_fin_message.add_amount_eff_type5 is 'Additional Amount Accounting Effect Type Code 5'
/
comment on column amx_fin_message.add_amount5 is 'Additional Amount 5'
/
comment on column amx_fin_message.add_amount_type5 is 'Additional Amount Type 5'
/
comment on column amx_fin_message.alternate_merchant_code is 'Alternate Card Acceptor Identification Code'
/
comment on column amx_fin_message.alternate_mrch_code_length is 'Alternate Card Acceptor Identification Code Length'
/
comment on column amx_fin_message.original_trans_date is 'First Presentment Transaction Date'
/
comment on column amx_fin_message.icc is 'ICC Chip/PIN Indicator'
/
comment on column amx_fin_message.card_capability is 'Card Capability'
/
comment on column amx_fin_message.net_proc_date is 'Network Processing Date'
/
comment on column amx_fin_message.trans_decimalization is 'Transaction Decimalization'
/
comment on column amx_fin_message.prg_indicator is 'Program Indicator'
/
comment on column amx_fin_message.tax_reason_code is 'Tax Reason Code'
/
comment on column amx_fin_message.original_net_proc_date is 'First Presentment Network Processing Date'
/
comment on column amx_fin_message.format_code is 'Format Code'
/
comment on column amx_fin_message.iin is 'Issuer Institution Identifier (IIN)'
/
comment on column amx_fin_message.media_code is 'Media Code'
/
comment on column amx_fin_message.msg_seq_number is 'Message Transaction Sequence Number'
/
comment on column amx_fin_message.merchant_location is 'Card Acceptor Location Text'
/
comment on column amx_fin_message.itemized_doc_code is 'Itemized Document Code'
/
comment on column amx_fin_message.itemized_doc_ref_number is 'Itemized Document Reference Number'
/
comment on column amx_fin_message.ext_payment_data is 'Extended Payment Data'
/
comment on column amx_fin_message.msg_number is 'Message Number'
/
comment on column amx_fin_message.ipn is 'Issuer Processor Identifier (IPN)'
/
comment on column amx_fin_message.invoice_number is 'Invoice Number'
/
comment on column amx_fin_message.reject_reason_code is 'Reject Reason Codes 1-10'
/
comment on column amx_fin_message.status is 'Status message'
/
comment on column amx_fin_message.chback_reason_code is 'Chargeback Message Reason Code'
/
comment on column amx_fin_message.card_expir_date is 'Card expiration date'
/
comment on column amx_fin_message.acq_sttl_amount is 'Acquirer Settlement Amount'
/
comment on column amx_fin_message.acq_sttl_currency is 'Acquirer Settlement Currency Code'
/
comment on column amx_fin_message.acq_sttl_decimalization is 'Acquirer Settlement Decimalization'
/
comment on column amx_fin_message.chback_reason_text is 'Chargeback Reason Text'
/
comment on column amx_fin_message.reject_message_id is 'File Reject Message reference number'
/
comment on column amx_fin_message.impact is 'Impact Debit -1/Credit 1'
/
comment on column amx_fin_message.originator_refnum is 'Reference number generated by originator of operation'
/

--update--
drop table amx_fin_message
/

create table amx_fin_message (
    id                           number(16) not null
    , split_hash                 number(4)
    , status                     varchar2(8)
    , inst_id                    number(4)
    , network_id                 number(4)
    , file_id                    number(16)
    , is_invalid                 number(1)
    , is_incoming                number(1)
    , is_reversal                number(1)
    , is_collection_only         number(1)
    , is_rejected                number(1)
    , reject_id                  number(16)
    , dispute_id                 number(16)    
    , impact                     number(1)
    , mtid                       varchar2(4)
    , func_code                  varchar2(3)
    , pan_length                 varchar2(2)                 
    , card_mask                  varchar2(19)
    , card_hash                  number(12)
    , proc_code                  varchar2(6)
    , trans_amount               number(22,4)
    , trans_date                 date
    , card_expir_date            varchar2(4)
    , capture_date               date
    , mcc                        varchar2(4)
    , pdc_1                      varchar2(1)
    , pdc_2                      varchar2(1)
    , pdc_3                      varchar2(1)
    , pdc_4                      varchar2(1)
    , pdc_5                      varchar2(1)
    , pdc_6                      varchar2(1)
    , pdc_7                      varchar2(1)
    , pdc_8                      varchar2(1)
    , pdc_9                      varchar2(1)
    , pdc_10                     varchar2(1)
    , pdc_11                     varchar2(1)
    , pdc_12                     varchar2(1)
    , reason_code                varchar2(4)
    , approval_code_length       number(1)
    , iss_sttl_date              date
    , eci                        varchar2(2)
    , fp_trans_amount            number(22,4)
    , ain                        varchar2(11)
    , apn                        varchar2(11)
    , arn                        varchar2(23)
    , approval_code              varchar2(6)
    , terminal_number            varchar2(8)
    , merchant_number            varchar2(15)
    , merchant_name              varchar2(38)
    , merchant_addr1             varchar2(38)
    , merchant_addr2             varchar2(38)
    , merchant_city              varchar2(21)
    , merchant_postal_code       varchar2(15)
    , merchant_country           varchar2(3)
    , merchant_region            varchar2(3)
    , iss_gross_sttl_amount      number(22,4)
    , iss_rate_amount            number(22,4)
    , matching_key_type          varchar2(2)
    , matching_key               varchar2(21)
    , iss_net_sttl_amount        number(22,4)
    , iss_sttl_currency          varchar2(3)
    , iss_sttl_decimalization    number(1)
    , fp_trans_currency          varchar2(3)
    , trans_decimalization       number(1)
    , fp_trans_decimalization    number(1)
    , fp_pres_amount             number(22,4)
    , fp_pres_conversion_rate    number(22,4)
    , fp_pres_currency           varchar2(3)
    , fp_pres_decimalization     number(1)
    , merchant_multinational     varchar2(1)
    , trans_currency             varchar2(3)
    , add_acc_eff_type1          varchar2(1)
    , add_amount1                number(22,4)
    , add_amount_type1           varchar2(3)
    , add_acc_eff_type2          varchar2(1)
    , add_amount2                number(22,4)
    , add_amount_type2           varchar2(3)
    , add_acc_eff_type3          varchar2(1)
    , add_amount3                number(22,4)
    , add_amount_type3           varchar2(3)
    , add_acc_eff_type4          varchar2(1)
    , add_amount4                number(22,4)
    , add_amount_type4           varchar2(3)
    , add_acc_eff_type5          varchar2(1)
    , add_amount5                number(22,4)
    , add_amount_type5           varchar2(3)
    , alt_merchant_number_length varchar2(2)
    , alt_merchant_number        varchar2(15)
    , fp_trans_date              date
    , icc_pin_indicator          varchar2(2)
    , card_capability            varchar2(1)
    , network_proc_date          date
    , program_indicator          varchar2(2)
    , tax_reason_code            varchar2(2)
    , fp_network_proc_date       date
    , format_code                varchar2(2)
    , iin                        varchar2(11)
    , media_code                 varchar2(2)
    , message_seq_number         number(3)
    , merchant_location_text     varchar2(40)
    , itemized_doc_code          varchar2(2)
    , itemized_doc_ref_number    varchar2(23)
    , transaction_id             varchar2(15)
    , ext_payment_data           varchar2(2)
    , message_number             number(8)
    , ipn                        varchar2(11)
    , invoice_number             varchar2(30)
    , reject_reason_code         varchar2(40)
    --ChBck
    , chbck_reason_text          varchar2(95)
    , chbck_reason_code          varchar2(4)    
    -- fee collection
    , valid_bill_unit_code       varchar2(3)
    , sttl_date                  date
    , forw_inst_code             varchar2(11)
    , fee_reason_text            varchar2(95)
    , fee_type_code              varchar2(2) 
    , receiving_inst_code        varchar2(11)
    , send_inst_code             varchar2(11)
    , send_proc_code             varchar2(11)
    , receiving_proc_code        varchar2(11)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table amx_fin_message is 'AMEX financial mesages'
/
comment on column amx_fin_message.id is 'Primary key. Message identifier'
/
comment on column amx_fin_message.split_hash is 'Hash value to split further processing'
/
comment on column amx_fin_message.status is 'Message status'
/
comment on column amx_fin_message.inst_id is 'Institution identifier'
/
comment on column amx_fin_message.network_id is 'Network identifier'
/
comment on column amx_fin_message.file_id is 'Reference to clearing file'
/
comment on column amx_fin_message.is_invalid is 'Is financial message loaded with errors'
/
comment on column amx_fin_message.is_incoming is 'Incoming/Outgouing message flag. 1 - incoming, 0 - outgoing'
/
comment on column amx_fin_message.is_reversal is 'Reversal flag'
/
comment on column amx_fin_message.is_collection_only is 'Collection only flag'
/
comment on column amx_fin_message.is_rejected is 'Rejected message flag'
/
comment on column amx_fin_message.reject_id is 'Reject message identifier. Reference to amx_rejected.id'
/
comment on column amx_fin_message.dispute_id is 'Dispute identifier'
/
comment on column amx_fin_message.impact is 'Message impact'
/
comment on column amx_fin_message.mtid is 'The Message Type Identifier'
/
comment on column amx_fin_message.func_code is 'Function Code'
/
comment on column amx_fin_message.pan_length is 'Primary Account Number Length'
/
comment on column amx_fin_message.card_mask is 'Card mask'
/
comment on column amx_fin_message.card_hash is 'Card hash'
/
comment on column amx_fin_message.proc_code is 'Processing Code'
/
comment on column amx_fin_message.trans_amount is 'Transaction Amount'
/
comment on column amx_fin_message.trans_date is 'Transaction Date'
/
comment on column amx_fin_message.card_expir_date is 'Card Expiration Date'
/
comment on column amx_fin_message.capture_date is 'Capture Date'
/
comment on column amx_fin_message.mcc is 'Merchant Category Code (MCC)'
/
comment on column amx_fin_message.pdc_1 is 'Card Data Input Capability'
/
comment on column amx_fin_message.pdc_2 is 'Cardmember Authentication Capabilit'
/
comment on column amx_fin_message.pdc_3 is 'Card Capture Capability'
/
comment on column amx_fin_message.pdc_4 is 'Operating Environment'
/
comment on column amx_fin_message.pdc_5 is 'Cardmember Present'
/
comment on column amx_fin_message.pdc_6 is 'Card Present'
/
comment on column amx_fin_message.pdc_7 is 'Card Data Input Mode'
/
comment on column amx_fin_message.pdc_8 is 'Cardmember Authentication'
/
comment on column amx_fin_message.pdc_9 is 'Cardmember Authentication Entity'
/
comment on column amx_fin_message.pdc_10 is 'Card Data Output Capability'
/
comment on column amx_fin_message.pdc_11 is 'Terminal Output Capability'
/
comment on column amx_fin_message.pdc_12 is 'PIN Capture Capability'
/
comment on column amx_fin_message.reason_code is 'Message Reason Code'
/
comment on column amx_fin_message.approval_code_length is 'Approval Code Length'
/
comment on column amx_fin_message.iss_sttl_date is 'Issuer Settlement Date'
/
comment on column amx_fin_message.eci is 'Electronic Commerce Indicator (ECI)'
/
comment on column amx_fin_message.fp_trans_amount is 'First Presentment Transaction Amount'
/
comment on column amx_fin_message.ain is 'Acquiring Institution Identification (AIN) Code'
/
comment on column amx_fin_message.apn is 'Acquiring Institution Processor Identifier (APN)'
/
comment on column amx_fin_message.arn is 'Acquirer Reference Number (ARN)'
/
comment on column amx_fin_message.approval_code is 'Approval Code'
/
comment on column amx_fin_message.terminal_number is 'Card Acceptor Terminal Identification'
/
comment on column amx_fin_message.merchant_number is 'Card Acceptor Identification Code'
/
comment on column amx_fin_message.merchant_name is 'Card Acceptor Name'
/
comment on column amx_fin_message.merchant_addr1 is 'Card Acceptor Address Line 1'
/
comment on column amx_fin_message.merchant_addr2 is 'Card Acceptor Address Line 2'
/
comment on column amx_fin_message.merchant_city is 'Card Acceptor City'
/
comment on column amx_fin_message.merchant_postal_code is 'Card Acceptor Postal Code'
/
comment on column amx_fin_message.merchant_country is 'Card Acceptor Country Code'
/
comment on column amx_fin_message.merchant_region is 'Card Acceptor Region Code'
/
comment on column amx_fin_message.iss_gross_sttl_amount is 'Issuer Gross Settlement Amount'
/
comment on column amx_fin_message.iss_rate_amount is 'Issuers/Network Rate Amount'
/
comment on column amx_fin_message.matching_key_type is 'Matching Key Type'
/
comment on column amx_fin_message.matching_key is 'Matching Key'
/
comment on column amx_fin_message.iss_net_sttl_amount is 'Issuer Net Settlement Amount'
/
comment on column amx_fin_message.iss_sttl_currency is 'Issuer Settlement Currency Code'
/
comment on column amx_fin_message.iss_sttl_decimalization is 'Issuer Settlement Decimalization'
/
comment on column amx_fin_message.fp_trans_currency is 'First Presentment Transaction Currency Code'
/
comment on column amx_fin_message.trans_decimalization is 'Transaction Decimalization'
/
comment on column amx_fin_message.fp_trans_decimalization is 'First Presentment Transaction Decimalization'
/
comment on column amx_fin_message.fp_pres_amount is 'First Presentment Presentment Amount'
/
comment on column amx_fin_message.fp_pres_conversion_rate is 'First Presentment Transaction To Present-ment Conversion Rate'
/
comment on column amx_fin_message.fp_pres_currency is 'First Presentment Presentment Currency Code'
/
comment on column amx_fin_message.fp_pres_decimalization is 'First Presentment Presentment Decimalization'
/
comment on column amx_fin_message.merchant_multinational is 'Card Acceptor Multinational Indicator'
/
comment on column amx_fin_message.trans_currency is 'Transaction Currency Code'
/
comment on column amx_fin_message.add_acc_eff_type1 is 'Additional Amount Accounting Effect Type Code 1'
/
comment on column amx_fin_message.add_amount1 is 'Additional Amount 1'
/
comment on column amx_fin_message.add_amount_type1 is 'Additional Amount Type 1'
/
comment on column amx_fin_message.add_acc_eff_type2 is 'Additional Amount Accounting Effect Type Code 2'
/
comment on column amx_fin_message.add_amount2 is 'Additional Amount 2'
/
comment on column amx_fin_message.add_amount_type2 is 'Additional Amount Type 2'
/
comment on column amx_fin_message.add_acc_eff_type3 is 'Additional Amount Accounting Effect Type Code 3'
/
comment on column amx_fin_message.add_amount3 is 'Additional Amount 3'
/
comment on column amx_fin_message.add_amount_type3 is 'Additional Amount Type 3'
/
comment on column amx_fin_message.add_acc_eff_type4 is 'Additional Amount Accounting Effect Type Code 4'
/
comment on column amx_fin_message.add_amount4 is 'Additional Amount 4'
/
comment on column amx_fin_message.add_amount_type4 is 'Additional Amount Type 4'
/
comment on column amx_fin_message.add_acc_eff_type5 is 'Additional Amount Accounting Effect Type Code 5'
/
comment on column amx_fin_message.add_amount5 is 'Additional Amount 5'
/
comment on column amx_fin_message.add_amount_type5 is 'Additional Amount Type 5'
/
comment on column amx_fin_message.alt_merchant_number_length is 'Alternate Card Acceptor Identification Code Length'
/
comment on column amx_fin_message.alt_merchant_number is 'Alternate Card Acceptor Identification Code'
/
comment on column amx_fin_message.fp_trans_date is 'First Presentment Transaction Date'
/
comment on column amx_fin_message.icc_pin_indicator is 'ICC Chip/PIN Indicator'
/
comment on column amx_fin_message.card_capability is 'Card Capability'
/
comment on column amx_fin_message.network_proc_date is 'Network Processing Date'
/
comment on column amx_fin_message.program_indicator is 'Program Indicator'
/
comment on column amx_fin_message.tax_reason_code is 'Tax Reason Code'
/
comment on column amx_fin_message.fp_network_proc_date is 'First Presentment Network Processing Date'
/
comment on column amx_fin_message.format_code is 'Format Code'
/
comment on column amx_fin_message.iin is 'Issuer Institution Identifier (IIN)'
/
comment on column amx_fin_message.media_code is 'Media Code'
/
comment on column amx_fin_message.message_seq_number is 'Message Transaction Sequence Number'
/
comment on column amx_fin_message.merchant_location_text is 'Card Acceptor Location Text'
/
comment on column amx_fin_message.itemized_doc_code is 'Itemized Document Code'
/
comment on column amx_fin_message.itemized_doc_ref_number is 'Itemized Document Reference Number'
/
comment on column amx_fin_message.transaction_id is 'Transaction Identifier (TID)'
/
comment on column amx_fin_message.ext_payment_data is 'Extended Payment Data'
/
comment on column amx_fin_message.message_number is 'Message Number'
/
comment on column amx_fin_message.ipn is 'Issuer Processor Identifier (IPN)'
/
comment on column amx_fin_message.invoice_number is 'Invoice Number'
/
comment on column amx_fin_message.reject_reason_code is 'Reject Reason Codes 1-10'
/
comment on column amx_fin_message.chbck_reason_text is 'Chargeback Reason Text'
/
comment on column amx_fin_message.chbck_reason_code is 'Chargeback Message Reason Code'
/
comment on column amx_fin_message.valid_bill_unit_code is 'Valid Billing Unit Code'
/
comment on column amx_fin_message.sttl_date is 'Settlement Date'
/
comment on column amx_fin_message.forw_inst_code is 'Forwarding Institution Identification Code'
/
comment on column amx_fin_message.fee_reason_text is 'Fee Reason Text'
/
comment on column amx_fin_message.fee_type_code is 'Fee Type Code'
/
comment on column amx_fin_message.receiving_inst_code is 'Receiving Institution Identifier'
/
comment on column amx_fin_message.send_inst_code is 'Sending Institution Identifier'
/
comment on column amx_fin_message.send_proc_code is 'Sending Processor Institution Identifier'
/
comment on column amx_fin_message.receiving_proc_code is 'Receiving Processor Institution Identifier'
/
alter table amx_fin_message add merchant_discount_rate varchar2(15)
/
comment on column amx_fin_message.merchant_discount_rate is 'Merchant discount rate'
/
