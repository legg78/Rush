insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) Values (10001180, 1, 10000019, 'I_INST_ID', 'DTTPNMBR', NULL, 0, 10, 298)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) Values (10001181, 1, 10000019, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, 299)
/

insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001214, 1, 10000020, 'I_INST_ID', 'DTTPNMBR', NULL, 0, 10, 298)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001215, 1, 10000020, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, 299)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001216, 1, 10000020, 'I_DATE_START', 'DTTPDATE', NULL, 1, 30, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001217, 1, 10000020, 'I_DATE_END', 'DTTPDATE', NULL, 1, 40, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001218, 1, 10000020, 'I_PLACEMENT_TYPE', 'DTTPCHAR', NULL, 0, 50, 289)
/

insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001212, 1, 10000021, 'I_INST_ID', 'DTTPNMBR', NULL, 0, 10, 298)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001213, 1, 10000021, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, 299)
/

insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001221, 1, 10000022, 'I_INST_ID', 'DTTPNMBR', NULL, 0, 10, 298)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10001222, 1, 10000022, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, 299)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10002218, 1, 10000129, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 10, 1)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10002219, 1, 10000129, 'I_AGENT_ID', 'DTTPNMBR', NULL, 0, 20, 2)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10002220, 1, 10000129, 'I_START_DATE', 'DTTPDATE', NULL, 0, 30, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id) values (10002221, 1, 10000129, 'I_END_DATE', 'DTTPDATE', NULL, 0, 40, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002726, 1, 10000132, 'I_EVENT_TYPE', 'DTTPCHAR', NULL, 1, 10, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002727, 1, 10000132, 'I_EFF_DATE', 'DTTPDATE', NULL, 1, 20, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002728, 1, 10000132, 'I_ENTITY_TYPE', 'DTTPCHAR', NULL, 1, 30, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002729, 1, 10000132, 'I_OBJECT_ID', 'DTTPNMBR', NULL, 1, 40, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002730, 1, 10000132, 'I_INST_ID', 'DTTPNMBR', NULL, 1, 50, NULL, NULL, NULL, NULL)
/
insert into rpt_parameter (id, seqnum, report_id, param_name, data_type, default_value, is_mandatory, display_order, lov_id, direction, is_grouping, is_sorting) values (10002731, 1, 10000132, 'I_NOTIFY_PARTY_TYPE', 'DTTPCHAR', NULL, 0, 60, NULL, NULL, NULL, NULL)
/
delete from rpt_parameter where id = 10001212
/
delete from rpt_parameter where id = 10001213
/
delete from rpt_parameter where id = 10001221
/
delete from rpt_parameter where id = 10001222
/
delete from rpt_parameter where id = 10002218
/
delete from rpt_parameter where id = 10002219
/
delete from rpt_parameter where id = 10002220
/
delete from rpt_parameter where id = 10002221
/
