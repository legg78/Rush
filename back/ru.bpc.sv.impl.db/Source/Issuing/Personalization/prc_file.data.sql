insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1313, 10000001, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPMGST')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1314, 10000001, 'FLPSOUTG', NULL, 'FLNT0030', NULL, 'FLTPCHIP')
/
update prc_file set file_nature = 'FLNT0050' where id = 1314
/
delete from prc_file where id = 1313
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1374, 10000033, 'FLPSOUTG', NULL, 'FLNT0050', NULL, 'FLTPCHIP', NULL)
/
update prc_file set file_type = null where id in (1314, 1374)
/
update prc_file set file_type = 'FLTPEMBS' where id in (1314, 1374)
/