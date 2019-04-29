insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1183, 10000505, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1312, 10000506, 'FLPSINCM', NULL, 'FLNT0030', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1360, 10000056, 'FLPSINCM', NULL, 'FLNT0030', NULL, NULL, NULL)
/
update prc_file set file_purpose = 'FLPSOUTG' where id = 1360
/
