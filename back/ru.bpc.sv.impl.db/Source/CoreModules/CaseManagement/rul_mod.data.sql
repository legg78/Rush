insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1613, 1017, ':CARD_STATUS IN (''CSTS0006'', ''CSTS0007'', ''CSTS0008'', ''CSTS0009'', ''CSTS0010'', ''CSTS0011'', ''CSTS0012'', ''CSTS0019'', ''CSTS0022'')', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1614, 1017, ':ACCOUNT_STATUS = ''ACSTCLSD''', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1615, 1017, ':STTL_TYPE = ''STTT0100'' AND (:MESSAGE_TYPE = ''MSGTPRES'' AND :IS_REVERSAL = 1 OR :MESSAGE_TYPE = ''MSGTREPR''  OR :OPER_TYPE IN (''OPTP0019'', ''OPTP0029''))', 30, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1616, 1017, ':STTL_TYPE = ''STTT0200'' AND (:MESSAGE_TYPE = ''MSGTRTRQ'' OR :MESSAGE_TYPE = ''MSGTCHBK'' OR :MESSAGE_TYPE = ''MSGTACBK'' AND :DE_024 IS NOT NULL OR :OPER_TYPE IN (''OPTP0019'', ''OPTP0029''))', 40, 1)
/

