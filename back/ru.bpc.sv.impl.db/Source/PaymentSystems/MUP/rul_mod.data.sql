insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1119, 1015, ':IS_REVERSAL = 0 AND :IS_INCOMING = 0', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1120, 1015, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1121, 1015, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 30, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1122, 1015, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 35, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1123, 1015, ':MESSAGE_TYPE = ''1644'' AND :DE_024 = ''603'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1 AND :PDS_0228 = ''1''', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1124, 1015, ':MESSAGE_TYPE = ''1442'' AND :IS_INCOMING = 0 AND :IS_REVERSAL = 0  AND :DE_025 in (4807,4808, 4847)', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1125, 1015, ':MESSAGE_TYPE = ''1442'' AND :DE_024 = ''450'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1126, 1015, ':MESSAGE_TYPE = ''1442'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1 AND :DE_024 in (''450'', ''453'')', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1127, 1015, ':MESSAGE_TYPE = ''1442'' AND :DE_024 in (''450'',''453'')  AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0   AND :DE_025 in ( 4807, 4808, 4847)', 80, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1128, 1015, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''205'' AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0', 90, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1129, 1015, ':MESSAGE_TYPE = ''1240'' AND :DE_024 in (''205'',''282'') AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0', 100, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1130, 1015, ':MESSAGE_TYPE LIKE ''%''', 110, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1131, 1015, ':MESSAGE_TYPE = ''1740'' AND :DE_024 = ''700'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 120, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1132, 1015, ':MESSAGE_TYPE = ''1740'' AND :DE_024 = ''780'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 130, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1133, 1015, ':MESSAGE_TYPE = ''1740'' AND :DE_024 = ''781'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 140, 1)
/
delete rul_mod where id = 1119
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1119, 1015, ':IS_REVERSAL = 0 AND :IS_INCOMING = 0', 10, 1)
/
update rul_mod set condition = 'TO_DATE(''26.07.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0' where id = 1120
/
update rul_mod set condition = 'TO_DATE(''26.07.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1' where id = 1121
/
update rul_mod set condition = 'TO_DATE(''26.07.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1' where id = 1122
/
update rul_mod set condition = 'TO_DATE(''25.08.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1442'' AND :DE_024 = ''450'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1' where id = 1125
/
update rul_mod set condition = 'TO_DATE(''25.08.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1442'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1 AND :DE_024 in (''450'', ''453'')' where id = 1126
/
update rul_mod set condition = 'TO_DATE(''24.09.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1240'' AND :DE_024 = ''205'' AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0' where id = 1128
/
update rul_mod set condition = 'TO_DATE(''24.09.2018'', ''DD.MM.YYYY'') > GET_SYSDATE AND :MESSAGE_TYPE = ''1240'' AND :DE_024 in (''205'',''282'') AND :IS_INCOMING = 1 AND :IS_REVERSAL = 0' where id = 1129
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1802, 1002, ':IS_MUP_SMS_MESSAGE = 1', 140, 1)
/
update rul_mod set scale_id = 1029, priority = 20 where id = 1802
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1809, 1029, 'NVL(:IS_MUP_SMS_MESSAGE, 0) = 0', 30, 1)
/
