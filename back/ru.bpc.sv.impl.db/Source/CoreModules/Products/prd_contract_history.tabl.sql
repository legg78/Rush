create table prd_contract_history(
    contract_id         number(12)
  , product_id          number(8)
  , start_date          date
  , end_date            date
  , split_hash          number(4)
)
/

comment on table prd_contract_history is 'History of contract products'
/

comment on column prd_contract_history.contract_id is 'Reference to contract'
/

comment on column prd_contract_history.product_id is 'Product assigned on contract in the past'
/

comment on column prd_contract_history.start_date is 'Start date of product validity'
/

comment on column prd_contract_history.end_date is 'End date of product validity'
/

comment on column prd_contract_history.split_hash is 'Hash value to split processing'
/
