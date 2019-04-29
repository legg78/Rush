create table cst_bnv_napas_card
(
    id                        number(16)
  , card_number               varchar2(19)
)
/

comment on table cst_bnv_napas_card is 'NAPAS cards.'
/
comment on column cst_bnv_napas_card.id is 'Primary key. Message identifier'
/
comment on column cst_bnv_napas_card.card_number is 'Primary Account Number (Card number)'
/
