create table cst_250_1_aggr_tran(
    customer_type           varchar2(8 byte)
  , region_code             varchar2(8 byte)
  , network_id              number(4, 0)
  , card_type               varchar2(8 byte)
  , customer_count          number(16, 0)
  , card_type_count         number(16, 0)
  , card_count              number(16, 0)
  , active_card_count       number(16, 0)
  , oper_amount_debit       number(22, 4)
  , oper_amount_credit      number(22, 4)
  , domestic_cash_count     number(16, 0)
  , domestic_cash_amount    number(22, 4)
  , foreign_cash_count      number(16, 0)
  , foreign_cash_amout      number(22, 4)
  , domestic_purch_count    number(12, 0)
  , domestic_purch_amount   number(22, 4)
  , foreign_purch_count     number(12, 0)
  , foreign_purch_amount    number(22, 4)
  , customs_count           number(12, 0)
  , customs_amount          number(22, 4)
  , other_count             number(12, 0)
  , other_amount            number(22, 4)
  , internet_count          number(12, 0)
  , internet_amount         number(22, 4)
  , internet_shop_count     number(12, 0)
  , internet_shop_amount    number(22, 4)
  , mobile_count            number(12, 0)
  , mobile_amount           number(22, 4)
)
/
comment on table cst_250_1_aggr_tran is 'Summary table by regions, customer types, networks and card types'
/
comment on column cst_250_1_aggr_tran.customer_type is 'Customer type'
/
comment on column cst_250_1_aggr_tran.region_code is 'Region code'
/
comment on column cst_250_1_aggr_tran.network_id is 'Card network'
/
comment on column cst_250_1_aggr_tran.card_type is 'Card type'
/
comment on column cst_250_1_aggr_tran.customer_count is 'Customer count'
/
comment on column cst_250_1_aggr_tran.card_type_count is 'Card type count'
/
comment on column cst_250_1_aggr_tran.card_count is 'Card count'
/
comment on column cst_250_1_aggr_tran.active_card_count is 'Active card count'
/
comment on column cst_250_1_aggr_tran.oper_amount_debit is 'Operation amount debit'
/
comment on column cst_250_1_aggr_tran.oper_amount_credit is 'Operation amount credit'
/
comment on column cst_250_1_aggr_tran.domestic_cash_count is 'Domestic cash count'
/
comment on column cst_250_1_aggr_tran.domestic_cash_amount is 'Domestic cash amount'
/
comment on column cst_250_1_aggr_tran.foreign_cash_count is 'Foreign cash count'
/
comment on column cst_250_1_aggr_tran.foreign_cash_amout is 'Foreign cash amout'
/
comment on column cst_250_1_aggr_tran.domestic_purch_count is 'Domestic purch count'
/
comment on column cst_250_1_aggr_tran.domestic_purch_amount is 'Domestic purch amount'
/
comment on column cst_250_1_aggr_tran.foreign_purch_count is 'Foreign purch count'
/
comment on column cst_250_1_aggr_tran.foreign_purch_amount is 'Foreign purch amount'
/
comment on column cst_250_1_aggr_tran.customs_count is 'Customs count'
/
comment on column cst_250_1_aggr_tran.customs_amount is 'Customs amount'
/
comment on column cst_250_1_aggr_tran.other_count is 'Other count'
/
comment on column cst_250_1_aggr_tran.other_amount is 'Other amount'
/
comment on column cst_250_1_aggr_tran.internet_count is 'Internet count'
/
comment on column cst_250_1_aggr_tran.internet_amount is 'Internet amount'
/
comment on column cst_250_1_aggr_tran.internet_shop_count is 'Internet shop count'
/
comment on column cst_250_1_aggr_tran.internet_shop_amount is 'Internet shop amount'
/
comment on column cst_250_1_aggr_tran.mobile_count is 'Mobile count'
/
comment on column cst_250_1_aggr_tran.mobile_amount is 'Mobile amount'
/
