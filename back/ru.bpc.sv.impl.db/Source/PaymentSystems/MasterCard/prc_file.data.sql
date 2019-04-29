insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1324, 10000011, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.MCWFileSaver', 'FLNT0020', NULL, 'FLTPCLMC')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1325, 10000012, 'FLPSOUTG', 'ru.bpc.sv2.scheduler.process.files.outgoing.MCWFileLoader', 'FLNT0020', NULL, 'FLTPCLMC')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1326, 10000013, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL)
/
update prc_file set saver_class = 'ru.bpc.sv2.scheduler.process.RDWFileSaver' where id = 1326
/
update prc_file set saver_class = 'ru.bpc.sv2.scheduler.process.mc.MCWFileSaver' where id = 1324
/
update prc_file set saver_class = 'ru.bpc.sv2.scheduler.process.mc.MCWFileLoader' where id = 1325
/
update prc_file set saver_class = 'ru.bpc.sv2.scheduler.process.mc.RDWFileSaver' where id = 1326
/
update prc_file set saver_id = 1008 where id = 1324
/
update prc_file set saver_id = 1009 where id = 1325
/
update prc_file set saver_id = 1007 where id = 1326
/

insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1350, 10000859, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL, NULL)
/

insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1383, 10000885, 'FLPSINCM', NULL, NULL, NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1417, 10000953, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTP250B', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1470, 10001020, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTP1700', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1480, 10001029, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1481, 10001032, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPR311', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1547, 10001138, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL, 1001)
/
update prc_file set saver_id = null where id = 1547
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1552, 10001147, 'FLPSINCM', NULL, NULL, NULL, 'FLTPT275', NULL)
/
update prc_file set file_type = 'FLTPR274' where id = 1480
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1553, 10001152, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTPT626', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1554, 10001151, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPR625', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1558, 10001158, 'FLPSINCM', NULL, NULL, NULL, NULL, NULL)
/
