create table prd_contract_type (
    id                   number(4)
  , seqnum               number(4)
  , contract_type        varchar2(8)
  , customer_entity_type varchar2(8)
  , product_type         varchar2(8)
 )
/

comment on table prd_contract_type is 'Relations between contract types, product types and customer types.'
/

comment on column prd_contract_type.id is 'Primary key.'
/
comment on column prd_contract_type.seqnum is 'Sequential number of data version'
/
comment on column prd_contract_type.contract_type is 'Contract type.'
/
comment on column prd_contract_type.customer_entity_type is 'Customer entity type (Company, Person).'
/
comment on column prd_contract_type.product_type is 'Product type.'
/

