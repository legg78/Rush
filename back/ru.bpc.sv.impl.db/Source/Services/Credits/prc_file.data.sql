insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1366, 10000866, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1370, 10000871, 'FLPSINCM', NULL, 'FLNT0010', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1371, 10000872, 'FLPSINCM', NULL, 'FLNT0010', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1372, 10000873, 'FLPSINCM', NULL, 'FLNT0010', NULL, NULL, NULL)
/
update prc_file set file_type = 'FLTPCMGR' where id in (1370, 1371, 1372)
/
delete from prc_file where id = 1375
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1375, 10000876, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPACCT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1387, 10000890, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPRSRV', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1550, 10001144, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1551, 10001145, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL, NULL)
/
