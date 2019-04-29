insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10003940, 1, 10000226, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 10, 1, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10003941, 1, 10000226, 'I_START_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10003942, 1, 10000226, 'I_END_DATE', 'DTTPDATE', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10003943, 1, 10000226, 'I_USER_ID', 'DTTPNMBR', NULL, 0, 40, 486, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004202, 1, 10000241, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004203, 1, 10000241, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004204, 1, 10000241, 'I_YEAR', 'DTTPNMBR', NULL, 1, 30, 1055, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004205, 1, 10000241, 'I_QUARTER', 'DTTPNMBR', NULL, 1, 40, 1056, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004198, 1, 10000240, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 10, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004199, 1, 10000240, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004200, 1, 10000240, 'I_YEAR', 'DTTPNMBR', NULL, 1, 30, 1055, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004201, 1, 10000240, 'I_QUARTER', 'DTTPNMBR', NULL, 1, 40, 1056, NULL, NULL, NULL, NULL)
/

delete from rpt_parameter where id in (10004204, 10004205, 10004200, 10004201)
/
insert into rpt_parameter(id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004200, 1, 10000240, 'I_DATE_START', 'DTTPDATE', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter(id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004201, 1, 10000240, 'I_DATE_END', 'DTTPDATE', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter(id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004204, 1, 10000241, 'I_DATE_START', 'DTTPDATE', NULL, 1, 30, NULL, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter(id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting, selection_form) values (10004205, 1, 10000241, 'I_DATE_END', 'DTTPDATE', NULL, 1, 40, NULL, NULL, NULL, NULL, NULL)
/
update rpt_parameter set lov_id = 1 where id in (10004198, 10004202)
/
update rpt_parameter set lov_id = 2 where id in (10004199, 10004203)
/
