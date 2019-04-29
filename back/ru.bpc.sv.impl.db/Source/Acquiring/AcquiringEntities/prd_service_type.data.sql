insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type) values (10000905, 1, 'PRDT0200', 'ENTTMRCH', 1, 'EVNT0200', 'EVNT0220')
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type) values (10001122, 1, 'PRDT0200', 'ENTTCUST', 1, 'EVNT0250', 'EVNT0251')
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type) values (10001022, 1, 'PRDT0200', 'ENTTTRMN', 1, 'EVNT0210', 'EVNT0240')
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10001508, 3, 'PRDT0200', 'ENTTMRCH', 1, 'EVNT0200', 'EVNT0220', NULL)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10001510, 8, 'PRDT0200', 'ENTTTRMN', 1, 'EVNT0210', 'EVNT0240', NULL)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10001687, 2, 'PRDT0200', 'ENTTTRMN', 1, 'EVNT0210', 'EVNT0240', NULL)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10002168, 2, 'PRDT0200', 'ENTTACCT', 1, 'EVNT0300', 'EVNT0301', NULL)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10002801, 1, 'PRDT0200', 'ENTTTRMN', 0, 'EVNT0247', 'EVNT0246', NULL)
/
insert into prd_service_type (id, seqnum, product_type, entity_type, is_initial, enable_event_type, disable_event_type, service_fee) values (10004094, 1, 'PRDT0100', 'ENTTCARD', 1, 'EVNT0270', 'EVNT0271', NULL)
/
delete from prd_service_type where id = 10004094
/
