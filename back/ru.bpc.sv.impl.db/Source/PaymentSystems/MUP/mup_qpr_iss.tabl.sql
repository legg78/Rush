create table mup_qpr_iss(
    inst_id                  number(4)
  , agent_id                 number(8)
  , subsection               number(1)
  , card_bin                 varchar2(8)
  , all_card_count           number(22)
  , active_card_count        number(22)
  , cashout_rf_count         number(22)
  , cashout_rf_amount        number(22)
  , cashout_foreign_count    number(22)
  , cashout_foreign_amount   number(22)
  , cashin_count             number(22)
  , cashin_amount            number(22)
  , purch_all_count          number(22)
  , purch_all_amount         number(22)
  , purch_rf_count           number(22)
  , purch_rf_amount          number(22)
  , purch_rf_int_count       number(22)
  , purch_rf_int_amount      number(22)
  , purch_foreign_count      number(22)
  , purch_foreign_amount     number(22)
  , purch_foreign_int_count  number(22)
  , purch_foreign_int_amount number(22)
  , p2p_debet_count          number(22)
  , p2p_debet_amount         number(22)
  , p2p_credit_count         number(22)
  , p2p_credit_amount        number(22)
  , oper_date_quartal        number(1)
)
/
comment on table mup_qpr_iss is 'Report form MIR Issuing'
/  
comment on column mup_qpr_iss.inst_id                  is 'Institution ID'
/
comment on column mup_qpr_iss.agent_id                 is 'Agent ID'
/
comment on column mup_qpr_iss.subsection               is 'Subsection'
/
comment on column mup_qpr_iss.card_bin                 is 'Card BIN'
/
comment on column mup_qpr_iss.all_card_count           is 'Card count all'
/
comment on column mup_qpr_iss.active_card_count        is 'Card count active'
/
comment on column mup_qpr_iss.cashout_rf_count         is 'Russia cash count'
/
comment on column mup_qpr_iss.cashout_rf_amount        is 'Russia cash amount'
/
comment on column mup_qpr_iss.cashout_foreign_count    is 'Foreign cash count'
/
comment on column mup_qpr_iss.cashout_foreign_amount   is 'Foreign cash amount'
/
comment on column mup_qpr_iss.cashin_count             is 'Russia cash in count'
/
comment on column mup_qpr_iss.cashin_amount            is 'Russia cash in amount'
/
comment on column mup_qpr_iss.purch_all_count          is 'Payment count all'
/
comment on column mup_qpr_iss.purch_all_amount         is 'Payment amount all'
/
comment on column mup_qpr_iss.purch_rf_count           is 'Russia payment count'
/
comment on column mup_qpr_iss.purch_rf_amount          is 'Russia payment amount'
/
comment on column mup_qpr_iss.purch_rf_int_count       is 'Russia payment count Internet'
/
comment on column mup_qpr_iss.purch_rf_int_amount      is 'Russia payment amount Internet'
/
comment on column mup_qpr_iss.purch_foreign_count      is 'Foreign payment count'
/
comment on column mup_qpr_iss.purch_foreign_amount     is 'Foreign payment amount'
/
comment on column mup_qpr_iss.purch_foreign_int_count  is 'Foreign payment count Internet'
/
comment on column mup_qpr_iss.purch_foreign_int_amount is 'Foreign payment amount Internet'
/
comment on column mup_qpr_iss.p2p_debet_count          is 'Transfer count Debit'
/
comment on column mup_qpr_iss.p2p_debet_amount         is 'Transfer amount Debit'
/
comment on column mup_qpr_iss.p2p_credit_count         is 'Transfer count Credit'
/
comment on column mup_qpr_iss.p2p_credit_amount        is 'Transfer amount Credit'
/
comment on column mup_qpr_iss.oper_date_quartal        is 'Operation date quartal'
/
