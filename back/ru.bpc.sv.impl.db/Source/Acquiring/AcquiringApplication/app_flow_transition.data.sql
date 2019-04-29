insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1, 1, 1, 2)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (2, 1, 1, 3)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (3, 1, 2, 1)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (4, 1, 2, 3)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (5, 1, 3, 1)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (6, 1, 4, 1)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (31, 1, 21, 22)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (32, 1, 21, 23)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (33, 1, 22, 21)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (34, 1, 22, 23)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (35, 1, 24, 21)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (36, 1, 23, 21)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (37, 1, 25, 26)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (38, 1, 25, 27)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (39, 1, 26, 25)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (40, 1, 26, 27)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (41, 1, 28, 25)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (42, 1, 27, 25)
/
------------ 10 - Merchant closure
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1007, 1, 10000001, 10000002)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1008, 1, 10000001, 10000003)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1009, 1, 10000002, 10000003)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1010, 1, 10000002, 10000001)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1011, 1, 10000003, 10000001)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id) values (1012, 1, 10000004, 10000001)
/
delete from app_flow_transition where id in (1007, 1008, 1009, 1010, 1011, 1012)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1169, 1, 10000114, 10000115, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1170, 1, 10000114, 10000116, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1171, 1, 10000115, 10000116, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1172, 1, 10000116, 10000117, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1173, 1, 10000116, 10000118, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1174, 1, 10000118, 10000114, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1175, 1, 10000121, 10000120, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1176, 1, 10000122, 10000120, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1177, 1, 10000123, 10000120, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1178, 1, 10000120, 10000121, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1179, 1, 10000120, 10000122, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1180, 1, 10000121, 10000122, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1181, 1, 10000125, 10000124, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1182, 1, 10000126, 10000124, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1183, 1, 10000127, 10000124, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1184, 1, 10000124, 10000125, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1185, 1, 10000124, 10000126, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1186, 1, 10000125, 10000126, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1187, 1, 10000129, 10000128, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1188, 1, 10000130, 10000128, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1189, 1, 10000131, 10000128, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1190, 1, 10000128, 10000129, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1191, 1, 10000128, 10000130, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1192, 1, 10000129, 10000130, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1193, 1, 23, 10000133, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1194, 1, 23, 24, 'STRT0020')
/
update app_flow_transition set stage_result = 'STRT0010' where id in (31, 32, 33, 34, 35, 36)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1273, 1, 10000181, 10000182, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1274, 1, 10000181, 10000183, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1275, 1, 10000182, 10000181, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1276, 1, 10000182, 10000183, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1277, 1, 10000183, 10000184, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1278, 1, 10000183, 10000185, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1279, 1, 10000185, 10000181, 'STRT0020')
/
-- 2018 Change acquiring account status
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1402, 1, 10000272, 10000271, 'STRT0020', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1403, 1, 10000273, 10000271, 'STRT0020', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1404, 1, 10000275, 10000271, 'STRT0020', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1405, 1, 10000271, 10000272, 'STRT0010', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1406, 1, 10000271, 10000273, 'STRT0010', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1407, 1, 10000272, 10000273, 'STRT0010', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1408, 1, 10000273, 10000274, 'STRT0010', NULL, NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1409, 1, 10000273, 10000275, 'STRT0020', NULL, NULL)
/

