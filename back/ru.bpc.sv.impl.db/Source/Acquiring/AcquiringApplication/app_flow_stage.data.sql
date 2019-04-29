insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (1, 1, 1, 'APST0001')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (2, 1, 1, 'APST0002')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (3, 1, 1, 'APST0006')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (4, 1, 1, 'APST0008')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (21, 1, 6, 'APST0001')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (22, 1, 6, 'APST0002')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (23, 1, 6, 'APST0006')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (24, 1, 6, 'APST0008')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (25, 1, 7, 'APST0001')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (26, 1, 7, 'APST0002')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (27, 1, 7, 'APST0006')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (28, 1, 7, 'APST0008')
/
------- 10 - Merchant Closure
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (10000001, 1, 10, 'APST0001')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (10000002, 1, 10, 'APST0002')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (10000003, 1, 10, 'APST0006')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status) values (10000004, 1, 10, 'APST0008')
/
delete from app_flow_stage where id in (10000001, 10000002, 10000003, 10000004)
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000114, 1, 2017, 'APST0001', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000115, 1, 2017, 'APST0002', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000116, 1, 2017, 'APST0006', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000117, 1, 2017, 'APST0007', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000118, 1, 2017, 'APST0008', NULL, 'HLTP0010')
/
update app_flow_stage set flow_id = 2010 where flow_id = 6
/
update app_flow_stage set flow_id = 2011 where flow_id = 7
/
update app_flow_stage set flow_id = 2012 where flow_id = 2017
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000120, 1, 2013, 'APST0001', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000121, 1, 2013, 'APST0002', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000122, 1, 2013, 'APST0006', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000123, 1, 2013, 'APST0008', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000124, 1, 2014, 'APST0001', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000125, 1, 2014, 'APST0002', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000126, 1, 2014, 'APST0006', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000127, 1, 2014, 'APST0008', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000128, 1, 2015, 'APST0001', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000129, 1, 2015, 'APST0002', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000130, 1, 2015, 'APST0006', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000131, 1, 2015, 'APST0008', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000133, 1, 2010, 'APST0007', NULL, 'HLTP0010')
/
update app_flow_stage set handler_type = 'HLTP0010' where id in (21, 22, 23, 24)
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000181, 1, 2016, 'APST0001', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000182, 1, 2016, 'APST0002', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000183, 1, 2016, 'APST0006', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000184, 1, 2016, 'APST0007', NULL, 'HLTP0010')
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type) values (10000185, 1, 2016, 'APST0008', NULL, 'HLTP0010')
/
-- 2018 Change acquiring account status
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type, reject_code, role_id) values (10000271, 1, 2018, 'APST0001', NULL, 'HLTP0010', NULL, NULL)
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type, reject_code, role_id) values (10000272, 1, 2018, 'APST0002', NULL, 'HLTP0010', NULL, NULL)
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type, reject_code, role_id) values (10000273, 1, 2018, 'APST0006', NULL, 'HLTP0010', NULL, NULL)
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type, reject_code, role_id) values (10000274, 1, 2018, 'APST0007', NULL, 'HLTP0010', NULL, NULL)
/
insert into app_flow_stage (id, seqnum, flow_id, appl_status, handler, handler_type, reject_code, role_id) values (10000275, 1, 2018, 'APST0008', NULL, 'HLTP0010', NULL, NULL)
/
update app_flow_stage set handler = 'ru.bpc.sv.ws.application.handlers.AppStageHandlerProcess', handler_type = 'HLTP0020' where id = 10000273
/
