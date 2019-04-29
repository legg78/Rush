create table cst_250_3_aggr_tran (
    region_code                varchar2(3 char)
  , subsection                 number
  , network_id                 number
  , payment_count_all          number
  , payment_amount_all         number
  , payment_count_impr         number
  , payment_amount_impr        number
  , payment_count_atm          number
  , payment_amount_atm         number
  , payment_count_pos          number
  , payment_amount_pos         number
  , payment_count_other        number
  , payment_amount_other       number
  , cash_count_all             number
  , cash_amount_all            number
  , cash_count_atm             number
  , cash_amount_atm            number
  , cash_count_foreign_curr    number
  , cash_amount_foreign_curr   number
  , agent_id                   number(10, 0)
)
/
comment on table cst_250_3_aggr_tran is 'Summary table by regions, subsections and networks'
/
comment on column cst_250_3_aggr_tran.region_code is 'Region code'
/
comment on column cst_250_3_aggr_tran.subsection is 'Subsection'
/
comment on column cst_250_3_aggr_tran.network_id is 'Card network ID'
/
comment on column cst_250_3_aggr_tran.payment_count_all is 'Payment count all'
/
comment on column cst_250_3_aggr_tran.payment_amount_all is 'Payment amount all'
/
comment on column cst_250_3_aggr_tran.payment_count_impr is 'Payment count imprinter'
/
comment on column cst_250_3_aggr_tran.payment_amount_impr is 'Payment amount imprinter'
/
comment on column cst_250_3_aggr_tran.payment_count_atm is 'Payment count ATM'
/
comment on column cst_250_3_aggr_tran.payment_amount_atm is 'Payment amount ATM'
/
comment on column cst_250_3_aggr_tran.payment_count_pos is 'Payment count POS'
/
comment on column cst_250_3_aggr_tran.payment_amount_pos is 'Payment amount POS'
/
comment on column cst_250_3_aggr_tran.payment_count_other is 'Payment count other'
/
comment on column cst_250_3_aggr_tran.payment_amount_other is 'Payment amount other'
/
comment on column cst_250_3_aggr_tran.cash_count_all is 'Cash count all'
/
comment on column cst_250_3_aggr_tran.cash_amount_all is 'Cash amount all'
/
comment on column cst_250_3_aggr_tran.cash_count_atm is 'Cash count ATM'
/
comment on column cst_250_3_aggr_tran.cash_amount_atm is 'Cash amount ATM'
/
comment on column cst_250_3_aggr_tran.cash_count_foreign_curr is 'Cash count in foreign currency'
/
comment on column cst_250_3_aggr_tran.cash_amount_foreign_curr is 'Cash amount in foreign currency'
/
comment on column cst_250_3_aggr_tran.agent_id is 'Agent ID'
/
