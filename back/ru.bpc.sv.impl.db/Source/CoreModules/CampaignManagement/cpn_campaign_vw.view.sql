create or replace force view cpn_campaign_vw as
select id
     , inst_id
     , seqnum
     , start_date
     , end_date
     , campaign_number
     , campaign_type
     , cycle_id
  from cpn_campaign
/
