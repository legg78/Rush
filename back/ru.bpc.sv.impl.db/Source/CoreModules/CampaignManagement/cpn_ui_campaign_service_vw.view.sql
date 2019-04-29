create or replace force view cpn_ui_campaign_service_vw as
select cs.id
     , cs.campaign_id
     , cs.product_id
     , cs.service_id
     , get_text(
           i_table_name  => 'prd_service'
         , i_column_name => 'label'
         , i_object_id   => cs.service_id
         , i_lang        => l.lang
       ) as service_label
     , get_text(
           i_table_name  => 'prd_product'
         , i_column_name => 'label'
         , i_object_id   => cs.product_id
         , i_lang        => l.lang
       ) as product_label
     , l.lang
  from cpn_campaign_service cs
     , prd_service s
     , com_language_vw l
 where s.id  = cs.service_id
   and s.inst_id in (select i.inst_id from acm_cu_inst_vw i)
/
