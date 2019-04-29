insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1138, 1016, ':IS_REVERSAL = 0 AND :IS_INCOMING = 0', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1139, 1016, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 30, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1140, 1016, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1141, 1016, ':MESSAGE_TYPE = ''1442'' AND :DE_024 = ''450'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1142, 1016, ':MESSAGE_TYPE = ''1442'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1 AND :DE_024 in (''450'', ''453'')', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1143, 1016, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''205'' AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1144, 1016, ':MESSAGE_TYPE = ''1240'' AND :DE_024 in (''205'',''282'') AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0', 80, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1145, 1016, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 90, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1146, 1016, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0', 20, 1)
/
