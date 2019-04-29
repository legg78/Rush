delete rul_mod where id = 1673
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1673, 1002, 'opr_api_shared_data_pkg.get_participant(''PRTYISS'').oper_id is not null', 10, 1)
/
delete rul_mod where id = 1674
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1674, 1002, 'opr_api_shared_data_pkg.get_participant(''PRTYACQ'').oper_id is not null', 20, 1)
/
