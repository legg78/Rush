create materialized view acc_gl_account_mvw
cache
build immediate
refresh on demand complete
with primary key
as 
select t.entity_type
     , decode(t.entity_type, 'ENTTINST', a.inst_id, 'ENTTAGNT', a.agent_id) entity_id
     , a.id              
     , a.split_hash      
     , a.account_type    
     , a.account_number  
     , a.currency        
     , a.inst_id         
     , a.agent_id        
     , a.customer_id     
     , a.contract_id     
     , a.status          
  from acc_account_type_entity t
     , acc_account a
 where t.entity_type in ('ENTTINST', 'ENTTAGNT') 
   and t.account_type = a.account_type 
   and t.inst_id = a.inst_id
/
create unique index acc_gl_account_inst_uk on acc_gl_account_mvw (entity_id, entity_type, account_type, currency)
/
