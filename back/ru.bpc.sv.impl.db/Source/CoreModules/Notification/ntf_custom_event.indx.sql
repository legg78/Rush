create unique index ntf_custom_event_uk on ntf_custom_event (entity_type, object_id, scheme_event_id, channel_id, delivery_address)
/
drop index ntf_custom_event_uk
/
create unique index ntf_custom_event_uk on ntf_custom_event (entity_type, object_id, channel_id, delivery_address, event_type)
/
drop index ntf_custom_event_uk
/
create unique index ntf_custom_event_uk on ntf_custom_event (entity_type, object_id, channel_id, delivery_address, event_type, contact_type)
/
