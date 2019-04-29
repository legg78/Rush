create table iss_card (
    id                  number(12)
    , split_hash        number(4)
    , card_hash         number(12)
    , card_mask         varchar2(24)
    , inst_id           number(4)
    , card_type_id      number(4)
    , country           varchar2(3)
    , customer_id       number(12)
    , cardholder_id     number(12)
    , contract_id       number(12)
    , reg_date          date
    , category          varchar2(8)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table iss_card is 'All own cards are stored here'
/
comment on column iss_card.id is 'Card identifier'
/
comment on column iss_card.split_hash is 'Hash value to split further processing'
/
comment on column iss_card.card_mask is 'Masked card number'
/
comment on column iss_card.card_hash is 'Card number hash value'
/
comment on column iss_card.inst_id is 'Institution identifier'
/
comment on column iss_card.cardholder_id is 'Cardholder identifier'
/
comment on column iss_card.card_type_id is 'Card type identifier'
/
comment on column iss_card.country is 'Card country association'
/
comment on column iss_card.contract_id is 'Issuing contract identifier'
/
comment on column iss_card.reg_date is 'Card registration date'
/
comment on column iss_card.customer_id is 'Customer which card belongs to'
/
comment on column iss_card.category is 'Card category (primary, double, suplementary)'
/
alter table iss_card enable row movement
/
