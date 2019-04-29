create table acq_terminal (
    id                      number(8)
  , seqnum                  number(4)
  , is_template             number(1)
  , terminal_number         varchar2(8)
  , terminal_type           varchar2(8)
  , merchant_id             number(8)
  , mcc                     varchar2(4)
  , plastic_number          varchar2(24)
  , card_data_input_cap     varchar2(8)
  , crdh_auth_cap           varchar2(8)
  , card_capture_cap        varchar2(8)
  , term_operating_env      varchar2(8)
  , crdh_data_present       varchar2(8)
  , card_data_present       varchar2(8)
  , card_data_input_mode    varchar2(8)
  , crdh_auth_method        varchar2(8)
  , crdh_auth_entity        varchar2(8)
  , card_data_output_cap    varchar2(8)
  , term_data_output_cap    varchar2(8)
  , pin_capture_cap         varchar2(8)
  , cat_level               varchar2(8)
  , gmt_offset              number(4)
  , is_mac                  number(1)
  , device_id               number(8)
  , status                  varchar2(8)
  , contract_id             number(12)
  , inst_id                 number(4)
  , split_hash              number(4)
  , cash_dispenser_present  number(1)
  , payment_possibility     number(1)
  , use_card_possibility    number(1)
  , cash_in_present         number(1)
  , available_network       number(8)
  , available_operation     number(8)
  , available_currency      number(8)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table acq_terminal is 'Terminals.'
/

comment on column acq_terminal.id is 'Primary key.'
/

comment on column acq_terminal.seqnum is 'Sequence number. Describe data version.'
/

comment on column acq_terminal.is_template is 'Template flag. If true record is template otherwise record is a real terminal.'
/

comment on column acq_terminal.terminal_number is 'External terminal identifier. Unique inside institution.'
/

comment on column acq_terminal.terminal_type is 'Terminal type (ATM, POS, ePOS, Imprinter)'
/

comment on column acq_terminal.merchant_id is 'Reference to parent merchant.'
/

comment on column acq_terminal.mcc is 'Merchant Category Code'
/

comment on column acq_terminal.plastic_number is 'Imprinter plastic number.'
/

comment on column acq_terminal.card_data_input_cap is 'Card data input capability (dictionary F221).'
/

comment on column acq_terminal.crdh_auth_cap is 'Cardholder authorization capability (dictionary F222).'
/

comment on column acq_terminal.card_capture_cap is 'Card capture capability (dictionary F223).'
/

comment on column acq_terminal.term_operating_env is 'Terminal operating environment (dictionary F224).'
/

comment on column acq_terminal.crdh_data_present is 'Cardholder present data (dictionary F225).'
/

comment on column acq_terminal.card_data_present is 'Card present data (dictionary F226)'
/

comment on column acq_terminal.card_data_input_mode is 'Card data input mode (dictionary F227).'
/

comment on column acq_terminal.crdh_auth_method is 'Cardholder authorization method (dictionary F228).'
/

comment on column acq_terminal.crdh_auth_entity is 'Cardholder authorization entity (dictionary F229).'
/

comment on column acq_terminal.card_data_output_cap is 'Card data output capability (dictionary F22A).'
/

comment on column acq_terminal.term_data_output_cap is 'Terminal data output capability (dictionary F22B).'
/

comment on column acq_terminal.pin_capture_cap is 'PIN capture capability (dictionary F22C).'
/

comment on column acq_terminal.cat_level is 'Cardholder activated terminal level.'
/

comment on column acq_terminal.gmt_offset is 'GMT offset (-12..13)'
/

comment on column acq_terminal.is_mac is 'Is using Message Authentification Code (MAC).'
/

comment on column acq_terminal.device_id is 'Communication device identifier.'
/

comment on column acq_terminal.status is 'Terminal status (active, inactive).'
/

comment on column acq_terminal.contract_id is 'Reference to contract.'
/

comment on column acq_terminal.inst_id is 'Institution identifier.'
/

comment on column acq_terminal.split_hash is 'Hash value to split further processing'
/

comment on column acq_terminal.cash_dispenser_present is 'Cash despenser present flag'
/

comment on column acq_terminal.payment_possibility is 'Make payment possibility flag'
/

comment on column acq_terminal.use_card_possibility is 'Use cards possibility flag'
/

comment on column acq_terminal.cash_in_present is 'Cash In device present flag'
/

comment on column acq_terminal.available_network is 'Available payment systems (networks)'
/

comment on column acq_terminal.available_operation is 'Available operation types'
/

comment on column acq_terminal.available_currency is 'Available currencies'
/
alter table acq_terminal add (
    mcc_template_id  number(12)
)
/
comment on column acq_terminal.mcc_template_id is 'MCC selection template identifier'
/
alter table acq_terminal add (terminal_profile  number(9))
/
comment on column acq_terminal.terminal_profile is 'Terminal profile'
/
alter table acq_terminal add (pin_block_format  varchar2(8))
/
comment on column acq_terminal.pin_block_format is 'PIN-block encription format'
/
alter table acq_terminal add pos_batch_support number(1)
/
comment on column acq_terminal.pos_batch_support is 'POS Batch Support Indicator'
/
alter table acq_terminal modify (terminal_number  varchar2(16))
/

