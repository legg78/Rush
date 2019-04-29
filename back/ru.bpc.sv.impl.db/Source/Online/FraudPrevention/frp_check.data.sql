insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000001, 1, 1001, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) <> merchant_country(2) and (oper_date(1) - oper_date(2))*24 < 6 and (card_data_input_mode(1) = ''F2270002'' and (card_data_input_mode(2) = ''F2270002'' or card_data_input_mode(2) = ''F2270005'')) and (card_data_input_mode(2) = ''F2270002'' and (card_data_input_mode(1) = ''F2270002'' or card_data_input_mode(1) = ''F2270005'')) and merchant_city(1) <> merchant_city(2) and (merchant_country(1) <> ''643'' and merchant_country(1) <> ''643'')', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000004, 1, 1001, 'CHTPEXPR', 'ALTPALWS', '(oper_date(1) - oper_date(2))*24 < 6 and mcc(2) <> ''5309'' and merchant_street(2) not like ''DUTY%'' and merchant_city(2) <> ''KHIMKI'' and merchant_country(1) <> ''643'' and merchant_country(2) = ''643'' and card_data_input_mode(1) = ''F2270002'' and (card_data_input_mode(2) = ''F2270002'' or card_data_input_mode(2) = ''F2270005'')', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000005, 1, 1002, 'CHTPEXPR', 'ALTPALWS', '(oper_date(1) - oper_date(2))*86400 < 60 and (oper_date(2) - oper_date(3))*86400 < 60 and (oper_date(3) - oper_date(4))*86400 < 60 and (oper_date(4) - oper_date(5))*86400 < 60 and mcc(1) = ''6011'' and mcc(2) = ''6011'' and mcc(3) = ''6011'' and mcc(4) = ''6011'' and mcc(5) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) <> ''643'' and merchant_country(1) <> ''804'' and merchant_country(1) <> ''112'' and merchant_country(1) <> ''156''', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000006, 1, 1002, 'CHTPEXPR', 'ALTPALWS', '(merchant_city(1) like ''%PETER%'' or merchant_city(1) like ''%PITER%'') and card_data_input_mode(1) <> ''F2270005'' and mcc(1) = ''6011'' and mcc(2) = ''6011'' and mcc(3) = ''6011'' and mcc(4) = ''6011'' and mcc(5) = ''6011'' and (oper_date(1) - oper_date(2))*86400 < 1800 and (oper_date(2) - oper_date(3))*86400 < 1800 and (oper_date(3) - oper_date(4))*86400 < 1800 and (oper_date(4) - oper_date(5))86400 < 1800 and (oper_date(5) - oper_date(6))*86400 < 1800 and mcc(6) = ''6011''', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000007, 1, 1002, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and terminal_id(3) = terminal_id(4) and oper_amount(1) > 20000 and oper_amount(2) > 20000 and oper_amount(3) > 20000 and oper_amount(4) > 20000', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000008, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''840'' and merchant_country(2) = ''840'' and merchant_country(3) = ''840'' and oper_currency(3) = ''840'' and oper_currency(2) = ''840'' and oper_amount(2) > 19000 and oper_amount(3) > 19000 and (mcc(2) = ''5200'' or mcc(2) = ''5912'' or mcc(2) = ''5411'' or mcc(2) = ''5310'') and (mcc(3) = ''5200'' or mcc(3) = ''5912'' or mcc(3) = ''5411'' or mcc(3) = ''5310'') and mcc(1) <> ''6011'' and oper_amount(1) > ''19000'' and oper_currency(1) = ''840'' and (oper_date(1) - oper_date(2))*24 < 3 and (oper_date(2) - oper_date(3))*24 < 3', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000009, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''840'' and merchant_country(2) = ''643'' and card_data_input_mode(1) = ''F2270002'' and (card_data_input_mode(2) = ''F2270002'' or card_data_input_mode(2) = ''F2270005'') and (oper_date(1) - oper_date(2))*24 < 8 and mcc(1) <> ''3011'' and mcc(1) <> ''3357'' and mcc(1) <> ''3389''', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000010, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''840'' and oper_currency(1) = ''840'' and oper_amount(1) > 49000 and (merchant_street(1) = ''WAL-MART'' or merchant_street(1) like ''WAL-MART%'' or merchant_street(1) like ''WALMART%'') and card_data_input_mode(1) = ''F2270002''', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000011, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''840'' and merchant_country(2) = ''840'' and card_data_input_mode(1) = ''F2270002'' and card_data_input_mode(2) = ''F2270002'' and (merchant_street(1) = ''WAL-MART'' or merchant_street(1) like ''WAL-MART%'' or merchant_street(1) like ''WALMART%'') and (merchant_street(2) = ''WAL-MART'' or merchant_street(2) like ''WAL-MART%'' or merchant_street(2) like ''WALMART%'') and (oper_date(1) - oper_date(2))*24 < 3 and oper_amount(1) > 19000 and oper_amount(2) > 19000 and oper_currency(1) = 840 and oper_currency(2) = 840', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000012, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''840'' and merchant_country(2) = ''840'' and oper_amount(1) > 49000 and oper_amount(2) > 49000 and oper_currency(1) = ''840'' and oper_currency(2) = ''840'' and card_data_input_mode(1) = ''F2270002'' and card_data_input_mode(2) = ''F2270002'' and (oper_date(1) - oper_date(2))*24 < 3 and (mcc(1) = ''5200'' or mcc(1) = ''5912'' or mcc(1) = ''5411'' or mcc(1) = ''5310'') and (mcc(2) = ''5200'' or mcc(2) = ''5912'' or mcc(2) = ''5411'' or mcc(2) = ''5310'')', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000013, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and terminal_id(3) = terminal_id(4) and oper_amount(4) > 10000000 and oper_amount(1) = oper_amount(2) and oper_amount(2) = oper_amount(3)', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000014, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'oper_amount(1) > 10000000', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000015, 1, 1003, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and oper_amount(1) = oper_amount(2) and oper_amount(2) = oper_amount(3) and ALERT_97(2)', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000016, 1, 1004, 'CHTPEXPR', 'ALTPALWS', '((merchant_country(1) = ''036'' and oper_amount(1) > 20000) or (merchant_country(1) = ''156'' and oper_amount(1) > 140000) or (merchant_country(1) = ''356'' and oper_amount(1) > 9999)) and card_data_input_mode(1) <> ''F2270005'' and mcc(1) <> ''6011'' and ALERT_10(2)', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000017, 1, 1004, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''144'' and (card_data_input_mode(1) = ''F2270002'' or card_data_input_mode(1) = ''F2270005'')', 20, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000018, 1, 1004, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''710'' and (card_data_input_mode(1) = ''F2270002'' or card_data_output_cap(1) = ''F2270005'')', 25, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000019, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''710'' and oper_amount(1) > 90000 and merchant_country(2) = ''710'' and oper_amount(2) > 90000 and merchant_country(3) = ''710'' and oper_amount(3) > 90000 and oper_type(1) = ''OPTP0001'' and oper_type(2) = ''OPTP0001'' and oper_type(3) = ''OPTP0001'' and (oper_date(1) - oper_date(3))*86400 < 43200 and card_data_input_mode(1) = ''F2270002'' and card_data_input_mode(2) = ''F2270002'' and card_data_input_mode(3) = ''F2270002''', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000020, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''380'' and (merchant_city(1) = ''ITALIA'' or merchant_city(1) like ''MILAN%'' or merchant_city(1) = ''TRECATE'' or merchant_city(1) like ''LURATE%'' or merchant_city(1) = ''VIAREGGIO'')', 35, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000021, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and (merchant_country(1) = ''100'' or merchant_country(1) = ''616'' or merchant_country(1) = ''032'' or merchant_country(1) = ''788'' or merchant_country(1) = ''380'' or merchant_country(1) = ''504'' or merchant_country(1) = ''422'' or merchant_country(1) = ''800'' or merchant_country(1) = ''076'' or merchant_country(1) = ''360'' or merchant_country(1) = ''404'')', 35, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000022, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and merchant_country(1) = ''804'' and (terminal_id(1) = ''ATMYA102'' or terminal_id(1) = ''ATMSEL06'' or terminal_id(1) = ''ATMKIE66'' or terminal_id(1) = ''77777103'' or terminal_id(1) = ''77777295'' or terminal_id(1) = ''CACR7877'' or terminal_id(1) = ''ATMODE07'' or terminal_id(1) = ''CAHE5164'' or terminal_id(1) = ''A0403339'' or terminal_id(1) = ''A1802882'' or terminal_id(1) = ''ATMB3403'' or terminal_id(1) = ''A0402963'' or terminal_id(1) = ''H0142188'' or terminal_id(1) = ''A0403782'' or terminal_id(1) = ''A0309050'' or terminal_id(1) = ''A0101110'' or terminal_id(1) = ''A0308300'' or terminal_id(1) = ''A0308755'' or terminal_id(1) = ''A1803319'' or terminal_id(1) = ''ATM00045'' or terminal_id(1) = ''ATM82337'' or terminal_id(1) = ''ATMB1978'')', 20, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000023, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) = ''F2270002'' and (merchant_country(1) = ''356'' or merchant_country(1) = ''818'' or merchant_country(1) = ''616'' or merchant_country(1) = ''788'' or merchant_country(1) = ''032'' or merchant_country(1) = ''380'' or merchant_country(1) = ''499'' or merchant_city(1) like ''%PETER%'' or merchant_city(1) like ''%PITER%'' or merchant_country(1) = ''760'') and ALERT_25(2)', 90, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000024, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) <> ''643'' and merchant_country(1) <> ''246'' and merchant_country(1) <> ''112'' and merchant_country(1) <> ''804'' and  mcc(1) = ''6011'' and card_data_input_mode(1) = ''F2270002'' and merchant_country(2) = ''643'' and (card_data_input_mode(2) = ''F2270002'' or card_data_input_mode(2) = ''F2270005'') and (oper_date(1) - oper_date(2))*24 < 3 and merchant_country(1) <> merchant_country(2)', 85, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000025, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''643'' and (card_data_input_mode(1) = ''F2270002'' or card_data_input_mode(1) = ''F2270005'') and merchant_country(2) <> ''643'' and card_data_input_mode(2) = ''F2270002'' and mcc(2) = ''6011'' and merchant_country(2) <> ''246'' and (oper_date(1) - oper_date(2))*24 < 3 and merchant_country(2) <> ''112'' and merchant_country(2) <> ''804'' and merchant_country(1) <> merchant_country(2)', 85, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000027, 1, 1005, 'CHTPEXPR', 'ALTPALWS', '(mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''818'' and oper_amount(1) > 250000) and (mcc(2) = ''6011'' and card_data_input_mode(2) <> ''F2270005'' and merchant_country(2) = ''818'' and oper_amount(2) < 25000 and oper_type(2) <> ''OPTP0030'') and (oper_date(1) - oper_date(2))*24 < 10', 85, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000028, 1, 1005, 'CHTPEXPR', 'ALTPALWS', '(mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''356'') and (oper_amount(1) > 499000 or (mcc(2) = ''6011'' and card_data_input_mode(2) <> ''F2270005'' and merchant_country(2) = ''356'' and (oper_date(1) - oper_date(2))*86400 < 300))', 35, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000029, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''100''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000030, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''616'' and (merchant_city(1) = ''ZAKOPANE'' or merchant_city(1) = ''POZNAN'')', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000031, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and (merchant_country(1) = ''218'' or merchant_country(1) = ''604'' or merchant_country(1) = ''214'')', 85, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000032, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''704''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000033, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''380''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000034, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''504''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000035, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''616''', 90, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000036, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''800''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000037, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_city(1) = ''SAO PAULO'' and merchant_country(1) = ''076''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000038, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''356''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000039, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''760''', 90, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000040, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and (oper_date(3) - oper_date(1))*86400 < 600', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000041, 1, 1005, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''840'' and mcc(1) = ''6011'' and mcc(2) = ''6011'' and merchant_country(2) = ''840'' and mcc(2) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and (oper_date(1) - oper_date(2))*86400 < 1800', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000042, 1, 1006, 'CHTPEXPR', 'ALTPALWS', '(merchant_street(1) like ''WAL-MART%'' or merchant_street(1) = ''WAL-MART'' or merchant_street(1) like ''WALMART%'' or merchant_street(1) like ''WM%'') and oper_amount(1) > 19000 and card_data_input_mode(1) <> ''F2270005''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000043, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'oper_type(2) = ''OPTP0000'' and oper_amount(2) < 6000 and card_data_input_mode(1) = ''F2270002'' and (oper_date(1) - oper_date(2))*24 < 6 and merchant_country(1) <> ''643''', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000044, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'oper_type(1) = ''OPTP0000'' and oper_type(2) = ''OPTP0000'' and oper_type(3) = ''OPTP0000'' and (oper_date(1) - oper_date(2))*86400 < 1800 and (oper_date(2) - oper_date(3))*86400 < 1800 and oper_amount(1) > 20000 and oper_amount(2) > 20000 and oper_amount(3) > 20000 and (oper_currency(1) = ''978'' or oper_currency(1) = ''840'') and card_data_input_mode(1) = ''F2270002''', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000045, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'merchant_country(1) = ''710'' and card_data_input_mode(1) <>''F2270005''', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000046, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'resp_code(2) = ''RESP0038'' and merchant_country(2) <> ''643''', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000047, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''5542'' and mcc(2) = ''5542'' and mcc(3) = ''5542'' and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(3) <> ''F2270005'' and (oper_date(1) - oper_date(2))*86400 < 600 and (oper_date(2) - oper_date(3))*86400 < 600', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000048, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'merchant_street(1) = ''ROSINTER RK MDM''', 20, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000049, 1, 1006, 'CHTPEXPR', 'ALTPALWS', 'card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''643'' and (mcc(1) = ''5732'' or mcc(1) = ''5722'' or mcc(1) = ''5944'' or mcc(1) = ''5251'' and ALERT_66(2)', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000050, 1, 1007, 'CHTPEXPR', 'ALTPALWS', '(oper_date(1) - oper_date(5))*86400 < 300 and oper_type(1) = oper_type(2) and oper_type(2) = oper_type(3) and oper_type(3) = oper_type(4) and oper_type(4) = oper_type(5) and oper_type(1) = ''OPTP0000'' and resp_code(2) = resp_code(3) and resp_code(3) = resp_code(4) and resp_code(4) = resp_code(5) and resp_code(2) = ''RESP0037''', 61, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000051, 1, 1008, 'CHTPEXPR', 'ALTPALWS', '(terminal_id(1) = ''PS204490'' or terminal_id(1) = ''PS196435'' or terminal_id(1) = ''PS470391'' or terminal_id(1) = ''00677613'' or terminal_id(1) = ''00689508'' or terminal_id(1) = ''00377530'' or terminal_id(1) = ''00740119'') or (mcc(1) <> ''6011'' and merchant_city(1) like ''%ANTAL%'' and merchant_country(1) = ''792'')', 30, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000052, 1, 1008, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''792'' and merchant_country(1) = ''268'' and merchant_country(1) = ''764'' and merchant_country(1) = ''031'' and ALERT_15(2)', 75, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000053, 1, 1008, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and mcc(2) = ''6011'' and (oper_date(1) - oper_date(2))*24 < 3 and (merchant_country(1) = ''724'' or merchant_country(1) = ESP or merchant_country(1) = ''380'' or merchant_country(1) = ''764'' or merchant_country(1) = ''344'' or merchant_country(1) = ''702'') and ALERT_15(2)', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000054, 1, 1009, 'CHTPEXPR', 'ALTPALWS', '(terminal_id(1) = ''00806960'' or terminal_id(1) = ''P0647711'' or (terminal_id(1) = ''41930001'' and mcc(1) = ''5999'') or (terminal_id(1) = ''43010001'' and merchant_street(1) = ''UNITED WAY'') or terminal_id(1) = ''VRU ONLY'' and (merchant_street(1) like ''RITE AID%'' or merchant_street(1) like ''BED BATH%'' or merchant_street(1) like ''FOREVER%'' or merchant_street(1) like ''WAL-MART%'' or merchant_street(1) like ''WALMART%'' or merchant_street(1) like ''TOYS R%'' or merchant_street(1) like ''EMERALD FOODS IN%'') or terminal_id(1) = ''80001010'' or terminal_id(1) = ''90100504'' or merchant_street(1) like ''THE INSTITUTE OF CHA%'') and card_data_input_mode(1) <> ''F2270002'' and card_data_input_mode(1) <> ''F2270005''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000055, 1, 1009, 'CHTPEXPR', 'ALTPALWS', '((terminal_id(1) = ''80010001'' and merchant_street(1) = ''PRC AND COMPANIES'') or (terminal_id(1) = ''00000001'' and (merchant_street(1) = ''GBMAA'' or merchant_street(1) = ''MERCOLACOMH'')) or (terminal_id(1) = ''00080001'' or (terminal_id(1) = ''10010001'' and mcc(1) = ''5999'')) and merchant_country(1) = ''840'' or merchant_street(1) = ''AQUAPAY LONDON'' or merchant_street(1) = ''AQUAPAY BRIGEND'' or merchant_street(1) = ''TOUCHTONE PROJECT'' or merchant_street(1) = ''CHLDRENS HOSPITAL TRUST'' or (merchant_street(1) = ''NTFM'' and terminal_id(1) = ''30384965'')) and card_data_input_mode(1) <> ''F2270002'' and card_data_input_mode(1) <> ''F2270005''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000056, 1, 1009, 'CHTPEXPR', 'ALTPALWS', '(terminal_id(1) = ''00010001'' and merchant_country(1) = ''840'' and oper_type(1) = ''OPTP0000'' and oper_amount(1) < 1000) or (terminal_id(1) = ''001'' and mcc(1) = ''5046'' and oper_amount(1) < 300 and merchant_country(1) = ''840'')', 30, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000057, 1, 1010, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = ''04983408'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''442''', 60, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000058, 1, 1011, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''144''', 80, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000059, 1, 1011, 'CHTPEXPR', 'ALTPALWS', 'merchant_city(1) = ''MOSCOW'' and mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and (oper_currency(1) = ''840'' and oper_amount(1) > 49900 or oper_amount(1) > 999900 and oper_currency(1) = ''643'') and merchant_city(2) = ''MOSCOW'' and mcc(2) = ''6011'' and card_data_input_mode(2) <> ''F2270005'' and oper_type(2) = ''OPTP0030''', 55, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000060, 1, 1011, 'CHTPEXPR', 'ALTPALWS', '(merchant_country(1) = ''170'' or merchant_country(1) = ''458'' or merchant_country(1) = ''422'') and card_data_input_mode(1) <> ''F2270005'' and mcc(1) = ''6011''', 55, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000061, 1, 1012, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and (merchant_city(1) = ''MOSCOW'' or merchant_city(1) = ''MOSKVA'') and ((oper_currency(1) = ''643'' and oper_amount(1) > 499000) or (oper_currency(1) = ''840'' and oper_amount(1) > 14900))', 65, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000062, 1, 1013, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and card_number(1) = card_number(2) and (oper_date(1) - oper_date(3))*86400 < 600 and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and resp_code(3) = ''RESP0001'' and card_number(2) = card_number(3)', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000063, 1, 1013, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and card_number(1) <> card_number(2) and oper_amount(1) = oper_amount(2) and (oper_date(1) - oper_date(2))*86400 < 600 and resp_code(2) = ''RESP0036'' and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005''', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000064, 1, 1013, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and (oper_date(1) - oper_date(5))*86400 < 600 and terminal_id(3) = terminal_id(4) and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(4) <> ''F2270005'' and card_data_input_mode(5) <> ''F2270005'' and terminal_id(4) = terminal_id(5) and card_number(1) = card_number(2) and card_number(2) = card_number(3) and card_number(3) = card_number(4) and card_number(4) = card_number(5) and card_data_input_mode(3) <> ''F2270005'' and mcc(1) <> ''6011'' and mcc(2) <> ''6011'' and mcc(3) <> ''6011'' and mcc(4) <> ''6011'' and mcc(5) <> ''6011''', 45, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000065, 1, 1013, 'CHTPEXPR', 'ALTPALWS', 'acq_inst_bin(1) = ''111199'' or terminal_id(1) = ''2254''', 10, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000066, 1, 1013, 'CHTPEXPR', 'ALTPALWS', 'merchant_id(1) = merchant_id(2) and merchant_id(2) = merchant_id(3) and card_number(1) = card_number(2) and card_number(2) = card_number(3) and ALERT_81(2)', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000067, 1, 1013, 'CHTPEXPR', 'ALTPALWS', 'card_number(1) = card_number(2) and card_number(2) = card_number(3) and card_number(3) = card_number(4) and card_number(4) = card_number(5) and terminal_id(1) <> terminal_id(2) and terminal_id(2) <> terminal_id(3) and terminal_id(3) <> terminal_id(4) and terminal_id(4) <> terminal_id(5) and mcc(1) <> ''6011'' and mcc(2) <> ''6011'' and mcc(3) <> ''6011'' and mcc(4) <> ''6011'' and mcc(5) <> ''6011'' and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(3) <> ''F2270005'' and card_data_input_mode(4) <> ''F2270005'' and card_data_input_mode(5) <> ''F2270005''', 45, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000068, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_number(1) = card_number(2) and card_number(2) = card_number(3) and mcc(2) = ''6011'' and mcc(3) <> ''6011'' and resp_code(1) = ''RESP0025'' and resp_code(2) = ''RESP0025'' and card_data_input_mode(3) <> ''F2270005''', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000069, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_number(1) = card_number(2) and card_number(2) = card_number(3) and mcc(2) = ''6011'' and mcc(3) <> ''6011'' and card_data_input_mode(3) <> ''F2270005''', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000070, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'oper_amount(1) = 1670', 50, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000071, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'oper_type(1) = oper_type(2) and oper_amount(1) = oper_amount(2)', 40, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000072, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and (oper_date(3) - oper_date(1))*86400 < 600 and card_number(1) <> card_number(2) and card_number(2) <> card_number(3) and card_number(1) <> card_number(3)', 10, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000073, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'merchant_id(1) = ''990000001082''', 35, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000074, 1, 1014, 'CHTPEXPR', 'ALTPALWS', 'pin_presence(1) = ''PINP0001'' and card_data_input_mode(1) <> ''F2270005''', 35, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000075, 1, 1015, 'CHTPEXPR', 'ALTPALWS', 'card_number(1) = card_number(2) and card_number(2) = card_number(3) and terminal_id(2) = terminal_id(3) and terminal_id(1) = terminal_id(2) and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(3) <> ''F2270005'' and (oper_date(1) - oper_date(3))*86400 < 1800', 45, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000076, 1, 1016, 'CHTPEXPR', 'ALTPALWS', 'terminal_id(1) = terminal_id(2) and terminal_id(2) = terminal_id(3) and oper_amount(1) > 5000 and oper_amount(2) > 5000 and oper_amount(3) > 5000', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000077, 1, 1017, 'CHTPEXPR', 'ALTPALWS', 'card_data_input_mode(1) <> ''F2270005'' and mcc(1) <> ''6011'' and mcc(1) <> ''7011'' and mcc(1) <> ''3011'' and mcc(1) <> ''4789'' and mcc(1) <> ''5812'' and mcc(1) <> ''6010'' and card_data_input_mode(1) <> ''F2270005'' and mcc(1) <> ''3649''', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000078, 1, 1018, 'CHTPEXPR', 'ALTPALWS', 'card_data_input_mode(1) <> ''F2270005'' and mcc(1) = ''6011'' and merchant_street(2) = ''KRASNODAR'' and (merchant_country(1) = ''724'' or merchant_country(1) = ''280'' or merchant_country(1) = ''076'' or merchant_country(1) = ''032'' or merchant_country(1) = ''404'' or merchant_country(1) = ''100'' or merchant_country(1) = ''380'' or merchant_country(1) = ''124'')', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000079, 1, 1018, 'CHTPEXPR', 'ALTPALWS', 'merchant_street(1) = ''123456789''', 20, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000080, 1, 1018, 'CHTPEXPR', 'ALTPALWS', 'card_data_input_mode(1) <> ''F2270005'' and mcc(1) = ''6011'' and merchant_country(1) <> ''643'' and ALERT_113(2)', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000081, 1, 1018, 'CHTPEXPR', 'ALTPALWS', 'merchant_street(1) = ''123456789''', 20, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000082, 1, 1018, 'CHTPEXPR', 'ALTPALWS', 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''804'' and ALERT_116(2)', 70, null)
/
insert into frp_check (id, seqnum, case_id, check_type, alert_type, expression, risk_score, risk_matrix_id) values (10000083, 1, 1019, 'CHTPEXMT', 'ALTPALWS', '(oper_date(1) - oper_date(2))*86400 < matrix_1001 and (card_data_input_mode(1) = ''F2270002'' and (card_data_input_mode(2) = ''F2270002'' or card_data_input_mode(2) = ''F2270005'')) or (card_data_input_mode(1) = ''F2270005'' and card_data_input_mode(2) = ''F2270002'')', 61, null)
/

update frp_check set expression = '(merchant_city(1) like ''%PETER%'' or merchant_city(1) like ''%PITER%'') and card_data_input_mode(1) <> ''F2270005'' and mcc(1) = ''6011'' and mcc(2) = ''6011'' and mcc(3) = ''6011'' and mcc(4) = ''6011'' and mcc(5) = ''6011'' and (oper_date(1) - oper_date(2))*86400 < 1800 and (oper_date(2) - oper_date(3))*86400 < 1800 and (oper_date(3) - oper_date(4))*86400 < 1800 and (oper_date(4) - oper_date(5))*86400 < 1800 and (oper_date(5) - oper_date(6))*86400 < 1800 and mcc(6) = ''6011''' where id = 10000006
/
update frp_check set expression = 'card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''643'' and mcc(1) in (''5732'',''5722'', ''5944'', ''5251'') and ALERT_10000048(2)' where id = 10000049
/
update frp_check set expression = 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''792'' and merchant_country(1) = ''268'' and merchant_country(1) = ''764'' and merchant_country(1) = ''031'' and ALERT_10000051(2)' where id = 10000052
/
update frp_check set expression = 'mcc(1) = ''6011'' and mcc(2) = ''6011'' and (oper_date(1) - oper_date(2))*24 < 3 and (merchant_country(1) = ''724'' or merchant_country(1) = ''724'' or merchant_country(1) = ''380'' or merchant_country(1) = ''764'' or merchant_country(1) = ''344'' or merchant_country(1) = ''702'') and ALERT_10000051(2)' where id = 10000053
/
update frp_check set risk_matrix_id = 1001 where id = 10000083
/

update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and terminal_number(3) = terminal_number(4) and oper_amount(1) > 20000 and oper_amount(2) > 20000 and oper_amount(3) > 20000 and oper_amount(4) > 20000' where id = 10000007
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and terminal_number(3) = terminal_number(4) and oper_amount(4) > 10000000 and oper_amount(1) = oper_amount(2) and oper_amount(2) = oper_amount(3)' where id = 10000013
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and oper_amount(1) = oper_amount(2) and oper_amount(2) = oper_amount(3) and ALERT_97(2)' where id = 10000015
/
update frp_check set expression = 'mcc(1) = ''6011'' and merchant_country(1) = ''804'' and (terminal_number(1) = ''ATMYA102'' or terminal_number(1) = ''ATMSEL06'' or terminal_number(1) = ''ATMKIE66'' or terminal_number(1) = ''77777103'' or terminal_number(1) = ''77777295'' or terminal_number(1) = ''CACR7877'' or terminal_number(1) = ''ATMODE07'' or terminal_number(1) = ''CAHE5164'' or terminal_number(1) = ''A0403339'' or terminal_number(1) = ''A1802882'' or terminal_number(1) = ''ATMB3403'' or terminal_number(1) = ''A0402963'' or terminal_number(1) = ''H0142188'' or terminal_number(1) = ''A0403782'' or terminal_number(1) = ''A0309050'' or terminal_number(1) = ''A0101110'' or terminal_number(1) = ''A0308300'' or terminal_number(1) = ''A0308755'' or terminal_number(1) = ''A1803319'' or terminal_number(1) = ''ATM00045'' or terminal_number(1) = ''ATM82337'' or terminal_number(1) = ''ATMB1978'')' where id = 10000022
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and (oper_date(3) - oper_date(1))*86400 < 600' where id = 10000040
/
update frp_check set expression = '(terminal_number(1) = ''PS204490'' or terminal_number(1) = ''PS196435'' or terminal_number(1) = ''PS470391'' or terminal_number(1) = ''00677613'' or terminal_number(1) = ''00689508'' or terminal_number(1) = ''00377530'' or terminal_number(1) = ''00740119'') or (mcc(1) <> ''6011'' and merchant_city(1) like ''%ANTAL%'' and merchant_country(1) = ''792'')' where id = 10000051
/
update frp_check set expression = '(terminal_number(1) = ''00806960'' or terminal_number(1) = ''P0647711'' or (terminal_number(1) = ''41930001'' and mcc(1) = ''5999'') or (terminal_number(1) = ''43010001'' and merchant_street(1) = ''UNITED WAY'') or terminal_number(1) = ''VRU ONLY'' and (merchant_street(1) like ''RITE AID%'' or merchant_street(1) like ''BED BATH%'' or merchant_street(1) like ''FOREVER%'' or merchant_street(1) like ''WAL-MART%'' or merchant_street(1) like ''WALMART%'' or merchant_street(1) like ''TOYS R%'' or merchant_street(1) like ''EMERALD FOODS IN%'') or terminal_number(1) = ''80001010'' or terminal_number(1) = ''90100504'' or merchant_street(1) like ''THE INSTITUTE OF CHA%'') and card_data_input_mode(1) <> ''F2270002'' and card_data_input_mode(1) <> ''F2270005''' where id = 10000054
/
update frp_check set expression = '((terminal_number(1) = ''80010001'' and merchant_street(1) = ''PRC AND COMPANIES'') or (terminal_number(1) = ''00000001'' and (merchant_street(1) = ''GBMAA'' or merchant_street(1) = ''MERCOLACOMH'')) or (terminal_number(1) = ''00080001'' or (terminal_number(1) = ''10010001'' and mcc(1) = ''5999'')) and merchant_country(1) = ''840'' or merchant_street(1) = ''AQUAPAY LONDON'' or merchant_street(1) = ''AQUAPAY BRIGEND'' or merchant_street(1) = ''TOUCHTONE PROJECT'' or merchant_street(1) = ''CHLDRENS HOSPITAL TRUST'' or (merchant_street(1) = ''NTFM'' and terminal_number(1) = ''30384965'')) and card_data_input_mode(1) <> ''F2270002'' and card_data_input_mode(1) <> ''F2270005''' where id = 10000055
/
update frp_check set expression = '(terminal_number(1) = ''00010001'' and merchant_country(1) = ''840'' and oper_type(1) = ''OPTP0000'' and oper_amount(1) < 1000) or (terminal_number(1) = ''001'' and mcc(1) = ''5046'' and oper_amount(1) < 300 and merchant_country(1) = ''840'')' where id = 10000056
/
update frp_check set expression = 'terminal_number(1) = ''04983408'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''442''' where id = 10000057
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and card_number(1) = card_number(2) and (oper_date(1) - oper_date(3))*86400 < 600 and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and resp_code(3) = ''RESP0001'' and card_number(2) = card_number(3)' where id = 10000062
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and card_number(1) <> card_number(2) and oper_amount(1) = oper_amount(2) and (oper_date(1) - oper_date(2))*86400 < 600 and resp_code(2) = ''RESP0036'' and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005''' where id = 10000063
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and (oper_date(1) - oper_date(5))*86400 < 600 and terminal_number(3) = terminal_number(4) and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(4) <> ''F2270005'' and card_data_input_mode(5) <> ''F2270005'' and terminal_number(4) = terminal_number(5) and card_number(1) = card_number(2) and card_number(2) = card_number(3) and card_number(3) = card_number(4) and card_number(4) = card_number(5) and card_data_input_mode(3) <> ''F2270005'' and mcc(1) <> ''6011'' and mcc(2) <> ''6011'' and mcc(3) <> ''6011'' and mcc(4) <> ''6011'' and mcc(5) <> ''6011''' where id = 10000064
/
update frp_check set expression = 'acq_inst_bin(1) = ''111199'' or terminal_number(1) = ''2254''' where id = 10000065
/
update frp_check set expression = 'card_number(1) = card_number(2) and card_number(2) = card_number(3) and card_number(3) = card_number(4) and card_number(4) = card_number(5) and terminal_number(1) <> terminal_number(2) and terminal_number(2) <> terminal_number(3) and terminal_number(3) <> terminal_number(4) and terminal_number(4) <> terminal_number(5) and mcc(1) <> ''6011'' and mcc(2) <> ''6011'' and mcc(3) <> ''6011'' and mcc(4) <> ''6011'' and mcc(5) <> ''6011'' and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(3) <> ''F2270005'' and card_data_input_mode(4) <> ''F2270005'' and card_data_input_mode(5) <> ''F2270005''' where id = 10000067
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and (oper_date(3) - oper_date(1))*86400 < 600 and card_number(1) <> card_number(2) and card_number(2) <> card_number(3) and card_number(1) <> card_number(3)' where id = 10000072
/
update frp_check set expression = 'card_number(1) = card_number(2) and card_number(2) = card_number(3) and terminal_number(2) = terminal_number(3) and terminal_number(1) = terminal_number(2) and card_data_input_mode(1) <> ''F2270005'' and card_data_input_mode(2) <> ''F2270005'' and card_data_input_mode(3) <> ''F2270005'' and (oper_date(1) - oper_date(3))*86400 < 1800' where id = 10000075
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and oper_amount(1) > 5000 and oper_amount(2) > 5000 and oper_amount(3) > 5000' where id = 10000076
/ 
update frp_check set expression = 'merchant_number(1) = merchant_number(2) and merchant_number(2) = merchant_number(3) and card_number(1) = card_number(2) and card_number(2) = card_number(3) and ALERT_10000065(2)' where id = 10000066
/
update frp_check set expression = 'merchant_number(1) = ''990000001082''' where id = 10000073
/

update frp_check set expression = 'card_data_input_mode(1) <> ''F2270005'' and mcc(1) = ''6011'' and merchant_country(1) <> ''643'' and ALERT_10000079(2)' where id = 10000080
/
update frp_check set expression = 'mcc(1) = ''6011'' and card_data_input_mode(1) <> ''F2270005'' and merchant_country(1) = ''804'' and ALERT_10000081(2)' where id = 10000082
/
update frp_check set expression = 'mcc(1) = ''6011'' and card_data_input_mode(1) = ''F2270002'' and (merchant_country(1) = ''356'' or merchant_country(1) = ''818'' or merchant_country(1) = ''616'' or merchant_country(1) = ''788'' or merchant_country(1) = ''032'' or merchant_country(1) = ''380'' or merchant_country(1) = ''499'' or merchant_city(1) like ''%PETER%'' or merchant_city(1) like ''%PITER%'' or merchant_country(1) = ''760'') and ALERT_10000022(2)' where id = 10000023
/
update frp_check set expression = '((merchant_country(1) = ''036'' and oper_amount(1) > 20000) or (merchant_country(1) = ''156'' and oper_amount(1) > 140000) or (merchant_country(1) = ''356'' and oper_amount(1) > 9999)) and card_data_input_mode(1) <> ''F2270005'' and mcc(1) <> ''6011'' and ALERT_10000017(2)' where id = 10000016
/
update frp_check set expression = 'terminal_number(1) = terminal_number(2) and terminal_number(2) = terminal_number(3) and oper_amount(1) = oper_amount(2) and oper_amount(2) = oper_amount(3) and ALERT_10000014(2)' where id = 10000015
/
update frp_check set expression = 'acq_bin(1) = ''111199'' or terminal_number(1) = ''2254''' where id = 10000065
/

update frp_check set expression = 'merchant_country(1) = ''840'' and merchant_country(2) = ''840'' and card_data_input_mode(1) = ''F2270002'' and card_data_input_mode(2) = ''F2270002'' and (merchant_street(1) = ''WAL-MART'' or merchant_street(1) like ''WAL-MART%'' or merchant_street(1) like ''WALMART%'') and (merchant_street(2) = ''WAL-MART'' or merchant_street(2) like ''WAL-MART%'' or merchant_street(2) like ''WALMART%'') and (oper_date(1) - oper_date(2))*24 < 3 and oper_amount(1) > 19000 and oper_amount(2) > 19000 and oper_currency(1) = ''840'' and oper_currency(2) = ''840''' where id = 10000011
/
update frp_check set risk_matrix_id = null where id = 10000083
/
update frp_check set risk_matrix_id = null, check_type = 'CHTPEXPR' where id = 10000083 
/
