insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order) values (10000542, 1, 10000010, 'I_INVOICE_ID', 'DTTPNMBR', NULL, 1, 10)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002278, 3, 10000130, 'I_ACCOUNT_NUMBER', 'DTTPCHAR', NULL, 1, 10, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002279, 3, 10000130, 'I_SETTL_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10002809, 1, 10000135, 'I_EVENT_TYPE', 'DTTPCHAR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10002810, 1, 10000135, 'I_EFF_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10002811, 1, 10000135, 'I_ENTITY_TYPE', 'DTTPCHAR', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10002812, 1, 10000135, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10002813, 1, 10000135, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 50, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10002815, 1, 10000136, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10003396, 1, 10000184, 'I_INVOICE_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
update rpt_parameter set lov_id = 1017 where id = 10002811
/
update rpt_parameter set lov_id = 1018, is_mandatory = 0 where id = 10002809
/
update rpt_parameter set lov_id = 1, is_mandatory = 0 where id = 10002813 
/
update rpt_parameter set is_mandatory = 0 where id = 10002810 
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004305, 1, 10000247, 'I_EFF_DATE', 'DTTPDATE', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004306, 1, 10000247, 'I_ENTITY_TYPE', 'DTTPCHAR', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004307, 1, 10000247, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004308, 1, 10000247, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004443, 1, 10000010, 'I_MODE', 'DTTPCHAR', NULL, 0, 10, 719, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004446, 1, 10000254, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004447, 1, 10000255, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004448, 1, 10000256, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
