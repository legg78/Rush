insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000073, 2, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000075, 2, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000077, 4, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000078, 2, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'ACQ_API_REPORT_PKG.LIST_OF_CASH' where id = 10000073
/
update rpt_report set data_source = 'ACQ_API_REPORT_PKG.LIST_OF_SALE' where id = 10000075
/
update rpt_report set data_source = 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_DAILY_TERM_AUTH' where id = 10000077
/
update rpt_report set data_source = 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_DAILY_CARD_TERM_AUTH' where id = 10000078
/

insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000108, 2, 9999, 'ACQ_API_REPORT_PKG.CASH_PAYMENT_SUM', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000109, 2, 9999, 'ACQ_API_REPORT_PKG.LIST_OF_UNCONFIRMED_AUTH', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000110, 2, 9999, 'ACQ_API_REPORT_PKG.LIST_OF_TERMINAL', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000111, 2, 9999, 'ACQ_API_REPORT_PKG.LIST_OF_INTERNET_SHOP', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000112, 2, 9999, 'ACQ_API_REPORT_PKG.LIST_OF_INTERNET_AUTH', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000113, 2, 9999, 'ACQ_API_REPORT_PKG.LIST_OF_INTERNET_REVERSAL', 'RPTSSXML', 0, NULL, NULL)
/

update rpt_report set data_source = 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_TERM_AUTH' where id = 10000077
/
update rpt_report set data_source = 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_CARD_TERM_AUTH' where id = 10000078
/

insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000114, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_TERM_AUTH', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000115, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_TERM_CHARGEBACK', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000116, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_TERM_MANUAL', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000117, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_BIN_TERM_AUTH', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000118, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.TOTAL_AVG_TERM_CREDIT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000119, 3, 9999, 'ACQ_API_AUDIT_REPORT_PKG.GET_TERM_INACTIVE', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000120, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.GET_TERM_ACTIVE_AFTER_INACTIVE', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000121, 2, 9999, 'ACQ_API_AUDIT_REPORT_PKG.GET_TERM_ACTIVE_AFTER_CLOSING', 'RPTSSXML', 0, NULL, NULL)
/

insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000151, 1, 9999, 'ACQ_API_REPORT_PKG.FIN_MESSAGES_FOR_PAYMENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000152, 1, 9999, 'ACQ_API_REPORT_PKG.FIN_CHARGEBACK', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000153, 1, 9999, 'ACQ_API_REPORT_PKG.PAY_ROLL', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000150, 1, 9999, 'ACQ_API_REPORT_PKG.LIST_OF_UNCONMERCHANTED_AUTH', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000154, 1, 9999, 'ACQ_API_AUDIT_REPORT_PKG.PERCENT_OF_BELOW_FLOOR_LIMIT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000155, 1, 9999, 'ACQ_API_REPORT_PKG.SLIP_LIST_ENTERED_BY_OPERATOR', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000156, 1, 9999, 'ACQ_API_REPORT_PKG.TOTAL_NUMBER_OF_AMEX_OPER', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000160, 1, 9999, 'ACQ_API_REPORT_PKG.AGGREGATE_STAT_BIN_RANGE_USED', 'RPTSSXML', 0, NULL, NULL)
/
delete from rpt_report where id = 10000156
/
delete from rpt_report where id = 10000073
/
delete from rpt_report where id = 10000075
/
delete from rpt_report where id = 10000112
/
delete from rpt_report where id = 10000113
/
delete from rpt_report where id = 10000151
/
delete from rpt_report where id = 10000153
/
delete from rpt_report where id = 10000155
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000186, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000229, 1, 9999, 'ACQ_API_REPORT_PKG.ACQUIRING_ACTIVITY_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000249, 1, 9999, 'ACQ_API_REPORT_PKG.ACQ_MERCHANT_ACTIVITY_REPORT', 'RPTSSXML', 0, NULL, NULL)
/
