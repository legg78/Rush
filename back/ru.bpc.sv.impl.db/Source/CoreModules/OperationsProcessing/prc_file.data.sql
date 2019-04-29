insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1337, 10000026, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPENTR')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1351, 10000047, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCLRG', NULL)
/
update prc_file set file_type = 'FLTP1700' where id = 1337
/
update prc_file set file_type = 'FLTP1710' where id = 1351
/

insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1393, 10000896, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPSTTT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1394, 10000897, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPUPDF', NULL)
/
update prc_file set  saver_id = 1013 where id = 1337
/
update prc_file set file_nature = 'FLNT0020' where id = 1337
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1402, 10000933, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTP1700', 1013)
/
update prc_file set saver_id=1020,  file_nature ='FLNT0010' where id = 1402
/
update prc_file set file_nature = 'FLNT0010' where id = 1337
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1453, 10001005, 'FLPSINCM', NULL, NULL, NULL, NULL, 1039)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1454, 10001008, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPFDCT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1486, 10001038, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP1700', 1046)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1514, 10001087, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTP1700', 1054)
/
update prc_file set file_nature = 'FLNT0020', file_type = 'FLTP1700', saver_id = 1054 where id = 1453
/
