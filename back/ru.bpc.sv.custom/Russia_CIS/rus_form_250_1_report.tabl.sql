create table rus_form_250_1_report(
    inst_id                number(4)
  , report_date            date
  , pmode                  number(3)
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
  , internet_count         number(12)
  , internet_amount        number(22,4)
  , internet_shop_count    number(12)
  , internet_shop_amount   number(22,4)
  , mobile_count           number(12)
  , mobile_amount          number(22,4)
)
/

comment on table rus_form_250_1_report is 'Data to create regular report - Forma 250 part 1'
/
comment on column rus_form_250_1_report.inst_id is 'Institution identifier'
/
comment on column rus_form_250_1_report.report_date is 'Fisrt day of quarter'
/
comment on column rus_form_250_1_report.pmode is 'Mode'
/
comment on column rus_form_250_1_report.customer_type is 'Customer type (Person, Organization)'
/
comment on column rus_form_250_1_report.region_code is 'Region code'
/
comment on column rus_form_250_1_report.network_id is 'Card network identifier'
/
comment on column rus_form_250_1_report.card_type is 'Card type'
/
comment on column rus_form_250_1_report.customer_count is 'Count of customers'
/
comment on column rus_form_250_1_report.card_type_count is 'Count of customers by card types'
/
comment on column rus_form_250_1_report.card_count is 'Total card count'
/
comment on column rus_form_250_1_report.active_card_count is 'Count of card which has activity in reporting period'
/
comment on column rus_form_250_1_report.oper_amount_debit is 'Amount of transactions performed by own funds'
/
comment on column rus_form_250_1_report.oper_amount_credit is 'Amount of transactions performed by credit'
/
comment on column rus_form_250_1_report.domestic_cash_count is 'Count of cash withdrawal transactions performed within the country'
/
comment on column rus_form_250_1_report.domestic_cash_amount is 'Amount of cash withdrawal transactions performed within the country'
/
comment on column rus_form_250_1_report.foreign_cash_count is 'Count of cash withdrawal transactions performed abroad'
/
comment on column rus_form_250_1_report.foreign_cash_amout is 'Amount of cash withdrawal transactions performed abroad'
/
comment on column rus_form_250_1_report.domestic_purch_count is 'Count of purchase transactions performed within the country'
/
comment on column rus_form_250_1_report.domestic_purch_amount is 'Amount of purchase transactions performed within the country'
/
comment on column rus_form_250_1_report.foreign_purch_count is 'Count of purchase transactions performed abroad'
/
comment on column rus_form_250_1_report.foreign_purch_amount is 'Amount of purchase transactions performed abroad'
/
comment on column rus_form_250_1_report.customs_count is 'Count of customs payments'
/
comment on column rus_form_250_1_report.customs_amount is 'Amount of customs payments'
/
comment on column rus_form_250_1_report.other_count is 'Count of other transactions'
/
comment on column rus_form_250_1_report.other_amount is 'Amount of other transactions'
/
comment on column rus_form_250_1_report.internet_count is 'Count of Internet transactions'
/
comment on column rus_form_250_1_report.internet_amount is 'Amount of Internet transactions'
/
comment on column rus_form_250_1_report.internet_shop_count is 'Count of Internet-shop transactions'
/
comment on column rus_form_250_1_report.internet_shop_amount is 'Amount of Internet-shop transactions'
/
comment on column rus_form_250_1_report.mobile_count is 'Count of Mobile transactions'
/
comment on column rus_form_250_1_report.mobile_amount is 'Amount of Mobile transactions'
/
