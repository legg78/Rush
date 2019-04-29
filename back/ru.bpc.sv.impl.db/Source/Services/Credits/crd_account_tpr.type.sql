create or replace type crd_account_tpr as object (
    id                      number(12)
  , account_number          varchar2(32)
  , currency                varchar2(3)
  , sttl_date               date
  , unpaid_interest_amount  number(22,4)
  , mad_amount              number(22,4)
  , unpaid_mad_amount       number(22,4)
  , overdue_age             number(4)
  , mad_date                date
  , grace_date              date
)
/
