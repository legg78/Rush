create index prd_contract_number_rvrs_ndx on prd_contract (reverse(contract_number))
/
create index prd_contract_customer_ndx on prd_contract(customer_id)
/
