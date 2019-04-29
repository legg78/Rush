create unique index ntf_scheme_event_uk on ntf_scheme_event (event_type, entity_type, contact_type, channel_id)
/
drop index ntf_scheme_event_uk
/
create unique index ntf_scheme_event_uk on ntf_scheme_event (event_type, entity_type, contact_type, channel_id, scheme_id)
/
