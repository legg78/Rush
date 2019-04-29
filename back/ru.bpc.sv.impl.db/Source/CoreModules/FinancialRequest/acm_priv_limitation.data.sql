insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000001, 10000458, 'flow_id=2017', 1)
/
update acm_priv_limitation set condition='flow_id=1601' where id=10000001
/
update acm_priv_limitation set limitation_type = 'PRLMRSLT' where limitation_type is null
/
