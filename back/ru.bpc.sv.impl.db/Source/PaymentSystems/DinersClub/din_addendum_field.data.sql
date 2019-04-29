insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XC', 'SCGMT', 8, 'N', 6, 'Acquirer Time (HHMMSS)', NULL)
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XC', 'SCDAT', 9, 'N', 6, 'Acquirer Date (YYMMDD)', NULL)
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XC', 'LCTIM', 10, 'N', 6, 'Local Terminal Time (HHMMSS)', NULL)
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XC', 'LCDAT', 11, 'N', 6, 'Local Terminal Date (YYMMDD)', NULL)
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XC', 'ATMID', 12, 'N', 8, 'ATM ID Number', NULL)
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CPANSQN', 8, 'N', 3, 'Application PAN Sequence Number', '5F34')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CAIDT', 9, 'HEX', 32, 'Application Identifier Terminal', '9F06')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CAIPFL', 10, 'HEX', 4, 'Application Interchange Profile', '82')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CATCTR', 11, 'HEX', 4, 'Application Transaction Counter', '9F36')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CACRG', 12, 'HEX', 16, 'Application Cryptogram (TC/AAC)', '9F26')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CAUCN', 13, 'HEX', 4, 'Application Usage Control', '8A')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CAMTA', 14, 'N', 12, 'Amount Authorized', '9F02')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CAMTO', 15, 'N', 12, 'Amount Other', '9F03')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CCRIF', 16, 'HEX', 2, 'Cryptogram Information Data', '9F27')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CCVMR', 17, 'HEX', 6, 'CVM Results', '9F34')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CDEDF', 18, 'HEX', 32, 'Dedicated File Name', '84')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CIDSN', 19, 'AN', 8, 'Interface Device Serial Number', '9F1E')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CADA1', 20, 'HEX', 64, 'Issuer Application Data', '9F10')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CADAT', 21, 'HEX', 32, 'Issuer Authentication Data', '91')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CISRT', 22, 'HEX', 50, 'Issuer Script Results', '71/72')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRMG', 23, 'N', 3, 'Terminal Country Code', '9F1A')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTAVN', 24, 'HEX', 4, 'Terminal Application Version Number', '9F09')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRMC', 25, 'HEX', 6, 'Terminal Capabilities', '9F33')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRMT', 26, 'N', 2, 'Terminal Type', '9F35')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRMR', 27, 'HEX', 10, 'Terminal Verification Results', '95')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRND', 28, 'CHAR', 6, 'Transaction Date', '9A')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRNT', 29, 'N', 2, 'Transaction Type', '9C')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CTRNC', 30, 'N', 3, 'Transaction Currency Code', '5F2A')
/
insert into din_addendum_field (function_code, field_name, field_number, format, field_length, description, emv_tag) values ('XM', 'CUNPN', 31, 'HEX', 8, 'Unpredictable Number', '9F37')
/
update din_addendum_field set emv_tag = '72' where function_code = 'XM' and field_name = 'CISRT'
/
update din_addendum_field set format = 'N' where function_code = 'XM' and field_name = 'CTRND'
/
update din_addendum_field set default_value = '001' where function_code = 'XM' and field_name = 'CPANSQN'
/
