create or replace force view cpn_ui_campaign_attribute_vw as
select a.id
     , a.campaign_id
     , a.product_id
     , a.service_id
     , a.attribute_id
     , com_api_i18n_pkg.get_text('prd_attribute', 'label', a.attribute_id, l.lang) as label
     , com_api_i18n_pkg.get_text('prd_attribute', 'description', a.attribute_id, l.lang) as description
     , com_api_i18n_pkg.get_text('prd_attribute', 'short_name', a.attribute_id, l.lang) as short_name
     , l.lang
  from cpn_campaign_attribute a
     , com_language_vw l
/
