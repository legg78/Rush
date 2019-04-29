-- privilege
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014557, 'LANGENG', null, 'ACM_PRIVILEGE', 'LABEL', 1179, 'Add Issuing Application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014558, 'LANGENG', null, 'ACM_PRIVILEGE', 'LABEL', 1180, 'Modify Issuing Application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014559, 'LANGENG', null, 'ACM_PRIVILEGE', 'LABEL', 1181, 'Process Issuing Application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014560, 'LANGENG', null, 'ACM_PRIVILEGE', 'LABEL', 1182, 'View Issuing Application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014561, 'LANGENG', null, 'ACM_PRIVILEGE', 'LABEL', 1183, 'Remove Issuing Application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000013887, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10000889, 'Issuer applications')
/
-- label
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021821, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003827, 'Unable to modify cardholder because institution cannot be changed.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018857, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003192, 'Unable to process cardholder because one person is linked to multiple cardholders in same institution.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117098, 'LANGENG', null, 'COM_LABEL', 'NAME', 10006036, 'Cardholder with CARDHOLDER NUMBER=[#1] already exist.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122040, 'LANGENG', null, 'COM_LABEL', 'NAME', 10008961, 'Cardholder not found.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135221, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10010945, 'Card [#1] already exists.')
/
-- app_flow
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000016638, 'LANGENG', null, 'APP_FLOW', 'LABEL', 3, 'Default issuing application.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017571, 'LANGENG', null, 'APP_FLOW', 'LABEL', 4, 'Instant issuing pool card generation.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119648, 'LANGENG', null, 'APP_FLOW', 'LABEL', 2, 'Prepaid bank cards.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120243, 'LANGENG', null, 'APP_FLOW', 'LABEL', 5, 'Reissue cards.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018264, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 8, 'Corporate cards')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018265, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 9, 'Salary Project')
/
-- lov
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121836, 'LANGENG', NULL, 'COM_LOV', 'NAME', 93, 'Issuing Products')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121835, 'LANGENG', NULL, 'COM_LOV', 'NAME', 91, 'Account types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121831, 'LANGENG', NULL, 'COM_LOV', 'NAME', 67, 'Customer Types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121030, 'LANGENG', NULL, 'COM_LOV', 'NAME', 113, 'List of major branches of the issuing application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121027, 'LANGENG', NULL, 'COM_LOV', 'NAME', 115, 'List of cards')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121028, 'LANGENG', NULL, 'COM_LOV', 'NAME', 116, 'List of accounts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018289, 'LANGENG', NULL, 'COM_LOV', 'NAME', 227, 'Departments with contract')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135790, 'LANGENG', NULL, 'COM_LOV', 'NAME', 317, 'List of cards')
/
delete com_i18n where id = 100000045684
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045684, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011519, 'INSTANCE_NOT_FOUND')
/


insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023881, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1001, 'Add new customer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023888, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1002, 'Open additional issuing account')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023889, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1003, 'Open additional card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023890, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1004, 'Change client')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023891, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1005, 'Open additional service')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023892, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1006, 'Close additional service')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023893, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1007, 'Close card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023894, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1008, 'Close account')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136130, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10001481, 'Posting date')
/
update com_i18n set object_id = 1009 where id in (100000017571, 100000129870)
/
update com_i18n set text= 'Default issuing application' where id = 100000016638
/
update com_i18n set text = 'Instant issuing pool card generation' where id = 100000017571
/
update com_i18n set text = 'Prepaid bank cards' where id = 100000119648
/
update com_i18n set text = 'Reissue cards' where id = 100000120243
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031880, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1010, 'Change contract')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031894, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1011, 'Close contract')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031917, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1012, 'Change card status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031919, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1013, 'Change cardholder info')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032012, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1014, 'Change card limit')
/
update com_i18n set text = 'Change service terms' where id = 100000032012
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000044028, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011256, 'Inconsistent data in block <CARD_PRECEDING>. Card instance can''t be located by the submitted elements of the block: card''s id [#1], card''s number [#2], sequential number [#3] and expiration date [#4].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000044929, 'LANGENG', NULL, 'COM_LOV', 'NAME', 405, 'Currency')
/
update com_i18n set text = 'Corporate card Issuings' where id = 100000018264
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045095, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011340, 'Card reissuing command [#1] must be used with correct value of tag REISSUE_CARD_NUMBER')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045096, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1015, 'Change agent number for contract and all its subordinate entities (accounts, card instances)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045098, 'LANGENG', null, 'COM_LABEL', 'NAME', 10011341, 'Can not determine cardholder because several registered cardholders associated with a person with identifier [#1].')
/
update com_i18n set text = 'Create new customer or contract' where id = 100000023881
/
delete com_i18n where id = 100000045095
/
update com_i18n set text = 'Cardholder with number [#1] not found by card [#2]' where id = 100000122040
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137074, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10000179, 'Card identifier')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047239, 'LANGENG', NULL, 'COM_LOV', 'NAME', 481, 'Reissuing commands (for applications)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049057, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000359, 'View carholders tab')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049059, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000361, 'View cards tab')
/
update com_i18n set text = 'Cardholder [#1] already exists' where id = 100000117098
/
update com_i18n set text = 'Cardholder not found by search condition [#1]' where id = 100000122040
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049796, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006979, 'Default account for POS already exists. Default account Id [#1], Card id [#2].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049798, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006980, 'Default account for ATM already exists. Default account Id [#1], Card id [#2].')
/
update com_i18n set text = 'Issuing account types' where id = 100000121835
/
update com_i18n set text = 'Customer types by products' where id = 100000121831
/
update com_i18n set text = 'List of cards by products' where id = 100000135790
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054213, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1016, 'PIN reissue')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055010, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001368, 'Impossible reissue closed card id [#1] with RCMDRENW command - renewal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055383, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000503, 'Fetch customer data from CBS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055384, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'DESCRIPTION', 10000503, 'This privilege enables the option of fetching customer information from CBS via webservice from customer search dialog')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055397, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10007313, 'Query CBS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055966, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1017, 'Payment order management')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137592, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10003444, 'Facilitator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056684, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10007999, 'Query eWallet')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056675, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1018, 'Change issuing account status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056710, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000537, 'Fetch customer data from eWallet')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056711, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'DESCRIPTION', 10000537, 'This privilege enables the option of fetching customer information from eWallet via webservice from customer search dialog')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000148708, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012310, 'Reissue card number [#1] cannot be equal to the old card number of being reissued card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008023, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1019, 'Customers pool generation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008048, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10004060, 'Count of customers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008050, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10004061, 'Customer status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008138, 'LANGENG', NULL, 'RUL_PROC_PARAM', 'NAME', 10001221, 'Card status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009152, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10004217, 'Inherit PIN-offset')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009335, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000645, 'Change status operation of card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009337, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000646, 'Change status operation of card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009344, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000647, 'Change limit amount operation of card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009346, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000648, 'Change limit amount operation of card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009353, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000649, 'Manual fee operation of card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009355, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000650, 'Manual fee operation of card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009362, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000651, 'Change limit amount operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009364, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000652, 'Change limit amount operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009371, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000653, 'Manual fee operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009373, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000654, 'Manual fee operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009380, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000655, 'Attach service notification for card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009382, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000656, 'Attach service notification for card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009389, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000657, 'Detach service operation of card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009391, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000658, 'Detach service operation of card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009398, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000659, 'Unhold authorization operation of card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009400, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000660, 'Unhold authorization operation of card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009405, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000661, 'Balance correction operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009407, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000662, 'Balance correction operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009410, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000663, 'Common issuing operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009412, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000664, 'Common issuing operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009417, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000665, 'Change status operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009419, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000666, 'Change status operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009424, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000667, 'Set balance operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009426, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000668, 'Set balance operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009431, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000669, 'Providing credit limit of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009433, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000670, 'Providing credit limit of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009438, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000671, 'Reprocessing operation privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009440, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000672, 'Reprocessing operation privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009445, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000673, 'Match operation manually privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009447, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000674, 'Match operation manually privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009452, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000675, 'Change operations status privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009454, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000676, 'Change operations status privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009459, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000677, 'Match reversal operation privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009461, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000678, 'Match reversal operation privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009466, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000679, 'Common wizard operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009468, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000680, 'Common wizard operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009473, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000681, 'Customer account funds transfer issuing operation privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009475, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000682, 'Customer account funds transfer issuing operation privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009480, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000683, 'Transfer funds between customers accounts issuing operation privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009482, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000684, 'Transfer funds between customers accounts issuing operation privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009487, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000685, 'Common acquiring operation of account privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009489, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000686, 'Common acquiring operation of account privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009494, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000687, 'Change fraud operation status privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009496, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000688, 'Change fraud operation status privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009503, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000689, 'Balance transfer from prepaid card privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009505, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000690, 'Balance transfer from prepaid card privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009512, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000691, 'Rewards loyalty to cardholder operation privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009514, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000692, 'Rewards loyalty to cardholder operation privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009521, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000693, 'Card operation privilege (maker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009523, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000694, 'Card operation privilege (checker)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112835, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10004364, 'Referral program')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112836, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10004365, 'Referrer code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112837, 'LANGENG', NULL, 'APP_ELEMENT', 'CAPTION', 10004366, 'Referral code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112838, 'LANGENG', NULL, 'APP_ELEMENT', 'DESCRIPTION', 10004365, 'Referral code generated for customer-referrer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112839, 'LANGENG', NULL, 'APP_ELEMENT', 'DESCRIPTION', 10004366, 'Reference to customer-referrer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112937, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1020, 'Account pool generation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113002, 'LANGENG', NULL, 'COM_LABEL', 'DESCRIPTION', 10013269, 'Count of tag CARD blocks [#1] is incorrect for  contract type.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000114832, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000721, 'Reissue card request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000114834, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000722, 'Reissue card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000114841, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000723, 'Change card product request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000114843, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000724, 'Change card product')
/
