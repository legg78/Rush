create table cst_cfc_scoring(
    customer_number         varchar2(100)
  , account_number          varchar2(100)
  , card_mask               varchar2(30)
  , category                varchar2(30)
  , status                  varchar2(30)
  , card_limit              number(22,4)
  , invoice_date            date
  , due_date                date
  , min_amount_due          number(22,4)
  , exceed_limit            number(22,4)
  , sub_acct                varchar2(100)
  , sub_acct_bal            number(22,4)
  , atm_wdr_cnt             number(12)
  , pos_cnt                 number(12)
  , all_trx_cnt             number(12)
  , atm_wdr_amt             number(22,4)
  , pos_amt                 number(22,4)
  , total_trx_amt           number(22,4)
  , daily_repayment         number(22,4)
  , cycle_repayment         number(22,4)
  , current_dpd             number(4)
  , bucket                  varchar2(10)
  , revised_bucket          varchar2(10)
  , eff_date                varchar2(8)
  , expir_date              varchar2(8)
  , valid_period            number(3)
  , reason                  varchar2(100)
  , highest_bucket_01       varchar2(2)
  , highest_bucket_03       varchar2(2)
  , highest_bucket_06       varchar2(2)
  , highest_dpd             number(4)
  , cycle_wdr_amt           number(22,4)
  , total_debit_amt         number(22,4)
  , cycle_avg_wdr_amt       number(22,4)
  , cycle_daily_avg_usage   number(22,4)
  , life_wdr_amt            number(22,4)
  , life_wdr_cnt            number(12)
  , avg_wdr                 number(22,4)
  , daily_usage             number(22,4)
  , monthly_usage           number(22,4)
  , tmp_crd_limit           number(22,4)
  , limit_start_date        date
  , limit_end_date          date
  , card_usage_limit        number(22,4)
  , overdue_interest        number(22,4)
  , indue_interest          number(22,4)
  , split_hash              number(4)
  , run_date                date
)
/

comment on table cst_cfc_scoring is 'This table stores the daily scoring data'
/
comment on column cst_cfc_scoring.customer_number is 'Customer number'
/
comment on column cst_cfc_scoring.account_number is 'Account number'
/
comment on column cst_cfc_scoring.card_mask is 'Card mask'
/
comment on column cst_cfc_scoring.category is 'Card category'
/
comment on column cst_cfc_scoring.status is 'Card status'
/
comment on column cst_cfc_scoring.card_limit is 'Card limit'
/
comment on column cst_cfc_scoring.invoice_date is 'Invoice date'
/
comment on column cst_cfc_scoring.due_date is 'Due date'
/
comment on column cst_cfc_scoring.min_amount_due is 'Min amount due'
/
comment on column cst_cfc_scoring.exceed_limit is 'Available limit'
/
comment on column cst_cfc_scoring.sub_acct is 'Sub account'
/
comment on column cst_cfc_scoring.sub_acct_bal is 'Sub account balance'
/
comment on column cst_cfc_scoring.atm_wdr_cnt is 'Count of ATM Cash withdrawal transactions'
/
comment on column cst_cfc_scoring.pos_cnt is 'Count of POS transactions'
/
comment on column cst_cfc_scoring.all_trx_cnt is 'Count of all transactions'
/
comment on column cst_cfc_scoring.atm_wdr_amt is 'Sum amount of ATM Cash withdrawal transactions'
/
comment on column cst_cfc_scoring.pos_amt is 'Sum amount of POS transactions'
/
comment on column cst_cfc_scoring.total_trx_amt is 'Sum amount of all transactions'
/
comment on column cst_cfc_scoring.daily_repayment is 'Daily repayment amount'
/
comment on column cst_cfc_scoring.cycle_repayment is 'Cycle repayment amount'
/
comment on column cst_cfc_scoring.current_dpd is 'Current DPD'
/
comment on column cst_cfc_scoring.bucket is 'Bucket'
/
comment on column cst_cfc_scoring.revised_bucket is 'Revised bucket'
/
comment on column cst_cfc_scoring.eff_date is 'Effective date'
/
comment on column cst_cfc_scoring.expir_date is 'Expired date'
/
comment on column cst_cfc_scoring.valid_period is 'Valid period'
/
comment on column cst_cfc_scoring.reason is 'Reason'
/
comment on column cst_cfc_scoring.highest_bucket_01 is 'Highest bucket 01'
/
comment on column cst_cfc_scoring.highest_bucket_03 is 'Highest bucket 03'
/
comment on column cst_cfc_scoring.highest_bucket_06 is 'Highest bucket 06'
/
comment on column cst_cfc_scoring.highest_dpd is 'Highest DPD'
/
comment on column cst_cfc_scoring.cycle_wdr_amt is 'Cycle Cash withdrawal amount'
/
comment on column cst_cfc_scoring.total_debit_amt is 'Total debit amount'
/
comment on column cst_cfc_scoring.cycle_avg_wdr_amt is 'Cycle of average Cash withdrawal amount'
/
comment on column cst_cfc_scoring.cycle_daily_avg_usage is 'Cycle of daily average usage'
/
comment on column cst_cfc_scoring.life_wdr_amt is 'Life Cash withdrawal amount'
/
comment on column cst_cfc_scoring.life_wdr_cnt is 'Life Cash withdrawal count'
/
comment on column cst_cfc_scoring.avg_wdr is 'Average Cash withdrawal amount'
/
comment on column cst_cfc_scoring.daily_usage is 'Daily usage'
/
comment on column cst_cfc_scoring.monthly_usage is 'Monthly usage'
/
comment on column cst_cfc_scoring.tmp_crd_limit is 'Temporary credit limit'
/
comment on column cst_cfc_scoring.limit_start_date is 'Limit start date'
/
comment on column cst_cfc_scoring.limit_end_date is 'Limit end date'
/
comment on column cst_cfc_scoring.card_usage_limit is 'Card usage limit'
/
comment on column cst_cfc_scoring.overdue_interest is 'Overdue interest'
/
comment on column cst_cfc_scoring.indue_interest is 'Indue interest'
/
comment on column cst_cfc_scoring.split_hash is 'Split hash'
/
comment on column cst_cfc_scoring.run_date is 'Sysdate when data is generated'
/
