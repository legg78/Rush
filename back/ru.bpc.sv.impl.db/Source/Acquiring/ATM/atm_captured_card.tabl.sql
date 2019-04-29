create table atm_captured_card (
    auth_id     number(16)
  , terminal_id number(8)
  , coll_id     number(16)
)
/

comment on table atm_captured_card is 'Captured cards by ATM'
/

comment on column atm_captured_card.auth_id is 'Authorization identifier finished with card capture'
/

comment on column atm_captured_card.terminal_id is 'ATM terminal identifier which capture the card'
/

comment on column atm_captured_card.coll_id is 'Current collection when card was captured.'
/