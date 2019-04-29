insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000001, 1, 'CBS_TRANSFER_BIC', 'DTTPCHAR', NULL, '^\d{4,9}$', 96)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000002, 1, 'CBS_TRANSFER_BANK_NAME', 'DTTPCHAR', NULL, NULL, 97)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000003, 1, 'CBS_TRANSFER_BANK_BRANCH_NAME', 'DTTPCHAR', NULL, NULL, 98)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000004, 1, 'CBS_TRANSFER_RECIPIENT_ACCOUNT', 'DTTPCHAR', NULL, '^\d{20}$', 99)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000005, 1, 'CBS_TRANSFER_RECIPIENT_TAX_ID', 'DTTPCHAR', NULL, '^(\d{10}|\d{12})$', 100)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000006, 1, 'CBS_TRANSFER_RECIPIENT_NAME', 'DTTPCHAR', NULL, '^.{1,160}$', 101)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000007, 1, 'CBS_TRANSFER_PAYER_NAME', 'DTTPCHAR', NULL, NULL, 103)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000008, 1, 'CBS_TRANSFER_PAYMENT_PURPOSE', 'DTTPCHAR', NULL, '^.{1,210}$', 18)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000009, 1, 'CBS_TRANSFER_BANK_CORR_ACC', 'DTTPCHAR', NULL, '^\d{20}$', 102)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000012, 1, 'CBS_TRANSFER_BANK_CITY', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000010, 1, 'CBS_CLIENT_ID_TYPE', 'DTTPCHAR', 1016, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000011, 1, 'CBS_CLIENT_ID_VALUE', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000018, 1, 'CBS_TRANSFER_BANK_REG_NUM', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000021, 1, 'CBS_TRANSFER_PAYER_ACCOUNT', 'DTTPCHAR', NULL, '^\d{20}$', 99)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000022, 1, 'CBS_TRANSFER_INVOICE_NUMBER ', 'DTTPCHAR', NULL, NULL, 19)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000023, 1, 'CBS_TRANSFER_INVOICE_DATE', 'DTTPCHAR', NULL, NULL, 20)
/
update pmo_parameter set param_name=trim(param_name) where id=10000022
/
