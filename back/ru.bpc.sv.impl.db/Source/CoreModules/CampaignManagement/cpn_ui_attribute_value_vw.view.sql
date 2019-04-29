create or replace force view cpn_ui_attribute_value_vw as
select v.id
     , v.campaign_id
     , v.attribute_value_id
     , l.lang
  from cpn_attribute_value v
     , com_language_vw l
/
