insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000053, 1, 9999, 'CST_IBB_REPORT_PKG.PREPAID_CARD_STATEMENT', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'CST_IBBL_REPORT_PKG.PREPAID_CARD_STATEMENT' where id = -50000053
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000067, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'CST_IBBL_REPORT_PKG.PREPAID_CARD_STATEMENT_WRAPPED' where id = -50000067
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000066, 1, 9999, NULL, 'RPTSSXML', 1, NULL, NULL)
/
update rpt_report set data_source = 'CST_IBBL_REPORT_PKG.PREPAID_STATEMENT_EVENT' where id = -50000066
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000268, 1, 9999, 'CST_IBBL_REPORT_PKG.ACQUIRING_ACTIVITY_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000269, 1, 9999, 'CRD_API_REPORT_PKG.RUN_PRC_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000270, 1, 9999, 'CST_IBBL_REPORT_PKG.RUN_REPORT_WRAPPED', 'RPTSSXML', 1, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000063, 1, 9999, 'CST_IBBL_REPORT_PKG.CREDIT_PAYMENT', 'RPTSSXML', 0, -5108, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000271, 1, 9999, 'CST_IBBL_REPORT_PKG.RIT_REPORT', 'RPTSSXML', 0, -5109, NULL)
/
delete from rpt_report where id = -50000268
/
update rpt_report set is_deterministic = 1 where id = -50000067
/
update rpt_report set is_deterministic = 1 where id = -50000066
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000280, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000281, 1, 9999, NULL, 'RPTSSXML', 1, NULL, NULL, 0)
/
