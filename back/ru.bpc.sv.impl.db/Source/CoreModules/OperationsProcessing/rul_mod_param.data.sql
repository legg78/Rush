delete rul_mod_param where id in (10003141,10003142,10003061)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003061, 'USE_MERCHANT_ADDRESS', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003141, 'ACQ_INST_BIN', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003142, 'MERCHANT_NAME', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003413, 'DEBIT_MACROS_TYPE', 'DTTPNMBR', 1005)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003414, 'CREDIT_MACROS_TYPE', 'DTTPNMBR', 1005)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003415, 'OPER_TYPE_TO_CREATE', 'DTTPCHAR', 49)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003417, 'MATCH_STATUS', 'DTTPCHAR', 573)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003695, 'FULL_SET', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003696, 'ISS_CONTRACT_TYPE', 'DTTPCHAR', 304)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004089, 'OPER_TYPE_FILTER', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004090, 'STATUS_REASON_FILTER', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004091, 'OPER_STAGE', 'DTTPCHAR', 107)
/
delete from rul_mod_param where id = 10004089
/
delete from rul_mod_param where id = 10004090
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004268, 'USING_CUSTOM_OBJECT', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004329, 'FORCED_PROCESSING', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004334, 'IS_LOOP', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004461, 'TOKEN_STATUS', 'DTTPCHAR', 722)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004505, 'BIN_PRODUCT_ID', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004506, 'MCW_BRAND', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004507, 'MCW_PRODUCT_TYPE', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004508, 'VIS_ACCOUNT_FUNDING_SOURCE', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004509, 'BIN_REGION', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004519, 'AUTH_CODE', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004520, 'ATTR_NAME', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004529, 'RESULT_RATE_TYPE', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004532, 'SERVICE_TYPE_ID', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004564, 'RESEND', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004565, 'DOCUMENT_TYPE', 'DTTPCHAR', 293)
/
