insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (75, 1, 10000579, 10000581, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 1)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (76, 1, 10000579, 10000582, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 1)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (73, 1, 10000388, 10000276, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 1)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (74, 1, 10000388, 10000278, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 1)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (68, 1, 10000566, 10000722, 'ASTD0003', 'decode('':CUSTOMER_TYPE'', ''ENTTPERS'', 1, 0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (63, 1, 10000566, 10000601, 'ASTD0002', 'DECODE('':CUSTOMER_TYPE'', ''ENTTCOMP'',1,''ENTTPERS'', 0, 0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (41, 1, 10000566, 10000290, 'ASTD0003', 'DECODE('':CUSTOMER_TYPE'', ''ENTTCOMP'',1,0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (40, 1, 10000566, 10000290, 'ASTD0003', 'DECODE('':CUSTOMER_TYPE'', ''ENTTPERS'',0,0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (12, 1, 10000566, 10000567, 'ASTD0002', 'DECODE('':CUSTOMER_TYPE'', ''ENTTCOMP'',1,0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (11, 1, 10000566, 10000428, 'ASTD0003', 'DECODE('':CUSTOMER_TYPE'', ''ENTTPERS'',1,0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (22, 1, 10000242, 10000327, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (43, 1, 10000242, 10000409, 'ASTD0005', 'institution_id in (:appl_inst_id, 9999)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (19, 1, 10000331, 10000327, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 1)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (18, 1, 10000331, 10000326, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 1)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (58, 1, 10000388, 10000275, 'ASTD0002', 'decode('':COMMAND'', ''CMMDCRPR'', 1, ''CMMDCREX'', 0, ''CMMDCRUP'', 1, ''CMMDEXUP'', 1, 0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (42, 1, 10000408, 10000409, 'ASTD0005', 'customer_type = app_ui_dependence_pkg.get_parent_entity(:parent_id)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (65, 1, 10000609, 10000409, 'ASTD0005', 'customer_type = app_ui_dependence_pkg.get_parent_entity(:parent_id)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (36, 1, 10000462, 10000398, 'ASTD0001', NULL, 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (14, 1, 10000712, 10000713, 'ASTD0003', 'DECODE('':COMMAND'', ''CMMDPRRE'',1,''CMMDEXRE'',1,0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (79, 1, 10000580, 10000723, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (80, 1, 10000388, 10000428, 'ASTD0002', 'DECODE('':COMMAND'', ''CMMDEXPR'', 1, 0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (81, 1, 10000826, 10000827, 'ASTD0001', NULL, 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (82, 1, 10000566, 10000826, 'ASTD0003', 'DECODE('':CUSTOMER_TYPE'', ''ENTTCOMP'',1,0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (83, 1, 10000566, 10000827, 'ASTD0003', 'DECODE('':CUSTOMER_TYPE'', ''ENTTCOMP'',1,0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (84, 1, 10000409, 10000410, 'ASTD0002', 'DECODE('':ID_TYPE'', ''IDTP0010'',0,1)', 'DPAZ0001')
/
update app_dependence set condition = 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 0, ''CMMDCRUP'', 0, ''CMMDCREX'', 0, 1)' where id = 76
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (85, 1, 10000462, 10000326, 'ASTD0001', NULL, 'DPAZ0002')
/
delete from app_dependence where id = 11
/
delete from app_dependence where id = 80
/
update app_dependence set condition = 'decode('':COMMAND'', ''CMMDEXPR'', 0, ''CMMDPRRE'', 0, ''CMMDEXUP'', 0, ''CMMDEXRE'', 0,  ''CMMDCRPR'', 0, ''CMMDCRUP'', 0, ''CMMDCREX'', 0, ''CMMDIGNR'', 0, 1)' where id = 76
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000004, 1, 10000566, 10000428, 'ASTD0003', 'decode('':CUSTOMER_TYPE'', ''ENTTPERS'', 1, 0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000005, 1, 10000406, 10000398, 'ASTD0002', 'decode('':COMMAND'', ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, 0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000009, 1, 10000462, 10000693, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000010, 1, 10000462, 10000698, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000011, 1, 10000377, 10000382, 'ASTD0002', 'decode('':COMMAND'', ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, ''CMMDEXUP'', 1, 0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000012, 1, 10000377, 10000426, 'ASTD0002', 'decode('':COMMAND'', ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, ''CMMDEXUP'', 1, 0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000013, 1, 10000377, 10000427, 'ASTD0002', 'decode('':COMMAND'', ''CMMDCRPR'', 1, ''CMMDCRUP'', 1, ''CMMDCREX'', 1, ''CMMDEXUP'', 1, 0)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000014, 1, 10000388, 10000428, 'ASTD0002', 'decode('':COMMAND'', ''CMMDEXPR'', 0, 1)', 'DPAZ0001')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000015, 1, 10000673, 10001175, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000016, 1, 10000675, 10001182, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000017, 1, 10000677, 10001184, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000018, 1, 10000676, 10001187, 'ASTD0001', NULL, 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000020, 1, 10001251, 10001291, 'ASTD0005', ':flow_id not in(1301, 1302, 1303, 1304) or CODE in (''CMMDCRPR'', ''CMMDPRRE'')', NULL)
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000021, 1, 10001251, 10001286, 'ASTD0005', ':flow_id not in(1301, 1302, 1303, 1304) or CODE in (''CMMDCRPR'', ''CMMDPRRE'')', NULL)
/
delete from app_dependence where id=84
/
delete from app_dependence where id=10000011
/
delete from app_dependence where id=10000012
/
delete from app_dependence where id=10000013
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000022, 1, 10000566, 10000428, 'ASTD0002', 'decode('':CUSTOMER_TYPE'', ''ENTTPERS'', 1, 0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000023, 1, 10000221, 10000566, 'ASTD0005', ':FLOW_ID not in (1009) or CODE in (''ENTTCOMP'')', NULL)
/
update app_dependence set condition = ':flow_id not in (1009) or CODE in (''ENTTCOMP'')' where id = 10000023
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000024, 1, 10000221, 10000601, 'ASTD0003', 'decode(:APPLICATION_FLOW_ID, 1009, 0, 1)', 'DPAZ0002')
/
update app_dependence set condition = 'DECODE('':CUSTOMER_TYPE'', ''ENTTCOMP'',0 ,''ENTTPERS'', 0, 0)' where id = 63
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000025, 1, 10000221, 10000601, 'ASTD0002', 'DECODE(:APPLICATION_FLOW_ID, 8, 1, 0)', 'DPAZ0002')
/
insert into app_dependence (id, seqnum, struct_id, depend_struct_id, dependence, condition, affected_zone) values (10000026, 1, 10001251, 10001294, 'ASTD0005', 'CODE in (''CMMDCRPR'',''CMMDPRRE'')', NULL)
/
