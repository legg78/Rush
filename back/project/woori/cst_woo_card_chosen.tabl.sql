create table cst_woo_card_chosen(
    card_number     varchar2(24)
  , is_used         number(1)
)
/
comment on table cst_woo_card_chosen is 'This table stores the special card numbers for Wooribank VIP customers'
/
comment on column cst_woo_card_chosen.card_number is 'Card number'
/
comment on column cst_woo_card_chosen.is_used is '0: not used, 1: used'
/
