insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000001, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0010', '%', '0', '%', '%', '%', '%', '%', '%', NULL, -5007, 230)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000002, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0010', '%', '1', '%', '%', '%', '%', '%', '%', NULL, -5007, 230)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000003, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0000', '%', '0', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000004, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0000', '%', '1', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000005, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0020', '%', '0', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000006, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0020', '%', '1', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000007, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0028', '%', '0', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000008, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0028', '%', '1', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000009, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0026', '%', '0', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (-50000010, 1, 'MSGTAUTH', 'PSTGCOMM', 'STTT0200', 'OPTP0026', '%', '1', '%', '%', '%', '%', '%', '%', NULL, -5007, 200)
/
update opr_rule_selection set iss_inst_id = 8001 where id in (-50000001,-50000002,-50000003,-50000004,-50000005,-50000006,-50000007,-50000008,-50000009,-50000010)
/
