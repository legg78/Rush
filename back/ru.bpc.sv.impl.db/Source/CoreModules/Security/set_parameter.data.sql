insert into set_parameter (id, module_code, name, lowest_level, parent_id, display_order) values (10003467, 'SEC', 'AUTHENTICATION', 'PLVLSYST', 1031, 60)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003468, 'SEC', 'AUTH_SCHEME', 'PLVLSYST', 'ATHSPASS', 'DTTPCHAR', 581, 10003467, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003469, 'SEC', 'AUTH_SUBJECT_DN_PATERN', 'PLVLSYST', 'CN=(.*?)(?:,|$)', 'DTTPCHAR', null, 10003467, 20)
/
update set_parameter set id=10003590 where id=10003468
/
