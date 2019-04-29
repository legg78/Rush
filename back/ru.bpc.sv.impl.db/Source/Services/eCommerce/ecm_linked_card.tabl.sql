create table ecm_linked_card
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , entity_type         varchar2(8)
  , object_id           number(16)
  , card_mask           varchar2(24)
  , cardholder_name     varchar2(200)
  , expiration_date     date
  , card_network_id     number(4)
  , card_inst_id        number(4)
  , iss_network_id      number(4)
  , iss_inst_id         number(4)
  , status              varchar2(8)
  , link_date           date
  , unlink_date         date
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition ecm_linked_card_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table ecm_linked_card is 'External card linked for futher payments'
/

comment on column ecm_linked_card.id is 'Primary key'
/
comment on column ecm_linked_card.entity_type is 'Entity type associated with linked card (internal customer, external customer, account etc)'
/
comment on column ecm_linked_card.object_id is 'Identifier of associated object'
/
comment on column ecm_linked_card.card_mask is 'Card mask'
/
comment on column ecm_linked_card.cardholder_name is 'Embossed cardholder name'
/
comment on column ecm_linked_card.expiration_date is 'Date of card expiration'
/
comment on column ecm_linked_card.card_network_id is 'Card network identifier'
/
comment on column ecm_linked_card.card_inst_id is 'Card institution identifier'
/
comment on column ecm_linked_card.iss_network_id is 'Issuing network identifier'
/
comment on column ecm_linked_card.iss_inst_id is 'Issuing institution identifier'
/
comment on column ecm_linked_card.status is 'Card link status (Active, Inactive)'
/
comment on column ecm_linked_card.link_date is 'Card link date'
/
comment on column ecm_linked_card.unlink_date is 'Card unlink date'
/
