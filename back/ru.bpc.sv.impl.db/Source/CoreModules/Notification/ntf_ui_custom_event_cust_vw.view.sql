create or replace force view ntf_ui_custom_event_cust_vw as
select
     c.id
     , s.id scheme_id
     , e.id scheme_event_id
     , c.object_id
     , nvl(c.channel_id, e.channel_id) channel_id
     , c.delivery_address
     , nvl(c.delivery_time, e.delivery_time) delivery_time
     , nvl(c.status, e.status) status
     , c.mod_id
     , s.inst_id
     , e.event_type
     , e.entity_type
     , case 
           when c.entity_type = 'ENTTCRDH' 
               then ch.cardholder_number
           when c.entity_type = 'ENTTCUST'
               then pc.customer_number
           else null   
       end  as event_entity_number 
     , c.start_date
     , c.end_date
     , get_text('ost_institution', 'name', s.inst_id, l.lang) inst_name
     , get_text('rul_mod', 'name', c.mod_id, l.lang) mod_name
     , get_text('ntf_channel', 'name', nvl(c.channel_id, e.channel_id), l.lang) channel_name
     , l.lang
  from (
    select c.id
         , c.object_id
         , c.entity_type
         , c.channel_id
         , c.delivery_address
         , c.delivery_time
         , c.status
         , c.mod_id
         , c.start_date
         , c.end_date
         , c.event_type
         , c.contact_type
         , prd_api_product_pkg.get_attr_value_number (
                i_entity_type    => 'ENTTCUST'
              , i_object_id      => c.customer_id
              , i_attr_name      => 'NOTIFICATION_SCHEME'
              , i_mask_error     => 1
            ) scheme_id
      from ntf_custom_event c
     ) c
     , ntf_scheme s
     , ntf_scheme_event e
     , com_language_vw l
     , iss_cardholder  ch
     , prd_customer    pc
 where s.id = c.scheme_id
   and s.scheme_type = 'NTFS0010'
   and s.id = e.scheme_id
   and e.entity_type = c.entity_type
   and (c.event_type   is null or c.event_type   = e.event_type)
   and (c.contact_type is null or c.contact_type = e.contact_type)
   and s.inst_id in (select inst_id from acm_cu_inst_vw)  
   and case 
           when c.entity_type = 'ENTTCUST' then c.object_id
           else null
       end = pc.id(+)       
   and case 
           when c.entity_type = 'ENTTCRDH' then c.object_id
           else null
       end = ch.id(+)  
/
