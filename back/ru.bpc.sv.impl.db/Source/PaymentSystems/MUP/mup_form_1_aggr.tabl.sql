create table mup_form_1_aggr (
    member_code              varchar2(20 byte) not null
  , reg_num                  varchar2(20 byte) not null
  , bank_name                varchar2(200 byte) not null
  , inst_id                  number(4) not null
  , agent_id                 number(8)
  , subsection               number(1) not null
  , card_bin                 varchar2(8 byte) not null
  , all_card_count           number(22) not null
  , active_card_count        number(22) not null
  , cashout_rf_count         number(22) not null
  , cashout_rf_amount        number(22) not null
  , cashout_foreign_count    number(22) not null
  , cashout_foreign_amount   number(22) not null
  , cashin_count             number(22) not null
  , cashin_amount            number(22) not null
  , purch_all_count          number(22) not null
  , purch_all_amount         number(22) not null
  , purch_rf_count           number(22) not null
  , purch_rf_amount          number(22) not null
  , purch_rf_int_count       number(22) not null
  , purch_rf_int_amount      number(22) not null
  , purch_foreign_count      number(22) not null
  , purch_foreign_amount     number(22) not null
  , purch_foreign_int_count  number(22) not null
  , purch_foreign_int_amount number(22) not null
  , p2p_debet_count          number(22) not null
  , p2p_debet_amount         number(22) not null
  , p2p_credit_count         number(22) not null
  , p2p_credit_amount        number(22) not null
)
/

comment on table mup_form_1_aggr is 'table for MUP report form 1 (aggregation)'
/


comment on column mup_form_1_aggr.member_code is 'Member code'
/
comment on column mup_form_1_aggr.reg_num is 'Registration number'
/
comment on column mup_form_1_aggr.bank_name is 'Name of bank'
/
comment on column mup_form_1_aggr.inst_id is 'Institution ID'
/
comment on column mup_form_1_aggr.agent_id is 'Agent ID'
/
comment on column mup_form_1_aggr.subsection is 'Sub section'
/
comment on column mup_form_1_aggr.card_bin is 'BIN of card'
/
comment on column mup_form_1_aggr.all_card_count is 'All card count'
/
comment on column mup_form_1_aggr.active_card_count is 'Active card count'
/
comment on column mup_form_1_aggr.cashout_rf_count is 'Count of cashout in Russian Federation'
/
comment on column mup_form_1_aggr.cashout_rf_amount is 'Amount of cashout in Russian Federation'
/
comment on column mup_form_1_aggr.cashout_foreign_count is 'Count of foreign cashout'
/
comment on column mup_form_1_aggr.cashout_foreign_amount is 'Amount of foreign cashout'
/
comment on column mup_form_1_aggr.cashin_count is 'Count of cash in'
/
comment on column mup_form_1_aggr.cashin_amount is 'Amount of cash in'
/
comment on column mup_form_1_aggr.purch_all_count is 'Count of all purchases'
/
comment on column mup_form_1_aggr.purch_all_amount is 'Amount of all purchases'
/
comment on column mup_form_1_aggr.purch_rf_count is 'Count of purchases in Russian Federation'
/
comment on column mup_form_1_aggr.purch_rf_amount is 'Amount of purchases in Russian Federation'
/
comment on column mup_form_1_aggr.purch_rf_int_count is 'Count of int purchases in Russian Federation'
/
comment on column mup_form_1_aggr.purch_rf_int_amount is 'Amount of int purchases in Russian Federation'
/
comment on column mup_form_1_aggr.purch_foreign_count is 'Count of foreign purchases'
/
comment on column mup_form_1_aggr.purch_foreign_amount is 'Amount of foreign purchases'
/
comment on column mup_form_1_aggr.purch_foreign_int_count is 'Count of int foreign purchases'
/
comment on column mup_form_1_aggr.purch_foreign_int_amount is 'Amount of int foreign purchases'
/
comment on column mup_form_1_aggr.p2p_debet_count is 'Count of peer-to-peer debit'
/
comment on column mup_form_1_aggr.p2p_debet_amount is 'Amount of peer-to-peer debit'
/
comment on column mup_form_1_aggr.p2p_credit_count is 'Count of peer-to-peer credit'
/
comment on column mup_form_1_aggr.p2p_credit_amount is 'Amount of peer-to-peer credit'
/
  
