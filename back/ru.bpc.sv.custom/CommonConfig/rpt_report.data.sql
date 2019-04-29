insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000049, 2, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000052, 2, 9999, 'VIS_API_REPORT_PKG.TOTAL_AUTHORIZATIONS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000053, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AUTHORIZATIONS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000054, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AUTHORIZATIONS_MERCHANT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000055, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AUTHORIZATIONS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000056, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_INVALID_PIN', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000057, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_POS_MODE_02', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000058, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AMOUNT_AUTHS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000059, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AMOUNT_AUTHS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000060, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AMOUNT_AUTHS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000061, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AMOUNT_INDIVIDUAL', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000062, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AMOUNT_INDIVIDUAL', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000063, 1, 9999, 'VIS_API_REPORT_PKG.TOTAL_AMOUNT_INDIVIDUAL', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000064, 2, 9999, 'VIS_API_REPORT_PKG.TOTAL_AUTHS_OF_COUNTRY', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000065, 1, 9999, 'VIS_API_REPORT_PKG.AUTHS_HIGH_AMOUNT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000066, 1, 9999, 'VIS_API_REPORT_PKG.AUTHS_MANUAL_INPUT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000067, 1, 9999, 'VIS_API_REPORT_PKG.PERCENT_USE_BALANCE', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000068, 2, 9999, 'ISS_API_REPORT_PKG.ISSUED_CARD_BY_AGENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000069, 2, 9999, 'ISS_API_REPORT_PKG.REGISTER_CARD_BY_AGENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000070, 2, 9999, 'ISS_API_REPORT_PKG.REGISTER_PIN_BY_AGENT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000071, 2, 9999, 'ISS_API_REPORT_PKG.UNCONFIRMED_AUTH_BY_INST', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'ISS_API_REPORT_PKG.ISSUED_CARD_BY_NETWORK' where id = 10000049
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000072, 2, 9999, 'ISS_API_REPORT_PKG.ISSUED_CARD_BY_COMPANY', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000074, 2, 9999, 'ISS_API_REPORT_PKG.EXPIRED_CARD', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000076, 2, 9999, 'ISS_API_REPORT_PKG.AVERAGE_BALANCE', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000079, 2, 9999, 'ISS_API_REPORT_PKG.CARD_BALANCES', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000080, 2, 9999, 'ISS_API_REPORT_PKG.ACTIVE_CARDS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000081, 2, 9999, 'ISS_API_REPORT_PKG.REISSUED_CARDS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000082, 2, 9999, 'ISS_API_REPORT_PKG.CARDS_BEING_DELETED', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000083, 2, 9999, 'ISS_API_REPORT_PKG.CARDS_EXCEED_LIMIT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000084, 2, 9999, 'ISS_API_REPORT_PKG.CORPORATE_CARDS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000085, 2, 9999, 'ISS_API_REPORT_PKG.OUT_BALANCES_BY_CARDS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000086, 2, 9999, 'ISS_API_REPORT_PKG.ACCOUNT_OUT_BALANCES', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000087, 2, 9999, 'ISS_API_REPORT_PKG.FINANCIAL_TRANSACTION', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000088, 2, 9999, 'VIS_API_REPORT_PKG.OPERATION_VISA_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000089, 2, 9999, 'VIS_API_REPORT_PKG.REJECTED_OPR_VISA_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000092, 2, 9999, 'ISS_API_REPORT_PKG.ISSUER_APPLICATIONS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000093, 2, 9999, 'VIS_API_REPORT_PKG.GENERAL_OPR_US_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000099, 2, 9999, 'ISS_API_REPORT_PKG.OVERDRAFT_ON_CARDS', 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'VIS_API_REPORT_PKG.TOTAL_AUTH' where id = 10000052
/
update rpt_report set data_source = 'VIS_API_REPORT_PKG.TOTAL_AUTH_MCC' where id = 10000053
/
update rpt_report set data_source = 'VIS_API_REPORT_PKG.TOTAL_AUTH_MERCHANT' where id = 10000054
/
update rpt_report set data_source = 'VIS_API_REPORT_PKG.TOTAL_AUTH_COUNTRY' where id = 10000055
/
delete from rpt_report where id = 10000092
/
delete from rpt_report where id = 10000088
/
delete from rpt_report where id = 10000082
/
delete from rpt_report where id = 10000081
/
delete from rpt_report where id = 10000089
/
delete from rpt_report where id = 10000099
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000081, 2, 9999, 'ISS_API_REPORT_PKG.REISSUED_CARDS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000082, 2, 9999, 'ISS_API_REPORT_PKG.CARDS_BEING_DELETED', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000088, 2, 9999, 'VIS_API_REPORT_PKG.OPERATION_VISA_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000089, 2, 9999, 'VIS_API_REPORT_PKG.REJECTED_OPR_VISA_ON_US', 'RPTSSXML', 0, NULL, NULL)
/
