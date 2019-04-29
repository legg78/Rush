insert into acm_priv_limitation (id, priv_id, condition) values (100, 100, 'vip!=''VIP''')
/
delete from acm_priv_limitation where id = 100
/
update acm_priv_limitation set limitation_type = 'PRLMRSLT' where limitation_type is null
/
insert into acm_priv_limitation (id, priv_id, seqnum, limitation_type) values (10000022, 1973, 1, 'PRLMFLTR')
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum, limitation_type) values (10000041, 10000451, NULL, 1, 'PRLMFLTR')
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum, limitation_type) values (10000042, 10000644, NULL, 1, 'PRLMFLTR')
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum, limitation_type) values (10000043, 1433, NULL, 1, 'PRLMFLTR')
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum, limitation_type) values (10000044, 1363, NULL, 1, 'PRLMFLTR')
/
