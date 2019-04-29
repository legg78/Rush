insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2345, 2328, NULL, 'interchange|visa_fees', 'page', 1, 41, 'MbInterchangeFee')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2346, 2328, NULL, 'interchange|visa_operations', 'page', 1, 42, 'MbInterchangeOperation')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2347, 2328, NULL, 'visa|process_log', 'page', 1, 43, 'MbModuleSessionLog')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2348, 2328, NULL, 'visa|params', 'page', 1, 44, 'MbModuleParam')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2355, 2328, NULL, 'aggregation|visa', 'page', 1, 45, 'MbIntAggregation')
/
update acm_section set display_order=43 where id=2346
/
update acm_section set display_order=44 where id=2347
/
update acm_section set display_order=45 where id=2348
/
update acm_section set display_order=46 where id=2355
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2367, 2328, NULL, 'interchange|visa_fee_criterias', 'page', 1, 42, 'MbInterchangeCriteria')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2371, 2328, NULL, 'visa|vssreports', 'page', 1, 50, 'MbVisaVssReports')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2374, 2328, NULL, 'visa|rejects', 'page', 1, 46, 'MbReject')
/
update acm_section set display_order=46 where id=2355
/
update acm_section set display_order=47 where id=2374
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2378, 2328, NULL, 'visa|country_regions', 'page', 1, 45, 'MbModuleParam')
/
update acm_section set is_visible=0 where id=2345
/
update acm_section set is_visible=0 where id=2346
/
update acm_section set is_visible=0 where id=2367
/
delete from acm_section where id = 2348
/
delete from acm_section where id = 2378
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2424, 2328, 'VIS', 'visa|fin_status_advice', 'page', 1, 55, 'MbVisaFinStatusAdviceSearch')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2435, 2328, 'VIS', 'visa|smsreports', 'page', 1, 52, 'MbVisaSmsReports')
/
delete from acm_section where id = 2435
/
