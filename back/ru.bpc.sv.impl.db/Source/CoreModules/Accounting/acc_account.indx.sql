create index acc_account_number_rvrs_ndx on acc_account (reverse(account_number))
/
create index acc_account_contract_ndx on acc_account (contract_id)
/
create index acc_account_customer_ndx on acc_account (customer_id)
/
