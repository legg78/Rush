create table bgn_card (
    id                number(16)
  , card_number        varchar2(24)
)
/

comment on table bgn_card is 'Card numbers for bgn_fin'
/

comment on column bgn_card.id is 'Primary key. Equal to bgn_fin.id'
/

comment on column bgn_card.card_number is 'Card number'
/
