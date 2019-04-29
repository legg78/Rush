insert into rpt_report (id, seqnum, inst_id, data_source, source_type) values (10000007, 1, 9999, 'prc_api_process_report_pkg.run_report', 'RPTSSXML')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000159, 1, 9999, 'PRC_API_REPORT_PKG.FILE_PASSWORD_EVENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000187, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set is_notification = 1 where id = 10000159
/
update rpt_report set is_notification = 1 where id = 10000187
/
