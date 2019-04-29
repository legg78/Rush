insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5077, -5009, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'', ''06'', ''07'')', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5078, -5009, ':USAGE_CODE = 2 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'', ''06'', ''07'')', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5079, -5009, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''15'', ''16'', ''17'')', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5080, -5009, ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'',''06'',''07'') AND :MCC != ''6011''', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5081, -5009, ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''15'', ''16'', ''17'')', 80, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5082, -5009, ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''05'', ''06'', ''07'')', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5083, -5009, ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in (''15'', ''16'', ''17'')', 90, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5084, -5009, ':IS_INCOMING = 1 AND :TRANSACTION_CODE in (''05'',''06'',''07'')', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5085, -5009, ':TRANSACTION_CODE LIKE ''%''', 110, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5086, -5009, ':TRANSACTION_CODE IN (''10'')', 120, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5087, -5009, ':TRANSACTION_CODE LIKE ''%''', 130, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (-5091, 1023, ':ACQ_NETWORK_ID = 5012 or :ISS_NETWORK_ID = 5012', 5010, 1)
/
update rul_mod set condition = ':ACQ_NETWORK_ID = 5012 or :CARD_NETWORK_ID = 5012' where id = -5091
/
update rul_mod set condition = ':ACQ_NETWORK_ID = 5012 or NVL(:CARD_NETWORK_ID, :ISS_NETWORK_ID) = 5012' where id = -5091
/
update rul_mod set condition = ':ACQ_INST_ID = 5012 or :ISS_INST_ID = 5012' where id = -5091
/
