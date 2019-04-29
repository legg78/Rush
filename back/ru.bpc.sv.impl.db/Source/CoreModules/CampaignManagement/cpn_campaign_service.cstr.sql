alter table cpn_campaign_service add (
    constraint cpn_campaign_service_pk primary key (id) using index
  , constraint cpn_campaign_service_uk unique(campaign_id, service_id, product_id)
)
/ 
