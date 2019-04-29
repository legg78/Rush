create table pmo_linked_card(
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , customer_id              number(12)
  , entity_type             varchar2(8)
  , object_id               number(16)
  , external_customer_id    varchar2(200)
  , card_mask               varchar2(24)
  , cardholder_name         varchar2(200)
  , expiration_date         date
  , card_network_id         number(4)
  , card_inst_id            number(4)
  , iss_network_id          number(4)
  , iss_inst_id             number(4)
  , status                  varchar2(8)
  , link_date               date
  , unlink_date             date
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition pmo_linked_card_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table pmo_linked_card is 'External cards linked to customer to make payments.'
/

comment on column pmo_linked_card.id is 'Primary key'
/
comment on column pmo_linked_card.customer_id is 'Reference to customer'
/
comment on column pmo_linked_card.entity_type is 'Type of additional entity linked to card (account for example).'
/
comment on column pmo_linked_card.object_id is 'Additional entity identifier.'
/
comment on column pmo_linked_card.card_mask is 'Card mask'
/
comment on column pmo_linked_card.cardholder_name is 'Cardholder name embossed on card.'
/
comment on column pmo_linked_card.expiration_date is 'Expiration date of linked card'
/
comment on column pmo_linked_card.card_network_id is 'Network identifier represents card payment system (Visa, MasterCard etc)'
/
comment on column pmo_linked_card.card_inst_id is 'Card owner institution idetifier'
/
comment on column pmo_linked_card.iss_network_id is 'Issuing network identifier'
/
comment on column pmo_linked_card.iss_inst_id is 'Issuing institution identifier'
/
comment on column pmo_linked_card.status is 'Linked card status (Linked, Unlinked)'
/
comment on column pmo_linked_card.link_date is 'Card link date'
/
comment on column pmo_linked_card.unlink_date is 'Card unlink date'
/
comment on column pmo_linked_card.external_customer_id is 'Customer identifier in external system'
/
