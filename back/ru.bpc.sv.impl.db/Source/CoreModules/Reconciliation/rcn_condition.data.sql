insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (1, 9999, 'RCNTCOMM', 'sv.recon_inst_id = cbs.recon_inst_id', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (2, 9999, 'RCNTCOMM', 'sv.auth_code = cbs.auth_code', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (3, 9999, 'RCNTCOMM', 'sv.merchant_number = cbs.merchant_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (4, 9999, 'RCNTCOMM', 'sv.terminal_number = cbs.terminal_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (5, 9999, 'RCNTCOMM', 'sv.card_number = cbs.card_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (6, 9999, 'RCNTCOMM', 'sv.oper_amount = cbs.oper_amount', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (7, 9999, 'RCNTCOMM', 'sv.oper_currency = cbs.oper_currency', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (8, 9999, 'RCNTCOMM', 'trunc(sv.oper_date) = trunc(cbs.oper_date)', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (9, 9999, 'RCNTCOMM', 'sv.originator_refnum = cbs.originator_refnum', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (18, 9999, 'RCNTCOMM', 'sv.msg_type = cbs.msg_type', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (10, 9999, 'RCNTATMJ', 'sv.acq_inst_id = atm.acq_inst_id', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (11, 9999, 'RCNTATMJ', 'sv.auth_code = atm.auth_code', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (12, 9999, 'RCNTATMJ', 'sv.terminal_number = atm.terminal_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (13, 9999, 'RCNTATMJ', 'sv.card_number = atm.card_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (14, 9999, 'RCNTATMJ', 'sv.oper_amount = atm.oper_amount', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (15, 9999, 'RCNTATMJ', 'sv.oper_currency = atm.oper_currency', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (16, 9999, 'RCNTATMJ', 'trunc(sv.oper_date) = trunc(atm.oper_date)', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (17, 9999, 'RCNTATMJ', 'sv.trace_number = atm.trace_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (19, 9999, 'RCNTHOST', 'sv.recon_inst_id = hst.recon_inst_id', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (20, 9999, 'RCNTHOST', 'sv.auth_code = hst.auth_code', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (21, 9999, 'RCNTHOST', 'sv.merchant_number = hst.merchant_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (22, 9999, 'RCNTHOST', 'sv.terminal_number = hst.terminal_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (23, 9999, 'RCNTHOST', 'sv.card_number = hst.card_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (24, 9999, 'RCNTHOST', 'sv.oper_amount = hst.oper_amount', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (25, 9999, 'RCNTHOST', 'sv.oper_currency = hst.oper_currency', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (26, 9999, 'RCNTHOST', 'trunc(sv.oper_date) = trunc(hst.oper_date)', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (27, 9999, 'RCNTHOST', 'sv.originator_refnum = hst.originator_refnum', 'RCTPCONN', 1)
/
update rcn_condition set condition = 'sv.approval_code = hst.approval_code' where id = 20
/
update rcn_condition set condition = 'sv.rrn = hst.rrn' where id = 27
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1001, 9999, 'RCNTNTSW', 'sv.recon_inst_id = hst.recon_inst_id', 'RCTPCONN', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1002, 9999, 'RCNTNTSW', 'sv.approval_code = hst.approval_code', 'RCTPCONN', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1003, 9999, 'RCNTNTSW', 'sv.merchant_number = hst.merchant_number', 'RCTPCONN', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1004, 9999, 'RCNTNTSW', 'sv.terminal_number = hst.terminal_number', 'RCTPCONN', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1005, 9999, 'RCNTNTSW', 'sv.card_number = hst.card_number', 'RCTPCONN', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1006, 9999, 'RCNTNTSW', 'sv.oper_amount = hst.oper_amount', 'RCTPCOMP', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1007, 9999, 'RCNTNTSW', 'sv.oper_currency = hst.oper_currency', 'RCTPCOMP', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1008, 9999, 'RCNTNTSW', 'trunc(sv.oper_date) = trunc(hst.oper_date)', 'RCTPCONN', 1, NULL, NULL)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (1009, 9999, 'RCNTNTSW', 'sv.rrn = hst.rrn', 'RCTPCONN', 1, NULL, NULL)
/
