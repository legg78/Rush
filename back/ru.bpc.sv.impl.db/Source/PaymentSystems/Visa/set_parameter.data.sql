delete from set_parameter where id in (10002840, 10002841)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002840, 'VIS', 'VISA', 'PLVLSYST', null, null, null, null)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002841, 'VIS', 'VISA_NETWORK_ID', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002840)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10003702, 'VIS', 'VISA_SEND_TO_INST_ID', 'PLVLSYST', null, 'DTTPNMBR', 607, 10002840)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10003703, 'VIS', 'VISA_SEND_TO_NETWORK_ID', 'PLVLSYST', null, 'DTTPNMBR', 1019, 10002840)
/
update set_parameter set name = 'VISA_FRAUD_SEND_TO_INST_ID' where id = 10003702
/
update set_parameter set name = 'VISA_FRAUD_SEND_TO_NETWORK_ID' where id = 10003703
/
update set_parameter set display_order = 10 where id = 10002841
/
update set_parameter set display_order = 20 where id = 10003702
/
update set_parameter set display_order = 30 where id = 10003703
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003914, 'VIS', 'VISA_FRAUD_HOST_INST_ID', 'PLVLSYST', NULL, 'DTTPNMBR', 607, 10002840, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003915, 'VIS', 'VISA_FRAUD_NEED_MODIFY_PROC_BIN', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10002840, 50)
/
delete from set_parameter where id = 10003702
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004383, 'VIS', 'DEBT_REPAYMENT_PROGRAM', 'PLVLINST', '000000000000000000.0000', 'DTTPNMBR', 4, 10002840, 60, NULL)
/
