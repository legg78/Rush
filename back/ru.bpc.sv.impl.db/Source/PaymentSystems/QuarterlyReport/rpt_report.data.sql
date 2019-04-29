insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000094, 1, 9999, 'QPR_API_REPORT.GET_PAYLATER_ISS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000095, 1, 9999, 'QPR_API_REPORT.GET_PAYLATER_ACQ', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000096, 1, 9999, 'QPR_API_REPORT.GET_ACCT_CARD', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000097, 1, 9999, 'QPR_API_REPORT.GET_PAYNOW_ATM', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000098, 1, 9999, 'QPR_API_REPORT.GET_PAYNOW_POS', 'RPTSSXML', 0, NULL, NULL)
/

update rpt_report set data_source = 'QPR_API_REPORT_PKG.MC_GET_PAYLATER_ISS' where id = 10000094
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.MC_GET_PAYLATER_ACQ' where id = 10000095
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.MC_GET_ACCT_CARD' where id = 10000096
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.MC_GET_PAYNOW_ATM' where id = 10000097
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.MC_GET_PAYNOW_POS' where id = 10000098
/

insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000101, 1, 9999, 'QPR_API_REPORT_PKG.VS_GET_ACQ_TR_VOLUMES', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000102, 1, 9999, 'QPR_API_REPORT_PKG.VS_GET_CARD_ISSUANCE', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000103, 2, 9999, 'QPR_API_REPORT_PKG.VS_GET_MONTHLY_ISSUING', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000104, 1, 9999, 'QPR_API_REPORT_PKG.VS_GET_MRC_CATEGORY', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000105, 1, 9999, 'QPR_API_REPORT_PKG.VS_GET_MRC_INFORM', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000106, 1, 9999, 'QPR_API_REPORT_PKG.VS_GET_SCHEDULE_A_E', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000107, 1, 9999, 'QPR_API_REPORT_PKG.VS_GET_SCHEDULE_F', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000139, 1, 9999, 'QPR_API_REPORT_PKG.MC_ISSUING', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000140, 1, 9999, 'QPR_API_REPORT_PKG.MC_ISSUING_MAESTRO', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000141, 1, 9999, 'QPR_API_REPORT_PKG.MC_ACQUIRING', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000142, 1, 9999, 'QPR_API_REPORT_PKG.MC_ACQUIRING_MAESTRO', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000143, 1, 9999, 'QPR_API_REPORT_PKG.MC_ACQUIRING_CIRRUS', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000144, 1, 9999, 'QPR_API_REPORT_PKG.VS_ISSUING', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000145, 1, 9999, 'QPR_API_REPORT_PKG.VS_CO_BRAND', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000146, 1, 9999, 'QPR_API_REPORT_PKG.VS_MRC_INFORM', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000147, 1, 9999, 'QPR_API_REPORT_PKG.VS_CASH_ACQUIRING', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000148, 1, 9999, 'QPR_API_REPORT_PKG.VS_MRC_MCC', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000149, 1, 9999, 'QPR_API_REPORT_PKG.MONTHLY_REPORT_BY_NETWORK', 'RPTSSXML', 0, NULL, NULL)
/
delete from rpt_report where id = 10000094
/
delete from rpt_report where id = 10000095
/
delete from rpt_report where id = 10000096
/
delete from rpt_report where id = 10000097
/
delete from rpt_report where id = 10000098
/
delete from rpt_report where id = 10000101
/
delete from rpt_report where id = 10000102
/
delete from rpt_report where id = 10000103
/
delete from rpt_report where id = 10000104
/
delete from rpt_report where id = 10000105
/
delete from rpt_report where id = 10000106
/
delete from rpt_report where id = 10000107
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000164, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000165, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000166, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000167, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000183, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL)
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.VS_ACQUIRING_V_PAY' where id = 10000164
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.VS_ACQUIRING_CONTACTLESS' where id = 10000165
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.VS_ACQUIRING' where id = 10000167
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.VS_ACQUIRING_ECOMMERCE' where id = 10000166
/
update rpt_report set data_source = 'QPR_API_REPORT_PKG.MC_MACHINE_READABLE' where id = 10000183
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000251, 1, 9999, 'QPR_API_REPORT_PKG.VS_ACQUIRING_VMT', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000259, 1, 9999, 'QPR_API_REPORT_PKG.VS_CEMEA', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000264, 1, 9999, 'QPR_API_REPORT_PKG.VS_ACQUIRING_CROSS_BORDER', 'RPTSSXML', 0, NULL, NULL)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type) values (10000273, 1, 9999, 'QPR_API_REPORT_PKG.VS_ACQUIRING_BAI', 'RPTSSXML', 0, NULL, NULL)
/