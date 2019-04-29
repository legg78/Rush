insert into cln_stage (id, seqnum, status, resolution) values (10000000, 1, 'CNST0000', null)
/
insert into cln_stage (id, seqnum, status, resolution) values (10000001, 1, 'CNST0001', null)
/
insert into cln_stage (id, seqnum, status, resolution) values (10000002, 1, 'CNST0001', 'CNRN0002')
/
insert into cln_stage (id, seqnum, status, resolution) values (10000003, 1, 'CNST0002', 'CNRN0003')
/
insert into cln_stage (id, seqnum, status, resolution) values (10000004, 1, 'CNST0002', 'CNRN0004')
/
insert into cln_stage (id, seqnum, status, resolution) values (10000005, 1, 'CNST0002', 'CNRN0005')
/
insert into cln_stage (id, seqnum, status, resolution) values (10000006, 1, 'CNST0002', 'CNRN0006')
/
insert into cln_stage (id, seqnum, status, resolution) values (10000007, 1, 'CNST0003', 'CNRN0000')
/
insert into cln_stage (id, seqnum, status, resolution) values (10000008, 1, 'CNST0003', 'CNRN0001')
/
update cln_stage set status = 'CLST0000' where id = 10000000
/
update cln_stage set status = 'CNST0001' where id = 10000001
/
update cln_stage set status = 'CNST0001' where id = 10000002
/
update cln_stage set status = 'CNST0002' where id = 10000003
/
update cln_stage set status = 'CNST0002' where id = 10000004
/
update cln_stage set status = 'CNST0002' where id = 10000005
/
update cln_stage set status = 'CNST0002' where id = 10000006
/
update cln_stage set status = 'CNST0003' where id = 10000007
/
update cln_stage set status = 'CNST0003' where id = 10000008
/
update cln_stage set status = 'CLST0001' where id = 10000001
/
update cln_stage set status = 'CLST0001' where id = 10000002
/
update cln_stage set status = 'CLST0002' where id = 10000003
/
update cln_stage set status = 'CLST0002' where id = 10000004
/
update cln_stage set status = 'CLST0002' where id = 10000005
/
update cln_stage set status = 'CLST0002' where id = 10000006
/
update cln_stage set status = 'CLST0003' where id = 10000007
/
update cln_stage set status = 'CLST0003' where id = 10000008
/
