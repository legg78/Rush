create or replace force view cpn_campaign_service_vw as
select id
     , campaign_id
     , product_id
     , service_id
  from cpn_campaign_service
/
