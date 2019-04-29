create table mcw_250byte_message(
    id                      number(16)
  , status                  varchar2(8)
  , file_id                 number(16)
  , record_number           number(8)
  , inst_id                 number(4)
  , network_id              number(4)
  , card_id                 number(12)
  , oper_id                 number(16)
  , mti                     varchar2(4)
  , switch_serial_number    varchar2(9)
  , processor               varchar2(1)
  , processor_id            varchar2(4)
  , transaction_date        date
  , pan_length              number(2)
  , card_number             varchar2(19)  
  , proc_code               varchar2(6)
  , trace_number            varchar2(6)
  , mcc                     varchar2(4)
  , pos_entry               varchar2(3)
  , reference_number        varchar2(12)
  , acq_institution_id      varchar2(10)
  , terminal_id             varchar2(10)
  , resp_code               varchar2(2)
  , brand                   varchar2(3)
  , advice_reason_code      varchar2(7)
  , intra_cur_agrmt_code    varchar2(4)    
  , authorization_id        varchar2(6)
  , trans_currency          varchar2(3)  
  , trans_implied_decimal   varchar2(1)
  , trans_amount            number(22,4)
  , trans_indicator         varchar2(1)
  , cashback_amount         number(22,4)    
  , cashback_indicator      varchar2(1)
  , access_fee              number(22,4)
  , access_fee_indicator    varchar2(1)
  , sttl_currency           varchar2(3)  
  , sttl_implied_decimal    varchar2(1)
  , sttl_rate               number(22,4)
  , sttl_amount             number(22,4)
  , sttl_indicator          varchar2(1)
  , interchange_fee         number(22,4)
  , intrchg_fee_indicator   varchar2(1)
  , positive_id_indicator   varchar2(1)
  , cross_border_indicator  varchar2(1)
  , crossb_curr_indicator   varchar2(1)
  , isa_fee_indicator       varchar2(1)
  , request_amount          number(22,4)
  , trace_number_adjust     varchar2(6)
)
/
comment on table mcw_250byte_message is 'MasterCard. Financial (FREC)/Non-financial (NREC) Records.'
/
comment on column mcw_250byte_message.id is 'Primary key.'
/
comment on column mcw_250byte_message.status is 'Message status.'
/
comment on column mcw_250byte_message.file_id is 'Reference to clearing file.'
/
comment on column mcw_250byte_message.record_number is 'Number of record in clearing file.'
/
comment on column mcw_250byte_message.inst_id is 'Institution identifier.'
/
comment on column mcw_250byte_message.network_id is 'Payment network identifier.'
/
comment on column mcw_250byte_message.card_id is 'Reference to card dictionary.'
/
comment on column mcw_250byte_message.oper_id is 'Reference to operation identifier.'
/
comment on column mcw_250byte_message.mti is 'The Message Type Identifier (MTI) is a four-digit numeric field describing the type of message being interchanged.'
/
comment on column mcw_250byte_message.switch_serial_number is 'Switch Serial Number.'
/
comment on column mcw_250byte_message.processor is 'Type of Processor listed in the FHDR record. Valid values are: A Acquirer I Issuer.'
/
comment on column mcw_250byte_message.processor_id is 'MasterCard-assigned acquirer or issuer processor ID. The acquirer processor ID appears in the last four positions of DE 33 in the ISO online message or as a processor option.'
/
comment on column mcw_250byte_message.transaction_date is 'Local date and time from the acquirer. '
/
comment on column mcw_250byte_message.pan_length is 'Length of significant number of Primary Account Number (PAN) digits.'
/
comment on column mcw_250byte_message.card_number is 'Primary Account Number (PAN). Card mask.'
/
comment on column mcw_250byte_message.proc_code is 'Processing code.'
/
comment on column mcw_250byte_message.trace_number is 'Trace Number.'
/
comment on column mcw_250byte_message.mcc is 'Merchant Type (MCC).'
/
comment on column mcw_250byte_message.pos_entry is 'POS Entry.'
/
comment on column mcw_250byte_message.reference_number is 'Reference Number.'
/
comment on column mcw_250byte_message.acq_institution_id is 'Acquirer Institution ID.'
/
comment on column mcw_250byte_message.terminal_id is 'The values for this field are derived from DE 41.'
/
comment on column mcw_250byte_message.resp_code is 'Response Code.'
/
comment on column mcw_250byte_message.brand is 'Includes the Brand and interchange type.'
/
comment on column mcw_250byte_message.advice_reason_code is 'Advice Reason Code.'
/
comment on column mcw_250byte_message.intra_cur_agrmt_code is 'If present, represents the currency in which the transaction will settle.'
/
comment on column mcw_250byte_message.authorization_id is 'Authorization ID.'
/
comment on column mcw_250byte_message.trans_currency is 'Currency Code—Transaction.'
/
comment on column mcw_250byte_message.trans_implied_decimal is 'Implied decimal of Currency Code—Transaction.'
/
comment on column mcw_250byte_message.trans_amount is 'Completed Amt Trans—Local.'
/
comment on column mcw_250byte_message.trans_indicator is 'Indicates whether the value is a credit or debit. Valid values are: C Credit to the receiver D Debit to the receiver.'
/
comment on column mcw_250byte_message.cashback_amount is 'Cash Back Amt—Local.'
/
comment on column mcw_250byte_message.cashback_indicator is 'Indicates whether the value is a credit or debit. Valid values are:C Credit to the receiver D Debit to the receiver.'
/
comment on column mcw_250byte_message.access_fee is 'Fee charged for the transaction activity.'
/
comment on column mcw_250byte_message.access_fee_indicator is 'Indicates whether the value is a credit or debit. Valid values are: C Credit to the receiver D Debit to the receiver.'
/
comment on column mcw_250byte_message.sttl_currency is 'Currency Code—Settlement.'
/
comment on column mcw_250byte_message.sttl_implied_decimal is 'Implied Decimal—Settlement.'
/
comment on column mcw_250byte_message.sttl_rate is 'Conversion Rate—Settlement.'
/
comment on column mcw_250byte_message.sttl_amount is 'Completed Amt—Settlement.'
/
comment on column mcw_250byte_message.sttl_indicator is 'Indicates whether the value is a credit or debit to the receiver. Valid values are: C Credit to the receiver D Debit to the receiver.'
/
comment on column mcw_250byte_message.interchange_fee is 'Interchange Fee.'
/
comment on column mcw_250byte_message.intrchg_fee_indicator is 'Indicates whether the value is a credit or debit to the receiver. Valid values are: C Credit to the receiver D Debit to the receiver.'
/
comment on column mcw_250byte_message.positive_id_indicator is 'Positive ID Indicator.'
/
comment on column mcw_250byte_message.cross_border_indicator is 'Valid values are: Y Transaction qualifies as a cross border transaction. N Transaction does not qualify as cross border transaction.'
/
comment on column mcw_250byte_message.crossb_curr_indicator is 'Cross Border Currency Indicator.'
/
comment on column mcw_250byte_message.isa_fee_indicator is 'VISA International Service Assessment (ISA) Fee Indicator.'
/
comment on column mcw_250byte_message.request_amount is 'Requested Amt Trans—Local.'
/
comment on column mcw_250byte_message.trace_number_adjust is 'Trace Number—Adjust-ment Trans.'
/
alter table mcw_250byte_message add recon_activity varchar2(1)
/
comment on column mcw_250byte_message.recon_activity is 'Recon Activity.'
/
