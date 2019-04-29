create table vis_vcr_advice (
    id                       number(16)
  , file_id                  number(16)
  , record_number            number(6)
  , status                   varchar2(8)
  , inst_id                  number(4)
  , trans_code               varchar2(2)
  , trans_code_qualifier     varchar2(1)
  , trans_component_seq      varchar2(1)
  , dest_bin                 varchar2(6)
  , source_bin               varchar2(6)
  , vcr_record_id            varchar2(3)
  , dispute_status           varchar2(2)
  , dispute_trans_code       varchar2(2)
  , pos_condition_code       varchar2(2)
  , dispute_tc_qualifier     varchar2(1)
  , orig_recipient_ind       varchar2(1)
  , card_number_ext          varchar2(3)
  , acq_inst_code            varchar2(11)
  , rrn                      varchar2(12)
  , acq_ref_number           varchar2(24)
  , purchase_date            varchar2(4)
  , source_amount            number(22,4)
  , source_curr_code         varchar2(3)
  , merchant_name            varchar2(30)
  , merchant_city            varchar2(14)
  , merchant_country         varchar2(3)
  , mcc                      varchar2(4)
  , merchant_region_code     varchar2(3)
  , merchant_postal_code     varchar2(10)
  , req_payment_service      varchar2(1)
  , auth_code                varchar2(6)
  , pos_entry_mode           varchar2(2)
  , central_proc_date        varchar2(4)
  , card_acceptor_id         varchar2(16)
  , reimbursement            varchar2(1)
  , network_code             varchar2(4)
  , dispute_condition        varchar2(3)
  , vrol_fin_id              varchar2(11)
  , vrol_case_number         varchar2(10)
  , vrol_bundle_case_num     varchar2(10)
  , client_case_number       varchar2(20)
  , clearing_seq_number      varchar2(2)
  , clearing_seq_count       varchar2(2)
  , product_id               varchar2(2)
  , spend_qualified_ind      varchar2(1)

  , dsp_fin_reason_code      varchar2(2)
  , processing_code          varchar2(2)
  , settlement_flag          varchar2(1)
  , usage_code               varchar2(1)
  , trans_identifier         varchar2(15)
  , acq_business_id          varchar2(8)
  , orig_trans_amount        number(22,4)
  , orig_trans_curr_code     varchar2(3)
  , spec_chargeback_ind      varchar2(1)
  , message_reason_code      number(4)
)
/


comment on table vis_vcr_advice is 'Table for store TC 33 (for BASE II and V.I.P.)'
/
comment on column vis_vcr_advice.trans_code           is 'Value of 33 (Dispute financial status advice).'
/
comment on column vis_vcr_advice.trans_code_qualifier is 'Value of 0 (BASE II VCR financial)'
/
comment on column vis_vcr_advice.trans_component_seq  is 'Value of 0 (zero)'
/
comment on column vis_vcr_advice.dest_bin             is 'Valid destination BIN'
/
comment on column vis_vcr_advice.source_bin           is 'Valid source BIN'
/
comment on column vis_vcr_advice.vcr_record_id        is 'Value of VCR to identify this TC 33 record as a VCR status advice'
/
comment on column vis_vcr_advice.dispute_status       is 'Code to indicate the status of the VCR dispute. Valid values are F1 (Dispute financial) R1 (Dispute financial reversal—recall) R2 (Dispute financial reversal—pre-arbitration acceptance) R3 (Dispute financial reversal—arbitration decision)   • P1 (Dispute response financial) L1 (Dispute response financial reversal—recall)  L2 (Dispute response financial reversal—pre-arbitration acceptance)  L3 (Dispute response financial reversal—arbitration decision'
/
comment on column vis_vcr_advice.pos_condition_code   is 'POS Condition Code'
/
comment on column vis_vcr_advice.dispute_tc_qualifier is 'Transaction code qualifier of the dispute transaction'
/
comment on column vis_vcr_advice.orig_recipient_ind   is 'Value that indicates if the advice is being delivered to the dispute originator or the dispute recipient. O(Originator)/R(Recipient)'
/
comment on column vis_vcr_advice.card_number_ext      is 'Account number extension'
/
comment on column vis_vcr_advice.acq_ref_number       is '23-digit identification number, assigned by the acquirer'
/
comment on column vis_vcr_advice.purchase_date        is 'Date the original transaction was made.'
/
comment on column vis_vcr_advice.source_amount        is 'Dispute value in transaction currency. This field is right-justified. Two decimal places are implied. The entry must be a numeric greater than zero.'
/
comment on column vis_vcr_advice.source_curr_code     is 'Currency code used in this transaction.'
/
comment on column vis_vcr_advice.merchant_name        is 'Name of the merchant'
/
comment on column vis_vcr_advice.merchant_city        is 'Merchant city, telephone number, email address, or URL'
/
comment on column vis_vcr_advice.merchant_country     is 'Code indicating the country where the Visa transaction occurred.REFERENCE For valid country codes, refer to BASE II Clearing Data Codes'
/
comment on column vis_vcr_advice.mcc                  is 'Merchant category code.'
/
comment on column vis_vcr_advice.merchant_region_code is 'If the code in Merchant Country, positions 125–127, is US or CA,  the U.S. state code or Canadian province code, respectively. Otherwise, it will contain spaces.'
/
comment on column vis_vcr_advice.merchant_postal_code is 'Postal code of the merchant where the transaction took place.'
/
comment on column vis_vcr_advice.req_payment_service  is 'Code indicating the acquirer’s choice of custom payment service.'
/
comment on column vis_vcr_advice.auth_code            is 'Code provided by the issuer when the original transaction was approved.'
/
comment on column vis_vcr_advice.pos_entry_mode       is 'Value indicating the method by which a point-of-transaction terminal obtains and transmits the cardholder information necessary to complete a transaction.'
/
comment on column vis_vcr_advice.central_proc_date    is 'Date that BASE II processes the dispute financial transaction. The date will be in yddd format, where: yddd = Julian date'
/
comment on column vis_vcr_advice.card_acceptor_id     is 'Code that identifies the card acceptor from the original transaction'
/
comment on column vis_vcr_advice.reimbursement        is 'Reimbursement attribute.'
/
comment on column vis_vcr_advice.network_code         is 'Network identification code. 0002(Visa)/0003(Interlink)/0004(Plus). NOTE: The network identification code field populated with all zeros is allowed'
/
comment on column vis_vcr_advice.dispute_condition    is 'Dispute condition assigned through the Visa Claims Resolution process.'
/
comment on column vis_vcr_advice.vrol_fin_id          is 'VROL financial ID assigned through the Visa Claims Resolution process.'
/
comment on column vis_vcr_advice.vrol_case_number     is 'VROL case number assigned through the Visa Claims Resolution process.'
/
comment on column vis_vcr_advice.vrol_bundle_case_num is 'VROL bundle case number when the dispute is part of a bundle.'
/
comment on column vis_vcr_advice.client_case_number   is 'Case tracking number assigned by the endpoint in VROL when a VCR dispute is created.'
/
comment on column vis_vcr_advice.clearing_seq_number  is 'Sequence number that distinguishes a specific clearing message among multiple clearing messages being submitted for a single authorization.'
/
comment on column vis_vcr_advice.clearing_seq_count   is 'Count of multiple clearing sequence.'
/
comment on column vis_vcr_advice.product_id           is 'Product identifier code.'
/
comment on column vis_vcr_advice.spend_qualified_ind  is 'Code that indicates whether the account is spend qualified or not. Valid values are: • Space (Spend processing does not apply (not applicable)) • B (Base spend assessment threshold defined by Visa has been met) • N (Spend assessment threshold defined by Visa has not been met) • Q (Spend assessment threshold defined by Visa has been met)'
/
comment on column vis_vcr_advice.dsp_fin_reason_code  is 'One of the new reason codes used to identify the dispute category for disputes processed through Visa Claims Resolution. Valid values are: • 10 (Fraud) • 11 (Authorization) • 12 (Processing error) • 13 (Consumer dispute)'
/
comment on column vis_vcr_advice.dsp_fin_reason_code  is 'A code identifying the customer transaction type or the center function being processed.'
/
comment on column vis_vcr_advice.settlement_flag      is 'Value that indicates the service used for settlement. 0(International settlement service)/3(Clearing-only (valid only for countries with defined service))/8(National net settlement service (valid only for countries with defined service))/9(BASE II selects the appropriate settlement service based on routing and country-defined default)'
/
comment on column vis_vcr_advice.usage_code           is 'New usage code value of 9 (Dispute financial).'
/
comment on column vis_vcr_advice.trans_identifier     is 'Transaction identifier, a unique value that Visa assigns to each transaction and returns to the acquirer in the authorization response. Visa uses this value to maintain an audit trail throughout the life cycle of the transaction and all related transactions, such as reversals, adjustments, confirmations, and dispute financials.'
/
comment on column vis_vcr_advice.acq_business_id      is 'Visa-assigned business ID of the acquirer.'
/
comment on column vis_vcr_advice.orig_trans_amount    is 'Original transaction amount for the dispute processed through the VCR. This field is right-justified. Two decimal places are implied. NOTE When the original transaction amount is greater than the source amount the special chargeback indicator field will contain the value of P (Partial amount).'
/
comment on column vis_vcr_advice.orig_trans_curr_code is 'Original transaction currency code for the dispute processed through the VCR process.'
/
comment on column vis_vcr_advice.spec_chargeback_ind  is 'Value that indicates if the amount disputed is the full amount of the original transaction or a partial amount. P(Partial amount)/Space (Not applicable)'
/
comment on column vis_vcr_advice.pos_condition_code   is 'Point-of-sale (POS) condition code of the dispute transaction.'
/
comment on column vis_vcr_advice.rrn                  is 'Retrieval reference number of the financial dispute transaction processed through the VCR process'
/
comment on column vis_vcr_advice.acq_inst_code        is 'Code that identifies the financial institution acting as the acquirer of the transaction'
/
comment on column vis_vcr_advice.message_reason_code  is 'One of the reason codes used to identify the dispute category for disputes processed through VCR. 0010(Fraud)/0011(Authorization)/0012(Processing error)/0013(Consumer dispute)'
/
alter table vis_vcr_advice add (dest_amount  number(22,4))
/
alter table vis_vcr_advice add (dest_curr_code  varchar2(3))
/
comment on column vis_vcr_advice.dest_amount is 'Destination amount'
/
comment on column vis_vcr_advice.dest_curr_code is 'Destination currency code'
/

alter table vis_vcr_advice add (src_sttl_amount_sign varchar2(1))
/
comment on column vis_vcr_advice.src_sttl_amount_sign is 'Sign of source settlement amount for the recipient of the advice (C-Credit, D-Debit)'
/
comment on column vis_vcr_advice.dest_amount          is 'Destination/Source Settlement Amount'
/
comment on column vis_vcr_advice.dest_curr_code       is 'Destination/Source Settlement Currency Code'
/
