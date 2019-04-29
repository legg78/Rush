delete aup_scheme where id in (1001, 1002)
/
insert into aup_scheme (id, seqnum, scheme_type, inst_id, scale_id, resp_code, system_name) values (1001, 2, 'AUSC0002', 9999, 1005, 'RESP0044', 'DEFAULT_SCHEME1')
/
insert into aup_scheme (id, seqnum, scheme_type, inst_id, scale_id, resp_code, system_name) values (1002, 1, 'AUSC0002', 9999, 1005, 'RESP0044', 'DEFAULT_SCHEME2')
/
