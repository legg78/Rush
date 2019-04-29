create or replace force view ntf_ui_scheme_event_vw as
select 
    n.id
    , n.seqnum
    , n.scheme_id
    , n.event_type
    , n.entity_type
    , n.contact_type
    , n.notif_id
    , n.channel_id
    , n.delivery_time
    , n.is_customizable
    , n.is_batch_send
    , n.scale_id
    , n.priority
    , n.status
from
    ntf_scheme_event n
/
