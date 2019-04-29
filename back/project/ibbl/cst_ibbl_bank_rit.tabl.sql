create table cst_ibbl_bank_rit(
    no_atm                      number(10)
  , no_pos                      number(10)
  , issued_local_credit         number(10)
  , issued_dual_credit          number(10)
  , issued_intna_credit         number(10)
  , issued_local_debit          number(10)
  , issued_intna_debit          number(10)
  , issued_local_prepaid        number(10)
  , issued_intna_prepaid        number(10)
  , debit_atm_bd_no_tran        number(20)
  , debit_atm_bd_value          number(20)
  , debit_pos_bd_no_tran        number(20)
  , debit_pos_bd_value          number(20)
  , debit_ecom_bd_no_tran       number(20)
  , debit_ecom_bd_value         number(20)
  , debit_atm_ab_no_tran        number(20)
  , debit_atm_ab_value          number(20)
  , debit_pos_ab_no_tran        number(20)
  , debit_pos_ab_value          number(20)
  , debit_ecom_ab_no_tran       number(20)
  , debit_ecom_ab_value         number(20)
  , credit_atm_bd_no_tran       number(20)
  , credit_atm_bd_value         number(20)
  , credit_pos_bd_no_tran       number(20)
  , credit_pos_bd_value         number(20)
  , credit_ecom_bd_no_tran      number(20)
  , credit_ecom_bd_value        number(20)
  , credit_atm_ab_no_tran       number(20)
  , credit_atm_ab_value         number(20)
  , credit_pos_ab_no_tran       number(20)
  , credit_pos_ab_value         number(20)
  , credit_ecom_ab_no_tran      number(20)
  , credit_ecom_ab_value        number(20)
  , credit_outstanding_amt      number(20)
  , credit_year_intr_rate       number(20)
  , prepaid_bd_no_tran          number(20)
  , prepaid_bd_value            number(20)
  , prepaid_ab_no_tran          number(20)
  , prepaid_ab_value            number(20)
  , fraud_atm_no                number(20)
  , fraud_atm_value             number(20)
  , acq_bd_debit_atm_no_tran    number(20)
  , acq_bd_debit_atm_value      number(20)
  , acq_bd_debit_pos_no_tran    number(20)
  , acq_bd_debit_pos_value      number(20)
  , acq_bd_credit_atm_no_tran   number(20)
  , acq_bd_credit_atm_value     number(20)
  , acq_bd_credit_pos_no_tran   number(20)
  , acq_bd_credit_pos_value     number(20)
  , acq_ab_atm_no_tran          number(20)
  , acq_ab_atm_value            number(20)
  , acq_ab_pos_no_tran          number(20)
  , acq_ab_pos_value            number(20)
  , acq_ab_ecom_no_tran         number(20)
  , acq_ab_ecom_value           number(20)
  , acq_ab_prepaid_no_tran      number(20)
  , acq_ab_prepaid_value        number(20)
  , i_month                     number(2)
  , i_year                      number(4)
  , run_date                    date
)
/

comment on table cst_ibbl_bank_rit is 'This table contains IBBL Bank RIT data'
/
comment on column cst_ibbl_bank_rit.no_atm is 'Numbers of ATM'
/
comment on column cst_ibbl_bank_rit.no_pos is 'Numbers of POS'
/
comment on column cst_ibbl_bank_rit.issued_local_credit is 'Numbers of issued local credit card'
/
comment on column cst_ibbl_bank_rit.issued_dual_credit is 'Numbers of issued dual credit card'
/
comment on column cst_ibbl_bank_rit.issued_intna_credit is 'Numbers of issued international credit card'
/
comment on column cst_ibbl_bank_rit.issued_local_debit is 'Numbers of issued local debit card'
/
comment on column cst_ibbl_bank_rit.issued_intna_debit is 'Numbers of issued international debit card'
/
comment on column cst_ibbl_bank_rit.issued_local_prepaid is 'Numbers of issued local prepaid card'
/
comment on column cst_ibbl_bank_rit.issued_intna_prepaid is 'Numbers of issued international prepaid card'
/
comment on column cst_ibbl_bank_rit.debit_atm_bd_no_tran is 'Debit card transactions through ATM in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_atm_bd_value is 'Debit card transactions through ATM in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_pos_bd_no_tran is 'Debit card transactions through POS in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_pos_bd_value is 'Debit card transactions through POS in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_ecom_bd_no_tran is 'Debit card transactions through E-Commerce in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_ecom_bd_value is 'Debit card transactions through E-Commerce in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_atm_ab_no_tran is 'Debit card transactions through ATM in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_atm_ab_value is 'Debit card transactions through ATM in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_pos_ab_no_tran is 'Debit card transactions through POS in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_pos_ab_value is 'Debit card transactions through POS in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_ecom_ab_no_tran is 'Debit card transactions through E-Commerce in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.debit_ecom_ab_value is 'Debit card transactions through E-Commerce in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_atm_bd_no_tran is 'Credit card transactions through ATM in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_atm_bd_value is 'Credit card transactions through ATM in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_pos_bd_no_tran is 'Credit card transactions through POS in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_pos_bd_value is 'Credit card transactions through POS in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_ecom_bd_no_tran is 'Credit card transactions through E-Commerce in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_ecom_bd_value is 'Credit card transactions through E-Commerce in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_atm_ab_no_tran is 'Credit card transactions through ATM in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_atm_ab_value is 'Credit card transactions through ATM in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_pos_ab_no_tran is 'Credit card transactions through POS in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_pos_ab_value is 'Credit card transactions through POS in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_ecom_ab_no_tran is 'Credit card transactions through E-Commerce in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_ecom_ab_value is 'Credit card transactions through E-Commerce in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.credit_outstanding_amt is 'Credit card transactions - Outstanding amount'
/
comment on column cst_ibbl_bank_rit.credit_year_intr_rate is 'Credit card transactions - Yearly interest rate (Weighted average)'
/
comment on column cst_ibbl_bank_rit.prepaid_bd_no_tran is 'Prepaid card transactions in BD (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.prepaid_bd_value is 'Prepaid card transactions in BD (value of transaction)'
/
comment on column cst_ibbl_bank_rit.prepaid_ab_no_tran is 'Prepaid card transactions in abroad (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.prepaid_ab_value is 'Prepaid card transactions in abroad (value of transaction)'
/
comment on column cst_ibbl_bank_rit.fraud_atm_no is 'Fraud through ATM  (no. of fraud)'
/
comment on column cst_ibbl_bank_rit.fraud_atm_value is 'Fraud through ATM (value of fraud)'
/
comment on column cst_ibbl_bank_rit.acq_bd_debit_atm_no_tran is 'Not-os-us Debit card transactions through ATM (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_debit_atm_value is 'Not-os-us Debit card transactions through ATM (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_debit_pos_no_tran is 'Not-os-us Debit card transactions through POS (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_debit_pos_value is 'Not-os-us Debit card transactions through POS (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_credit_atm_no_tran is 'Not-os-us Credit card transactions through ATM (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_credit_atm_value is 'Not-os-us Credit card transactions through ATM (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_credit_pos_no_tran is 'Not-os-us Credit card transactions through POS (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_bd_credit_pos_value is 'Not-os-us Credit card transactions through POS (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_atm_no_tran is 'ATM transactions by cards issued outside the country (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_atm_value is 'ATM transactions by cards issued outside the country (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_pos_no_tran is 'POS transactions by cards issued outside the country (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_pos_value is 'POS transactions by cards issued outside the country (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_ecom_no_tran is 'E-commerce transactions by cards issued outside the country (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_ecom_value is 'E-commerce transactions by cards issued outside the country (value of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_prepaid_no_tran is 'Transactions by Prepaid cards issued outside the country (no. of transaction)'
/
comment on column cst_ibbl_bank_rit.acq_ab_prepaid_value is 'Transactions by Prepaid cards issued outside the country (value of transaction)'
/
comment on column cst_ibbl_bank_rit.i_month is 'Month of the transaction date'
/
comment on column cst_ibbl_bank_rit.i_year is 'Year of the transaction date'
/
comment on column cst_ibbl_bank_rit.run_date is 'Execution date time'
/
