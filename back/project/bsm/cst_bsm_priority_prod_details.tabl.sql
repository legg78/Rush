create table cst_bsm_priority_prod_details(
    id                  number(12)
  , product_id          number(8)
  , parent_product_id   number(8)
  , product_number      varchar2(30)
  , product_description varchar2(200)
  , product_category    varchar2(30)
  , product_subcategory varchar2(30)
  , product_level3      varchar2(30)
  , creation_date       date
  , product_level4      varchar2(30)
  , product_lag         number(2)
)
/

comment on table cst_bsm_priority_prod_details is 'Priority product details'
/
comment on column cst_bsm_priority_prod_details.id is 'Identifier'
/
comment on column cst_bsm_priority_prod_details.product_id          is 'Table ID'
/
comment on column cst_bsm_priority_prod_details.parent_product_id   is 'Product group'
/
comment on column cst_bsm_priority_prod_details.product_number      is 'Product code'
/
comment on column cst_bsm_priority_prod_details.product_description is 'Product description'
/
comment on column cst_bsm_priority_prod_details.product_category    is 'Product category'
/
comment on column cst_bsm_priority_prod_details.product_subcategory is 'Product sub category'
/
comment on column cst_bsm_priority_prod_details.product_level3      is 'Product level3'
/
comment on column cst_bsm_priority_prod_details.creation_date       is 'Product creation date'
/
comment on column cst_bsm_priority_prod_details.product_level4      is 'Product level4'
/
comment on column cst_bsm_priority_prod_details.product_lag         is 'Lags'
/
