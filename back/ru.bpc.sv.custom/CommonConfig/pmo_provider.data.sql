insert into pmo_provider (id, seqnum, region_code) values (10000001, 1, NULL)
/
insert into pmo_provider (id, seqnum, region_code) values (10000002, 1, NULL)
/
update pmo_provider set inst_id = 9999 where id = 10000001
/
update pmo_provider set inst_id = 9999 where id = 10000002
/
