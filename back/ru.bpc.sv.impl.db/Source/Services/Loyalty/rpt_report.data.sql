insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000181, 1, 9999, 'EVT_API_NOTIF_REPORT_PKG.CREATE_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000182, 1, 9999, 'EVT_API_NOTIF_REPORT_PKG.CREATE_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000189, 1, 9999, 'LTY_API_REPORT_PKG.LOYALTY_STATEMENT_BATCH', 'RPTSSXML', 1, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000190, 1, 9999, 'LTY_API_REPORT_PKG.LOYALTY_STATEMENT_NOTIFY', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set document_type = 'DCMT0013' where id = 10000189
/

