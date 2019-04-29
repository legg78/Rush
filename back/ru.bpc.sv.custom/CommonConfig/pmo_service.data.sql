insert into pmo_service (id, seqnum, direction) values (10000001, 1, 0)
/
insert into pmo_service (id, seqnum, direction) values (10000002, 1, 0)
/
insert into pmo_service (id, seqnum, direction) values (10000003, 1, 0)
/
insert into pmo_service (id, seqnum, direction) values (10000004, 1, 0)
/
insert into pmo_service (id, seqnum, direction) values (10000005, 1, 0)
/
insert into pmo_service (id, seqnum, direction) values (10000006, 1, 0)
/
insert into pmo_service (id, seqnum, direction) values (10000008, 1, 1)
/
insert into pmo_service (id, seqnum, direction) values (10000009, 1, 0)
/
update pmo_service set direction = -1 where id in( 10000001, 10000002, 10000003, 10000005, 10000006)
/
update pmo_service set direction = 1 where id in( 10000008, 10000009, 10000004)
/
update pmo_service set direction = -1 where id in( 10000008)
/
update pmo_service set direction = -1 where id = 10000004
/
update pmo_service set direction = 1 where id = 10000008
/
insert into pmo_service (id, seqnum, direction) values (10000010, 1, 1)
/
insert into pmo_service (id, seqnum, direction) values (10000011, 1, 1)
/
insert into pmo_service (id, seqnum, direction) values (10000012, 1, 1)
/
insert into pmo_service (id, seqnum, direction) values (10000013, 2, 1)
/
update pmo_service set inst_id = 9999 where id = 10000001
/
update pmo_service set inst_id = 9999 where id = 10000002
/
update pmo_service set inst_id = 9999 where id = 10000003
/
update pmo_service set inst_id = 9999 where id = 10000004
/
update pmo_service set inst_id = 9999 where id = 10000005
/
update pmo_service set inst_id = 9999 where id = 10000006
/
update pmo_service set inst_id = 9999 where id = 10000007
/
update pmo_service set inst_id = 9999 where id = 10000008
/
update pmo_service set inst_id = 9999 where id = 10000009
/
update pmo_service set inst_id = 9999 where id = 10000010
/
update pmo_service set inst_id = 9999 where id = 10000011
/
update pmo_service set inst_id = 9999 where id = 10000012
/
update pmo_service set inst_id = 9999 where id = 10000013
/
