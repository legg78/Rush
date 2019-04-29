insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1505, 10001067, 'FLPSINCM', NULL, 'FLNT0010', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1506, 10001067, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTP1720', NULL)
/
update prc_file set saver_id = 1052, saver_class = 'ru.bpc.sv2.scheduler.process.nbc.NBCFastFileSaver' where id = 1505
/
