insert into opr_proc_stage (id, msg_type, sttl_type, oper_type, proc_stage, exec_order, parent_stage, split_method, status) values (1, '%', '%', '%', 'PSTGCOMM', 1, 'PSTGCOMM', NULL, NULL)
/
insert into opr_proc_stage (id, msg_type, sttl_type, oper_type, proc_stage, exec_order, parent_stage, split_method, status, command) values (2, '%', 'STTT0200', '%', 'PSTGDNST', 1, 'PSTGDNST', 'PRTYACQ', 'OPST0100', 'OPCM0001')
/
insert into opr_proc_stage (id, msg_type, sttl_type, oper_type, proc_stage, exec_order, parent_stage, split_method, status, command) values (3, '%', 'STTT0200', '%', 'PSTGSCLI', 1, 'PSTGSCLI', 'PRTYACQ', 'OPST0100', 'OPCM0002')
/
insert into opr_proc_stage (id, msg_type, sttl_type, oper_type, proc_stage, exec_order, parent_stage, split_method, status, command) values (4, '%', 'STTT0200', '%', 'PSTGPYMR', 1, 'PSTGPYMR', 'PRTYACQ', 'OPST0100', 'OPCM0003')
/
update opr_proc_stage set result_status = 'OPST0101' where id = 2
/
update opr_proc_stage set result_status = 'OPST0400' where id = 3
/
update opr_proc_stage set result_status = 'OPST0400' where id = 4
/
insert into opr_proc_stage (id, msg_type, sttl_type, oper_type, proc_stage, exec_order, parent_stage, split_method, status, command, result_status) values (10000001, '%', 'STTT0200', '%', 'PSTGFRZN', 1, 'PSTGFRZN', 'PRTYACQ', 'OPST0100', 'OPCM0004', 'OPST0102')
/

