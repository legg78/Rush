insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee, external_code) values (10004386, 1, 'PRDT0100', 'ENTTCARD', 1, 'EVNT4601', 'EVNT4602', NULL, NULL)
/
update prd_service_type set is_initial = 0 where id = 10004386
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee, external_code) values (10004466, 1, 'PRDT0200', 'ENTTMRCH', 0, 'EVNT0275', 'EVNT0276', NULL, NULL)
/
