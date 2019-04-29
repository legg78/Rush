create table rcn_cbs_card (
    id                        number(16)
  , card_number               varchar2(24)
)
/
comment on table rcn_cbs_card is 'CBS reconciliation cards'
/
comment on column rcn_cbs_card.id is 'Record identifier'
/
comment on column rcn_cbs_card.card_number is 'Card number'
/
drop table rcn_cbs_card
/
