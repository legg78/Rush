create unique index acc_balance_account_bal_ndx on acc_balance (
    account_id
    ,balance_type
)
/

drop index acc_balance_account_bal_ndx
/
create unique index acc_balance_account_bal_ndx_uk on acc_balance (account_id, balance_type)
/
