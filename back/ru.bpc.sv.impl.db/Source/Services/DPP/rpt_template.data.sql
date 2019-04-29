insert into rpt_template (id, seqnum, report_id, lang, text, base64, report_processor, report_format, start_date, end_date) values (10000356, 1, 10000257, 'LANGENG', NULL, NULL, 'RPTPJSPR', 'RPTFPDF', NULL, NULL)
/
insert into rpt_template (id, seqnum, report_id, lang, text, base64, report_processor, report_format, start_date, end_date) values (10000357, 1, 10000258, 'LANGENG', NULL, NULL, 'RPTPXSLT', 'RPTFTEXT', NULL, NULL)
/
update rpt_template set report_format = 'RPTFHTML' where id = 10000357
/
