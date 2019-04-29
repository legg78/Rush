create or replace force view ecm_api_linked_card_vw as
select a.id                
     , a.entity_type        
     , a.object_id        
     , a.card_mask        
     , a.cardholder_name
     , a.expiration_date
     , a.card_network_id
     , a.card_inst_id    
     , a.iss_network_id
     , a.iss_inst_id        
     , a.status            
     , a.link_date        
     , a.unlink_date
  from ecm_linked_card a
/
