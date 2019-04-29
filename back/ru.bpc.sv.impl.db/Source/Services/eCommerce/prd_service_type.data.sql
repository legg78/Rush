insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10001717, 1, 'PRDT0100', 'ENTTCARD', 0, NULL, NULL, NULL)
/
update prd_service_type set enable_event_type = 'EVNT0104', disable_event_type = 'EVNT0105' where id = 10001717
/
