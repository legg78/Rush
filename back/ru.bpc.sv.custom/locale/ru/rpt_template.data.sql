delete rpt_template where id = 10000111
/
insert into rpt_template (id, seqnum, report_id, lang, text, base64, report_processor, report_format, start_date, end_date) values (10000111, 1, 10000090, 'LANGRUS', NULL, NULL, 'RPTPJSPR', 'RPTFPDF', NULL, NULL)
/
delete rpt_template where id = 10000113
/
insert into rpt_template (id, seqnum, report_id, lang, text, base64, report_processor, report_format, start_date, end_date) values (10000113, 1, 10000091, 'LANGRUS', NULL, NULL, 'RPTPJSPR', 'RPTFPDF', NULL, NULL)
/
delete from rpt_template where id = 10000111
/
delete from rpt_template where id = 10000113
/
insert into rpt_template (id, seqnum, report_id, lang, text, base64, report_processor, report_format, start_date, end_date) values (10000113, 1, 10000091, 'LANGRUS', NULL, NULL, 'RPTPJSPR', 'RPTFPDF', NULL, NULL)
/
