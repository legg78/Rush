insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000791, 10000790, NULL, 'LTY_ACCOUNTING', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000792, 10000790, 10000791, 'LTY_ACCOUNT_CURRENCY', 'DTTPCHAR', 25, 10, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000793, 10000790, 10000791, 'LTY_ACCOUNT_TYPE', 'DTTPCHAR', 91, 20, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000795, 10000790, 10000791, 'LTY_OUTDATE_BUNCH_TYPE', 'DTTPNMBR', 1022, 30, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000796, 10000790, NULL, 'LTY_BONUS', 'DTTPNMBR', NULL, 20, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000798, 10000790, 10000796, 'LTY_BONUS_RATE', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP1101', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000800, 10000790, 10000796, 'LTY_BONUS_START_DATE', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP1102', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000801, 10000790, 10000796, 'LTY_BONUS_EXPIRE_DATE', 'DTTPNMBR', NULL, 50, 'ENTTCYCL', 'CYTP1103', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000802, 10000790, 10000791, 'LTY_EXTERNAL_NUMBER', 'DTTPCHAR', NULL, 50, NULL, NULL, 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000803, 10000790, 10000791, 'LTY_BONUS_UPLOAD_PERIOD', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP1104', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000820, 10000790, 10000796, 'LTY_WELLCOME_BONUS', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP1102', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000821, 10000790, 10000796, 'LTY_BIRTHDAY_BONUS', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP1103', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000829, 10000790, 10000791, 'LTY_CUSTOMER_BIRTHDAY', 'DTTPNMBR', NULL, 60, 'ENTTCYCL', 'CYTP1105', 'SADLSRVC', 1)
/
update prd_attribute set lov_id = 206 where id = 10000793
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003292, 10000790, 10000796, 'LTY_BIRTHDAY_POINTS_BY_TRANS', 'DTTPNMBR', NULL, 60, 'ENTTFEES', 'FETP0149', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003293, 10000790, 10000796, 'LTY_LIMIT_REWARD', 'DTTPNMBR', NULL, 70, 'ENTTLIMT', 'LMTP0142', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003294, 10000790, 10000796, 'LTY_REWARD_BONUSES', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP0150', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003256, 10003241, NULL, 'LTY_ACCOUNTING_ENTTMRCH', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003257, 10003241, NULL, 'LTY_BONUS_ENTTMRCH', 'DTTPNMBR', NULL, 20, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003259, 10003241, 10003256, 'LTY_ACCOUNT_CURRENCY_ENTTMRCH', 'DTTPCHAR', 25, 10, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003260, 10003241, 10003256, 'LTY_ACCOUNT_TYPE_ENTTMRCH', 'DTTPCHAR', 205, 20, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003261, 10003241, 10003256, 'LTY_OUTDATE_BUNCH_TYPE_ENTTMRCH', 'DTTPNMBR', 1022, 30, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003262, 10003241, 10003256, 'LTY_BONUS_UPLOAD_PERIOD_ENTTMRCH', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP0206', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003263, 10003241, 10003256, 'LTY_EXTERNAL_NUMBER_ENTTMRCH', 'DTTPCHAR', NULL, 50, NULL, NULL, 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003264, 10003241, 10003257, 'LTY_BONUS_RATE_ENTTMRCH', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP0220', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003265, 10003241, 10003257, 'LTY_WELLCOME_BONUS_ENTTMRCH', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP0221', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003266, 10003241, 10003257, 'LTY_BONUS_START_DATE_ENTTMRCH', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP0208', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003267, 10003241, 10003257, 'LTY_BONUS_EXPIRE_DATE_ENTTMRCH', 'DTTPNMBR', NULL, 50, 'ENTTCYCL', 'CYTP0209', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003269, 10003268, NULL, 'LTY_ACCOUNTING_ENTTACCT', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003270, 10003268, 10003269, 'LTY_ACCOUNT_CURRENCY_ENTTACCT', 'DTTPCHAR', 25, 10, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003271, 10003268, 10003269, 'LTY_ACCOUNT_TYPE_ENTTACCT', 'DTTPCHAR', 206, 20, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003272, 10003268, 10003269, 'LTY_OUTDATE_BUNCH_TYPE_ENTTACCT', 'DTTPNMBR', 1022, 30, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003273, 10003268, 10003269, 'LTY_BONUS_UPLOAD_PERIOD_ENTTACCT', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP0401', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003274, 10003268, 10003269, 'LTY_EXTERNAL_NUMBER_ENTTACCT', 'DTTPCHAR', NULL, 50, NULL, NULL, 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003275, 10003268, 10003269, 'LTY_CUSTOMER_BIRTHDAY_ENTTACCT', 'DTTPNMBR', NULL, 60, 'ENTTCYCL', 'CYTP0402', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003276, 10003268, NULL, 'LTY_BONUS_ENTTACCT', 'DTTPNMBR', NULL, 20, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003277, 10003268, 10003276, 'LTY_BONUS_RATE_ENTTACCT', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP0405', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003278, 10003268, 10003276, 'LTY_WELLCOME_BONUS_ENTTACCT', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP0406', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003279, 10003268, 10003276, 'LTY_BONUS_START_DATE_ENTTACCT', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP0404', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003280, 10003268, 10003276, 'LTY_BONUS_EXPIRE_DATE_ENTTACCT', 'DTTPNMBR', NULL, 50, 'ENTTCYCL', 'CYTP0405', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003281, 10003268, 10003276, 'LTY_BIRTHDAY_BONUS_ENTTACCT', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP0407', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003404, 10000790, 10000796, 'LTY_LOTTERY_TICKET', 'DTTPNMBR', NULL, 90, 'ENTTLIMT', 'LMTP0144', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003423, 10003422, NULL, 'LTY_ACCOUNTING_ENTTCUST', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003424, 10003422, 10003423, 'LTY_ACCOUNT_CURRENCY_ENTTCUST', 'DTTPCHAR', 25, 10, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003425, 10003422, 10003423, 'LTY_OUTDATE_BUNCH_TYPE_ENTTCUST', 'DTTPNMBR', 1022, 30, NULL, NULL, 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003426, 10003422, 10003423, 'LTY_BONUS_UPLOAD_PERIOD_ENTTCUST', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP0904', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003427, 10003422, 10003423, 'LTY_EXTERNAL_NUMBER_ENTTCUST', 'DTTPCHAR', NULL, 50, NULL, NULL, 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003428, 10003422, 10003423, 'LTY_CUSTOMER_BIRTHDAY_ENTTCUST', 'DTTPNMBR', NULL, 60, 'ENTTCYCL', 'CYTP0905', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003429, 10003422, NULL, 'LTY_BONUS_ENTTCUST', 'DTTPNMBR', NULL, 20, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003430, 10003422, 10003429, 'LTY_BONUS_RATE_ENTTCUST', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP0905', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003431, 10003422, 10003429, 'LTY_WELLCOME_BONUS_ENTTCUST', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP0906', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003432, 10003422, 10003429, 'LTY_BIRTHDAY_BONUS_ENTTCUST', 'DTTPNMBR', NULL, 30, 'ENTTFEES', 'FETP0907', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003433, 10003422, 10003429, 'LTY_BONUS_START_DATE_ENTTCUST', 'DTTPNMBR', NULL, 40, 'ENTTCYCL', 'CYTP0907', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003434, 10003422, 10003429, 'LTY_BONUS_EXPIRE_DATE_ENTTCUST', 'DTTPNMBR', NULL, 50, 'ENTTCYCL', 'CYTP0908', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003435, 10003422, 10003429, 'LTY_LOTTERY_TICKET_ENTTCUST', 'DTTPNMBR', NULL, 60, 'ENTTLIMT', 'LMTP0904', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003473, 10003241, 10003257, 'LTY_REDEMPTION_MIN_THRESHOLD', 'DTTPNMBR', NULL, 25, 'ENTTFEES', 'FETP0223', 'SADLPRDT', 1)
/
update prd_attribute set attr_name = 'LTY_CARD_LIMIT_REWARD' where id = 10003293
/
update prd_attribute set attr_name = 'LTY_CARD_REWARD' where id = 10003294
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003478, 10003422, 10003429, 'LTY_CUSTOMER_LIMIT_REWARD', 'DTTPNMBR', NULL, 70, 'ENTTLIMT', 'LMTP0905', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003479, 10003268, 10003276, 'LTY_ACCOUNT_LIMIT_REWARD', 'DTTPNMBR', NULL, 70, 'ENTTLIMT', 'LMTP0410', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003480, 10003241, 10003257, 'LTY_MERCHANT_LIMIT_REWARD', 'DTTPNMBR', NULL, 70, 'ENTTLIMT', 'LMTP0204', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003481, 10003422, 10003429, 'LTY_CUSTOMER_REWARD', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP0908', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003482, 10003268, 10003276, 'LTY_ACCOUNT_REWARD', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP0413', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003483, 10003241, 10003257, 'LTY_MERCHANT_REWARD', 'DTTPNMBR', NULL, 80, 'ENTTFEES', 'FETP0224', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003484, 10003241, 10003257, 'LTY_PROMOTIONS_LOYALTY_POINTS_MERCHANT', 'DTTPNMBR', NULL, 100, 'ENTTFEES', 'FETP0225', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003486, 10003241, 10003256, 'LTY_MERCHANT_BIRTHDAY', 'DTTPNMBR', NULL, 60, 'ENTTCYCL', 'CYTP0211', 'SADLOBJT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003492, 10003241, 10003257, 'LTY_BIRTHDAY_LOYALTY_POINTS_MERCHANT', 'DTTPNMBR', NULL, 110, 'ENTTFEES', 'FETP0226', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003498, 10000790, 10000791, 'LTY_POINT_NAME', 'DTTPCHAR', NULL, 70, NULL, NULL, 'SADLSRVC', 1)
/
update prd_attribute set attr_name = 'LTY_REDEMPTION_MIN_THRESHOLD_ENTTMRCH' where id = 10003473
/
update prd_attribute set attr_name = 'LTY_LIMIT_REWARD' where id = 10003293
/
update prd_attribute set attr_name = 'LTY_LIMIT_REWARD_ENTTCUST' where id = 10003478
/
update prd_attribute set attr_name = 'LTY_LIMIT_REWARD_ENTTACCT' where id = 10003479
/
update prd_attribute set attr_name = 'LTY_LIMIT_REWARD_ENTTMRCH' where id = 10003480
/
update prd_attribute set attr_name = 'LTY_REWARD_POINTS' where id = 10003294
/
update prd_attribute set attr_name = 'LTY_REWARD_POINTS_ENTTCUST' where id = 10003481
/
update prd_attribute set attr_name = 'LTY_REWARD_POINTS_ENTTACCT' where id = 10003482
/
update prd_attribute set attr_name = 'LTY_REWARD_POINTS_ENTTMRCH' where id = 10003483
/
update prd_attribute set attr_name = 'LTY_PROMOTIONS_LOYALTY_POINTS_ENTTMRCH' where id = 10003484
/
update prd_attribute set attr_name = 'LTY_BIRTHDAY_LOYALTY_POINTS_ENTTMRCH' where id = 10003492
/
update prd_attribute set attr_name = 'LTY_BIRTHDAY' where id = 10000829
/
update prd_attribute set attr_name = 'LTY_BIRTHDAY_ENTTMRCH' where id = 10003486
/
update prd_attribute set attr_name = 'LTY_BIRTHDAY_ENTTACCT' where id = 10003275
/
update prd_attribute set attr_name = 'LTY_BIRTHDAY_ENTTCUST' where id = 10003428
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003512, 10003241, 10003256, 'LTY_INVOICE_PERIOD_ENTTMRCH', 'DTTPNMBR', NULL, 70, 'ENTTCYCL', 'CYTP0212', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003615, 10003241, NULL, 'LTY_REWARDS_LOYALTY_ENTTMRCH', 'DTTPNMBR', NULL, 30, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003616, 10003241, 10003615, 'LTY_REWARD_LOYALTY_FEE_ENTTMRCH', 'DTTPNMBR', NULL, 150, 'ENTTFEES', 'FETP0229', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003617, 10003241, 10003615, 'LTY_REWARD_ACCUM_THRESHOLD_ENTTMRCH', 'DTTPNMBR', NULL, 160, 'ENTTFEES', 'FETP0230', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003618, 10003241, 10003615, 'LTY_REWARD_REDEMTION_ELIGIBILITY_ENTTMRCH', 'DTTPNMBR', NULL, 170, 'ENTTCYCL', 'CYTP0213', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003729, 10003268, 10003276, 'LTY_CASHBACK_MONTHLY_LIMIT', 'DTTPNMBR', NULL, 55, 'ENTTLIMT', 'LMTP0420', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003730, 10003268, 10003276, 'LTY_CASHBACK_CYCLIC_LIMIT', 'DTTPNMBR', NULL, 60, 'ENTTLIMT', 'LMTP0421', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003731, 10003268, 10003276, 'LTY_CASHBACK_YEARLY_LIMIT', 'DTTPNMBR', NULL, 65, 'ENTTLIMT', 'LMTP0422', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003713, 10003268, 10003276, 'LTY_ANNIVERSARY_BONUS_ENTTACCT', 'DTTPNMBR', NULL, 45, 'ENTTFEES', 'FETP0421', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003981, 10003268, 10003276, 'LTY_CASHBACK_CYCLE', 'DTTPNMBR', NULL, 90, 'ENTTCYCL', 'CYTP0415', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004336, 10000790, NULL, 'LTY_PROMOTION_LEVEL_CARD', 'DTTPNMBR', NULL, 100, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004337, 10000790, 10004336, 'LTY_PROMOTION_ALGORITHM_CARD', 'DTTPCHAR', 690, 110, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004338, 10000790, 10004336, 'LTY_PROMOTION_LEVEL_THRESHOLD_CARD', 'DTTPNMBR', NULL, 120, 'ENTTLIMT', 'LMTP0145', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004339, 10000790, 10004336, 'LTY_PROMOTION_PERIOD_CARD', 'DTTPNMBR', NULL, 130, 'ENTTCYCL', 'CYTP0140', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004340, 10000790, 10004336, 'LTY_PROMOTION_LEVEL_PRODUCT_CARD', 'DTTPNMBR', 187, 140, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004342, 10003268, NULL, 'LTY_PROMOTION_LEVEL_ACCOUNT', 'DTTPNMBR', NULL, 100, 'ENTTAGRP', NULL, NULL, 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004343, 10003268, 10004342, 'LTY_PROMOTION_ALGORITHM_ACCOUNT', 'DTTPCHAR', 690, 110, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004344, 10003268, 10004342, 'LTY_PROMOTION_LEVEL_THRESHOLD_ACCOUNT', 'DTTPNMBR', NULL, 120, 'ENTTLIMT', 'LMTP0424', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004346, 10003268, 10004342, 'LTY_PROMOTION_PERIOD_ACCOUNT', 'DTTPNMBR', NULL, 130, 'ENTTCYCL', 'CYTP0420', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004347, 10003268, 10004342, 'LTY_PROMOTION_LEVEL_PRODUCT_ACCOUNT', 'DTTPNMBR', 187, 140, NULL, NULL, 'SADLPRDT', 1)
/
