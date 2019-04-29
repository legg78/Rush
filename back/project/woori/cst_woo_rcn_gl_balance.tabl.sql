create table cst_woo_rcn_gl_balance(
    aggregation_date    date
  , account_number      varchar2(32)
  , status              varchar2(8)
  , amount              number(22,4)
  , currency            varchar2(3)
  , agent_number        varchar2(30)
)
/
comment on table cst_woo_rcn_gl_balance is 'Reconciliation GL account balance from CBS'
/
comment on column cst_woo_rcn_gl_balance.aggregation_date is 'Aggregation date'
/
comment on column cst_woo_rcn_gl_balance.account_number is 'GL account number'
/
comment on column cst_woo_rcn_gl_balance.status is 'Reconciliation status: RCNS0001 = imported, RCNS0002 = aggregated, RCNS0000 = matched'
/
comment on column cst_woo_rcn_gl_balance.amount is 'Balance amount'
/
comment on column cst_woo_rcn_gl_balance.currency is 'Currency'
/
comment on column cst_woo_rcn_gl_balance.agent_number is 'Agent number (branch code)'
/
