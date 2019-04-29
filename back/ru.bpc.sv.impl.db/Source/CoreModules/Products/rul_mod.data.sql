insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1669, 1020, ':PRODUCT_ATTRIBUTE = prd_api_attribute_pkg.get_attribute(''ISS_CARD_SPENDING_CREDIT_LIMIT_VALUE'').ID AND :ATTRIBUTE_VALUE > 0', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1670, 1020, ':PRODUCT_ATTRIBUTE = prd_api_attribute_pkg.get_attribute(''ACC_ACCOUNT_CREDIT_LIMIT_VALUE'').ID AND :ATTRIBUTE_VALUE > 0', 20, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1671, 1020, ':PRODUCT_ATTRIBUTE = prd_api_attribute_pkg.get_attribute(''CRD_CUSTOMER_CREDIT_LIMIT_VALUE'').ID AND :ATTRIBUTE_VALUE > 0', 30, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1672, 1020, ':PRODUCT_ATTRIBUTE = prd_api_attribute_pkg.get_attribute(''ISS_CARD_TEMPORARY_CREDIT_LIMIT_VALUE'').ID AND :ATTRIBUTE_VALUE > 0', 40, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1781, 1019, ':ENTITY_TYPE = ''ENTTLIMT''', 80, 1)
/
