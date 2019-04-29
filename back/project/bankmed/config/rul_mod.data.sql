insert into rul_mod (id, scale_id, condition, priority, seqnum) values (5001, 5001, ':ACQ_NETWORK_ID = 5001 OR :ACQ_INST_ID = 5001', 10, 1)
/
update rul_mod set scale_id = 1019 where id = 5001
/
