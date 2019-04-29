insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1004, 1009, ':TRANSACTION_CODE LIKE ''%''', 110, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1005, 1009, ':TRANSACTION_CODE IN (''10'')', 120, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1006, 1009, ':TRANSACTION_CODE LIKE ''%''', 130, 1)
/
delete from rul_mod where id = 140
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 131
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 132
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 133
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 134
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 137
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 138
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND :ACQ_COUNTRY NOT IN (''344'', ''554'') AND :ISS_COUNTRY NOT IN (''344'', ''554'')' where id = 139
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1665, 1009, ':TRANSACTION_CODE IN ( ''05'',''06'',''07'') AND :VCR_DISPUTE_ENABLE = 1 AND :ACQ_COUNTRY IN (''344'', ''554'') AND :ISS_COUNTRY IN (''344'', ''554'')', 150, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1666, 1009, ':TRANSACTION_CODE IN ( ''15'',''16'',''17'') AND :VCR_DISPUTE_ENABLE = 1 AND :ACQ_COUNTRY IN (''344'', ''554'') AND :ISS_COUNTRY IN (''344'', ''554'')', 160, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1667, 1009, ':TRANSACTION_CODE IN ( ''25'',''26'',''27'') AND :VCR_DISPUTE_ENABLE = 1 AND :ACQ_COUNTRY IN (''344'', ''554'') AND :ISS_COUNTRY IN (''344'', ''554'')', 170, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1668, 1009, ':TRANSACTION_CODE IN ( ''35'',''36'',''37'') AND :VCR_DISPUTE_ENABLE = 1 AND :ACQ_COUNTRY IN (''344'', ''554'') AND :ISS_COUNTRY IN (''344'', ''554'')', 180, 1)
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 131
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 132
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 133
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 134
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 137
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 138
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 139
/
update rul_mod set condition = ':TRANSACTION_CODE IN ( ''35'',''36'',''37'') AND :USAGE_CODE = 9' where id = 1668
/
update rul_mod set condition = ':TRANSACTION_CODE IN ( ''25'',''26'',''27'') AND :USAGE_CODE = 9' where id = 1667
/
update rul_mod set condition = ':TRANSACTION_CODE IN ( ''15'',''16'',''17'') AND  :USAGE_CODE = 9' where id = 1666
/
update rul_mod set condition = ':TRANSACTION_CODE IN ( ''05'',''06'',''07'') AND :USAGE_CODE = 9' where id = 1665
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'',''06'',''07'')' where id = 1035
/
update rul_mod set condition = ':TRANSACTION_CODE LIKE ''%'' AND :USAGE_CODE != 9' where id = 1006
/
update rul_mod set condition = ':TRANSACTION_CODE IN (''10'') AND :USAGE_CODE != 9' where id = 1005
/
update rul_mod set condition = ':TRANSACTION_CODE LIKE ''%'' AND :USAGE_CODE != 9' where id = 1004
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'')' where id = 139
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') ' where id = 138
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'')' where id = 137
/
update rul_mod set condition = ':IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'',''06'',''07'') AND :USAGE_CODE != 9' where id = 136
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'',''06'',''07'') AND :MCC != ''6011''' where id = 135
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') ' where id = 134
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'')' where id = 133
/
update rul_mod set condition = ':USAGE_CODE = 2 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') ' where id = 132
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'')' where id = 131
/
update rul_mod set condition = ':USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 1' where id = 1666
/
update rul_mod set condition = ':USAGE_CODE = 9 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'')' where id = 1665
/
update rul_mod set condition = ':USAGE_CODE = 9 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'')' where id = 1667
/
update rul_mod set condition = ':USAGE_CODE = 9 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'')' where id = 1668
/
delete from rul_mod where id = 131
/
update rul_mod set condition = 'GET_SYSDATE <= TO_DATE(''01.11.2019'', ''DD.MM.YYYY'') AND :USAGE_CODE = 2 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 132
/
update rul_mod set condition = 'GET_SYSDATE <= TO_DATE(''01.11.2019'', ''DD.MM.YYYY'') AND :USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'')' where id = 139
/
update rul_mod set condition = 'GET_SYSDATE <= TO_DATE(''01.11.2019'', ''DD.MM.YYYY'') AND :USAGE_CODE = 2 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''05'', ''06'', ''07'') ' where id = 134
/
update rul_mod set condition = 'GET_SYSDATE <= TO_DATE(''01.11.2019'', ''DD.MM.YYYY'') AND :USAGE_CODE = 1 AND :IS_INCOMING = 1 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'')' where id = 137
/
update rul_mod set condition = 'GET_SYSDATE <= TO_DATE(''01.11.2019'', ''DD.MM.YYYY'') AND :USAGE_CODE = 1 AND :IS_INCOMING = 0 AND :TRANSACTION_CODE in ( ''15'', ''16'', ''17'') AND :VCR_DISPUTE_ENABLE = 0 AND (:ACQ_COUNTRY NOT IN (''344'', ''554'') OR :ISS_COUNTRY NOT IN (''344'', ''554'') )' where id = 138
/
