create table cst_260_aggr_tran (
    record_type   number
  , atm_count     number
  , term_count    number
  , agent_id      number
  , region_code   char(2 char)
  , ci_cnt        number
  , cl_cnt        number
  , cw_cnt        number
  , ci_amount     number
  , cl_amount     number
  , cw_amount     number
  , ci_corr_cnt   number
  , cl_corr_cnt   number
  , cw_corr_cnt   number
)
/
comment on table cst_260_aggr_tran is 'Summary table by regions and agents'
/
comment on column cst_260_aggr_tran.record_type is 'Record type'
/
comment on column cst_260_aggr_tran.atm_count is 'ATM count'
/
comment on column cst_260_aggr_tran.term_count is 'Terminal count'
/
comment on column cst_260_aggr_tran.agent_id is 'Agent ID'
/
comment on column cst_260_aggr_tran.region_code is 'Region code'
/
comment on column cst_260_aggr_tran.ci_cnt is 'Count of operations for accepting cash using ATMs with the use of payment cards'
/
comment on column cst_260_aggr_tran.cl_cnt is 'Count of operations for accepting cash using ATMs without the use of payment cards (their requisites)'
/
comment on column cst_260_aggr_tran.cw_cnt is 'Count of operations for the issuance of cash using ATMs'
/
comment on column cst_260_aggr_tran.ci_amount is 'Amount of operations for accepting cash using ATMs with the use of payment cards'
/
comment on column cst_260_aggr_tran.cl_amount is 'Amount of operations for accepting cash using ATMs without the use of payment cards (their requisites)'
/
comment on column cst_260_aggr_tran.cw_amount is 'Amount of operations for the issuance of cash using ATMs'
/
comment on column cst_260_aggr_tran.ci_corr_cnt is 'Count of operations for accepting cash using ATMs with the use of payment cards'
/
comment on column cst_260_aggr_tran.cl_corr_cnt is 'Count of operations for accepting cash using ATMs without the use of payment cards (their requisites)'
/
comment on column cst_260_aggr_tran.cw_corr_cnt is 'Count of operations for the issuance of cash using ATMs'
/
