create table rus_form_259_1_cards(
    card_id                number(16)
  , customer_id            number(12)
  , contract_id            number(12)
  , inst_id                number(4)
  , period                 date
)
/

comment on table rus_form_259_1_cards is 'Data of active cards to create regular report - Forma 259 part 1'
/
comment on column rus_form_259_1_cards.card_id is 'Card ID'
/
comment on column rus_form_259_1_cards.customer_id is 'Customer ID'
/
comment on column rus_form_259_1_cards.contract_id is 'Contract ID'
/
comment on column rus_form_259_1_cards.inst_id is 'Institution ID'
/
comment on column rus_form_259_1_cards.period is 'Card activity period'
/
alter table rus_form_259_1_cards add (network_id number(4))
/
comment on column rus_form_259_1_cards.network_id is 'Card network identifier'
/
