insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000829, 1, -50000053, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 30, 1, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000828, 1, -50000053, 'I_END_DATE', 'DTTPDATE', NULL, 0, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000827, 1, -50000053, 'I_START_DATE', 'DTTPDATE', NULL, 0, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000826, 1, -50000053, 'I_ACCOUNT_NUMBER', 'DTTPCHAR', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000941, 1, -50000067, 'I_ENTITY_TYPE', 'DTTPCHAR', NULL, 0, 50, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000940, 1, -50000067, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000936, 1, -50000067, 'I_LANG', 'DTTPCHAR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000935, 1, -50000067, 'I_EFF_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000934, 1, -50000067, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000933, 1, -50000066, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 50, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000932, 1, -50000066, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000931, 1, -50000066, 'I_ENTITY_TYPE', 'DTTPCHAR', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000930, 1, -50000066, 'I_EFF_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000929, 1, -50000066, 'I_EVENT_TYPE', 'DTTPCHAR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
delete from rpt_parameter where id = -50000936
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001151, 1, -50000268, 'I_END_DATE', 'DTTPDATE', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001150, 1, -50000268, 'I_START_DATE', 'DTTPDATE', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001149, 1, -50000268, 'I_CUSTOMER_ID', 'DTTPNMBR', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001148, 1, -50000268, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
update rpt_parameter set display_order = 40 where id = -50000826
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001152, 1, -50000269, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001154, 1, -50000270, 'I_ACCOUNT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000922, 1, -50000063, 'I_SRC_SYSTEM', 'DTTPNMBR', NULL, 0, 50, -5019, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000921, 1, -50000063, 'I_TRAN_STATUS', 'DTTPNMBR', NULL, 0, 40, -5020, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000920, 1, -50000063, 'I_CARD_NUMBER', 'DTTPCHAR', NULL, 0, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000919, 1, -50000063, 'I_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50000918, 1, -50000063, 'I_INST_ID', 'DTTPNMBR', '000000000000001001.0000', 0, 10, 1, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001175, 1, -50000271, 'I_YEAR', 'DTTPNMBR', '000000000000002018.0000', 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001174, 1, -50000271, 'I_MONTH', 'DTTPNMBR', '000000000000000001.0000', 1, 20, -5021, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001173, 1, -50000271, 'I_INST_ID', 'DTTPNMBR', '000000000000001001.0000', 0, 10, 1, NULL, NULL, NULL, NULL)
/
delete from rpt_parameter where id = -50001148
/
delete from rpt_parameter where id = -50001149
/
delete from rpt_parameter where id = -50001150
/
delete from rpt_parameter where id = -50001151
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001247, 1, -50000280, 'I_INVOICE_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (-50001248, 1, -50000281, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
