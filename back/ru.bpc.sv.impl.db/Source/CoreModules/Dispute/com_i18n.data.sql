insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029161, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1, 'Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029162, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 2, 'Retrieval request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029163, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 3, 'First chageback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029164, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 4, 'Retrieval fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029165, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 5, 'Chargeback fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029166, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 6, 'Second presentment full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029167, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 7, 'Second presentment part')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029168, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 8, 'Second presentment fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029169, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 9, 'Second chageback full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029170, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 10, 'Second chageback part')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029171, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 11, 'Member fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029172, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 12, 'Fee return')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029173, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 13, 'Fee resubmition')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029174, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 14, 'Fee second return')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029175, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 15, 'Fraud reporting')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029176, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 16, 'First chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029177, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 17, 'Second chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029178, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 18, 'Second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029179, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 19, 'Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029180, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 20, 'Reversal second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029181, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 21, 'Presentment chargeback reversal')
/
delete from com_i18n where id = 100000029182
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029182, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 22, 'Second presentment charge reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029183, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 23, 'Retrival request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029184, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 24, 'Retrival request response')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029185, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 25, 'Fraud advice reporting')
/
update com_i18n set text = 'First chargeback' where id = 100000029163
/
update com_i18n set text = 'Second presentment chargeback reversal' where id = 100000029182
/
update com_i18n set text = 'Retrieval request' where id = 100000029183
/
update com_i18n set text = 'Retrieval request response' where id = 100000029184
/
update com_i18n set text = 'Second chargeback full' where id = 100000029169
/
update com_i18n set text = 'Second chargeback part' where id = 100000029170
/
update com_i18n set text = 'Second presentment chargeback reversal' where id = 100000029182
/
update com_i18n set text = 'Chargeback' where id = 100000029176
/
update com_i18n set text = 'Chargeback on Second Presentment' where id = 100000029177
/
update com_i18n set text = 'Reversal on Second Presentment' where id = 100000029179
/
update com_i18n set text = 'Reversal' where id = 100000029178
/
update com_i18n set text = 'Second Presentment' where id = 100000029182
/
update com_i18n set text = 'Fraud Advice Reporting' where id = 100000029185
/
update com_i18n set text = 'Presentment Chargeback Reversal' where id = 100000029181
/
update com_i18n set text = 'Retrieval Request' where id = 100000029183
/
update com_i18n set text = 'Retrieval Request Response' where id = 100000029184
/
update com_i18n set text = 'Second Presentment Chargeback Reversal' where id = 100000029180
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136804, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 26, 'Fee Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136898, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 27, 'Funds disbursement transactions')
/
update com_i18n set text = 'First chargeback full' where id = 100000028933
/
update com_i18n set text = 'First chargeback full' where id = 100000029163
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045479, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 29, 'First chargeback part')
/
update com_i18n set text = 'Funds Disbursement reversal' where id = 100000136898
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045480, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 28, 'Funds Disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045649, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011487, 'Dispute not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045650, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011488, 'Reversal already exists')
/
delete from com_i18n where id = 100000029184
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136921, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 30, 'Internal reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136919, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1557, 'Init internal reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136920, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1558, 'Gen internal reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136916, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1036, 'Reversal ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136908, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1034, 'Write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136909, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1035, 'Write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136962, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1037, 'Write-off internal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136958, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1559, 'Init write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136959, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1560, 'Gen write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136963, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 31, 'Write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136964, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 32, 'Write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136965, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 33, 'Write-off internal')
/
update com_i18n set text = 'Write-off positive' where id in (100000136963, 100000136964)
/
update com_i18n set text = 'Write-off internal positive' where id in (100000136965)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136982, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 34, 'Write-off negative')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136983, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 35, 'Write-off negative')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136984, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 36, 'Write-off internal negative')
/
update com_i18n set text = 'Init write-off positive' where id = 100000136958
/
update com_i18n set text = 'Gen write-off positive' where id = 100000136959
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136976, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1561, 'Gen write-off negative')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136977, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1562, 'Init write-off negative')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136990, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005782, 'Dispute borica parametrization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136994, 'LANGENG', NULL, 'RUL_MOD_SCALE', 'NAME', 1014, 'Default Borica dispute scale')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137053, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 37, 'Reversal')
/
update com_i18n set text = 'Dispute Borica parametrization' where id = 100000136990
/
delete from com_i18n where id = 100000137053
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046754, 'LANGENG', NULL, 'COM_LOV', 'NAME', 474, 'Scales for disputes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046747, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1016, 'Scales for disputes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046749, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000010, 'Scales for disputes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046751, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10001205, 'Dispute visa parametrization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046752, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10001206, 'Dispute mastercard parametrization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046753, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10001207, 'Dispute borica parametrization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051666, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1001, 'Retrieval request acknowledgement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053001, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007016, 'Dispute application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053004, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003098, 'Path to attachments of dispute applications')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053007, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007017, 'Dispute reason')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053008, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007018, 'Operation is disclaimed by the client')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053009, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10007018, 'Abjured operation, a client denies that the operation occured')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053010, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007019, 'Wrong operation amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053011, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007020, 'Duplicated operation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053012, 'LANGENG', NULL, 'COM_LOV', 'NAME', 500, 'Dispute reasons')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053018, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003099, 'Dispute reason')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053026, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1501, 'Dispute investigation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053028, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007024, 'Cardholder dispute form')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053029, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007025, 'Copy of sales slip')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053030, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007026, 'Copy of credit slip/voucher')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053031, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007027, 'Copy of return receipt')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053032, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007028, 'Copy of alternate payment')
/
delete com_i18n where id = 100000053033
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053033, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007029, 'Copy of merchant''s delivery terms and conditions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053034, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007030, 'Correspondence with merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053035, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007031, 'Other attachment regarding a dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053046, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007032, 'Dispute attachment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053058, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003100, 'Operation date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053059, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003101, 'Operation amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000053060, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003102, 'Operation currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054288, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007107, 'Dispute progress')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054289, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007108, 'Pre-Compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054290, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007109, 'Compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054291, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007110, 'Pre-Arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054292, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007111, 'Arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054293, 'LANGENG', NULL, 'COM_LOV', 'NAME', 516, 'Dispute progress')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054286, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003137, 'Dispute identifier')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054287, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003138, 'Dispute progress')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054304, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1502, 'Internal dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054305, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1503, 'Issuing domestic dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054306, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1504, 'Acquiring domestic dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054307, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1505, 'Issuing international dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054308, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1506, 'Acquiring international dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054335, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054335, 'Accounting entries are made')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054336, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054336, 'Accounting entries are needed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054337, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054337, 'Acquirer accepted dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054338, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054338, 'Acquirer accepted pre-arbitration full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054339, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054339, 'Acquirer accepted pre-compliance full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054340, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054340, 'Acquirer declined dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054341, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054341, 'Acquirer declined pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054342, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054342, 'Acquirer declined pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054343, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054343, 'Acquirer partly accepted pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054344, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054344, 'Acquirer partly accepted pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054345, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054345, 'Additional information/documents are needed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054346, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054346, 'Case is closed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054347, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054347, 'Case is pending - issuer continues dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054348, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054348, 'Case is resolved - "accepted"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054349, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054349, 'Case is resolved - "cardholder to bear the transaction"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054350, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054350, 'Case is resolved - "credit to cardholder"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054351, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054351, 'Case is resolved - "fulfilled"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054352, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054352, 'Case is resolved - "invalid"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054353, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054353, 'Case is resolved - "represented"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054354, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054354, 'Case is resolved - "unfulfilled"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054355, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054355, 'Case is submitted for write-off approval')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054356, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054356, 'Debit merchant/ATM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054357, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054357, 'Dispute is accepted')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054358, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054358, 'Dispute is accepted - ATM did not dispense cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054359, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054359, 'Dispute is declined - ATM dispensed cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054360, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054360, 'Dispute is not accepted')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054361, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054361, 'Domestic (international) POS dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054362, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054362, 'Domestic ATM dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054363, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054363, 'Domestic dispute letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054364, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054364, 'Filed for arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054365, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054365, 'Filed for compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054366, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054366, 'Final decision on arbitration is made in favor of acquirer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054367, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054367, 'Final decision on arbitration is made in favor of issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054368, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054368, 'Final decision on compliance is made in favor of acquirer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054369, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054369, 'Final decision on compliance is made in favor of issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054370, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054370, 'Incoming arbitration chargeback is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054371, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054371, 'Incoming arbitration email is received from CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054372, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054372, 'Incoming chargeback is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054373, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054373, 'Incoming email is received from CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054374, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054374, 'Incoming representment is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054375, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054375, 'Incoming retrieval request is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054376, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054376, 'Internal ATM dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054377, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054377, 'Internal dispute letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054378, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054378, 'Internal POS dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054379, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054379, 'International ATM dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054380, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054380, 'International dispute letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054381, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054381, 'International POS dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054382, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054382, 'Invalid dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054383, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054383, 'Issuer accepted pre-arbitration full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054384, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054384, 'Issuer accepted pre-compliance full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054385, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054385, 'Issuer continues dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054386, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054386, 'Issuer declined pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054387, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054387, 'Issuer declined pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054388, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054388, 'Issuer does not continue dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054389, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054389, 'Issuer partly accepted pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054390, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054390, 'Issuer partly accepted pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054391, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054391, 'Letter is sent to the acquiring team')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054392, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054392, 'Letter is sent to the acquiring/ATM team')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054393, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054393, 'Letter is sent to the ATM team')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054394, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054394, 'No required information/documents are provided')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054395, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054395, 'Outgoing arbitration chargeback is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054396, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054396, 'Outgoing arbitration email is sent to CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054397, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054397, 'Outgoing chargeback is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054398, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054398, 'Outgoing email is sent to CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054399, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054399, 'Outgoing representment is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054400, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054400, 'Outgoing retrieval request is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054401, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054401, 'Possible compromised card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054402, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054402, 'Possible friendly fraud')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054403, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054403, 'Possible recurring transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054404, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054404, 'Possible instalment transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054405, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054405, 'Possible using the main card by additional card cardholder')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054406, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054406, 'Pre-arbitration attempt is made')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054407, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054407, 'Pre-compliance attempt is made')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054408, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054408, 'Reason code, case progress and due date are set')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054409, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054409, 'Required information/documents are provided')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054410, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054410, 'Retrieval request is fulfilled')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054411, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054411, 'Retrieval request is needed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054412, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054412, 'Retrieval request is unfulfilled')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054413, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054413, 'Supporting documents (if needed) are prepared')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054414, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054414, 'Valid dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054415, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054415, 'Write-off is approved')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054416, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054416, 'Write-off is approved - not debit merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054417, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054417, 'Write-off is declined')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054418, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054418, 'Write-off is declined - debit merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054419, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054419, 'Write-off letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054420, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054420, 'Write-off letter is sent to the management')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054421, 'LANGENG', NULL, 'APP_HISTORY', 'COMMENTS', 100000054421, 'Possible addendum transaction or delayed charge (T&E or rental transaction)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054422, 'LANGENG', NULL, 'COM_LOV', 'NAME', 518, 'Dispute history messages')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054444, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003144, 'Write-off amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054445, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003145, 'Write-off currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054450, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10007053, 'Dispute with selected message type already exists for this operation.')
/
delete from com_i18n where id between 100000054335 and 100000054421 and table_name = 'APP_HISTORY'
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054460, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007120, 'Application history comments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054335, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007121, 'Accounting entries are made')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054336, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007122, 'Accounting entries are needed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054337, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007123, 'Acquirer accepted dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054338, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007124, 'Acquirer accepted pre-arbitration full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054339, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007125, 'Acquirer accepted pre-compliance full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054340, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007126, 'Acquirer declined dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054341, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007127, 'Acquirer declined pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054342, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007128, 'Acquirer declined pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054343, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007129, 'Acquirer partly accepted pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054344, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007130, 'Acquirer partly accepted pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054345, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007131, 'Additional information/documents are needed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054346, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007132, 'Case is closed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054347, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007133, 'Case is pending - issuer continues dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054348, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007134, 'Case is resolved - "accepted"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054349, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007135, 'Case is resolved - "cardholder to bear the transaction"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054350, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007136, 'Case is resolved - "credit to cardholder"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054351, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007137, 'Case is resolved - "fulfilled"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054352, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007138, 'Case is resolved - "invalid"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054353, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007139, 'Case is resolved - "represented"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054354, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007140, 'Case is resolved - "unfulfilled"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054355, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007141, 'Case is submitted for write-off approval')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054356, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007142, 'Debit merchant/ATM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054357, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007143, 'Dispute is accepted')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054358, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007144, 'Dispute is accepted - ATM did not dispense cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054359, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007145, 'Dispute is declined - ATM dispensed cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054360, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007146, 'Dispute is not accepted')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054361, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007147, 'Domestic (international) POS dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054362, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007148, 'Domestic ATM dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054363, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007149, 'Domestic dispute letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054364, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007150, 'Filed for arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054365, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007151, 'Filed for compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054366, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007152, 'Final decision on arbitration is made in favor of acquirer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054367, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007153, 'Final decision on arbitration is made in favor of issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054368, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007154, 'Final decision on compliance is made in favor of acquirer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054369, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007155, 'Final decision on compliance is made in favor of issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054370, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007156, 'Incoming arbitration chargeback is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054371, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007157, 'Incoming arbitration email is received from CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054372, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007158, 'Incoming chargeback is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054373, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007159, 'Incoming email is received from CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054374, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007160, 'Incoming representment is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054375, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007161, 'Incoming retrieval request is received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054376, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007162, 'Internal ATM dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054377, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007163, 'Internal dispute letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054378, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007164, 'Internal POS dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054379, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007165, 'International ATM dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054380, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007166, 'International dispute letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054381, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007167, 'International POS dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054382, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007168, 'Invalid dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054383, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007169, 'Issuer accepted pre-arbitration full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054384, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007170, 'Issuer accepted pre-compliance full')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054385, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007171, 'Issuer continues dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054386, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007172, 'Issuer declined pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054387, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007173, 'Issuer declined pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054388, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007174, 'Issuer does not continue dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054389, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007175, 'Issuer partly accepted pre-arbitration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054390, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007176, 'Issuer partly accepted pre-compliance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054391, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007177, 'Letter is sent to the acquiring team')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054392, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007178, 'Letter is sent to the acquiring/ATM team')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054393, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007179, 'Letter is sent to the ATM team')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054394, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007180, 'No required information/documents are provided')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054395, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007181, 'Outgoing arbitration chargeback is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054396, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007182, 'Outgoing arbitration email is sent to CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054397, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007183, 'Outgoing chargeback is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054398, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007184, 'Outgoing email is sent to CSC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054399, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007185, 'Outgoing representment is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054400, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007186, 'Outgoing retrieval request is sent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054401, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007187, 'Possible compromised card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054402, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007188, 'Possible friendly fraud')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054403, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007189, 'Possible recurring transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054404, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007190, 'Possible instalment transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054405, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007191, 'Possible using the main card by additional card cardholder')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054406, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007192, 'Pre-arbitration attempt is made')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054407, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007193, 'Pre-compliance attempt is made')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054408, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007194, 'Reason code, case progress and due date are set')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054409, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007195, 'Required information/documents are provided')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054410, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007196, 'Retrieval request is fulfilled')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054411, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007197, 'Retrieval request is needed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054412, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007198, 'Retrieval request is unfulfilled')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054413, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007199, 'Supporting documents (if needed) are prepared')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054414, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007200, 'Valid dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054415, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007201, 'Write-off is approved')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054416, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007202, 'Write-off is approved - not debit merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054417, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007203, 'Write-off is declined')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054418, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007204, 'Write-off is declined - debit merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054419, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007205, 'Write-off letter is created')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054420, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007206, 'Write-off letter is sent to the management')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054421, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007207, 'Possible addendum transaction or delayed charge (T&E or rental transaction)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054569, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003161, 'Due date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054572, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003162, 'Dispute expiration notification gap')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054573, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007226, 'Dispute expiration notification gap')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054716, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1119, 'Reversal First Presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054717, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1120, 'Reversal Chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054718, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1121, 'Reversal Second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054719, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1122, 'Reversal Administrative Chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055056, 'LANGENG', NULL, 'COM_LOV', 'NAME', 533, 'Dispute document type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055045, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007262, 'Dispute document type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055048, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007263, 'Cardholder dispute form')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055049, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007264, 'Copy of sales slip')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055050, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007265, 'Copy of credit slip/voucher')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055052, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007267, 'Copy of alternate payment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055053, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007268, 'Copy of merchant''s delivery terms and conditions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055054, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007269, 'Correspondence with merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055055, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007270, 'Other attachment regarding a dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055076, 'LANGENG', NULL, 'COM_LOV', 'NAME', 535, 'Dispute case statuses')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055103, 'LANGENG', NULL, 'COM_LOV', 'NAME', 537, 'Case source for dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055105, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007283, 'Case source for dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055106, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007284, 'Manual case')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055107, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007285, 'Incoming clearing file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055108, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007286, 'Unpaired item')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055109, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007287, 'Original transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055110, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007288, 'Loss advice')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055763, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003329, 'Settlement amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055764, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003330, 'Settlement currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055765, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003331, 'Reason code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056252, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003409, 'Case progress')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056346, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001409, 'MMT')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056347, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001410, 'Doc Indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056349, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001412, 'Fraud type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056351, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001414, 'Cancelled')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056354, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003418, 'Acquirer institution BIN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056356, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003419, 'Transaction code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056358, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003420, 'Source')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137657, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007560, 'The claim was submitted before')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137658, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007561, 'The disputed transaction was not found in the system')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137659, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007562, 'The disputed amount was already credited to cardholder''s account')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137660, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007563, 'The required information was not specified (specify)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137661, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007564, 'The required supporting documents were not enclosed (specify)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137664, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007565, 'Other (specify)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137675, 'LANGENG', NULL, 'COM_LOV', 'NAME', 574, 'Reasons for rejecting applications')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137656, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007568, 'Reasons for rejecting the application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137695, 'LANGENG', NULL, 'COM_LOV', 'NAME', 575, 'Users in chargeback roles ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137701, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006384, 'Scale type selection already exists: identifier [#1], scale type [#2], modifier ID [#3]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137703, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007571, 'Selection of a dispute network')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137705, 'LANGENG', NULL, 'RUL_MOD_SCALE', 'NAME', 1023, 'Custom selection of a dispute network')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137706, 'LANGENG', NULL, 'RUL_MOD_SCALE', 'DESCRIPTION', 1023, 'The scale contains parameters and modifiers that allow to implement custom selection of a network of a dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137708, 'LANGENG', NULL, 'COM_LOV', 'NAME', 576, 'Modifiers for custom selection of a dipute network')
/
update com_i18n set text = 'Dispute Visa parameterization' where id = 100000046751
/
update com_i18n set text = 'Dispute Mastercard parameterization' where id = 100000046752
/
update com_i18n set text = 'Dispute Borica parameterization' where id = 100000046753
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064683, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1677, 'Init Visa SMS second presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064684, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1678, 'Init Visa SMS second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064687, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1679, 'Init Visa SMS funds disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064688, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1680, 'Init Visa SMS first presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064689, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1681, 'Init Visa SMS fee_collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064690, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1682, 'Init Visa SMS debit adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064691, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1683, 'Init Visa SMS credit adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064692, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1684, 'Create Visa SMS second presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064693, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1685, 'Create Visa SMS second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064694, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1686, 'Create Visa SMS funds disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064695, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1687, 'Create Visa SMS first presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064696, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1688, 'Create Visa SMS fee collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064697, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1689, 'Create Visa SMS debit adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064698, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1690, 'Create Visa SMS credit adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064711, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1123, 'Visa SMS Second Presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064712, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1124, 'Visa SMS Funds Disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064713, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1125, 'Visa SMS Fee Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064714, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1126, 'Visa SMS Reversal on Second Presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064715, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1127, 'Visa SMS Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064716, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1128, 'Visa SMS Debit Adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064717, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1129, 'Visa SMS Credit Adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065279, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008474, 'Original operation is not found for the dispute with identifier [#1] and operation with identifier [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006211, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003786, 'Dispute rate type to base currency')
/
update com_i18n set text = 'Chargeback team users' where id = 100000137695
/
update com_i18n set text = 'Modifiers for custom selection of a dispute network' where id = 100000137708
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006274, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007907, 'Presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006275, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007908, 'Presentment  reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006276, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007909, 'Retrieval Request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006277, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007910, 'Retrieval Request reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006278, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007911, 'Chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006279, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007912, 'Chargeback reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006280, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007913, 'Representment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006281, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007914, 'Representment  reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006282, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007915, 'Arbitration chargeback ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006283, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007916, 'Arbitration chargeback reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006284, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007917, 'Fraud advice reporting')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006285, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007918, 'SAFE Fraud reporting')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006286, 'LANGENG', NULL, 'COM_LOV', 'NAME', 618, 'International case progress')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006287, 'LANGENG', NULL, 'COM_LOV', 'NAME', 619, 'Domestic case progress')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006680, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1605, 'Dispute write-off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006657, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008203, 'Dispute message [#1] is not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006661, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008205, 'Item is removed [#1] [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006666, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008207, 'Unable to edit meesage [#1], already send to the network')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006677, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008209, 'Operation [#1] is already processed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006854, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006395, 'Dispute fin message [#1] is already exists')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007033, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006406, 'Financial message [#1] is from unsupported IPC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007116, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008122, 'VCR transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007117, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008123, 'VCR liability assignment: acquirer liable')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007118, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008124, 'VCR liability assignment: issuer liable')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007119, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008125, 'Case is resolved - "responded"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007124, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008126, 'VCR liability assignment: acquirer liable')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007224, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006414, 'Unsupported operation [#1] mti [#2] de024 [#3]  de025 [#4]is_reversal [#5] is_incoming [#6]')
/
delete com_i18n where id = 100000053009
/
delete com_i18n where id = 100000088831
/
delete com_i18n where id = 100000065583
/
delete com_i18n where id = 100000053008
/
delete com_i18n where id = 100000104167
/
delete com_i18n where id = 100000080919
/
delete com_i18n where id = 100000053010
/
delete com_i18n where id = 100000111584
/
delete com_i18n where id = 100000088336
/
delete com_i18n where id = 100000053011
/
delete com_i18n where id = 100000095921
/
delete com_i18n where id = 100000072673
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007277, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008147, 'Duplicate Processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007278, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008148, 'Counterfeit Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007279, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008149, 'Credit Posted as Debit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007280, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008150, 'Paid by Other Means')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007281, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008151, 'Retrieval request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007282, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008152, 'Services Not Provided or Merchandise Not Received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007283, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008153, 'Incorrect Transaction Amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007284, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008154, 'ATM Dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007285, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008155, 'Not as Described or Defective Merchandise')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007286, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008156, 'Cancelled Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007287, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008157, 'Credit Not Processed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007288, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008158, 'Fraudulent Processing of Transactions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007289, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008159, 'Fraud - Card-Present Environment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007290, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008160, 'Fraud-Card-Absent Environment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007529, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011783, 'Settlement type [#1] of operation [#2] is not defined in arrays with settlement types of Issuer or Acquirer.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008951, 'LANGENG', NULL, 'COM_LOV', 'NAME', 674, 'Letter formats')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113407, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1803, 'MC Manual Refund')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113408, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1806, 'Visa Manual Refund')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113409, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1774, 'Init manual refund')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113410, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1775, 'Gen manual refund')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113411, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1144, 'Visa manual refund')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113412, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1145, 'MC manual refund')
/
update com_i18n set text = 'Financial message [#1] is from IPS unsupported by Case management module' where id = 100000007033
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113583, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10013361, 'I/O')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113585, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10013363, 'The card was already listed on the stop list')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113587, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10013365, 'Item details')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047499, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004566, 'Identifier assigned to the Claim in MasterCom')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047501, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004567, 'MasterCom Message Id')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047503, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004568, 'Hidden reversal flag for integration with MasterCom')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047505, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004569, 'Hidden chargeback type for integration with MasterCom')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047507, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004570, 'Hidden partial chargeback flag for integration with MasterCom')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047509, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004571, 'Hidden credit receiver flag for integration with MasterCom')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047522, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008671, 'Dispute case')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047633, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10013562, 'Dispute due date already exists for standard [#1] msg [#2] incoming [#3] reason_code [#4] usage [#5]')
/
