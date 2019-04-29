insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1320, 10000845, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1373, 10000875, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPPROD', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1411, 10000943, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPPROD', NULL)
/
update prc_file set saver_id=1021 where id=1411
/
