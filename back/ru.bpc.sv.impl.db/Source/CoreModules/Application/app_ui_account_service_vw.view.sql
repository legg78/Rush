create or replace force view app_ui_account_service_vw as
select ps.id
     , ps.parent_id
     , sv.id service_id
     , get_text (i_table_name    => 'prd_service'
               , i_column_name   => 'label'
               , i_object_id     => sv.id
               , i_lang          => l.lang
       ) service_label
     , l.lang
     , st.id service_type_id
     , get_text (i_table_name    => 'prd_service_type'
               , i_column_name   => 'label'
               , i_object_id     => st.id
               , i_lang          => l.lang
       ) service_type
     , st.is_initial
     , m.id account_id
     , m.account_number
     , cn.contract_number
     , m.contract_id
     , cn.product_id
     , decode(
         (select count(*) 
            from prd_service_object o 
           where((st.is_initial = 0 and o.entity_type = 'ENTTACCT' and o.object_id = m.id)
              or (st.is_initial = 1 and o.contract_id = cn.id)) 
             and o.service_id = sv.id),0,0,1) is_service_exist
     , sum(
         (select count(*) 
            from prd_service_object o 
           where((st.is_initial = 0 and o.entity_type = 'ENTTACCT' and o.object_id = m.id)
              or (st.is_initial = 1 and o.contract_id = cn.id)) 
             and o.service_id = sv.id)
     ) over(partition by l.lang, m.id) total_count      
     , nvl(ps.min_count, 0) min_count    
     , nvl(ps.max_count, 0) max_count
 from (select connect_by_root service_id root_service_id
            , id
            , parent_id
            , product_id
            , service_id
            , min_count
            , max_count
         from prd_product_service_vw
      connect by parent_id = prior id
        start with parent_id is null
       ) ps
     , prd_service_vw s
     , prd_service_type_vw t
     , acc_account m
     , prd_contract cn
     , prd_service sv
     , prd_service_type st
     , com_language_vw l
 where t.entity_type      = 'ENTTACCT'
   and s.service_type_id  = t.id
   and m.contract_id      = cn.id
   and m.inst_id          = s.inst_id
   and ps.root_service_id = s.id
   and ps.product_id      = cn.product_id
   and sv.id              = ps.service_id
   and st.id              = sv.service_type_id
   and sv.inst_id in (select x.inst_id from acm_cu_inst_vw x)
/