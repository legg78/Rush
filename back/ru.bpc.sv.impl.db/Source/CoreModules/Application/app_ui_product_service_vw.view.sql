create or replace force view app_ui_product_service_vw as
select ps.id
     , ps.parent_id
     , l.lang
     , s.id service_id
     , get_text (i_table_name    => 'prd_service'
               , i_column_name   => 'label'
               , i_object_id     => s.id
               , i_lang          => l.lang) service_label
     , s.service_type_id
     , ps.product_id 
     , t.entity_type
     , t.is_initial
     , ps.min_count
     , ps.max_count
     , ps.conditional_group
  from prd_service s
     , prd_service_type t
     , prd_product_service ps
     , com_language_vw l
 where s.id              = ps.service_id
   and s.service_type_id = t.id
/
