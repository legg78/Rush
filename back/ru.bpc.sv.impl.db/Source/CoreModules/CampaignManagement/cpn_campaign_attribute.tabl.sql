create table cpn_campaign_attribute (
    id                  number(8)
  , campaign_id         number(8)
  , product_id          number(8)
  , service_id          number(8)  
  , attribute_id        number(8)  
)
/
comment on table cpn_campaign_attribute is 'Attributes linked with campaign'
/
comment on column cpn_campaign_attribute.id is 'Link identifier'
/
comment on column cpn_campaign_attribute.campaign_id is 'Campaign identifier'
/
comment on column cpn_campaign_attribute.product_id is 'Campaign product identifier'
/
comment on column cpn_campaign_attribute.service_id is 'Service identifier'
/
comment on column cpn_campaign_attribute.attribute_id is 'Attribute identifier'
/
