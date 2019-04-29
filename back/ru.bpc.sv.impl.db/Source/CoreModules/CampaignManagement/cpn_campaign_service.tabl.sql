create table cpn_campaign_service (
    id                  number(8)
  , campaign_id         number(8)
  , product_id          number(8)
  , service_id          number(8)  
)
/
comment on table cpn_campaign_service is 'Services linked with campaign'
/
comment on column cpn_campaign_service.id is 'Link identifier'
/
comment on column cpn_campaign_service.campaign_id is 'Campaign identifier'
/
comment on column cpn_campaign_service.product_id is 'Campaign product identifier'
/
comment on column cpn_campaign_service.service_id is 'Service identifier'
/
