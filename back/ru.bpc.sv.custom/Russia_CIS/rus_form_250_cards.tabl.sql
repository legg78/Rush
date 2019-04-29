create table rus_form_250_cards(
    card_id                number(12)
  , card_feature           varchar2(8 char)
  , customer_type          varchar2(8 char)
  , region_code            varchar2(8 char)
  , customer_id            number(12)
  , network_id             number(4)
  , start_date             date
  , expir_date             date
)
/

comment on table rus_form_250_cards is 'Data of cards to create regular report - Forma 250 part 1'
/
comment on column rus_form_250_cards.card_id is 'Card identifier'
/
comment on column rus_form_250_cards.card_feature is 'Card feature (CFCH dictionary)'
/
comment on column rus_form_250_cards.customer_type is 'Customer type (Person, Organization)'
/
comment on column rus_form_250_cards.region_code is 'Region code'
/
comment on column rus_form_250_cards.customer_id is 'Customer identifier'
/
comment on column rus_form_250_cards.network_id is 'Card network identifier'
/
comment on column rus_form_250_cards.start_date is 'Card instance start date'
/
comment on column rus_form_250_cards.expir_date is 'Card instance expiration date'
/

begin
  for rec in (select 1 from dual where not exists(
      select 1 from user_tab_cols
       where table_name = upper('rus_form_250_cards')
         and column_name = upper('is_contactless')) )
  loop
      execute immediate 'alter table rus_form_250_cards add (is_contactless number (1))';
  end loop;
end;
/

comment on column rus_form_250_cards.is_contactless is 'Flag that card is contactless.'
/
