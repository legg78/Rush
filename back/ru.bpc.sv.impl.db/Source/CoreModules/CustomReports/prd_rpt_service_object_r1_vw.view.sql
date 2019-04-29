create or replace force view prd_rpt_service_object_r1_vw as
select id
     , contract_id
     , service_id
     , entity_type
     , object_id
     , status
     , start_date
     , end_date
     , split_hash
  from prd_service_object
/

