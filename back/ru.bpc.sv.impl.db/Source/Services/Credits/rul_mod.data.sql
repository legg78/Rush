insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1743, 1024, ':AGING_PERIOD = 0', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1744, 1024, ':AGING_PERIOD = 1', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1745, 1024, ':AGING_PERIOD = 2', 30, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1746, 1024, ':AGING_PERIOD = 3', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1747, 1024, ':AGING_PERIOD = 4', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1748, 1024, ':AGING_PERIOD = 5', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1749, 1024, ':AGING_PERIOD = 6', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1750, 1024, ':AGING_PERIOD = 7', 80, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1751, 1024, ':AGING_PERIOD = 8', 90, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1752, 1024, ':AGING_PERIOD = 9', 100, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1753, 1024, ':AGING_PERIOD = 10', 110, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1754, 1024, ':AGING_PERIOD = 11', 120, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1755, 1024, ':AGING_PERIOD = 12', 130, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1782, 1024, ':IS_MAD_PAID = 0 AND (:AGING_PERIOD > 0 OR :OVERDUE_DATE < :EVENT_DATE)', 200, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1783, 1024, 'NOT( :IS_MAD_PAID = 0 AND (:AGING_PERIOD > 0 OR :OVERDUE_DATE < :EVENT_DATE) )', 210, 1)
/
update rul_mod set condition = ':OVERDUE_DATE is not null AND :IS_MAD_PAID = 0 AND (:AGING_PERIOD > 0 OR :OVERDUE_DATE < :EVENT_DATE)' where id = 1782
/
update rul_mod set condition = 'NOT (:OVERDUE_DATE is not null AND :IS_MAD_PAID = 0 AND (:AGING_PERIOD > 0 OR :OVERDUE_DATE < :EVENT_DATE))' where id = 1783
/
update rul_mod set scale_id = 1028 where id = 1782
/
update rul_mod set scale_id = 1028 where id = 1783
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1810, 1019, ':OBJECT_TYPE IN (''FETP1001'', ''FETP1013'')', 100, 1)
/
