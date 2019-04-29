insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (50000001, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set name_format_id = 5001 where id = 50000001
/
update rpt_report set data_source = 'CRD_CST_REPORT_PKG.CREDIT_CARD_STATEMENT' where id = 50000001
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (50000002, 1, 9999, NULL, 'RPTSSXML', 0, 5001, NULL)
/
update rpt_report set data_source = 'CRD_CST_REPORT_PKG.OVER_SIX_MONTHS_STATEMENT' where id = 50000002
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (50000003, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (50000004, 1, 9999, 'CRD_CST_REPORT_PKG.REPORT_FOR_COLLECTORS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000005, 1, 9999, 'ISS_CST_REPORT_PKG.CARD_HOLDER_STATEMENT_REPORT', 'RPTSSXML', 0, 5001, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000009, 1, 9999, 'ISS_CST_REPORT_PKG.CARD_MAILER_LIST_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000016, 1, 9999, 'ISS_CST_REPORT_PKG.CARD_HOLDER_STTMNT_REP_DETERM', 'RPTSSXML', 1, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000017, 1, 9999, 'ISS_CST_REPORT_PKG.CARD_HOLDER_STTMNT_REP_EVENT', 'RPTSSXML', 1, 1306, NULL)
/
update rpt_report set document_type = 'DCMT0012' where id = -50000016
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000045, 1, 9999, 'ISS_CST_REPORT_PKG.CARD_HOLDER_STATEMENT_REP_EXT', 'RPTSSXML', 0, 5001, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000046, 1, 9999, 'ISS_CST_REPORT_PKG.CARD_HOLD_STMNT_REP_EXT_DETERM', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000052, 1, 9999, 'CST_ICC_API_REPORT_PKG.CUP_AUDIT_TRAILER_UNMATCHED', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set document_type = 'DCMT0012' where id = -50000046
/
update rpt_report set is_deterministic = 1 where id = -50000046
/
