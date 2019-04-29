insert into aup_tag (id, tag, tag_type, seqnum, reference, db_stored) values (-50000015, 2004, 'ATTP0004', 1, ' CST_ATM_CONNECTION', 0)
/
insert into aup_tag (id, tag, tag_type, seqnum, reference, db_stored) values (-50000014, 2003, 'ATTP0004', 1, 'CST_ISS_PART_CODE', 0)
/
insert into aup_tag (id, tag, tag_type, seqnum, reference, db_stored) values (-50000013, 2002, 'ATTP0004', 1, 'CST_AGENT_CODE', 0)
/
insert into aup_tag (id, tag, tag_type, seqnum, reference, db_stored) values (-50000012, 2001, 'ATTP0004', 1, 'CST_ACQ_PART_CODE', 0)
/
insert into aup_tag (id, tag, tag_type, seqnum, reference, db_stored) values (-50000011, 2000, 'ATTP0004', 1, 'CST_ACQ_BIN', 0)
/
update aup_tag set reference = trim(reference) where id = -50000015
/
insert into aup_tag (id, tag, tag_type, seqnum, reference, db_stored) values (-50000016, 2005, 'ATTP0004', 1, 'CST_SESSION_DAY', 0)
/
