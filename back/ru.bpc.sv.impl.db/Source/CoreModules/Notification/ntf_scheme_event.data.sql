insert into ntf_scheme_event (id, seqnum, scheme_id, event_type, entity_type, contact_type, notif_id, channel_id, delivery_time, is_customizable, is_active, is_batch_send, scale_id, priority, status) values (10000045, 1, 1006, 'EVNT2303', 'ENTTCUST', 'CNTTNTFC', 1044, 1, '08-20', 0, NULL, 0, NULL, NULL, 'NTES0010')
/
insert into ntf_scheme_event (id, seqnum, scheme_id, event_type, entity_type, contact_type, notif_id, channel_id, delivery_time, is_customizable, is_active, is_batch_send, scale_id, priority, status) values (10000046, 1, 1007, 'CYTP1014', 'ENTTCUST', 'CNTTNTFC', 1045, 3, '00-23', 0, NULL, 0, NULL, NULL, 'NTES0010')
/
insert into ntf_scheme_event (id, seqnum, scheme_id, event_type, entity_type, contact_type, notif_id, channel_id, delivery_time, is_customizable, is_active, is_batch_send, scale_id, priority, status) values (10000047, 1, 1008, 'CYTP0417', 'ENTTCUST', 'CNTTNTFC', 1046, 3, '00-24', 0, NULL, 0, NULL, NULL, 'NTES0010')
/
delete ntf_scheme_event where id = 10000046
/
delete ntf_scheme_event where id = 10000047
/
