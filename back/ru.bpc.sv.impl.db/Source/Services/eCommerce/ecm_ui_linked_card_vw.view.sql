create or replace force view ecm_ui_linked_card_vw as
select id                
     , entity_type        
     , object_id        
     , card_mask        
     , cardholder_name
     , expiration_date
     , card_network_id
     , card_inst_id    
     , iss_network_id
     , iss_inst_id        
     , status            
     , link_date        
     , unlink_date        
from ecm_linked_card
/
