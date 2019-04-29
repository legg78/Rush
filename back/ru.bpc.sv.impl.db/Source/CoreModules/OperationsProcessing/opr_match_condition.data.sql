insert into opr_match_condition (id, inst_id, condition, seqnum) values (1001, 9999, 'auth.network_refnum = oper.network_refnum', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1002, 9999, 'p_auth.auth_code = nvl2(rtrim(p_oper.auth_code, ''0''), p_oper.auth_code, null)', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1003, 9999, 'trunc(auth.oper_date) = trunc(oper.oper_date)', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1004, 9999, 'abs(trunc(auth.oper_date) - trunc(oper.oper_date)) <= 30', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1005, 9999, 'auth.acq_inst_bin = oper.acq_inst_bin', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1006, 9999, 'auth.merchant_number = oper.merchant_number', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1007, 9999, 'auth.terminal_number = oper.terminal_number', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1008, 9999, 'auth.oper_amount = oper.oper_amount', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1009, 9999, 'auth.oper_currency = oper.oper_currency', 1)
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1010, 9999, 'auth.oper_amount * 10 / 100  >= abs(auth.oper_amount - oper.oper_amount)', 1)
/
update opr_match_condition set condition = 'auth.originator_refnum = oper.originator_refnum' where id = 1001
/
update opr_match_condition set condition = 'auth.auth_code = nvl2(rtrim(oper.auth_code, ''0''), oper.auth_code, null)' where id = 1002
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1011, 9999, 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'') and ((auth.oper_type like ''OPTP002_'' and oper.oper_type like ''OPTP002_'') or (auth.oper_type not like ''OPTP002_'' and oper.oper_type not like ''OPTP002_''))', 1)
/

update opr_match_condition set condition = 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'') and ((auth.oper_type like ''OPTP002_'' and oper.oper_type like ''OPTP002_'') or (auth.oper_type not like ''OPTP002_'' and oper.oper_type not like ''OPTP002_''))' where id = 1011
/
update opr_match_condition set condition = 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'', ''OPTP0428'') and ((auth.oper_type like ''%002_'' and oper.oper_type like ''%002_'') or (auth.oper_type not like ''%002_'' and oper.oper_type not like ''%002_''))' where id = 1011
/

update opr_match_condition set condition = 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'') and (1 = opr_api_operation_pkg.is_oper_type_same_group(auth.oper_type, oper.oper_type))' where id = 1011
/
insert into opr_match_condition (id, inst_id, condition, seqnum) values (1012, 9999, 'auth.total_amount = oper.total_amount', 1)
/
update opr_match_condition set condition = 'auth.total_amount = oper.oper_amount' where id = 1012
/
update opr_match_condition set condition = 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'') and auth.is_credit_operation = oper.is_credit_operation' where id = 1011
/
update opr_match_condition set condition = 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'') and (1 = opr_api_operation_pkg.is_oper_type_same_group(auth.oper_type, oper.oper_type))' where id = 1011
/
update opr_match_condition set condition = 'auth.oper_type not in (''OPTP0070'', ''OPTP0030'') and auth.is_credit_operation = oper.is_credit_operation' where id = 1011
/
