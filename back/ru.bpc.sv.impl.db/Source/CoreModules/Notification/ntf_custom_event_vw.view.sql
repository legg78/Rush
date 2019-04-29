create or replace force view ntf_custom_event_vw as
select n.id
     , n.event_type
     , n.entity_type
     , n.object_id
     , n.channel_id
     , n.delivery_address
     , n.delivery_time
     , n.is_active
     , n.mod_id
     , n.start_date
     , n.end_date
     , n.status
     , n.customer_id
     , n.contact_type
  from ntf_custom_event n
/
