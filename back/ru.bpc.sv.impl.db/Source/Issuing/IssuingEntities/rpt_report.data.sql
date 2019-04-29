insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000033, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000038, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000039, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000040, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000041, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000042, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000043, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000044, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000045, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000046, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000047, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000100, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000123, 2, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000124, 3, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000125, 4, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000126, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000127, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'ISS_API_REPORT_PKG.ACCOUNT_STATEMENT' where id = 10000033
/
delete rpt_report where id = 10000090
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000090, 2, 9999, 'VIS_API_REPORT_PKG.OPERATION_US_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
delete rpt_report where id = 10000091
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000091, 2, 9999, 'VIS_API_REPORT_PKG.REJECT_OPR_US_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
delete rpt_report where id = 10000090
/
delete rpt_report where id = 10000091
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000231, 1, 9999, 'APP_API_REPORT_PKG.APPL_RESPONSE', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000091, 2, 9999, 'VIS_API_REPORT_PKG.REJECT_OPR_US_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set is_notification = 1 where id = 10000038
/
update rpt_report set is_notification = 1 where id = 10000039
/
update rpt_report set is_notification = 1 where id = 10000040
/
update rpt_report set is_notification = 1 where id = 10000041
/
update rpt_report set is_notification = 1 where id = 10000042
/
update rpt_report set is_notification = 1 where id = 10000043
/
update rpt_report set is_notification = 1 where id = 10000044
/
update rpt_report set is_notification = 1 where id = 10000045
/
update rpt_report set is_notification = 1 where id = 10000046
/
update rpt_report set is_notification = 1 where id = 10000047
/
update rpt_report set is_notification = 1 where id = 10000100
/
update rpt_report set is_notification = 1 where id = 10000126
/
update rpt_report set is_notification = 1 where id = 10000127
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000262, 1, 9999, 'ISS_API_REPORT_PKG.ACCOUNT_STATEMENT_FOR_BATCH', 'RPTSSXML', 1, NULL, 'DCMT0015', 0)
/
