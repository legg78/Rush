create or replace force view prd_service_type_vw as
select n.id
     , n.seqnum
     , n.product_type
     , n.entity_type
     , n.is_initial
     , n.enable_event_type
     , n.disable_event_type
     , n.service_fee
	 , n.external_code
  from prd_service_type n
/

