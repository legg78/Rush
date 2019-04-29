insert into prc_parameter (id, param_name, data_type, lov_id) values (10002340, 'I_ACCOUNT_TYPE', 'DTTPCHAR', 1014)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002709, 'I_MASKING_CARD', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002784, 'I_UNLOAD_LIMITS', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002792, 'I_ARRAY_BALANCE_TYPE_ID', 'DTTPNMBR', 483)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002793, 'I_ARRAY_TRANS_TYPE_ID', 'DTTPNMBR', 484)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002794, 'I_ARRAY_SETTL_TYPE_ID', 'DTTPNMBR', 485)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002800, 'I_ARRAY_ACCOUNT_TYPE_ID', 'DTTPNMBR', 487)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003634, 'I_GL_ACCOUNTS', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003637, 'I_ARRAY_OPERATIONS_TYPE_ID', 'DTTPNMBR', 597)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003700, 'I_USE_MATCHED_DATA', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003733, 'I_ARRAY_LINK_ACCOUNT_NUMBERS', 'DTTPNMBR', 606)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003781, 'I_ARRAY_ACCOUNT_STATUS_ID', 'DTTPCHAR', 1033)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003931, 'I_ARRAY_ACCOUNT_TYPE', 'DTTPNMBR', 629)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004111, 'I_MBR_VERSION', 'DTTPCHAR', 668, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004142, 'I_ARRAY_ACCOUNT_TYPE_CBS', 'DTTPNMBR', 672, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004360, 'I_INCLUDE_DOCUMENT', 'DTTPNMBR', 4, NULL)
/
update prc_parameter set id = 10004367 where id = 10004360
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004531, 'I_INCLUDE_CANCELED_ENTRIES', 'DTTPNMBR', 4, NULL)
/
