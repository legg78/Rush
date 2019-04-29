insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id) values (10000019, 1, 9999, 'ATM_API_REPORT_PKG.REPORT_ATM_CNT', 'RPTSSXML', 0, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id) values (10000020, 1, 9999, 'ATM_API_REPORT_PKG.REPORT_ATM_TURNOVER', 'RPTSSXML', 0, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id) values (10000021, 1, 9999, 'ATM_API_REPORT_PKG.REPORT_ATM_DISP_EMPTY_CNT', 'RPTSSXML', 0, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id) values (10000022, 1, 9999, 'ATM_API_REPORT_PKG.REPORT_ATM_DOWN_CNT', 'RPTSSXML', 0, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000129, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000132, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'ATM_API_NOTIFICATION_PKG.REPORT_ATM_EVENT' where id = 10000132
/
delete from rpt_report where id = 10000129
/
delete from rpt_report where id = 10000021
/
delete from rpt_report where id = 10000022
/
