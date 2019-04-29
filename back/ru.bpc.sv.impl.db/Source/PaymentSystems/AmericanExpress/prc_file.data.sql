insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1353, 10000048, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1354, 10000049, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPCLAE', NULL)
/
update prc_file set file_type = 'FLTPCLAE' where id = 1353
/
update prc_file set saver_id = 1055 where id = 1353
/
update prc_file set saver_id = 1055 where id = 1354
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1516, 10001092, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPCLAE', 1055)
/
update prc_file set saver_id=1055 where id = 1353
/
update prc_file set saver_id=1056 where id = 1354
/
update prc_file set saver_id = 1056 where id = 1516
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1531, 10001120, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPCLAE', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1546, 10001135, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTPCLAE', 1064)
/

