insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000246, 1, 9999, 'APP_API_REPORT_PKG.PROCESS_REJECTED_APPLICATION', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set is_notification = 1 where id = 10000246
/
