create table prd_product (
    id                  number(8)
  , product_type      varchar2(8)
  , contract_type     varchar2(8)
  , parent_id         number(8)
  , seqnum            number(4)
  , inst_id           number(4)
  , status            varchar2(8)
)
/

comment on table prd_product is 'Products list'
/
comment on column prd_product.id is 'Identifier'
/
comment on column prd_product.product_type is 'Product type (PRDT key)'
/
comment on column prd_product.contract_type is 'Contract type. Describe business area where product could be used.'
/
comment on column prd_product.parent_id is 'Parent product identifier'
/
comment on column prd_product.seqnum is 'Sequential number of data version'
/
comment on column prd_product.inst_id is 'Owner institution identifier'
/
comment on column prd_product.status is 'Product status (PRDS key)'
/

alter table prd_product add(product_number varchar2(200))
/
comment on column prd_product.product_number is 'External product number'
/
update prd_product set product_number = to_char(id) where product_number is null
/
alter table prd_product add (split_hash number(4))
/
comment on column prd_product.split_hash is 'Hash value to split processing which is calculated by product identifier'
/
