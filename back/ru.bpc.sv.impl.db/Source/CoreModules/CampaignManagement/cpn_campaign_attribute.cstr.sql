alter table cpn_campaign_attribute add (
    constraint cpn_campaign_attribute_pk primary key (id) using index
  , constraint cpn_campaign_attribute_uk unique(campaign_id, service_id, product_id, attribute_id)
)
/ 
