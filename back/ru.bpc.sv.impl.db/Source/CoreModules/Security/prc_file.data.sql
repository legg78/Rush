insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1304, 10000004, 'FLPSOUTG', '', 'FLNT0050', NULL, 'FLTPINP')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1305, 10000004, 'FLPSOUTG', '', 'FLNT0050', NULL, 'FLTPSIP')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1306, 10000004, 'FLPSOUTG', '', 'FLNT0050', NULL, 'FLTPHIP')
/

insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1307, 10000005, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.SimpleBlobFileSaver', 'FLNT0050', NULL, 'FLTPCERT')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1309, 10000005, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.SimpleBlobFileSaver', 'FLNT0050', NULL, 'FLTPSEP')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1311, 10000005, 'FLPSINCM', 'ru.bpc.sv2.scheduler.process.SimpleBlobFileSaver', 'FLNT0050', NULL, 'FLTPHEP')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1327, 10000016, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1332, 10000021, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1333, 10000022, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL)
/
update prc_file set saver_id = 1004 where id = 1307
/
update prc_file set saver_id = 1004 where id = 1309
/
update prc_file set saver_id = 1004 where id = 1311
/