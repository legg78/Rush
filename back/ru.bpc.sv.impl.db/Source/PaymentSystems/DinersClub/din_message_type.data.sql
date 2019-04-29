insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XD', NULL, NULL, NULL, 'DCMCDMSG', 'Charge detail message')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XA', NULL, 10, '1', 'DCMCADND', 'Airline additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XB', 'XA', 20, '0', 'DCMCADND', 'Airline routing detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XC', NULL, 30, '1', 'DCMCADND', 'ATM additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XV', NULL, 40, '1', 'DCMCADND', 'Car rental additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XG', NULL, 50, '1', 'DCMCADND', 'Gasoline additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XH', NULL, 60, '1', 'DCMCADND', 'Hotel additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XR', NULL, 70, '0', 'DCMCADND', 'Rail additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XL', 'XR', 80, '0', 'DCMCADND', 'Rail routing detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XE', NULL, 90, '1', 'DCMCADND', 'Restaurant additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XT', NULL, 100, '1', 'DCMCADND', 'Telephone additional detail record')
/
insert into din_message_type (function_code, parent_function_code, priority, is_unique, message_category, description) values ('XM', NULL, 110, '1', 'DCMCADND', 'Chip card additional detail record')
/
