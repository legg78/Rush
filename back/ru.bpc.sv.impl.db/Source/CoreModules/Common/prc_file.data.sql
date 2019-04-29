insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1335, 10000024, 'FLPSINCM', NULL, 'FLNT0010', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1396, 10000900, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1400, 10000904, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP1700', NULL)
/
update prc_file set file_nature='FLNT0020' where id=1400
/
update prc_file set file_type='FLTPRTSV' where id=1396
/
update prc_file set file_nature='FLNT0010' where id=1400
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1405, 10000024, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL, NULL)
/
update prc_file set saver_id = 1016 where id = 1396
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1425, 10000961, 'FLPSINCM', NULL, NULL, NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1426, 10000962, 'FLPSINCM', NULL, NULL, NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1518, 10001100, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPDICT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1533, 10001122, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPMCC', NULL)
/
