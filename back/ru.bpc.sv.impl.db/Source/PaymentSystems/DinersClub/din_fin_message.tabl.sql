create table din_fin_message(
    id                           number(16)
  , status                       varchar2(8)
  , file_id                      number(16)
  , record_number                number(8)
  , batch_id                     number(12)
  , sequential_number            number(3)
  , is_incoming                  number(1)
  , is_rejected                  number(1)
  , is_reversal                  number(1)
  , is_invalid                   number(1)
  , network_id                   number(4)
  , inst_id                      number(4)
  , sending_institution          varchar2(2)
  , receiving_institution        varchar2(2)
  , dispute_id                   number(16)
  , originator_refnum            varchar2(8)
  , network_refnum               varchar2(15)
  , card_id                      number
  , type_of_charge               varchar2(2)
  , charge_type                  varchar2(3)
  , date_type                    varchar2(2)
  , charge_date                  date
  , sttl_date                    date
  , host_date                    date
  , auth_code                    varchar2(6)
  , action_code                  number(3)
  , oper_amount                  number(22, 4)
  , oper_currency                varchar2(3)
  , sttl_amount                  number(22, 4)
  , sttl_currency                varchar2(3)
  , mcc                          varchar2(4)
  , merchant_number              varchar2(15)
  , merchant_name                varchar2(36)
  , merchant_city                varchar2(26)
  , merchant_country             varchar2(3)
  , merchant_state               varchar2(20)
  , merchant_street              varchar2(35)
  , merchant_postal_code         varchar2(11)
  , merchant_phone               varchar2(20)
  , merchant_international_code  number(4)
  , terminal_number              varchar2(16)
  , program_transaction_amount   number(22, 4)
  , alt_currency                 varchar2(3)
  , alt_rate_type                varchar2(8)
  , tax_amount1                  number(22, 4)
  , tax_amount2                  number(22, 4)
  , original_document_number     varchar2(15)
  , crdh_presence                varchar2(1)
  , card_presence                varchar2(1)
  , card_data_input_mode         varchar2(1)
  , card_data_input_capability   varchar2(1)
)
/

comment on table din_fin_message is 'Diners Club financial messages. There are character codes with field names from the specification in comments (in square brackets)'
/
comment on column din_fin_message.id is 'Primary key. It contains the same value as in corresponding record in OPR_OPERATION table'
/
comment on column din_fin_message.status is 'Message status (CLMS dictionary)'
/
comment on column din_fin_message.file_id is 'Reference to a clearing file (primary key of the table DIN_FILE and PRC_SESSION_FILE)'
/
comment on column din_fin_message.record_number is 'Record number in a clearing file'
/
comment on column din_fin_message.batch_id is 'Batch identifier, it relates to the primary key of DIN_BATCH'
/
comment on column din_fin_message.sequential_number is 'Sequential number of financial message in a batch [SEQNO]'
/
comment on column din_fin_message.is_incoming is 'Incoming/outgouing message flag (1 — incoming, 0 — outgoing)'
/
comment on column din_fin_message.is_rejected is 'Rejected message flag (1 — message was rejected by Diners Club)'
/
comment on column din_fin_message.is_reversal is 'Reversal flag'
/
comment on column din_fin_message.is_invalid is 'Loading/parsing error flag'
/
comment on column din_fin_message.network_id is 'Network ID (as usual Diners Club network ID)'
/
comment on column din_fin_message.inst_id is 'Institution ID that generates (ACQ) an outgoing message or receives (ISS) an incoming message'
/
comment on column din_fin_message.sending_institution is 'Sending institution identification code [SFTER]. For outgoing clearing it is associated with the field INST_ID (ACQ institution)'
/
comment on column din_fin_message.receiving_institution is 'Receiving institution identification code [DFTER]. For incoming clearing it is associated with the field INST_ID (ISS institution)'
/
comment on column din_fin_message.dispute_id is 'Reference to a dispute message group'
/
comment on column din_fin_message.network_refnum is 'Network reference ID [NRID]'
/
comment on column din_fin_message.card_id is 'Card identifier'
/
comment on column din_fin_message.type_of_charge is 'Type of Charge. It indicates debit or credit; and charge acquisition — paper backup, electronically, or Internet [TYPCH]'
/
comment on column din_fin_message.charge_type is 'Charge type (DXS format) [CHTYP]'
/
comment on column din_fin_message.date_type is 'Date type [DATYP]'
/
comment on column din_fin_message.charge_date is 'Operation (charge) date [CHGDT]'
/
comment on column din_fin_message.sttl_date is 'Acquirer date and time [SCGMT/SCDAT], for ATM additional detail record'
/
comment on column din_fin_message.host_date is 'Local date and time [LCTIM/LCDAT], for ATM additional detail record'
/
comment on column din_fin_message.auth_code is 'Authorization number / Approval code (DE 38) [ANBR]'
/
comment on column din_fin_message.action_code is 'Action code [APPCD]'
/
comment on column din_fin_message.oper_amount is 'Operation (charge) amount in currency of charge [CAMTR]'
/
comment on column din_fin_message.oper_currency is 'Operation (charge) currency ISO code'
/
comment on column din_fin_message.sttl_amount is 'Operation (charge) amount in issuer currency [BLAMT]'
/
comment on column din_fin_message.sttl_currency is 'Settlement currecny ISO code (Issuer billing currency code) [BLCUR]'
/
comment on column din_fin_message.merchant_number is 'Merchant ISO number (Member establishment number) [SENUM]'
/
comment on column din_fin_message.merchant_name is 'Merchant name (Merchant establishment name) [ESTAB]'
/
comment on column din_fin_message.merchant_city is 'Merchant city (Merchant establishment city) [LCITY]'
/
comment on column din_fin_message.merchant_country is 'Merchant country (Geographic Area Code) [GEOCD]'
/
comment on column din_fin_message.merchant_state is 'Merchant state (Establishment State/County/Province) [ESTCO]'
/
comment on column din_fin_message.merchant_street is 'Merchant street (Establishment Street Address) [ESTST]'
/
comment on column din_fin_message.merchant_postal_code is 'Merchant postal/zip code (Establishment Zip Code) [ESTZP]'
/
comment on column din_fin_message.merchant_phone is 'Merchant phone number (Establishment Phone Number) [ESTPN]'
/
comment on column din_fin_message.merchant_international_code is 'Merchant international code (International Establishment Code) [INTES]'
/
comment on column din_fin_message.terminal_number is 'Terminal ISO number [ATMID], for ATM additional detail record'
/
comment on column din_fin_message.program_transaction_amount is 'Program transaction amount [DRATE]. It represents percent that is used for calculating Recap message net amount (RNAMT)'
/
comment on column din_fin_message.alt_currency is 'Alternate currency name [ACRKY]. It is 3 characters name (ISO) that is used for calculating alternate gross (AGAMT) and net amounts (ACAMT) for a recap trailer'
/
comment on column din_fin_message.alt_rate_type is 'Alternate currency rate type (RTTP dictionary) that is used to fetch a convertation rate for alternate currency (ACRKY)'
/
comment on column din_fin_message.mcc is 'Merchant category code [MCCCD]'
/
comment on column din_fin_message.originator_refnum is 'Retrieval reference number (RRN) [REFNO]'
/
comment on column din_fin_message.tax_amount1 is 'Tax 1 amount (in Currency of charge) [TAX1]'
/
comment on column din_fin_message.tax_amount2 is 'Tax 2 amount (in Currency of charge) [TAX2]'
/
comment on column din_fin_message.original_document_number is 'Original ticket or document number. Used for refund transaction, etc. [ORIGD]'
/
comment on column din_fin_message.crdh_presence is 'Cardholder presence indicator [CHOLDP]. DE 22, subfield 5 (0 — present; overwise, not present: 1 — unspecified reason, 2 — mail order request, 3 — phone request, 4 — standing order, 9 — Internet; S — unknown)'
/
comment on column din_fin_message.card_presence is 'Card presence indicator [CARDP]. DE22, subfield 6 (0 — card was not present; 1 — card was present; 8 — unknown)'
/
comment on column din_fin_message.card_data_input_mode is 'Input method indicator for card data [CPTRM]. DE 22, subfield 7'
/
comment on column din_fin_message.card_data_input_capability is 'Card data input capacity indicator [CRDINP]. DE22, subfield 1 (0 — unknown; 1 — manual entry; 2 — magnetic stripe read; 5 — ICC read; 6 — key entered at POS; 8 — contactlessl; 9 — hybrid)'
/
comment on column din_fin_message.is_incoming is 'Incoming/outgouing message flag (1 - incoming, 0 - outgoing)'
/
comment on column din_fin_message.is_rejected is 'Rejected message flag (1 - message was rejected by Diners Club)'
/
comment on column din_fin_message.crdh_presence is 'Cardholder presence indicator [CHOLDP]. DE 22, subfield 5 (0 - present; overwise, not present: 1 - unspecified reason, 2 - mail order request, 3 - phone request, 4 - standing order, 9 - Internet; S - unknown)'
/
comment on column din_fin_message.card_presence is 'Card presence indicator [CARDP]. DE22, subfield 6 (0 - card was not present; 1 - card was present; 8 - unknown)'
/
comment on column din_fin_message.card_data_input_capability is 'Card data input capacity indicator [CRDINP]. DE22, subfield 1 (0 - unknown; 1 - manual entry; 2 - magnetic stripe read; 5 - ICC read; 6 - key entered at POS; 8 - contactlessl; 9 - hybrid)'
/
comment on column din_fin_message.crdh_presence is 'Cardholder presence indicator [CHOLDP]. DE 22, subfield 5 (0 — present; otherwise, not present: 1 — unspecified reason, 2 — mail order request, 3 — phone request, 4 — standing order, 9 — Internet; S — unknown)'
/
comment on column din_fin_message.crdh_presence is 'Cardholder presence indicator [CHOLDP]. DE 22, subfield 5 (0 - present; otherwise, not present: 1 - unspecified reason, 2 - mail order request, 3 - phone request, 4 - standing order, 9 - Internet; S - unknown)'
/
alter table din_fin_message add (card_type varchar2(1))
/
comment on column din_fin_message.card_type is 'Card Type [VCRDD] (S - Standard Card Number (PAN), V - Virtual Card Number, D - Digital Token)'
/
alter table din_fin_message add (payment_token varchar2(19))
/
comment on column din_fin_message.payment_token is 'Payment Token [TKNID]'
/
alter table din_fin_message add (token_requestor_id varchar2(11))
/
comment on column din_fin_message.token_requestor_id is 'Token Requestor ID [TKRQID]'
/
alter table din_fin_message add (token_assurance_level varchar2(2))
/
comment on column din_fin_message.token_assurance_level is 'Token Assurance Level [TKLVL] (01 - VCN Mapped to PAN and transaction enriched, 02 - VCN Mapped to PAN)'
/
