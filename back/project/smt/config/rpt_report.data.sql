insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000282, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000283, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000284, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000285, 1, 9999, NULL, 'RPTSSXML', 0, NULL, NULL, 0)
/
update rpt_report set data_source='cst_smt_settlement_report_pkg.central_bank_summary_clearing' where id = -50000282
/
update rpt_report set data_source='cst_smt_settlement_report_pkg.acq_transaction_statistic' where id = -50000283
/
update rpt_report set data_source='cst_smt_settlement_report_pkg.acq_general_transaction' where id = -50000284
/
update rpt_report set data_source='cst_smt_settlement_report_pkg.mc_acq_transaction' where id = -50000285
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000287, 1, 9999, 'cst_smt_settlement_report_pkg.acq_national_transaction', 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000286, 1, 9999, 'cst_smt_settlement_report_pkg.iss_national_transaction', 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000288, 1, 9999, 'cst_smt_settlement_report_pkg.outgoing_international_trnx', 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000289, 1, 9999, 'cst_smt_settlement_report_pkg.summary_merchant_remittance', 'RPTSSXML', 0, NULL, NULL, 0)
/
insert into rpt_report (id, seqnum, inst_id, data_source, source_type, is_deterministic, name_format_id, document_type, is_notification) values (-50000290, 1, 9999, 'cst_smt_settlement_report_pkg.acq_rejected_transaction', 'RPTSSXML', 0, NULL, NULL, 0)
/
