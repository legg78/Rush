insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5001, 50000001, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPACCT', 1001)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5002, 50000002, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPNBRC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5003, 50000002, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPOBRC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5004, 50000003, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTPCSC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5005, 50000004, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPCSC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5006, 50000005, 'FLPSOUTG', NULL, 'FLNT0030', NULL, 'FLTP5001', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (5007, 50000035, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL, NULL)
/
update prc_file set file_nature = 'FLNT0030' where id = 5007
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5157, -50000167, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPBMDD', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5158, -50000170, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPBMDD', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5155, -50000168, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTPBMDD', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5167, -50000186, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTP6003', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5166, -50000185, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTP6002', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5165, -50000184, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTP6001', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5174, -50000192, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL, NULL)
/
update prc_file set saver_id = NULL where id = 5001
/
delete from prc_file where id = -5167
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (-5205, -50000287, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTP6004', NULL)
/
