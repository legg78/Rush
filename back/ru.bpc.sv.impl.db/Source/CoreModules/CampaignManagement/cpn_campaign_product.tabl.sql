create table cpn_campaign_product (
    id                number(8)
  , campaign_id       number(8)
  , product_id        number(8)  
)
/
comment on table cpn_campaign_product is 'Products linked with campaign'
/
comment on column cpn_campaign_product.id is 'Link identifier'
/
comment on column cpn_campaign_product.campaign_id is 'Campaign identifier'
/
comment on column cpn_campaign_product.product_id is 'Product identifier'
/

create unique index cpn_campaign_product_uk on cpn_campaign_product (campaign_id, product_id)
/
