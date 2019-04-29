insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1321, 10000008, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPTRAC')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1323, 10000847, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPENTR')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1336, 10000025, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPENTR')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1386, 10000888, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPENTR', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1409, 10000940, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPACCT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1415, 10000951, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPRTRA', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1524, 10001109, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPMSTT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1537, 10001127, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPSTAL', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1538, 10001128, 'FLPSOUTG', NULL, NULL, NULL, 'FLTPSTAU', NULL)
/
update prc_file set file_nature = 'FLNT0010' where id = 1538
/
update prc_file set saver_id = 1065 where id = 1386
/
