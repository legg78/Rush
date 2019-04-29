insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000011, 1, 9999, 'RUS_API_REPORT_PKG.RUN_REPORT_ACC', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000013, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT5001')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000014, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT5002')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000015, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT5003')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000016, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT5004')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000017, 1, 9999, NULL, 'RPTSSXML', 1, NULL, 'DCMT5002')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000024, 1, 9999, NULL, 'RPTSSXML', 0, NULL, 'DCMT5001')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000026, 1, 9999, NULL, 'RPTSSXML', 0, NULL, 'DCMT5004')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000028, 1, 9999, NULL, 'RPTSSXML', 0, NULL, 'DCMT5002')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000030, 1, 9999, NULL, 'RPTSSXML', 0, NULL, 'DCMT5002')
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000032, 1, 9999, NULL, 'RPTSSXML', 0, NULL, 'DCMT5003')
/
delete rpt_report where id in (10000013, 10000016)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000035, 1, 9999, 'RUS_API_FORM_250_PKG.RUN_RPT_FORM_250_1', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000036, 1, 9999, 'RUS_API_FORM_250_PKG.RUN_RPT_FORM_250_2', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000037, 1, 9999, 'RUS_API_FORM_250_PKG.RUN_RPT_FORM_250_3', 'RPTSSXML', 0, NULL, NULL)
/
delete from rpt_report where id in (10000024,10000026,10000028,10000030,10000032)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000133, 1, 9999, 'RUS_API_FORM_260_PKG.RUN_RPT_FORM_260', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'RUS_API_FORM_260_PKG.RUN_RPT_FORM_260_1' where id = 10000133
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000137, 1, 9999, 'RUS_API_FORM_260_PKG.RUN_RPT_FORM_260_2', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000138, 1, 9999, 'RUS_API_FORM_260_PKG.RUN_RPT_FORM_260_3', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000194, 1, 9999, 'RUS_API_FORM_259_PKG.RUN_RPT_FORM_259_1', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000195, 1, 9999, 'RUS_API_FORM_259_PKG.RUN_RPT_FORM_259_2', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000196, 1, 9999, 'RUS_API_FORM_407_PKG.RUN_RPT_FORM_407_3', 'RPTSSXML', 0, NULL, NULL)
/
