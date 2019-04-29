insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000018, 1, 9999, 'CST_LVP_REPORT_PKG.CARD_INVENTORY', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000026, 1, 9999, 'CST_BNV_NAPAS_REPORT_PKG.RECONCILIATE_RESULTS_NOT_NAPAS', 'RPTSSXML', 0, -5089, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000025, 1, 9999, 'CST_BNV_NAPAS_REPORT_PKG.RECONCILIATE_RESULTS_NOT_SV', 'RPTSSXML', 0, -5088, NULL)
/
update rpt_report set name_format_id = 1310 where id = -50000026
/
update rpt_report set name_format_id = 1311 where id = -50000025
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (-50000278, 1, 1001, 'CST_LVP_API_NOTIFICATION_PKG.REPORT_PAYMENT', 'RPTSSXML', 0, NULL, NULL)
/
