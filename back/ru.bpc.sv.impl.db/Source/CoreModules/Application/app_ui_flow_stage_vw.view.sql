create or replace force view app_ui_flow_stage_vw as
select a.id
     , a.seqnum
     , a.flow_id
     , get_text(
           i_table_name  => 'app_flow'
         , i_column_name => 'label'
         , i_object_id   => a.flow_id
       ) as flow_name
     , a.appl_status
     , a.handler
     , a.handler_type
     , a.reject_code
     , a.role_id
     , r.name as role_name
  from app_flow_stage a
     , acm_role r
 where r.id(+) = a.role_id
/
