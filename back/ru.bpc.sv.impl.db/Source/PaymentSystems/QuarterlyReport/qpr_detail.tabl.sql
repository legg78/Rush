create table qpr_detail(
    id                      number(16)
  , amount                  number(22,4)
  , currency                varchar2(3)
  , oper_date               date
  , oper_type               varchar2(8)
  , sttl_type               varchar2(8)
  , msg_type                varchar2(8)
  , status                  varchar2(8)
  , oper_reason             varchar2(8)
  , is_reversal             number(1)
  , mcc                     varchar2(4)
  , merchant_country        varchar2(3)
  , acq_inst_bin            varchar2(12)
  , card_type_id            number(4)
  , card_inst_id            number(4)
  , card_network_id         number(4)
  , card_country            varchar2(3)
  , card_product_id         number(8)
  , card_perso_method_id    number(4)
  , card_bin                varchar2(6)
  , card_number             varchar2(24)
  , acq_inst_id             number(4)
  , card_data_input_mode    varchar2(8)
  , terminal_number         varchar2(8)
  , is_iss                  number(1)
  , is_acq                  number(1)
  , account_funding_source  varchar2(100)
  , crdh_presence           varchar2(8)
  , match_id                number(16)
  , oper_desc               varchar2(2000)
)
/
comment on table qpr_detail                          is 'Detail data for aggregated quarter reports'
/
comment on column qpr_detail.id                      is 'Operation identifier'
/
comment on column qpr_detail.amount                  is 'Operation amount'
/
comment on column qpr_detail.currency                is 'Operation currency'
/
comment on column qpr_detail.oper_date               is 'Operation date'
/
comment on column qpr_detail.oper_type               is 'Operation type (OPTP dictionary)'
/
comment on column qpr_detail.sttl_type               is 'Settlement type (STTT dictionary)'
/
comment on column qpr_detail.msg_type                is 'Message type (MSGT dictionary)'
/
comment on column qpr_detail.status                  is 'Authorisation status (OPST dictionary)'
/
comment on column qpr_detail.oper_reason             is 'Operation reason (fee type or adjustment type)'
/
comment on column qpr_detail.is_reversal             is 'Reversal indicator'
/
comment on column qpr_detail.mcc                     is 'Merchant category code (MCC)'
/
comment on column qpr_detail.merchant_country        is 'Merchant country'
/
comment on column qpr_detail.acq_inst_bin            is 'Acquirer institution BIN'
/
comment on column qpr_detail.card_type_id            is 'Card type identifier'
/
comment on column qpr_detail.card_inst_id            is 'Card institution identifier'
/
comment on column qpr_detail.card_network_id         is 'Card network identifier'
/
comment on column qpr_detail.card_country            is 'Card country'
/
comment on column qpr_detail.card_product_id         is 'Card product identifier'
/
comment on column qpr_detail.card_perso_method_id    is 'Identifier of personalization method'
/
comment on column qpr_detail.card_bin                is 'Card BIN'
/
comment on column qpr_detail.card_number             is 'Card number'
/
comment on column qpr_detail.acq_inst_id             is 'Acquirer institution identifier'
/
comment on column qpr_detail.card_data_input_mode    is 'Card data input mode'
/
comment on column qpr_detail.terminal_number         is 'Terminal number'
/
comment on column qpr_detail.is_iss                  is 'Issuer operation indicator'
/
comment on column qpr_detail.is_acq                  is 'Acquirer operation indicator'
/
comment on column qpr_detail.account_funding_source  is 'Account funding source'
/
comment on column qpr_detail.crdh_presence           is 'Cardholder presence indicator'
/
comment on column qpr_detail.match_id                is 'Link between authorizations and presentment'
/
comment on column qpr_detail.oper_desc               is 'Operation description'
/
alter table qpr_detail add (oper_id number(16))
/
comment on column qpr_detail.oper_id                 is 'Operation identifier'
/
comment on column qpr_detail.id                      is 'Identifier (unused)'
/
alter table qpr_detail add (visa_bin varchar2(24))
/
comment on column qpr_detail.visa_bin                is 'Full BIN for Visa network'
/
alter table qpr_detail add (participant_type varchar2(8))
/
comment on column qpr_detail.participant_type        is 'Type of operation participant (Dictionary "PRTY" - Issuer, Acquirer, Destination)'
/
alter table qpr_detail drop column participant_type
/
alter table qpr_detail add (card_id number(12))
/
comment on column qpr_detail.card_id                 is 'Card identifier'
/
alter table qpr_detail add (original_id number(16))
/
comment on column qpr_detail.original_id             is 'Reference to original operation in case of reversal'
/
alter table qpr_detail modify (terminal_number varchar2(16))
/
alter table qpr_detail add (trans_code_qualifier varchar2(1))
/
comment on column qpr_detail.trans_code_qualifier is 'Transaction code qualifier.'
/
alter table qpr_detail add (pos_environment varchar2(1))
/
comment on column qpr_detail.pos_environment is 'POS environment.'
/
alter table qpr_detail add (product_id varchar2(2))
/
comment on column qpr_detail.product_id is 'Visa Product ID'
/
alter table qpr_detail add (business_application_id varchar2(2))
/
comment on column qpr_detail.business_application_id is 'Business Application IDs'
/