create or replace force view cpn_attribute_value_vw as
select id
     , campaign_id
     , attribute_value_id
from cpn_attribute_value
/
