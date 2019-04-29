insert into rul_mod (id, scale_id, condition, priority, seqnum) values (5045, -5005, ':AGING_PERIOD > 6', 10, 1)
/
insert into rul_mod (id, scale_id, condition, priority, seqnum) values (5046, -5006, ':PRODUCT_ATTRIBUTE = prd_api_attribute_pkg.get_attribute(''CRD_MINIMUM_AMOUNT_TOLERANCE'').ID AND :ATTRIBUTE_VALUE > 0', 10, 1)
/
