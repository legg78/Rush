insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000002, 10000451, 'reject_code in (''APRJ0004'', ''APRJ0007'')', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000003, 10000451, 'reject_code in (''APRJ0005'')', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000004, 10000451, 'reject_code in (''APRJ0006'')', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000005, 10000451, 'reject_code in (''APRJ0008'')', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000006, 10000451, 'appl_status in (''APST0014'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000007, 10000451, 'appl_status in (''APST0015'', ''APST0016'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000008, 10000451, 'appl_status in (''APST0015'', ''APST0014'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000009, 10000486, 'reject_code in (''APRJ0004'', ''APRJ0007'')', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000010, 10000486, 'appl_status in (''APST0014'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000011, 10000486, 'appl_status in (''APST0015'', ''APST0016'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000012, 10000486, 'appl_status in (''APST0015'', ''APST0014'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000013, 10000487, 'reject_code in (''APRJ0004'', ''APRJ0007'')', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000014, 10000487, 'appl_status in (''APST0014'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000015, 10000487, 'appl_status in (''APST0015'', ''APST0016'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000016, 10000487, 'appl_status in (''APST0015'', ''APST0014'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000017, 10000451, 'appl_status in (''APST0001'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000018, 10000451, 'appl_status not in (''APST0001'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000019, 10000453, 'appl_status in (''APST0001'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000020, 10000453, 'appl_status in (''APST0011'') and appl_type = ''APTPDSPT''', 1)
/
insert into acm_priv_limitation (id, priv_id, condition, seqnum) values (10000021, 10000454, 'appl_status in (''APST0001'') and appl_type = ''APTPDSPT''', 1)
/
update acm_priv_limitation set limitation_type = 'PRLMRSLT' where limitation_type is null
/
update acm_role_privilege set filter_limit_id = 10000022 where priv_id in (1973, 1363, 1433)
/
