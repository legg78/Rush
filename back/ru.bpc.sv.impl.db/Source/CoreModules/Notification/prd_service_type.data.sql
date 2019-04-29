insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial) values (10000540, 1, 'PRDT0100', 'ENTTCUST', 0)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10002000, 1, 'PRDT0100', 'ENTTCARD', 0, NULL, NULL, 10002001)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10002228, 12, 'PRDT0200', 'ENTTCUST', 0, NULL, NULL, NULL)
/
update prd_service_type set enable_event_type = 'EVNT0112', disable_event_type = 'EVNT0113' where id = 10002000
/
update prd_service_type set enable_event_type = 'EVNT2107', disable_event_type = 'EVNT2108' where id = 10000540
/
