insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1288, 1, 10000191, 10000192, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1289, 1, 10000192, 10000193, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1290, 1, 10000192, 10000194, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1420, 1, 10000281, 10000282, 'STRT0010', NULL, NULL) 
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1421, 1, 10000282, 10000283, 'STRT0010', NULL, NULL) 
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1422, 1, 10000282, 10000284, 'STRT0020', NULL, NULL) 
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1423, 1, 10000285, 10000286, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1424, 1, 10000286, 10000287, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1425, 1, 10000286, 10000288, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1426, 1, 10000289, 10000290, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1427, 1, 10000290, 10000291, 'STRT0010')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result) values (1428, 1, 10000290, 10000292, 'STRT0020')
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1455, 1, 10000323, 10000324, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1456, 1, 10000324, 10000325, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1457, 1, 10000324, 10000326, 'STRT0020', 'EVNT2402', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1458, 1, 10000327, 10000328, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1459, 1, 10000328, 10000329, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1460, 1, 10000328, 10000330, 'STRT0020', 'EVNT2402', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1461, 1, 10000331, 10000332, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1462, 1, 10000332, 10000333, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1463, 1, 10000332, 10000334, 'STRT0020', 'EVNT2402', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1464, 1, 10000335, 10000336, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1465, 1, 10000336, 10000337, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1466, 1, 10000336, 10000338, 'STRT0020', 'EVNT2402', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1467, 1, 10000339, 10000340, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1468, 1, 10000340, 10000341, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1469, 1, 10000340, 10000342, 'STRT0020', 'EVNT2402', NULL)
/
update app_flow_transition set event_type = 'EVNT2400' where id = 1288
/
update app_flow_transition set event_type = 'EVNT2401' where id = 1289
/
update app_flow_transition set event_type = 'EVNT2402' where id = 1290
/
update app_flow_transition set event_type = 'EVNT2400' where id = 1420
/
update app_flow_transition set event_type = 'EVNT2401' where id = 1421
/
update app_flow_transition set event_type = 'EVNT2402' where id = 1422
/
update app_flow_transition set event_type = 'EVNT2400' where id = 1423
/
update app_flow_transition set event_type = 'EVNT2401' where id = 1424
/
update app_flow_transition set event_type = 'EVNT2402' where id = 1425
/
update app_flow_transition set event_type = 'EVNT2400' where id = 1426
/
update app_flow_transition set event_type = 'EVNT2401' where id = 1427
/
update app_flow_transition set event_type = 'EVNT2402' where id = 1428
/
update app_flow_transition set event_type = 'EVNT2400' where id = 1429
/
update app_flow_transition set event_type = 'EVNT2401' where id = 1430
/
update app_flow_transition set event_type = 'EVNT2402' where id = 1431
/
delete from app_flow_transition where id = 1467
/
delete from app_flow_transition where id = 1468
/
delete from app_flow_transition where id = 1469
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1467, 1, 10000344, 10000345, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1468, 1, 10000345, 10000346, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1469, 1, 10000345, 10000347, 'STRT0020', 'EVNT2402', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1470, 1, 10000348, 10000349, 'STRT0010', 'EVNT2400', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1471, 1, 10000349, 10000350, 'STRT0010', 'EVNT2401', NULL)
/
insert into app_flow_transition (id, seqnum, stage_id, transition_stage_id, stage_result, event_type, reason_code) values (1472, 1, 10000349, 10000351, 'STRT0020', 'EVNT2402', NULL)
/
