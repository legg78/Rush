create or replace force view cpn_ui_campaign_product_vw as
select cp.id
     , cp.campaign_id
     , cp.product_id
     , get_text(
           i_table_name  => 'prd_product'
         , i_column_name => 'label'
         , i_object_id   => p.id
         , i_lang        => l.lang
     ) as product_label
     , p.product_type
     , get_article_text(p.product_type, l.lang) as product_type_desc
     , p.inst_id
     , l.lang
  from cpn_campaign_product cp
     , prd_product p
     , com_language_vw l
 where p.id    = cp.product_id
/
