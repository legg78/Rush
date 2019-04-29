insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000000, 1, 1, 8, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000001, 1, 1, 2, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000002, 1, 2, 4, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000003, 1, 2, 5, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000004, 1, 2, 6, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000005, 1, 2, 7, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000006, 1, 4, 3, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000007, 1, 5, 3, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000008, 1, 6, 3, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000009, 1, 7, 3, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000010, 1, 3, 4, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000011, 1, 3, 5, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000012, 1, 3, 6, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000013, 1, 3, 7, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000014, 1, 2, 4, 'EVNT1017')
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000015, 1, 3, 4, 'EVNT1017')
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000016, 1, 4, 9, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000017, 1, 5, 9, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000018, 1, 6, 9, null)
/
insert into cln_stage_transition (id, seqnum, stage_id, transition_stage_id, reason_code) values (10000019, 1, 7, 9, null)
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000008 where id = 10000000
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000002 where id = 10000001
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000004 where id = 10000002
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000005 where id = 10000003
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000006 where id = 10000004
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000007 where id = 10000005
/
update cln_stage_transition set stage_id = 10000004, transition_stage_id = 10000003 where id = 10000006
/
update cln_stage_transition set stage_id = 10000005, transition_stage_id = 10000003 where id = 10000007
/
update cln_stage_transition set stage_id = 10000006, transition_stage_id = 10000003 where id = 10000008
/
update cln_stage_transition set stage_id = 10000007, transition_stage_id = 10000003 where id = 10000009
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000004 where id = 10000010
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000005 where id = 10000011
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000006 where id = 10000012
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000007 where id = 10000013
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000004 where id = 10000014
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000004 where id = 10000015
/
update cln_stage_transition set stage_id = 10000004, transition_stage_id = 10000009 where id = 10000016
/
update cln_stage_transition set stage_id = 10000005, transition_stage_id = 10000009 where id = 10000017
/
update cln_stage_transition set stage_id = 10000006, transition_stage_id = 10000009 where id = 10000018
/
update cln_stage_transition set stage_id = 10000007, transition_stage_id = 10000009 where id = 10000019
/
update cln_stage_transition set stage_id = 10000000, transition_stage_id = 10000007 where id = 10000000
/
update cln_stage_transition set stage_id = 10000000, transition_stage_id = 10000001 where id = 10000001
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000003 where id = 10000002
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000004 where id = 10000003
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000005 where id = 10000004
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000006 where id = 10000005
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000002 where id = 10000006
/
update cln_stage_transition set stage_id = 10000004, transition_stage_id = 10000002 where id = 10000007
/
update cln_stage_transition set stage_id = 10000005, transition_stage_id = 10000002 where id = 10000008
/
update cln_stage_transition set stage_id = 10000006, transition_stage_id = 10000002 where id = 10000009
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000003 where id = 10000010
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000004 where id = 10000011
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000005 where id = 10000012
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000006 where id = 10000013
/
update cln_stage_transition set stage_id = 10000001, transition_stage_id = 10000003 where id = 10000014
/
update cln_stage_transition set stage_id = 10000002, transition_stage_id = 10000003 where id = 10000015
/
update cln_stage_transition set stage_id = 10000003, transition_stage_id = 10000008 where id = 10000016
/
update cln_stage_transition set stage_id = 10000004, transition_stage_id = 10000008 where id = 10000017
/
update cln_stage_transition set stage_id = 10000005, transition_stage_id = 10000008 where id = 10000018
/
update cln_stage_transition set stage_id = 10000006, transition_stage_id = 10000008 where id = 10000019
/
