create table iss_product_card_type (
    id                          number(8)
    , seqnum                    number(4)
    , product_id                number(8)
    , card_type_id              number(4)
    , seq_number_low            number(4)
    , seq_number_high           number(4)
    , bin_id                    number(8)
    , index_range_id            number(8)
    , number_format_id          number(4)
    , pin_request               varchar2(8)
    , pin_mailer_request        varchar2(8)
    , embossing_request         varchar2(8)
    , blank_type_id             number(4)
    , status                    varchar2(8)
    , perso_priority            varchar2(8)
    , reiss_command             varchar2(8)
    , reiss_start_date_rule     varchar2(8)
    , reiss_expir_date_rule     varchar2(8)
    , reiss_card_type_id        number(4)
    , reiss_contract_id         number(12)
    , state                     varchar2(8)
    , emv_appl_id               number(8)
)
/
comment on table iss_product_card_type is 'Product allowed card types'
/
comment on column iss_product_card_type.id is 'Identifier'
/
comment on column iss_product_card_type.seqnum is 'Sequential number of data version'
/
comment on column iss_product_card_type.product_id is 'Product identifier'
/
comment on column iss_product_card_type.card_type_id is 'Card type identifier'
/
comment on column iss_product_card_type.seq_number_low is 'Card sequential number low'
/
comment on column iss_product_card_type.seq_number_high is 'Card sequential number high'
/
comment on column iss_product_card_type.bin_id is 'Issuing bin identifier'
/
comment on column iss_product_card_type.index_range_id is 'Index range identifier'
/
comment on column iss_product_card_type.number_format_id is 'Number format identifier'
/
comment on column iss_product_card_type.pin_request is 'Requesting action about PIN generation'
/
comment on column iss_product_card_type.pin_mailer_request is 'Requesting action about PIN mailer printing'
/
comment on column iss_product_card_type.embossing_request is 'Requesting action about plastic embossing'
/
comment on column iss_product_card_type.blank_type_id is 'Identifier of blank for card embossing'
/
comment on column iss_product_card_type.status is 'Online status'
/
comment on column iss_product_card_type.perso_priority is 'Personalization priority'
/
comment on column iss_product_card_type.reiss_command is 'Reissuing command (RCMD)'
/
comment on column iss_product_card_type.reiss_start_date_rule is 'Rule for reissuing start date generation (SDRL)'
/
comment on column iss_product_card_type.reiss_expir_date_rule is 'Rule for reissuing expiration date generation (EDRL)'
/
comment on column iss_product_card_type.reiss_card_type_id is 'Card type for reissued card'
/
comment on column iss_product_card_type.reiss_contract_id is 'Card contract for reissued card'
/
comment on column iss_product_card_type.state is 'Card instance state'
/
comment on column iss_product_card_type.emv_appl_id is 'Identifier of EMV application'
/
alter table iss_product_card_type add (
    perso_method_id  number(4)
)
/
comment on column iss_product_card_type.perso_method_id is 'Personalization method identifier'
/
alter table iss_product_card_type drop column emv_appl_id
/
alter table iss_product_card_type add (
    emv_appl_scheme_id  number(4)
)
/
comment on column iss_product_card_type.emv_appl_scheme_id is 'Identifier of EMV application scheme'
/
alter table iss_product_card_type add service_id number(8)
/
comment on column iss_product_card_type.service_id is 'Service identifier.'
/
alter table iss_product_card_type add reiss_product_id number(8)
/
comment on column iss_product_card_type.reiss_product_id is 'Product identifier for reissue.'
/

alter table iss_product_card_type add reiss_bin_id number(8)
/
comment on column iss_product_card_type.reiss_bin_id is 'BIN identifier for reissue.'
/

alter table iss_product_card_type add uid_format_id number(4)
/
comment on column iss_product_card_type.uid_format_id is 'UID naming format.'
/
