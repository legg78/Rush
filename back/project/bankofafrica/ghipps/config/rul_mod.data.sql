insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5092, -5010, ':TRANSACTION_CODE LIKE ''%''', 130, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5093, -5010, ':TRANSACTION_CODE IN (''10'')', 120, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5094, -5010, ':TRANSACTION_CODE LIKE ''%''', 110, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5095, -5010, ':IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'',''06'',''07'')', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5096, -5010, ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''15'', ''16'', ''17'')', 90, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5097, -5010, ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''05'', ''06'', ''07'')', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5098, -5010, ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''15'', ''16'', ''17'')', 80, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5099, -5010, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'',''06'',''07'') AND :MCC != ''6011''', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5100, -5010, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''15'', ''16'', ''17'')', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5101, -5010, ':USAGE_CODE = 2 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'', ''06'', ''07'')', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5102, -5010, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'', ''06'', ''07'')', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5103, 1023, ':ACQ_NETWORK_ID = 5014 or :ISS_NETWORK_ID = 5014', 5020, 1)
/
update rul_mod set condition = ':ACQ_NETWORK_ID = 5014 or :CARD_NETWORK_ID = 5014' where id = -5103
/
