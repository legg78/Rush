create or replace force view prd_ui_contract_service_vw as
select a.id
     , a.contract_number
     , c.service_id
     , c.min_count
     , c.max_count
     , c.max_count - (select count(1)
                        from prd_service_object d
                       where d.service_id  = c.service_id 
                         and d.contract_id = a.id
                         and nvl(d.end_date, get_sysdate + 1) > get_sysdate
                      ) aval_count
     , f.entity_type
     , f.is_initial
     , e.service_type_id
     , get_text(
           i_table_name  => 'prd_service'
         , i_column_name => 'label'
         , i_object_id   => c.service_id
         , i_lang        => b.lang
       ) service_label
     , get_text(
           i_table_name  => 'prd_service_type'
         , i_column_name => 'label'
         , i_object_id   => e.service_type_id
         , i_lang        => b.lang
       ) service_type_label
     , b.lang
     , a.id contract_id
     , e.status
  from prd_contract_vw a
     , prd_ui_product_service_vw c
     , prd_service e
     , prd_service_type_vw f
     , com_language_vw b
 where a.product_id = c.product_id
   and c.service_id = e.id
   and f.id         = e.service_type_id
/
