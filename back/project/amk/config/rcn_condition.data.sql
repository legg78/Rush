insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5001, 1001, 'RCNTCOMM', 'sv.recon_inst_id = cbs.recon_inst_id', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5002, 1001, 'RCNTCOMM', 'sv.terminal_number = cbs.terminal_number', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5003, 1001, 'RCNTCOMM', 'sv.is_reversal = cbs.is_reversal', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5004, 1001, 'RCNTCOMM', 'trunc(sv.oper_date) = trunc(cbs.oper_date)', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5005, 1001, 'RCNTCOMM', 'sv.msg_type = cbs.msg_type', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5006, 1001, 'RCNTCOMM', 'sv.sttl_type = cbs.sttl_type', 'RCTPCONN', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5007, 1001, 'RCNTCOMM', 'sv.oper_amount = cbs.oper_amount', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5008, 1001, 'RCNTCOMM', 'sv.oper_currency = cbs.oper_currency', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5009, 1001, 'RCNTCOMM', 'sv.oper_request_amount = cbs.oper_request_amount', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5010, 1001, 'RCNTCOMM', 'sv.oper_request_currency = cbs.oper_request_currency', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5011, 1001, 'RCNTCOMM', 'sv.oper_surcharge_amount = cbs.oper_surcharge_amount', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum) values (-5012, 1001, 'RCNTCOMM', 'sv.oper_surcharge_currency = cbs.oper_surcharge_currency', 'RCTPCOMP', 1)
/
insert into rcn_condition (id, inst_id, recon_type, condition, condition_type, seqnum, provider_id, purpose_id) values (-5013, 9999, 'RCNTCOMM', 'sv.AMPR0020_amount = cbs.AMPR0020_amount and sv.AMPR0020_currency = cbs.AMPR0020_currency', 'RCTPCOMP', 1, null, null)
/
