insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1714, 1002, ':MSG_TYPE IN (''MSGTAUTH'', ''MSGTPRES'', ''MSGTCHBK'') AND :OPER_TYPE NOT IN (''OPTP1100'', ''OPTP1102'', ''OPTP1122'', ''OPTP1128'', ''OPTP1138'') AND (opr_api_shared_data_pkg.get_participant(''PRTYISS'').oper_id is not null or opr_api_shared_data_pkg.get_participant(''PRTYACQ'').oper_id is not null)', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1717, 1019, ':TERMINAL_TYPE = ''TRMT0002'' AND :MESSAGE_TYPE = ''MSGTAUTH'' AND :ACQ_INST_ID IS NOT NULL', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1734, 1002, ':PROC_MODE = ''AUPMNORM''', 50, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1737, 1002, ':PROC_MODE = ''AUPMDECL'' and :RESP_CODE = ''RESP0025''', 60, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1738, 1002, ':PROC_MODE = ''AUPMDECL'' and :RESP_CODE = ''RESP0021''', 70, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1739, 1002, ':PROC_MODE = ''AUPMDECL'' and :RESP_CODE = ''RESP0022''', 80, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1740, 1002, ':PROC_MODE = ''AUPMDECL'' and :RESP_CODE in (''RESP0017'', ''RESP0018'', ''RESP0028'', ''RESP0036'', ''RESP0046'', ''RESP0048'')', 90, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1741, 1002, ':PROC_MODE = ''AUPMDECL'' and :RESP_CODE = ''RESP0037''', 100, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1742, 1002, ':OPER_TYPE NOT IN ( ''OPTP1100'', ''OPTP1102'', ''OPTP1122'', ''OPTP1128'', ''OPTP1138'',''OPTP1148'') AND :MSG_TYPE IN (''MSGTAUTH'', ''MSGTPRES'', ''MSGTCHBK'') AND (:ACQ_INST_ID = 1001 OR :ISS_INST_ID = 1001) AND :PROC_MODE IN (''AUPMCABS'', ''AUPMDECL'', ''AUPMNORM'')', 110, 1)
/
