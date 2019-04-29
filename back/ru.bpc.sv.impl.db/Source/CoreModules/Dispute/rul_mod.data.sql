insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1036, 1008, ':STTL_TYPE IN (''STTT0010'',''STTT0000'') AND :IS_REVERSAL = 0', 500, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1034, 1008, ':MESSAGE_TYPE = ''1240'' AND :DE_024 = ''200'' AND :IS_REVERSAL = 0 AND :IS_INCOMING = 1', 160, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1035, 1009, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'',''06'',''07'')', 140, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1037, 1008, ':STTL_TYPE IN (''STTT0010'',''STTT0000'') AND :IS_REVERSAL = 0', 510, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1803, 1008, ':IS_REVERSAL = 0 AND :IS_INCOMING = 0 AND :MESSAGE_TYPE||''/''||:DE_024 IN (''1240/200'') AND mcw_api_dispute_pkg.has_dispute_msg(:OPERATION_ID, ''1442'', ''450'', ''453'', 0) = 0 AND mcw_api_dispute_pkg.has_dispute_msg(:OPERATION_ID, ''1240'', ''200'', 1) = 0', 25, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1806, 1009, ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''05'') AND vis_api_dispute_pkg.has_dispute_msg(:OPERATION_ID, ''15'', 0) = 0 AND vis_api_dispute_pkg.has_dispute_msg(:OPERATION_ID, ''25'', 1) = 0', 55, 1)
/
