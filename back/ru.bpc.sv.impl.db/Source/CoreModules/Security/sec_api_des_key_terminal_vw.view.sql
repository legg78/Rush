create or replace force view sec_api_des_key_terminal_vw (   
   key_type,
   key_prefix,
   key_length,
   check_value,
   key_value,   
   terminal_id,
   lmk_id
   )
as
   select 
       a.key_type,
       a.key_prefix,
       a.key_length,
       a.check_value,
       a.key_value,          
       b.id,
       a.lmk_id
   from 
       sec_des_key a, 
       acq_terminal_vw b
   where 
       a.entity_type = 'ENTTTRMN' 
       and a.object_id = b.id
/