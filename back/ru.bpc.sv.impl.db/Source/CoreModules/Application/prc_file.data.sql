insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source) values (1122, 10000045, 'FPLSOUTG', NULL, 'FLNT0010', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1315, 10000836, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.ApplicationsFileSaver', 'FLNT0010', NULL, 'FLTPACQF')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1316, 10000836, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.ApplicationsFileSaver', 'FLNT0010', NULL, 'FLTPISSF')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1346, 10000046, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.files.BTRTSaver', 'FLNT0030', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1347, 10000046, 'FLPSOUTG', NULL, 'FLNT0030', NULL, NULL)
/
update prc_file set saver_id = 1005 where id = 1315
/
update prc_file set saver_id = 1005 where id = 1316
/
update prc_file set saver_id = 1006 where id = 1346
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1378, 10000879, 'FLPSINCM', NULL, 'FLNT0030', NULL, NULL, 1011)
/
delete from prc_file where id = 1122
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1413, 10000045, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPAPRS', 1002)
/
update prc_file set saver_id = null where id = 1413 and saver_id = 1002
/
update prc_file set saver_id = 1019 where id = 1378
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1559, 10001162, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPACQF', 1005)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1560, 10001162, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPISSF', 1005)
/
