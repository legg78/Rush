create table mcw_brand_product (
    licensed_product_id varchar2(3) not null
    , gcms_product_id   varchar2(3)
    , card_program_id   varchar2(3)
    , product_class     varchar2(3)
    , product_type_id   varchar2(1)
    , product_category  varchar2(1)
    , product_category_code  varchar2(1)
    , comm_product_indicator varchar2(1)
)
/

comment on table mcw_brand_product is 'This table contains the valid licensed product ID and masked product ID combinations.'
/

comment on column mcw_brand_product.licensed_product_id is 'The actual product code assigned by MasterCard when licensing the combination of issuer account range and card program identifier'
/

comment on column mcw_brand_product.gcms_product_id is 'The Product ID recognized by the GCMS issuer account range and card program ID combination'
/

comment on column mcw_brand_product.card_program_id is 'The card program identifier associated with the account range'
/

comment on column mcw_brand_product.product_class is 'Used in interchange processing'
/

comment on column mcw_brand_product.product_type_id is 'The product type of the associated account range and card program identifier'
/

comment on column mcw_brand_product.product_category is 'Identifies the intended business functionality of cards issued under the associated licensed product ID'
/

comment on column mcw_brand_product.product_category_code is 'Europe Product Category Code'
/

comment on column mcw_brand_product.comm_product_indicator is 'Identifies the product category'
/
