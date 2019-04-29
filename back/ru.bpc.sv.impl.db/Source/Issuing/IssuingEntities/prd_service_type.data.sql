insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type) values (10000472, 1, 'PRDT0100', 'ENTTCARD', 1, 'EVNT0100', 'EVNT0101')
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type) values (10001089, 1, 'PRDT0100', 'ENTTCNTR', 1, 'EVNT0130', 'EVNT0131')
/
update prd_service_type set service_fee = 10000493 where id = 10000472
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee, external_code) values (10004065, 1, 'PRDT0100', 'ENTTCARD', 0, 'EVNT0132', 'EVNT0133', NULL, NULL)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee, external_code) values (10004110, 1, 'PRDT0100', 'ENTTCARD', 1, 'EVNT0270', 'EVNT0271', NULL, NULL)
/
