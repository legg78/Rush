create or replace force view cpn_campaign_product_vw as
select p.id
     , p.campaign_id
     , p.product_id
  from cpn_campaign_product p
/
