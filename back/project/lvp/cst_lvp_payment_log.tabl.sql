create table cst_lvp_payment_log(   
    pay_debt_id     number(16, 0)
  , eff_date        date
  , run_date        date
)
/

comment on table cst_lvp_payment_log is 'Custom table for LienVietPostBank to prevent duplicated GL payment'
/
comment on column cst_lvp_payment_log.pay_debt_id is 'Debt payment ID'
/
comment on column cst_lvp_payment_log.eff_date is 'Effective date'
/
comment on column cst_lvp_payment_log.run_date is 'Running date (sysdate)'
/
