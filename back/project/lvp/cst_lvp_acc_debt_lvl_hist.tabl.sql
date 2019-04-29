create table cst_lvp_acc_debt_lvl_hist(
    id                number(12)    not null
  , flex_field_name   varchar2(200) not null
  , account_id        number(12)    not null
  , debt_level        varchar2(8)   not null
  , prev_debt_level   varchar2(8)
  , start_date        date          not null
  , end_date          date
  , reason_event      varchar2(8)
)
/

comment on table cst_lvp_acc_debt_lvl_hist is 'Debt level of account.'
/
comment on column cst_lvp_acc_debt_lvl_hist.account_id is 'Account identifier.'
/
comment on column cst_lvp_acc_debt_lvl_hist.debt_level is 'Debt level (dictionary DBTL).'
/
comment on column cst_lvp_acc_debt_lvl_hist.prev_debt_level is 'Previous debt level (dictionary DBTL).'
/
comment on column cst_lvp_acc_debt_lvl_hist.start_date is 'Start date'
/
comment on column cst_lvp_acc_debt_lvl_hist.end_date is 'End date'
/
comment on column cst_lvp_acc_debt_lvl_hist.reason_event is 'Reason event'
/
