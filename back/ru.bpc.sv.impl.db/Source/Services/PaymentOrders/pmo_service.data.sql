insert into pmo_service (id, seqnum, direction) values (10000007, 1, 0)
/
update pmo_service set direction = -1 where id in( 10000007)
/
insert into pmo_service (id, seqnum, direction) values (10000010, 1, 1)
/
insert into pmo_service (id, seqnum, direction) values (10000011, 1, 1)
/
insert into pmo_service (id, seqnum, direction) values (10000012, 1, 1)
/
delete from pmo_service where id in (10000010, 10000011, 10000012)
/
insert into pmo_service (id, seqnum, direction) values (10000014, 1, -1)
/
insert into pmo_service (id, seqnum, direction) values (10000015, 2, -1)
/
insert into pmo_service (id, seqnum, direction) values (10000016, 2, -1)
/
insert into pmo_service (id, seqnum, direction) values (10000017, 2, -1)
/
update pmo_service set inst_id = 9999 where id = 10000007
/
update pmo_service set inst_id = 9999 where id = 10000014
/
update pmo_service set inst_id = 9999 where id = 10000015
/
update pmo_service set inst_id = 9999 where id = 10000016
/
update pmo_service set inst_id = 9999 where id = 10000017
/
