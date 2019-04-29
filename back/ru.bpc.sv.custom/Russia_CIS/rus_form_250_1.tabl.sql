create global temporary table rus_form_250_1(
    pmode                  number(3)
  , customer_type          varchar2(8 byte)
  , region_code            varchar2(8 byte)
  , network_id             number(4)
  , card_type              varchar2(8 byte)
  , customer_count         number(16)
  , card_type_count        number(16)
  , card_count             number(16)
  , active_card_count      number(16)
  , oper_amount_debit      number(22,4)
  , oper_amount_credit     number(22,4)
  , domestic_cash_count    number(16)
  , domestic_cash_amount   number(22,4)
  , foreign_cash_count     number(16)
  , foreign_cash_amout     number(22,4)
  , domestic_purch_count   number(12)
  , domestic_purch_amount  number(22,4)
  , foreign_purch_count    number(12)
  , foreign_purch_amount   number(22,4)
  , customs_count          number(12)
  , customs_amount         number(22,4)
  , other_count            number(12)
  , other_amount           number(22,4)
)
on commit preserve rows
/

comment on table rus_form_250_1 is 'Data to create regular report - Forma 250'
/

comment on column rus_form_250_1.pmode is 'Mode'
/

comment on column rus_form_250_1.customer_type is 'Customer type (Person, Organization)'
/

comment on column rus_form_250_1.region_code is 'Region code'
/

comment on column rus_form_250_1.network_id is 'Card network identifier'
/

comment on column rus_form_250_1.card_type is 'Card type'
/

comment on column rus_form_250_1.customer_count is 'Count of customers'
/

comment on column rus_form_250_1.card_type_count is 'Count of customers by card types'
/

comment on column rus_form_250_1.card_count is 'Total card count'
/

comment on column rus_form_250_1.active_card_count is 'Count of card which has activity in reporting period'
/

comment on column rus_form_250_1.oper_amount_debit is 'Amount of transactions performed by own funds'
/

comment on column rus_form_250_1.oper_amount_credit is 'Amount of transactions performed by credit'
/

comment on column rus_form_250_1.domestic_cash_count is 'Count of cash withdrawal transactions performed within the country'
/

comment on column rus_form_250_1.domestic_cash_amount is 'Amount of cash withdrawal transactions performed within the country'
/

comment on column rus_form_250_1.foreign_cash_count is 'Count of cash withdrawal transactions performed abroad'
/

comment on column rus_form_250_1.foreign_cash_amout is 'Amount of cash withdrawal transactions performed abroad'
/

comment on column rus_form_250_1.domestic_purch_count is 'Count of purchase transactions performed within the country'
/

comment on column rus_form_250_1.domestic_purch_amount is 'Amount of purchase transactions performed within the country'
/

comment on column rus_form_250_1.foreign_purch_count is 'Count of purchase transactions performed abroad'
/

comment on column rus_form_250_1.foreign_purch_amount is 'Amount of purchase transactions performed abroad'
/

comment on column rus_form_250_1.customs_count is 'Count of customs payments'
/

comment on column rus_form_250_1.customs_amount is 'Amount of customs payments'
/

comment on column rus_form_250_1.other_count is 'Count of other transactions'
/

comment on column rus_form_250_1.other_amount is 'Amount of other transactions'
/

alter table rus_form_250_1 add (internet_count number(12))
/
alter table rus_form_250_1 add (internet_amount number(22,4))
/
comment on column rus_form_250_1.internet_count is 'Count of Internet transactions'
/
comment on column rus_form_250_1.internet_amount is 'Amount of Internet transactions'
/