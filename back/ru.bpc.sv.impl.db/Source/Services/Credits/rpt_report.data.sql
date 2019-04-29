insert into rpt_report (id, seqnum, inst_id, data_source, source_type) values (10000010, 1, 9999, 'crd_api_report_pkg.run_report', 'RPTSSXML')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000130, 2, 9999, 'CRD_API_REPORT_PKG.INSTANT_CREDIT_STATEMENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000135, 1, 9999, 'CRD_API_REPORT_PKG.CREDIT_STATMENT_EVENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000136, 1, 9999, 'CRD_API_REPORT_PKG.RUN_PRC_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'CRD_API_REPORT_PKG.CREDIT_STATEMENT_EVENT' where id = 10000135
/
update rpt_report set is_deterministic = 1, name_format_id = 1306 where id = 10000135
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000184, 1, 9999, 'CRD_API_REPORT_PKG.CREDIT_LOYALTY_STATEMENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000247, 1, 9999, 'CRD_API_REPORT_PKG.MAD_OVERDUE', 'RPTSSXML', 0, 1312, NULL)
/
update rpt_report set is_notification = 1 where id = 10000135
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000254, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000255, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000256, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
