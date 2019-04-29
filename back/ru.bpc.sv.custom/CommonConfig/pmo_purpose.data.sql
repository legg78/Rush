insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000001, 10000001, 10000001, 'POHAHOST', 'OPTP0042', NULL, NULL)
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000002, 10000001, 10000002, 'POHAHOST', 'OPTP0042', NULL, NULL)
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000003, 10000001, 10000003, 'POHAHOST', 'OPTP0041', NULL, NULL)
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000004, 10000001, 10000005, 'POHAHOST', 'OPTP0041', NULL, NULL)
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000005, 10000001, 10000006, 'POHAHOST', 'OPTP0041', NULL, NULL)
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000007, 10000001, 10000008, 'POHAHOST', 'OPTP0042', 10000002, '6010')
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000008, 10000001, 10000009, 'POHAHOST', 'OPTP0028', NULL, NULL)
/
update pmo_purpose set oper_type = 'OPTP0041' where id = 10000007
/
update pmo_purpose set terminal_id = 10000002 where id = 10000001
/
update pmo_purpose set terminal_id = 10000002 where id in (10000002,10000003,10000004,10000005,10000008,10000006)
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000009, 10000002, 10000010, 'POHAHOST', 'OPTP0010', NULL, '6010')
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000010, 10000002, 10000011, 'POHAHOST', 'OPTP0010', NULL, '6010')
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000011, 10000002, 10000012, 'POHAHOST', 'OPTP0000', NULL, '6010')
/
update pmo_purpose set terminal_id = 10000002 where id = 10000011
/
insert into pmo_purpose (id, provider_id, service_id, host_algorithm, oper_type, terminal_id, mcc) values (10000012, 10000001, 10000013, 'POHAHOST', 'OPTP0041', 10000002, NULL)
/
update pmo_purpose set inst_id = 9999 where id = 10000001
/
update pmo_purpose set inst_id = 9999 where id = 10000002
/
update pmo_purpose set inst_id = 9999 where id = 10000003
/
update pmo_purpose set inst_id = 9999 where id = 10000004
/
update pmo_purpose set inst_id = 9999 where id = 10000005
/
update pmo_purpose set inst_id = 9999 where id = 10000006
/
update pmo_purpose set inst_id = 9999 where id = 10000007
/
update pmo_purpose set inst_id = 9999 where id = 10000008
/
update pmo_purpose set inst_id = 9999 where id = 10000009
/
update pmo_purpose set inst_id = 9999 where id = 10000010
/
update pmo_purpose set inst_id = 9999 where id = 10000011
/
update pmo_purpose set inst_id = 9999 where id = 10000012
/
