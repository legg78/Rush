create table prd_contract (
    id                number(12)
  , seqnum            number(4)
  , product_id        number(8)
  , customer_id       number(12)
  , contract_type     varchar2(8)
  , contract_number   varchar2(200)
  , start_date        date
  , end_date          date
  , inst_id           number(4)
  , agent_id          number(8)
  , split_hash        number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table prd_contract is 'Customer contracts.'
/
comment on column prd_contract.id is 'Primary key.'
/
comment on column prd_contract.seqnum is 'Sequential number of data version'
/
comment on column prd_contract.product_id is 'Reference to product assigned to contract.'
/
comment on column prd_contract.customer_id is 'Customer which contract belongs to'
/
comment on column prd_contract.contract_type is 'Contract type.'
/
comment on column prd_contract.contract_number is 'External contract number.'
/
comment on column prd_contract.start_date is 'Contract start date.'
/
comment on column prd_contract.end_date is 'Contract end date.'
/
comment on column prd_contract.inst_id is 'Institution identifier.'
/
comment on column prd_contract.agent_id is 'Agent identifier'
/
comment on column prd_contract.split_hash is 'Hash value to split processing'
/

