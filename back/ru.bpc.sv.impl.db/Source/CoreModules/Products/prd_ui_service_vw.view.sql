create or replace force view prd_ui_service_vw as
select n.id
     , n.seqnum
     , n.service_type_id
     , n.template_appl_id
     , n.inst_id
     , n.status
     , n.service_number
     , get_text(
           i_table_name  => 'prd_service'
         , i_column_name => 'label'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) as label
     , get_text(
           i_table_name  => 'prd_service'
         , i_column_name => 'description'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) as description
     , l.lang
  from prd_service n
     , com_language_vw l
 where n.inst_id in (select inst_id from acm_cu_inst_vw)
/
