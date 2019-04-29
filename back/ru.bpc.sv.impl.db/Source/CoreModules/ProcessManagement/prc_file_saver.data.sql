insert into prc_file_saver (id, seqnum, source, is_parallel) values (1001, 1, 'ru.bpc.sv2.scheduler.process.SimpleFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1002, 1, 'ru.bpc.sv2.scheduler.process.SimpleXMLFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1003, 1, 'ru.bpc.sv2.scheduler.process.SimpleClobFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1004, 1, 'ru.bpc.sv2.scheduler.process.SimpleBlobFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1005, 1, 'ru.bpc.sv2.scheduler.process.ApplicationsFileSaver', 1)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1006, 1, 'ru.bpc.sv2.scheduler.process.BTRTSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1007, 1, 'ru.bpc.sv2.scheduler.process.mc.RDWFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1008, 1, 'ru.bpc.sv2.scheduler.process.mc.MCWFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1009, 1, 'ru.bpc.sv2.scheduler.process.mc.MCWFileLoader', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1010, 1, 'ru.bpc.sv2.scheduler.process.DeterministicFileLoader', 0)
/
update prc_file_saver set source = 'ru.bpc.sv2.scheduler.process.files.BTRTSaver' where id = 1006
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1011, 1, 'ru.bpc.sv2.scheduler.process.files.incoming.ApplicationsMigrateFileSaver', 1)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1012, 1, 'ru.bpc.sv2.scheduler.process.ActiveMqSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1013, 1, 'ru.bpc.sv2.scheduler.process.svng.UpdateFileSession', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1014, 1, 'ru.bpc.sv2.scheduler.process.svng.MerchTermMQSaver', 0)
/
update prc_file_saver set source = 'ru.bpc.sv2.scheduler.process.svng.MerchMQSaver'  where id=1014
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1015, 1, 'ru.bpc.sv2.scheduler.process.svng.TermMQSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1016, 1, 'ru.bpc.sv2.scheduler.process.svng.RateMQSaver', 0)
/
update prc_file_saver set source = 'ru.bpc.sv2.scheduler.process.svng.CrefMQSaver' where id = 1012
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1017, 1, 'ru.bpc.sv2.scheduler.process.svng.DbalMQSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1018, 1, 'ru.bpc.sv2.scheduler.process.svng.NotificationMQSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1019, 1, 'ru.bpc.sv2.scheduler.process.files.incoming.ApplicationsMigrateSaxFileSaver', 1)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1020, 1, 'ru.bpc.sv2.scheduler.process.svng.PostingMqSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1021, 1, 'ru.bpc.sv2.scheduler.process.svng.ProductMQSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1022, 1, 'ru.bpc.sv2.scheduler.process.visa.VisaClearingFileLoader', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1023, 1, 'ru.bpc.sv2.scheduler.process.cup.CupOutClearingSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1024, 1, 'ru.bpc.sv2.scheduler.process.mc.MCIPMFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1025, 1, 'ru.bpc.sv2.scheduler.process.cup.CupLoadSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1026, 1, 'ru.bpc.sv2.scheduler.process.svng.PostingWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1027, 1, 'ru.bpc.sv2.scheduler.process.svng.CrefWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1028, 1, 'ru.bpc.sv2.scheduler.process.svng.DbalWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1029, 1, 'ru.bpc.sv2.scheduler.process.svng.RateWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1030, 1, 'ru.bpc.sv2.scheduler.process.svng.MerchWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1031, 1, 'ru.bpc.sv2.scheduler.process.svng.TermWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1036, 1, 'ru.bpc.sv2.scheduler.process.svng.NotificationWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1039, 1, 'ru.bpc.sv2.scheduler.process.svng.LoadSvfePostingSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1040, 1, 'ru.bpc.sv2.scheduler.process.svng.CrefFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1041, 1, 'ru.bpc.sv2.scheduler.process.svng.DbalFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1042, 1, 'ru.bpc.sv2.scheduler.process.svng.MerchFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1043, 1, 'ru.bpc.sv2.scheduler.process.svng.TermFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1044, 1, 'ru.bpc.sv2.scheduler.process.svng.RateFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1045, 1, 'ru.bpc.sv2.scheduler.process.svng.RejectFELoadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1046, 1, 'ru.bpc.sv2.scheduler.process.svng.LoadSvxpPostingSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1047, 1, 'ru.bpc.sv2.scheduler.process.svng.CrefUploadMqSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1048, 1, 'ru.bpc.sv2.scheduler.process.svng.CrefUploadWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1049, 1, 'ru.bpc.sv2.scheduler.process.svng.LoadSvfeCardStatusesSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1052, 1, 'ru.bpc.sv2.scheduler.process.nbc.NBCFastFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1054, 1, 'ru.bpc.sv2.scheduler.process.svng.ParallelLoadSvfePostingSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1055, 1, 'ru.bpc.sv2.scheduler.process.amex.AmExFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1056, 1, 'ru.bpc.sv2.scheduler.process.amex.AmExFileLoader', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1058, 1, 'ru.bpc.sv2.scheduler.process.svng.PersonsMQSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1059, 1, 'ru.bpc.sv2.scheduler.process.svng.CompaniesMQSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1060, 1, 'ru.bpc.sv2.scheduler.process.svng.PersonsWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1061, 1, 'ru.bpc.sv2.scheduler.process.svng.CompaniesWsSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1062, 1, 'ru.bpc.sv2.scheduler.process.svng.PersonsFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1063, 1, 'ru.bpc.sv2.scheduler.process.svng.CompaniesFEUnloadFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1065, 1, 'ru.bpc.sv2.scheduler.process.AccountsTurnoverFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1066, 1, 'ru.bpc.sv2.scheduler.process.svng.CrefMergeableFileSaver', 0)
/
insert into prc_file_saver (id, seqnum, source, is_parallel) values (1067, 1, 'ru.bpc.sv2.scheduler.process.svng.DbalMergeableFileSaver', 0)
/
update prc_file_saver set post_source = 'ru.bpc.sv2.scheduler.process.mergeable.AccountsTurnoverPostFileSaver' where id = 1065
/
update prc_file_saver set post_source = 'ru.bpc.sv2.scheduler.process.mergeable.CrefPostFileSaver' where id = 1066
/
update prc_file_saver set post_source = 'ru.bpc.sv2.scheduler.process.mergeable.DbalPostFileSaver' where id = 1067
/
update prc_file_saver set source = 'ru.bpc.sv2.scheduler.process.mergeable.AccountsTurnoverFileSaver' where id = 1065
/
update prc_file_saver set source = 'ru.bpc.sv2.scheduler.process.mergeable.CrefMergeableFileSaver' where id = 1066
/
update prc_file_saver set source = 'ru.bpc.sv2.scheduler.process.mergeable.DbalMergeableFileSaver' where id = 1067
/
