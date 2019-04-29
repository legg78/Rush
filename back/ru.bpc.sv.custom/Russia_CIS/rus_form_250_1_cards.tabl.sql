create global temporary table rus_form_250_1_cards(
    card_id                number(12)
  , card_feature           varchar2(8 char)
  , customer_type          varchar2(8 char)
  , region_code            varchar2(8 char)
  , customer_id            number(12)
  , network_id             number(4)
  , start_date             date
  , expir_date             date
)
on commit delete rows
/

comment on table rus_form_250_1_cards is 'Data of cards to create regular report - Forma 250 part 1'
/
comment on column rus_form_250_1_cards.card_id is 'Card identifier'
/
comment on column rus_form_250_1_cards.card_feature is 'Card feature (CFCH dictionary)'
/
comment on column rus_form_250_1_cards.customer_type is 'Customer type (Person, Organization)'
/
comment on column rus_form_250_1_cards.region_code is 'Region code'
/
comment on column rus_form_250_1_cards.customer_id is 'Customer identifier'
/
comment on column rus_form_250_1_cards.network_id is 'Card network identifier'
/
comment on column rus_form_250_1_cards.start_date is 'Card instance start date'
/
comment on column rus_form_250_1_cards.expir_date is 'Card instance expiration date'
/
