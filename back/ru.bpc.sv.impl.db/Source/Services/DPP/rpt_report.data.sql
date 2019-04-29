insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000257, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT0014', 1)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000258, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 1)
/
delete from rpt_report where id = 10000258
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000258, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 1)
/
delete from rpt_report where id = 10000257
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000257, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT0014', 1)
/
