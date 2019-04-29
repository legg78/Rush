insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1341, 10000030, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1342, 10000031, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1343, 10000031, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1344, 10000032, 'FLPSOUTG', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1345, 10000037, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1384, 10000886, 'FLPSOUTG', NULL, 'FLNT0020', NULL, 'FLTPBTLV', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1385, 10000887, 'FLPSINCM', NULL, 'FLNT0020', NULL, 'FLTPBRDG', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1389, 10000891, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPMRCH', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1390, 10000892, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPTRMN', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1395, 10000899, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPTRAC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1399, 10000903, 'FLPSOUTG', NULL, 'FLNT0010', NULL, NULL, NULL)
/
update prc_file set saver_id=1015 where id=1390
/
update prc_file set saver_id=1014 where id=1389
/
update prc_file set saver_id=1017 where id=1395
/
update prc_file set file_type = 'FLTPEVNT' where id = 1399
/
update prc_file set saver_id = 1018 where id = 1399
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1418, 10000899, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRTRA', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1419, 10000874, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRCRD', NULL)
/
delete prc_file where id = 1455
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1455, 10001010, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCRDN', 1012)
/
delete prc_file where id = 1456
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1456, 10001011, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPMRCH', 1014)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1457, 10001012, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPTRMN', 1015)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1458, 10001013, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTP1710', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1459, 10001014, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPRTSV', 1016)
/
update prc_file set saver_id=null where id=1455
/
update prc_file set saver_id=null where id=1456
/
update prc_file set saver_id=null where id=1457
/
update prc_file set saver_id=null where id=1459
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1471, 10001021, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRMRC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1472, 10001022, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRTRM', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1478, 10000891, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRMRC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1479, 10000892, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRTRM', NULL)
/
update prc_file set file_nature='FLNT0010' where id = 1471
/
update prc_file set file_nature='FLNT0010' where id = 1472
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1509, 10001075, 'FLPSINCM', NULL, 'FLNT0020', NULL, NULL, NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1535, 10001126, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPACCT', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1536, 10001126, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRTRA', NULL)
/
