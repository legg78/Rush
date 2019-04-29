insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000274, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'CST_BOF_API_REPORT_PKG.REISSUED_CARDS' where id = -50000274
/
