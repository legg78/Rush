create table h2h_fin_message(
    id                              number(16)  not null
  , part_key                        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual
  , split_hash                      number(4)
  , status                          varchar2(8)
  , inst_id                         number(4)
  , network_id                      number(4)
  , file_id                         number(16)
  , file_type                       varchar2(8)
  , file_date                       date
  , incom_sess_file_id              number(16)
  , is_invalid                      number(1)
  , is_incoming                     number(1)
  , is_reversal                     number(1)
  , is_collection_only              number(1)
  , is_rejected                     number(1)
  , reject_id                       number(16)
  , dispute_id                      number(16)
  , forw_inst_id                    number(4)
  , receiv_inst_id                  number(4)
  , oper_type                       varchar2(8)
  , msg_type                        varchar2(8)
  , oper_date                       date
  , oper_amount_value               number(22, 4)
  , oper_amount_currency            varchar2(3)
  , oper_surcharge_amount_value     number(22, 4)
  , oper_surcharge_amount_currency  varchar2(3)
  , oper_cashback_amount_value      number(22, 4)
  , oper_cashback_amount_currency   varchar2(3)
  , sttl_amount_value               number(22, 4)
  , sttl_amount_currency            varchar2(3)
  , sttl_rate                       number
  , crdh_bill_amount_value          number(22, 4)
  , crdh_bill_amount_currency       varchar2(3)
  , crdh_bill_rate                  number
  , acq_inst_bin                    varchar2(24)
  , arn                             varchar2(23)
  , merchant_number                 varchar2(15)
  , mcc                             varchar2(4)
  , merchant_name                   varchar2(200)
  , merchant_street                 varchar2(200)
  , merchant_city                   varchar2(200)
  , merchant_region                 varchar2(3)
  , merchant_country                varchar2(3)
  , merchant_postcode               varchar2(10)
  , terminal_type                   varchar2(8)
  , terminal_number                 varchar2(8)
  , card_mask                       varchar2(24)
  , card_number                     varchar2(24)
  , card_hash                       number(12)
  , card_seq_num                    number(4)
  , card_expiry                     date
  , service_code                    varchar2(3)
  , approval_code                   varchar2(6)
  , rrn                             varchar2(12)
  , trn                             varchar2(16)
  , oper_id                         varchar2(30)
  , original_id                     varchar2(30)
  , emv_5f2a                        number(4)
  , emv_5f34                        number(4)
  , emv_71                          varchar2(16)
  , emv_72                          varchar2(16)
  , emv_82                          varchar2(8)
  , emv_84                          varchar2(32)
  , emv_8a                          varchar2(32)
  , emv_91                          varchar2(32)
  , emv_95                          varchar2(10)
  , emv_9a                          number(6)
  , emv_9c                          number(2)
  , emv_9f02                        number(12)
  , emv_9f03                        number(12)
  , emv_9f06                        varchar2(64)
  , emv_9f09                        varchar2(4)
  , emv_9f10                        varchar2(64)
  , emv_9f18                        varchar2(8)
  , emv_9f1a                        number(4)
  , emv_9f1e                        varchar2(16)
  , emv_9f26                        varchar2(16)
  , emv_9f27                        varchar2(2)
  , emv_9f28                        varchar2(16)
  , emv_9f29                        varchar2(16)
  , emv_9f33                        varchar2(6)
  , emv_9f34                        varchar2(6)
  , emv_9f35                        number(2)
  , emv_9f36                        varchar2(32)
  , emv_9f37                        varchar2(32)
  , emv_9f41                        number(8)
  , emv_9f53                        varchar2(32)
  , pdc_1                           varchar2(8)
  , pdc_2                           varchar2(8)
  , pdc_3                           varchar2(8)
  , pdc_4                           varchar2(8)
  , pdc_5                           varchar2(8)
  , pdc_6                           varchar2(8)
  , pdc_7                           varchar2(8)
  , pdc_8                           varchar2(8)
  , pdc_9                           varchar2(8)
  , pdc_10                          varchar2(8)
  , pdc_11                          varchar2(8)
  , pdc_12                          varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition h2h_fin_message_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/

comment on table h2h_fin_message is 'H2H financial messages'
/
comment on column h2h_fin_message.id  is 'Primary key. Message identifier'
/
comment on column h2h_fin_message.split_hash is 'Hash value to split further processing'
/
comment on column h2h_fin_message.status is 'Message status'
/
comment on column h2h_fin_message.inst_id is 'Institution identifier'
/
comment on column h2h_fin_message.network_id is 'Network identifier'
/
comment on column h2h_fin_message.file_id is 'Reference to clearing file'
/
comment on column h2h_fin_message.is_invalid is 'Is financial message loaded with errors'
/
comment on column h2h_fin_message.is_incoming is 'Incoming/Outgouing message flag. 1 - incoming, 0 - outgoing'
/
comment on column h2h_fin_message.is_reversal is 'Reversal flag'
/
comment on column h2h_fin_message.is_collection_only is 'Collection only flag'
/
comment on column h2h_fin_message.is_rejected is 'Rejected message flag'
/
comment on column h2h_fin_message.reject_id is 'Reject message identifier. Reference to amx_rejected.id'
/
comment on column h2h_fin_message.dispute_id is 'Dispute identifier'
/
comment on column h2h_fin_message.file_type is 'Type of incoming/ongoing file. Describe the purpose of data in file. Dictionary FLTP: FLTPH2H – network to host-to-host'
/
comment on column h2h_fin_message.file_date is 'File Reference Date'
/
comment on column h2h_fin_message.forw_inst_id is 'Forwarding Institution ID'
/
comment on column h2h_fin_message.receiv_inst_id is 'Receiving Institution ID'
/
comment on column h2h_fin_message.file_id is 'Unique identifier of file'
/
comment on column h2h_fin_message.oper_type is 'Operation type. Dictionary OPTP in SV. Articles: OPTP0000 - Purchase, OPTP0001 - ATM Cash withdrawal, OPTP0009 - Purchase with casback, OPTP0012 - POS Cash advance, OPTP0018 - Unique Transaction (Quasi Cash), OPTP0028 - Payment transaction,  OPTP0020 - Purchase return (Credit), OPTP0010 - P2P Debit, OPTP0026 - P2P Credit'
/
comment on column h2h_fin_message.msg_type is 'Message type. Dictionary MSGT in SV. Articles: MSGTPRES'
/
comment on column h2h_fin_message.oper_date is 'Date when operation occurs (de 12)'
/
comment on column h2h_fin_message.oper_amount_value is 'Original operation amount value (de 4/de 49)'
/
comment on column h2h_fin_message.oper_amount_currency is 'Original operation currency (de 4/de 49)'
/
comment on column h2h_fin_message.oper_surcharge_amount_value is 'Operation surcharge amount value (de 54)'
/
comment on column h2h_fin_message.oper_surcharge_amount_currency is 'Operation surcharge amount curremcy (de 54)'
/
comment on column h2h_fin_message.oper_cashback_amount_value is 'Operation cashback amount value (de 54)'
/
comment on column h2h_fin_message.oper_cashback_amount_currency is 'Operation cashback amount currency (de 54)'
/
comment on column h2h_fin_message.sttl_amount_value is 'Settlement operation amount (de 5/de50). Used for h2h transactions in which participate IPS.'
/
comment on column h2h_fin_message.sttl_amount_currency is 'Settlement operation amount (de 5/de50). Used for h2h transactions in which participate IPS.'
/
comment on column h2h_fin_message.sttl_rate is 'Settlement conversion rate (de 9)'
/
comment on column h2h_fin_message.crdh_bill_amount_value is 'Cardholder billing amount value (de 6/de 51)'
/
comment on column h2h_fin_message.crdh_bill_amount_currency is 'Cardholder billing amount currency (de 6/de 51)'
/
comment on column h2h_fin_message.crdh_bill_rate is 'Cardholder billing conversion rate (de 10)'
/
comment on column h2h_fin_message.acq_inst_bin is 'Acquiring Institution ID Code (de 32)'
/
comment on column h2h_fin_message.arn is 'Acquirer Reference Data (de 31).Used for h2h transactions in which participate IPS. Field contains ARN which it get from IPS.'
/
comment on column h2h_fin_message.is_reversal is '0 – operation is not reversal, 1 – operation is reversal'
/
comment on column h2h_fin_message.merchant_number is 'Merchant number (de 42)'
/
comment on column h2h_fin_message.mcc is 'Merchant category code'
/
comment on column h2h_fin_message.merchant_name is 'Merchant name (de 43)'
/
comment on column h2h_fin_message.merchant_street is 'Merchant street address (de 43)'
/
comment on column h2h_fin_message.merchant_city is 'Merchant’s city (de 43)'
/
comment on column h2h_fin_message.merchant_region is 'Region of merchant (de 43)'
/
comment on column h2h_fin_message.merchant_country is 'Country of merchant (de 43)'
/
comment on column h2h_fin_message.merchant_postcode is 'Merchant’s postal code (de 43)'
/
comment on column h2h_fin_message.terminal_type is 'Terminal type. Dictionary TRMT in SV. Articles: ‘0’ - Unknown terminal type, ‘1’ - Imprinter, ‘2’ - ATM, ‘3’ - POS, ‘4’ - ePOS, ‘5’ - Mobile, ‘6’ - Internet, ‘7’ - Mobile POS'
/
comment on column h2h_fin_message.terminal_number is 'Terminal number (de 41)'
/
comment on column h2h_fin_message.card_number is 'Card number (de 2)'
/
comment on column h2h_fin_message.card_seq_num is 'Card sequential number (de 23)'
/
comment on column h2h_fin_message.card_expiry is 'Card expiration date (de 14)'
/
comment on column h2h_fin_message.service_code is 'Card service code (de 40)'
/
comment on column h2h_fin_message.approval_code is 'Approval Code (de 38)'
/
comment on column h2h_fin_message.rrn is 'Retrieval Reference Number (de 37)'
/
comment on column h2h_fin_message.trn is 'Transaction  Reference  Number (de 63). Internal identifier of a transaction (created by the sender`s system)'
/
comment on column h2h_fin_message.oper_id is 'Used for h2h transactions in which does not participate IPS.'
/
comment on column h2h_fin_message.original_id is 'Internal identifier of original transaction (created by the sender`s system). Used for: h2h transactions in which does not participate IPS. Reversal transaction only. It contains reference to original transaction.'
/
comment on column h2h_fin_message.emv_5F2A is 'Transaction Currency Code – Tag ‘5F2A’ – Taken from terminal initialisation table or chip card.'
/
comment on column h2h_fin_message.emv_5F34 is 'Application Primary Account Number (PAN) Sequence Number. This field is present if it was present in the chip card.'
/
comment on column h2h_fin_message.emv_71 is 'Issuer Script Template 1 – Tag 71’ – (Response Message) –Scripts from the issuer sent to the terminal for delivery to the ICC. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_72 is 'Issuer Script Template 2 – Tag 72’ – (Response Msg) – Scripts from the issuer sent to the terminal for delivery to the ICC. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_82 is 'Application Interchange Profile – Tag ‘82’ – Specifies the application functions that is supported by the card. The terminal attempts to execute only those functions that the ICC supports. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_84 is 'Dedicated File (DF) Name – Tag ‘84’ – Taken from the application (application specific data). Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_8A is 'Authorisation Response Code – Code that defines the disposition of a message.'
/
comment on column h2h_fin_message.emv_91 is 'Issuer Authentication Data – Tag ‘91’ – (Response Message) –Sent by the issuer if on-line issuer authentication is required. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_95 is 'Terminal Verification Result (TVR) – Tag ‘95’ – Status of the different functions as seen by the terminal during the processing of a transaction. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9A is 'Transaction Date – Tag ‘9A’ – Formatted as ‘YYMMDD’. Taken from terminal clock.'
/
comment on column h2h_fin_message.emv_9C is 'Transaction Type – Tag ‘9C’ – Taken from the transaction data'
/
comment on column h2h_fin_message.emv_9F02 is 'Transaction Amount – Tag ‘9F02’ – Taken from transaction data'
/
comment on column h2h_fin_message.emv_9F03 is 'Amount Other-Tag ‘9F03’'
/
comment on column h2h_fin_message.emv_9F06 is 'Application Identifier (AID) – Identifies the application as described in ISO/IEC 7816-5. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F09 is 'Terminal Application Version Number – Tag ‘9F09’. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F10 is 'Issuer Application Data (IAD) –Tag ‘9F10’. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F18 is 'Issuer Script Identifier – Identification of the Issuer Script. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F1A is 'Terminal Country Code – Tag ‘9F1A’'
/
comment on column h2h_fin_message.emv_9F1E is 'Interface Device (IFD) Serial Number-Tag ‘9F1E’'
/
comment on column h2h_fin_message.emv_9F26 is 'Application Cryptogram (AC) – Tag ‘9F26’. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F27 is 'Cryptogram Information Data – Tag ‘9F27’ – Used to approve offline transactions. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F28 is 'Authorisation Request Cryptogram (ARQC) – Tag ‘9F28’. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F29 is 'Transaction Certificate (TC) – Tag ‘9F29’. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F33 is 'Terminal Capabilities – Tag ‘9F33’ – Specifies the capabilities of the terminal. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F34 is 'CVM Results – Tag ‘9F34’ – Result of the last cardholder verification method. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F35 is 'Terminal Type – Tag ‘9F35’ – Specifies the type of terminal'
/
comment on column h2h_fin_message.emv_9F36 is 'Application Transaction Counter (ÀÒÑ) – Tag ‘9F36’ – from the card. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F37 is 'Unpredictable Number-Tag ‘9F37’ – Value to provide variability and uniqueness to the generation of the application cryptogram. Type of data Hexadecimal.'
/
comment on column h2h_fin_message.emv_9F41 is 'Transaction Sequence Counter-Tag ‘9F41’ – Counter maintained by the terminal that is incremented by one for each transaction'
/
comment on column h2h_fin_message.emv_9F53 is 'Transaction Category Code / Merchant Category Code – Tag ‘9F53’ – Usually provided by the acquirer'
/
comment on column h2h_fin_message.pdc_1 is 'Card data input capability. Dictionary F221 in SV. 0 - Unknown; data not available. 1 - Manual; no terminal. 2 - Magnetic stripe reader capability. 3 - Barcode reader. 4 - Optical character reader (OCR) capability. 5 - Integrated circuit card (ICC) capability. 6 - Key entry-only capability. A - PAN auto-entry via contactless magnetic stripe. B - Magnetic stripe reader and key entry capability. C - Magnetic stripe reader, ICC, and key entry capability. D - Magnetic stripe reader and ICC capability. E - ICC and key entry capability. M - PAN auto-entry via contactless M/Chip. V - Other capability'
/
comment on column h2h_fin_message.pdc_2 is 'Cardholder authentication capability. Dictionary F222 in SV. 0 - No electronic authentication capability. 1 - PIN entry capability. 2 - Electronic signature analysis capability. 5 - Electronic authentication capability is inoperative. 6 - Other. 8 - PIN entry capability with PIN pad. 9 - Unknown; data unavailable'
/
comment on column h2h_fin_message.pdc_3 is 'Card capture capability. Dictionary F223 in SV. 0 - No capture capability. 1 - Card capture capability. 2 - Unknown; data unavailable'
/
comment on column h2h_fin_message.pdc_4 is 'Operating environment. Dictionary F224 in SV.. 0 - No terminal used. 1 - On card acceptor premises; attended terminal. 2 - On card acceptor premises; unattended terminal. 3 - Off card acceptor premises; attended. 4 - Off card acceptor premises; unattended. 5 - On cardholder premises; unattended. 6 - Off cardholder premises; unattended. 7 - Private use (Future use). 9 - Unknown; data unavailable. A - Attended cardholder terminal on card acceptor premises. B - Unattended cardholder terminal on card acceptor premises'
/
comment on column h2h_fin_message.pdc_5 is 'Cardholder presence indicator. Dictionary F225 in SV.. 0 - Cardholder present. 1 - Cardholder not present (unspecified). 2 - Cardholder not present (mail/facsimile transaction). 3 - Cardholder not present (phone order or from automated response unit [ARU]). 4 - Cardholder not present (standing order/recurring transaction). 5 - Cardholder not present (electronic order [PC, Internet, mobile phone or PDA]). 9 - Unknown; data unavailable'
/
comment on column h2h_fin_message.pdc_6 is 'Card presence indicator. Dictionary F226 in SV.. 0 - Card present. 1 - Card not present. 9 - Unknown; data unavailable'
/
comment on column h2h_fin_message.pdc_7 is 'Card data input mode. Dictionary F227 in SV. in SV. 0 - Unspecified; data unavailable. 1 - Manual input; no terminal. 2 - Magnetic stripe reader input. 3 - Barcode reader. 5 - Secured electronic commerce, 3D-security. 6 - Key entered input. 7 - Electronic commerce, channel encryption. 8 - Master Pass channel encrypted. 9 - Electronic commerce, cardholder does not participate in security programm. A - PAN auto-entry via contactless magnetic stripe. B - Magnetic stripe reader input; track data captured and passed unaltered. C - Online chip. D - Master Digital Secure Remote Payment. E - Credential on file. F - Offline chip. M - PAN auto-entry via contactless M/Chip. N - Contactless input, PayPass mapping service applied. P - PAN entry via contactless magstripe, with PayPass Mapping service applied. R - PAN entry via electronic commerce, including remote chip. S - Electronic commerce. W - PAN Auto Entry via Server (issuer, acquirer, or third party vendor system). W - Automatic'
/
comment on column h2h_fin_message.pdc_8 is 'Cardholder authentication method. Dictionary F228 in SV. 0 - Not authenticated. 1 - PIN. 2 - Electronic signature analysis. 5 - Manual signature verification. 6 - Other manual verification (such as driver`s license number). 9 - Unknown; data unavailable. S - Other systematic verification'
/
comment on column h2h_fin_message.pdc_9 is 'Cardholder authentication entity. Dictionary F229 in SV.. 0 - Not authenticated. 1 - ICC - offline PIN. 2 - Card acceptance device (CAD). 3 - Authorizing agent - online PIN. 4 - Merchant/card acceptor - signature. 5 - Other. 6 - Merchant is suspicious. 9 - Unknown; data unavailablecomment on column h2h_fin_message.pdc_1. Card data output capability. Dictionary F22A in SV. 0 - Unknown; data unavailable. 1 - None. 2 - Magnetic stripe write. 3 - ICC. S - Other'
/
comment on column h2h_fin_message.pdc_11 is 'Terminal output capability. Dictionary F22B in SV.. 0 - Unknown; data unavailable. 1 - None. 2 - Printing capability only. 3 - Display capability only. 4 - Printing and display capability'
/
comment on column h2h_fin_message.pdc_12 is 'Pin capture capability. Dictionary F22C in SV.. 0 - No PIN capture capability. 1 - Unknown; data unavailable. 2 - Reserved. 3 - Reserved. 4 - PIN capture capability 4 characters maximum. 5 - PIN capture capability 5 characters maximum. 6 - PIN capture capability 6 characters maximum. 7 - PIN capture capability 7 characters maximum. 8 - PIN capture capability 8 characters maximum. 9 - PIN capture capability 9 characters maximum. A - PIN capture capability 10 characters maximum. B - PIN capture capability 11 characters maximum. C - PIN capture capability 12 characters maximum'
/
comment on column h2h_fin_message.pdc_1 is 'Card data input capability. Dictionary F221 in SV.'
/
comment on column h2h_fin_message.pdc_2 is 'Cardholder authentication capability. Dictionary F222 in SV.'
/
comment on column h2h_fin_message.pdc_3 is 'Card capture capability. Dictionary F223 in SV.'
/
comment on column h2h_fin_message.pdc_4 is 'Operating environment. Dictionary F224 in SV.'
/
comment on column h2h_fin_message.pdc_5 is 'Cardholder presence indicator. Dictionary F225 in SV.'
/
comment on column h2h_fin_message.pdc_6 is 'Card presence indicator. Dictionary F226 in SV.'
/
comment on column h2h_fin_message.pdc_7 is 'Card data input mode. Dictionary F227 in SV.'
/
comment on column h2h_fin_message.pdc_8 is 'Cardholder authentication method. Dictionary F228 in SV.'
/
comment on column h2h_fin_message.pdc_9 is 'Cardholder authentication entity. Dictionary F229 in SV.'
/
comment on column h2h_fin_message.pdc_11 is 'Terminal output capability. Dictionary F22B in SV.'
/
comment on column h2h_fin_message.pdc_12 is 'Pin capture capability. Dictionary F22C in SV.'
/
comment on column h2h_fin_message.pdc_10 is 'Card Data Output Capability'
/
comment on column h2h_fin_message.card_hash is 'Card number hash value'
/
comment on column h2h_fin_message.card_mask is 'Masked card number'
/
comment on column h2h_fin_message.incom_sess_file_id is 'Reference to the incoming file from which the operation was created'
/
alter table h2h_fin_message add forw_inst_code varchar2(11)
/
comment on column h2h_fin_message.forw_inst_code is 'Forwarding Institution code'
/
alter table h2h_fin_message add receiv_inst_code varchar2(11)
/
comment on column h2h_fin_message.receiv_inst_code is 'Receiving Institution code'
/
alter table h2h_fin_message modify (terminal_number varchar2(16))
/
alter table h2h_fin_message drop column forw_inst_id
/
alter table h2h_fin_message drop column receiv_inst_id
/
comment on column h2h_fin_message.forw_inst_code is 'Forwarding institution code (external)'
/
comment on column h2h_fin_message.receiv_inst_code is 'Receiving Institution code  (external)'
/
comment on column h2h_fin_message.split_hash is 'Hash value for multi-threaded unloading of messages, this value doesn''t relate to customer split_hash'
/
alter table h2h_fin_message drop column card_mask
/
alter table h2h_fin_message drop column card_hash
/
alter table h2h_fin_message drop column is_invalid
/
alter table h2h_fin_message drop column card_number
/
alter table h2h_fin_message modify (pdc_1 varchar2(1))
/
comment on column h2h_fin_message.pdc_1 is 'Card data input capability (analog of dictionary F221)'
/
alter table h2h_fin_message modify (pdc_2 varchar2(1))
/
comment on column h2h_fin_message.pdc_2 is 'Cardholder authentication capability (analog of dictionary F222)'
/
alter table h2h_fin_message modify (pdc_3 varchar2(1))
/
comment on column h2h_fin_message.pdc_3 is 'Card capture capability (analog of dictionary F223)'
/
alter table h2h_fin_message modify (pdc_4 varchar2(1))
/
comment on column h2h_fin_message.pdc_4 is 'Operating environment (analog of dictionary F224)'
/
alter table h2h_fin_message modify (pdc_5 varchar2(1))
/
comment on column h2h_fin_message.pdc_5 is 'Cardholder presence indicator (analog of dictionary F225)'
/
alter table h2h_fin_message modify (pdc_6 varchar2(1))
/
comment on column h2h_fin_message.pdc_6 is 'Card presence indicator (analog of dictionary F226)'
/
alter table h2h_fin_message modify (pdc_7 varchar2(1))
/
comment on column h2h_fin_message.pdc_7 is 'Card data input mode (analog of dictionary F227)'
/
alter table h2h_fin_message modify (pdc_8 varchar2(1))
/
comment on column h2h_fin_message.pdc_8 is 'Cardholder authentication method (analog of dictionary F228)'
/
alter table h2h_fin_message modify (pdc_9 varchar2(1))
/
comment on column h2h_fin_message.pdc_9 is 'Cardholder authentication entity (analog of dictionary F229)'
/
alter table h2h_fin_message modify (pdc_10 varchar2(1))
/
comment on column h2h_fin_message.pdc_10 is 'Card data output capability (analog of dictionary F22A)'
/
alter table h2h_fin_message modify (pdc_11 varchar2(1))
/
comment on column h2h_fin_message.pdc_11 is 'Terminal output capability (analog of dictionary F22B)'
/
alter table h2h_fin_message modify (pdc_12 varchar2(1))
/
comment on column h2h_fin_message.pdc_12 is 'PIN capture capability (analog of dictionary F22C)'
/
alter table h2h_fin_message drop column incom_sess_file_id
/
