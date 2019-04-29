create table cst_bof_ghp_card(
    id           number(16)
  , card_number  varchar2(24)
)
/

comment on table cst_bof_ghp_card is 'Transactions card numbers store.'
/
comment on column cst_bof_ghp_card.id is 'Primary key. Financial message identifier.'
/
comment on column cst_bof_ghp_card.card_number is 'Card number.'
/
