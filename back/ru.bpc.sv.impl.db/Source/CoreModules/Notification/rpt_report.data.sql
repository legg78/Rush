insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000048, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000122, 2, 1001, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set inst_id = 9999 where id = 10000122
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000222, 1, 9999, 'iss_api_notification_pkg.report_debit_card_by_branch', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000223, 1, 9999, 'iss_api_notification_pkg.report_prepaid_card_by_branch', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000225, 1, 9999, 'iss_api_notification_pkg.report_credit_card_by_branch', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000227, 1, 9999, 'ntf_api_report_pkg.create_text_message_report', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000228, 1, 9999, 'ntf_api_report_pkg.create_due_message_report', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000230, 1, 9999, 'ntf_api_report_pkg.create_due_message_report', 'RPTSSXML', 0, NULL, NULL)
/
delete rpt_report where id = 10000228
/
delete rpt_report where id = 10000230
/
update rpt_report set is_notification = 1 where id = 10000048
/
update rpt_report set is_notification = 1 where id = 10000222
/
update rpt_report set is_notification = 1 where id = 10000223
/
update rpt_report set is_notification = 1 where id = 10000225
/
update rpt_report set is_notification = 1 where id = 10000227
/
delete from rpt_report where id = 10000223
/
delete from rpt_report where id = 10000225
/
update rpt_report set data_source = 'iss_api_notification_pkg.report_card_by_branch' where id = 10000222
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (10000263, 1, 9999, 'COM_API_REPORT_PKG.NOTIFICATION_WITH_ATTACH_EVENT', 'RPTSSXML', 0, NULL, NULL, 1)
/
