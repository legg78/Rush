insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1001, 1, 2001, 'APST0001', 'MbAppWizardNewCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1002, 1, 2001, 'APST0001', 'MbAppWizCustomer', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1003, 1, 2001, 'APST0001', 'MbAppWizAccount', 0, 30)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1004, 1, 2001, 'APST0001', 'MbAppWizMerchant', 0, 40)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1005, 1, 2001, 'APST0001', 'MbAppWizTerminal', 0, 50)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1006, 1, 1001, 'APST0001', 'MbAppWizardNewCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1007, 1, 1001, 'APST0001', 'MbAppWizCustomer', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1008, 1, 1002, 'APST0001', 'MbAppWizardNewCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1009, 1, 1002, 'APST0001', 'MbAppWizCustomer', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1010, 1, 1002, 'APST0001', 'MbAppWizAccount', 0, 30)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1011, 1, 1003, 'APST0001', 'MbAppWizardNewCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1012, 1, 1003, 'APST0001', 'MbAppWizCustomer', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1013, 1, 1003, 'APST0001', 'MbAppWizCard', 0, 30)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1014, 1, 1004, 'APST0001', 'MbAppWizardNewCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1015, 1, 1004, 'APST0001', 'MbAppWizCustomer', 0, 20)
/
update app_flow_step set step_source = 'MbAppWizOldCustomerContract' where id = 1014
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1016, 1, 1003, 'APST0001', 'MbAppWizOldCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1017, 1, 1002, 'APST0001', 'MbAppWizOldCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1018, 1, 1006, 'APST0001', 'MbAppWizOldCustomerContract', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1019, 1, 1006, 'APST0001', 'MbAppWizCustomer', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1020, 1, 1006, 'APST0001', 'MbAppWizCloseService', 0, 30)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1021, 1, 1301, 'APST0001', 'MbAppWizAcmNewUser', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1022, 1, 1302, 'APST0001', 'MbAppWizAcmChangeUser', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1023, 1, 1302, 'APST0001', 'MbAppWizAcmUserInsts', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1024, 1, 1303, 'APST0001', 'MbAppWizAcmChangeStatus', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1025, 1, 1304, 'APST0001', 'MbAppWizAcmSelectUser', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1026, 1, 1304, 'APST0001', 'MbAppWizAcmUserRoles', 0, 20)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1028, 1, 1501, 'APST0001', 'MbAppWizDspNew', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1029, 1, 1502, 'APST0014', 'MbAppWizDspNew', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1030, 1, 1503, 'APST0014', 'MbAppWizDspNew', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1031, 1, 1504, 'APST0014', 'MbAppWizDspNew', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1032, 1, 1505, 'APST0014', 'MbAppWizDspNew', 0, 10)
/
insert into app_flow_step (id, seqnum, flow_id, appl_status, step_source, read_only, display_order) values (1033, 1, 1506, 'APST0014', 'MbAppWizDspNew', 0, 10)
/
