insert into opr_rule_selection (id, seqnum, msg_type, proc_stage, sttl_type, oper_type, oper_reason, is_reversal, iss_inst_id, acq_inst_id, terminal_type, oper_currency, account_currency, sttl_currency, mod_id, rule_set_id, exec_order) values (10000001, 1, 'MSGTPRES', 'PSTGCOMM', 'STTT0000', 'OPTP0401', '%', '0', '%', '%', '%', '%', '%', '%', 1677, 1022, 10)
/
update opr_rule_selection set oper_type = 'OPTP0423' where id = 10000001
/
