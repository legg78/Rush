insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000226, 1, 9999, 'mup_prc_report_pkg.report_card_instrastructure', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000241, 1, 9999, 'MUP_API_REPORT_PKG.RUN_RPT_FORM_ACQ_OPER', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000240, 1, 9999, 'MUP_API_REPORT_PKG.RUN_RPT_FORM_ISS_OPER', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'MUP_API_REPORT_PKG.RUN_RPT_FORM_2_2_ACQ_OPER' where id = 10000241
/
update rpt_report set data_source = 'MUP_API_REPORT_PKG.RUN_RPT_FORM_1_ISS_OPER' where id = 10000240
/
