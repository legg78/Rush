insert into rul_mod_param (id, name, data_type, lov_id) values (10002036, 'MEMBER_MESSAGE_TEXT', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002037, 'DOCUMENTATION_INDICATOR', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002038, 'SPECIAL_CHARGEBACK_INDICATOR', 'DTTPNMBR', 4)
/
update rul_mod_param set lov_id = 396 where id = 10002037
/

insert into rul_mod_param (id, name, data_type, lov_id) values (10002206, 'FRAUD_TYPE', 'DTTPCHAR', 416)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002207, 'ISS_GEN_AUTH', 'DTTPCHAR', 418)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002208, 'NOTIFICATION_CODE', 'DTTPCHAR', 417)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002742, 'ISSUER_RFC_BIN', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002743, 'ISSUER_RFC_SUBADDRESS', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002744, 'REQUESTED_FULFILLMENT_METHOD', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002745, 'ESTABLISHED_FULFILLMENT_METHOD', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002746, 'FAX_NUMBER', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10002747, 'CONTACT_FOR_INFORMATION', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003313, 'MESSAGE_REASON', 'DTTPCHAR', 551)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003314, 'DISPUTE_CONDITION', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003315, 'VROL_FINANCIAL_ID', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003316, 'VROL_CASE_NUMBER', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003317, 'VROL_BUNDLE_NUMBER', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003318, 'CLIENT_CASE_NUMBER', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003321, 'VCR_DISPUTE_ENABLE', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003322, 'ISS_COUNTRY', 'DTTPCHAR', 24)
/
update rul_mod_param set data_type = 'DTTPCHAR' where id = 10002037
/
update rul_mod_param set lov_id = 625 where id = 10003314
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004385, 'DISPUTE_STATUS', 'DTTPCHAR', 552)
/
