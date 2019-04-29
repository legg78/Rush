insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TRANS', 0, NULL, 4, 1, NULL, NULL, 'Transaction Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'FUNCD', 1, NULL, 2, 1, NULL, NULL, 'Function code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'SFTER', 2, NULL, 2, 1, NULL, NULL, 'Sending Institution Identification Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'RCPNO', 3, NULL, 3, 1, NULL, NULL, 'Recap Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'DFTER', 4, NULL, 2, 1, NULL, NULL, 'Receiving Institution Identification Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'BATCH', 5, NULL, 3, 1, NULL, NULL, 'Batch Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'SEQNO', 6, NULL, 3, 1, NULL, NULL, 'Sequence within the batch')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ACCT', 7, NULL, 19, 1, NULL, NULL, 'Card Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CAMTR', 8, NULL, 16, 1, NULL, NULL, 'Charge Amount. In currency of charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CHGDT', 9, NULL, 6, 1, NULL, NULL, 'Charge date YYMMDD')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'DATYP', 10, NULL, 2, 1, NULL, NULL, 'Date Type')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CHTYP', 11, NULL, 3, 1, NULL, NULL, 'Charge Type (DXS format)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ESTAB', 12, NULL, 36, 1, NULL, NULL, 'Member Establishment Name')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'LCITY', 13, NULL, 26, 1, NULL, NULL, 'Member Establishment City')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'GEOCD', 14, NULL, 3, 1, NULL, NULL, 'Geographic Area Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'APPCD', 15, NULL, 3, 0, NULL, NULL, 'Action Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TYPCH', 16, NULL, 2, 1, NULL, NULL, 'Type of Charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'REFNO', 17, NULL, 8, 1, NULL, NULL, 'Reference Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ANBR', 18, NULL, 6, 0, NULL, NULL, 'Authorization Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'SENUM', 19, NULL, 15, 1, NULL, NULL, 'Member Establishment Number')
/
delete din_message_field where function_code = 'XD' and field_name = 'BLCUR'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'BLCUR', 20, NULL, 3, 0, NULL, NULL, 'Issuer-designated Billing Currency Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'BLAMT', 21, NULL, 16, 0, NULL, NULL, 'Charge Amount (CAMTR)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'INTES', 22, NULL, 4, 0, NULL, NULL, 'International Establishment Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ESTST', 23, NULL, 35, 1, NULL, NULL, 'Establishment Street Address')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ESTCO', 24, NULL, 20, 0, NULL, NULL, 'Establishment State/County/Province')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ESTZP', 25, NULL, 11, 0, NULL, NULL, 'Establishment Zip Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ESTPN', 26, NULL, 20, 0, NULL, NULL, 'Establishment Phone Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'MSCCD', 27, NULL, 4, 0, NULL, NULL, 'Merchant Specific Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'MCCCD', 28, NULL, 4, 1, NULL, NULL, 'Merchant Classification Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TAX1', 29, NULL, 15, 0, NULL, NULL, 'Tax 1 Amount (in Currency of charge)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TAX2', 30, NULL, 15, 0, NULL, NULL, 'Tax 2 Amount (in Currency of charge)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ORIGD', 31, NULL, 15, 0, NULL, NULL, 'Original Ticket or Document Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CUSRF1', 32, NULL, 30, 0, NULL, NULL, 'Customer Reference Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CUSRF2', 33, NULL, 30, 0, NULL, NULL, 'Customer Reference Number2')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CUSRF3', 34, NULL, 30, 0, NULL, NULL, 'Customer Reference Number3')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CUSRF4', 35, NULL, 30, 0, NULL, NULL, 'Customer Reference Number4')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CUSRF5', 36, NULL, 30, 0, NULL, NULL, 'Customer Reference Number5')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CUSRF6', 37, NULL, 30, 0, NULL, NULL, 'Customer Reference Number6')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CHOLDP', 38, NULL, 1, 0, NULL, NULL, 'Card Holder Present Indicator obtained in Xpress Authorization')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CARDP', 39, NULL, 1, 0, NULL, NULL, 'Card Present Indicator')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CPTRM', 40, NULL, 1, 0, NULL, NULL, 'Card Input Data Method')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'ECI', 41, NULL, 1, 0, NULL, NULL, 'Electronic Commerce and Payments Indicator')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CAVV', 42, NULL, 4, 0, NULL, NULL, 'CAVV value')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'NRID', 43, NULL, 15, 0, NULL, NULL, 'Network Reference ID (NRID)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'CRDINP', 44, NULL, 1, 0, NULL, NULL, 'Card Data Input Capability indicator')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'SURFEE', 45, NULL, 8, 0, NULL, NULL, 'Surcharge Fee')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XC', 'SCGMT', 8, 'N', 6, 'Acquirer Time (HHMMSS)', NULL, 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XC', 'SCDAT', 9, 'N', 6, 'Acquirer Date (YYMMDD)', NULL, 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XC', 'LCTIM', 10, 'N', 6, 'Local Terminal Time (HHMMSS)', NULL, 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XC', 'LCDAT', 11, 'N', 6, 'Local Terminal Date (YYMMDD)', NULL, 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XC', 'ATMID', 12, 'N', 8, 'ATM ID Number', NULL, 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CPANSQN', 8, 'N', 3, 'Application PAN Sequence Number', '5F34', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CAIDT', 9, 'HEX', 32, 'Application Identifier Terminal', '9F06', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CAIPFL', 10, 'HEX', 4, 'Application Interchange Profile', '82', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CATCTR', 11, 'HEX', 4, 'Application Transaction Counter', '9F36', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CACRG', 12, 'HEX', 16, 'Application Cryptogram (TC/AAC)', '9F26', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CAUCN', 13, 'HEX', 4, 'Application Usage Control', '8A', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CAMTA', 14, 'N', 12, 'Amount Authorized', '9F02', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CAMTO', 15, 'N', 12, 'Amount Other', '9F03', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CCRIF', 16, 'HEX', 2, 'Cryptogram Information Data', '9F27', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CCVMR', 17, 'HEX', 6, 'CVM Results', '9F34', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CDEDF', 18, 'HEX', 32, 'Dedicated File Name', '84', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CIDSN', 19, 'AN', 8, 'Interface Device Serial Number', '9F1E', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CADA1', 20, 'HEX', 64, 'Issuer Application Data', '9F10', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CADAT', 21, 'HEX', 32, 'Issuer Authentication Data', '91', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CISRT', 22, 'HEX', 50, 'Issuer Script Results', '71/72', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRMG', 23, 'N', 3, 'Terminal Country Code', '9F1A', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTAVN', 24, 'HEX', 4, 'Terminal Application Version Number', '9F09', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRMC', 25, 'HEX', 6, 'Terminal Capabilities', '9F33', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRMT', 26, 'N', 2, 'Terminal Type', '9F35', 0)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRMR', 27, 'HEX', 10, 'Terminal Verification Results', '95', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRND', 28, 'CHAR', 6, 'Transaction Date', '9A', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRNT', 29, 'N', 2, 'Transaction Type', '9C', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CTRNC', 30, 'N', 3, 'Transaction Currency Code', '5F2A', 1)
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, description, emv_tag, is_mandatory) values ('XM', 'CUNPN', 31, 'HEX', 8, 'Unpredictable Number', '9F37', 0)
/
update din_message_field set emv_tag = '72' where function_code = 'XM' and field_name = 'CISRT'
/
update din_message_field set format = 'N' where function_code = 'XM' and field_name = 'CTRND'
/
update din_message_field set default_value = '001' where function_code = 'XM' and field_name = 'CPANSQN'
/
delete din_message_field where function_code = 'XA' and field_name = 'AIRCD'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AIRCD', 8, NULL, 3, 0, NULL, NULL, 'Ticket-issuing airline Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AIRRF', 9, NULL, 20, 0, NULL, NULL, 'Booking Reference Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGAFE', 10, NULL, 12, 0, NULL, NULL, 'Agent Fees')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGARF', 11, NULL, 20, 0, NULL, NULL, 'Agent Fee Reference')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGADS', 12, NULL, 32, 0, NULL, NULL, 'Agent Fee Description')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'IATCD', 13, NULL, 8, 0, NULL, NULL, 'IATA Agent code (includes check digit)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'IATNM', 14, NULL, 32, 0, NULL, NULL, 'IATA Agent Trading name')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGAD1', 15, NULL, 32, 0, NULL, NULL, 'Agent Address Line 1')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGAD2', 16, NULL, 32, 0, NULL, NULL, 'Agent Address Line 2')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGAD3', 17, NULL, 32, 0, NULL, NULL, 'Agent Address Line 3')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGCTY', 18, NULL, 30, 0, NULL, NULL, 'Agent City')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGSTA', 19, NULL, 30, 0, NULL, NULL, 'Agent State/County')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGZIP', 20, NULL, 10, 0, NULL, NULL, 'Agent Zip Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'AGGCD', 21, NULL, 3, 0, NULL, NULL, 'Agent Geographic Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'PNODC', 22, NULL, 6, 0, NULL, NULL, 'Agent International dialing code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'PNOAC', 23, NULL, 6, 0, NULL, NULL, 'Agent Area Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'PNONO', 24, NULL, 12, 0, NULL, NULL, 'Agent Telephone Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XA', 'RESSY', 25, NULL, 4, 0, NULL, NULL, 'Computerized Reservation System')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'TICNO', 8, NULL, 10, 0, NULL, NULL, 'Sequential part of the Ticket number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'TICCD', 9, NULL, 1, 0, NULL, NULL, 'Ticket Check Digit')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'PASNG', 10, NULL, 49, 0, NULL, NULL, 'Passenger Name')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'CARR1', 11, NULL, 4, 0, NULL, NULL, 'First leg Carrier code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'FLNO1', 12, NULL, 4, 0, NULL, NULL, 'First leg Numeric Flight Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'DAPC1', 13, NULL, 6, 0, NULL, NULL, 'First leg Departure Airport Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'DDTE1', 14, NULL, 6, 0, NULL, NULL, 'First leg Departure Date')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'DTIM1', 15, NULL, 4, 0, NULL, NULL, 'First leg Departure Time (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'AAPC1', 16, NULL, 6, 0, NULL, NULL, 'First leg Arrival Airport Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'ADTE1', 17, NULL, 6, 0, NULL, NULL, 'First leg Arrival date (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'ATIM1', 18, NULL, 4, 0, NULL, NULL, 'First leg Arrival time (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'FAMT1', 19, NULL, 15, 0, NULL, NULL, 'First leg Fare Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'BASI1', 20, NULL, 15, 0, NULL, NULL, 'First leg Fare Basis')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'CLAS1', 21, NULL, 1, 0, NULL, NULL, 'First leg Class of Travel')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XB', 'STOA1', 22, NULL, 1, 0, NULL, NULL, 'First leg Stop over allowed ')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RENNO', 8, NULL, 10, 0, NULL, NULL, 'Rental Agreement Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RENNM', 9, NULL, 49, 0, NULL, NULL, 'Renter Name')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RENCY', 10, NULL, 26, 0, NULL, NULL, 'Car Pickup City')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RENST', 11, NULL, 20, 0, NULL, NULL, 'Car Pickup State or County or Province')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RENCO', 12, NULL, 3, 0, NULL, NULL, 'Car Pick-up Country')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RENDT', 13, NULL, 6, 0, NULL, NULL, 'Car Pickup Date (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'REMTM', 14, NULL, 4, 0, NULL, NULL, 'Car Pickup time (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RETCY', 15, NULL, 26, 0, NULL, NULL, 'City of car return')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RETST', 16, NULL, 20, 0, NULL, NULL, 'State, County or Province of Return')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RETCO', 17, NULL, 3, 0, NULL, NULL, 'Country of Return')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RETDT', 18, NULL, 6, 0, NULL, NULL, 'Date of Return (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RETTM', 19, NULL, 4, 0, NULL, NULL, 'Time of Return (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RCCAR', 20, NULL, 4, 0, NULL, NULL, 'Class of car')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RWRTE', 21, NULL, 15, 0, NULL, NULL, 'Weekly Rental Rate')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RDRTE', 22, NULL, 15, 0, NULL, NULL, 'Daily Rental Rate')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RMRTE', 23, NULL, 15, 0, NULL, NULL, 'Rate per mile/km')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RDIST', 24, NULL, 5, 0, NULL, NULL, 'Total Rental distance (i.e., miles driven)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RFREM', 25, NULL, 5, 0, NULL, NULL, 'Free mile/km')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RINSC', 26, NULL, 15, 0, NULL, NULL, 'Insurance Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RFUEC', 27, NULL, 15, 0, NULL, NULL, 'Fuel Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RMORK', 28, NULL, 1, 0, NULL, NULL, 'Miles or Kilometres (K or M)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'ROWDC', 29, NULL, 15, 0, NULL, NULL, 'One way drop charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RAUTC', 30, NULL, 15, 0, NULL, NULL, 'Auto towing charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RRMIC', 31, NULL, 15, 0, NULL, NULL, 'Regular mileage charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'REMIC', 32, NULL, 15, 0, NULL, NULL, 'Extra mileage charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RLRTC', 33, NULL, 15, 0, NULL, NULL, 'Late return charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RTELC', 34, NULL, 15, 0, NULL, NULL, 'Telephone charge')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'ROTHC', 35, NULL, 15, 0, NULL, NULL, 'Other charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XV', 'RNOSH', 36, NULL, 1, 0, NULL, NULL, 'No show charges flag')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GVLPN', 8, NULL, 15, 0, NULL, NULL, 'Vehicle/License Plate Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GVID', 9, NULL, 20, 0, NULL, NULL, 'Vehicle ID')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GODOR', 10, NULL, 7, 0, NULL, NULL, 'Odometer Reading')
/
delete din_message_field where function_code = 'XG' and field_name = 'GODUN'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GODUN', 11, NULL, 1, 0, NULL, NULL, 'Odometer Unit (M-Miles, K-Kilometers)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GDRID', 12, NULL, 20, 0, NULL, NULL, 'Driver ID Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GFUUP', 13, NULL, 7, 0, NULL, NULL, 'Fuel Units Dispensed')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GFUPU', 14, NULL, 15, 0, NULL, NULL, 'Fuel Price per Unit')
/
delete din_message_field where function_code = 'XG' and field_name = 'GFUUN'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GFUUN', 15, NULL, 1, 0, NULL, NULL, 'Fuel Unit (G-Gallons, L-Liters)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GFUPD', 16, NULL, 15, 0, NULL, NULL, 'Fuel Product Type')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GFUAM', 17, NULL, 15, 0, NULL, NULL, 'Total Fuel Amount')
/
delete din_message_field where function_code = 'XG' and field_name = 'GOIUP'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GOIUP', 18, NULL, 7, 0, NULL, NULL, 'Oil-Number of Units')
/
delete din_message_field where function_code = 'XG' and field_name = 'GOIUN'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GOIUN', 19, NULL, 1, 0, NULL, NULL, 'Oil Units (P-Pints, G-Gallons, L-Liters)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GOIAM', 20, NULL, 15, 0, NULL, NULL, 'Total Oil Purchase Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GMEPT', 21, NULL, 15, 0, NULL, NULL, 'Merchandise Product Type')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GMEAM', 22, NULL, 15, 0, NULL, NULL, 'Other Merchandise Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GCONO', 23, NULL, 15, 0, NULL, NULL, 'Contract Number')
/
delete din_message_field where function_code = 'XG' and field_name = 'GFLEE'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XG', 'GFLEE', 24, NULL, 1, 0, NULL, NULL, 'Fleet Transaction (Y-Yes, N-No)')
/
delete din_message_field where function_code = 'XH' and field_name = 'HCIDT'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HCIDT', 8, NULL, 6, 0, NULL, NULL, 'Date of Check-in (YYMMDD)')
/
delete din_message_field where function_code = 'XH' and field_name = 'HCODT'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HCODT', 9, NULL, 6, 0, NULL, NULL, 'Date of Check-out (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HNOPT', 10, NULL, 3, 0, NULL, NULL, 'Number in party')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HNAME', 11, NULL, 49, 0, NULL, NULL, 'Guest Name')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HRMTY', 12, NULL, 4, 0, NULL, NULL, 'Room type')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HPROG', 13, NULL, 2, 0, NULL, NULL, 'Program Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HFOLI', 14, NULL, 10, 0, NULL, NULL, 'Folio Reference Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HCRES', 15, NULL, 1, 0, NULL, NULL, 'Confirmed Reservation Indicator')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HRMRT', 16, NULL, 15, 0, NULL, NULL, 'Daily Room Rate')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HRMTX', 17, NULL, 15, 0, NULL, NULL, 'Room Tax')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HNRTX', 18, NULL, 15, 0, NULL, NULL, 'Non-Room Tax')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HPHAM', 19, NULL, 15, 0, NULL, NULL, 'Phone charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HRSAM', 20, NULL, 15, 0, NULL, NULL, 'Room service charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HMBAM', 21, NULL, 15, 0, NULL, NULL, 'Mini bar charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HRBAM', 22, NULL, 15, 0, NULL, NULL, 'Bar charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HGSAM', 23, NULL, 15, 0, NULL, NULL, 'Gift shop charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HLAAM', 24, NULL, 15, 0, NULL, NULL, 'Laundry/dry cleaning charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HPPAM', 25, NULL, 15, 0, NULL, NULL, 'Prepaid expenses')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HREAM', 26, NULL, 15, 0, NULL, NULL, 'Restaurant charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HCAAM', 27, NULL, 15, 0, NULL, NULL, 'Cash advances')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HPKAM', 28, NULL, 15, 0, NULL, NULL, 'Parking/Valet/Transportation charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HHCAM', 29, NULL, 15, 0, NULL, NULL, 'Health club charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HBCAM', 30, NULL, 15, 0, NULL, NULL, 'Business Center charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HMVAM', 31, NULL, 15, 0, NULL, NULL, 'Movie charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HOTAM', 32, NULL, 15, 0, NULL, NULL, 'Other service charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HTIPS', 33, NULL, 15, 0, NULL, NULL, 'Gratuities')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HCONF', 34, NULL, 15, 0, NULL, NULL, 'Conference Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HAUDI', 35, NULL, 15, 0, NULL, NULL, 'Audio Visual Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HBANQ', 36, NULL, 15, 0, NULL, NULL, 'Banquet Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HINTE', 37, NULL, 15, 0, NULL, NULL, 'Internet Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HDEPA', 38, NULL, 15, 0, NULL, NULL, 'Early Arrival or Departure Charges')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HBAIN', 39, NULL, 1, 0, NULL, NULL, 'Billing Adjustment')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XH', 'HBAAM', 40, NULL, 15, 0, NULL, NULL, 'Billing Adjustment amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'RISTK', 8, NULL, 3, 0, NULL, NULL, 'Railway that issued the ticket')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'TICNO', 9, NULL, 10, 0, NULL, NULL, 'Ticket Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'TICCD', 10, NULL, 1, 0, NULL, NULL, 'Ticket Check Digit')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'RAGCD', 11, NULL, 8, 0, NULL, NULL, 'Agent Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'RAGNM', 12, NULL, 32, 0, NULL, NULL, 'Agent Name')
/
delete din_message_field where function_code = 'XR' and field_name = 'AGAD1'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGAD1', 13, NULL, 32, 0, NULL, NULL, 'Agent Address-line 1')
/
delete din_message_field where function_code = 'XR' and field_name = 'AGAD2'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGAD2', 14, NULL, 32, 0, NULL, NULL, 'Agent Address-line 2')
/
delete din_message_field where function_code = 'XR' and field_name = 'AGAD3'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGAD3', 15, NULL, 32, 0, NULL, NULL, 'Agent Address-line 3')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGCTY', 16, NULL, 30, 0, NULL, NULL, 'Agent City')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGSTA', 17, NULL, 30, 0, NULL, NULL, 'Agent State/County')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGZIP', 18, NULL, 10, 0, NULL, NULL, 'Agent Zip Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'AGGCD', 19, NULL, 3, 0, NULL, NULL, 'Agent Geographic Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'PNODC', 20, NULL, 6, 0, NULL, NULL, 'Agent International Dialing Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'PNOAC', 21, NULL, 6, 0, NULL, NULL, 'Agent Area Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'PNONO', 22, NULL, 12, 0, NULL, NULL, 'Agent Telephone Number')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'RRESY', 23, NULL, 4, 0, NULL, NULL, 'Computerized Reservation System Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XR', 'PASNG', 24, NULL, 49, 0, NULL, NULL, 'Passenger Name')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RCACD1', 8, NULL, 4, 0, NULL, NULL, 'First Leg Carrier Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RJNNO1', 9, NULL, 4, 0, NULL, NULL, 'First Leg Journey Number (numeric)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RDECY1', 10, NULL, 3, 0, NULL, NULL, 'First Leg Departure City/Station Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RDEDT1', 11, NULL, 6, 0, NULL, NULL, 'First Leg Departure Date (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RDETM1', 12, NULL, 4, 0, NULL, NULL, 'First Leg Departure Time (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RARCY1', 13, NULL, 3, 0, NULL, NULL, 'First Leg Arrival City/Station Code')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RARDT1', 14, NULL, 6, 0, NULL, NULL, 'First Leg Arrival Date (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RARTM1', 15, NULL, 4, 0, NULL, NULL, 'First Leg Arrival Time (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RFAAM1', 16, NULL, 15, 0, NULL, NULL, 'First Leg Fare Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RBASI1', 17, NULL, 15, 0, NULL, NULL, 'First Leg Fare Basis')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XL', 'RCLAS1', 18, NULL, 1, 0, NULL, NULL, 'First Leg Class of Travel')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XE', 'RFDAM', 8, NULL, 15, 0, NULL, NULL, 'Restaurant Food Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XE', 'RBVAM', 9, NULL, 15, 0, NULL, NULL, 'Restaurant Beverage Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XE', 'ROTAM', 10, NULL, 15, 0, NULL, NULL, 'Restaurant Other Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XE', 'RTPAM', 11, NULL, 15, 0, NULL, NULL, 'Restaurant Tip Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TCLDT', 8, NULL, 6, 0, NULL, NULL, 'Date Of Call (YYMMDD)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TCLTM', 9, NULL, 4, 0, NULL, NULL, 'Time Of Call (HHMM)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TCLDU', 10, NULL, 5, 0, NULL, NULL, 'Call Duration (MMMSS)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TFRNO', 11, NULL, 20, 0, NULL, NULL, 'From Phone Number')
/
delete din_message_field where function_code = 'XT' and field_name = 'TFRCY'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TFRCY', 12, NULL, 26, 0, NULL, NULL, 'From Location-City')
/
delete din_message_field where function_code = 'XT' and field_name = 'TFRCO'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TFRCO', 13, NULL, 3, 0, NULL, NULL, 'From Location-Country')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TTONO', 14, NULL, 20, 0, NULL, NULL, 'To Phone Number')
/
delete din_message_field where function_code = 'XT' and field_name = 'TTOCY'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TTOCY', 15, NULL, 26, 0, NULL, NULL, 'To Location-City')
/
delete din_message_field where function_code = 'XT' and field_name = 'TTOCO'
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TTOCO', 16, NULL, 3, 0, NULL, NULL, 'To Location-Country')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TCLAM', 17, NULL, 15, 0, NULL, NULL, 'Original Charge Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XT', 'TDIAM', 18, NULL, 15, 0, NULL, NULL, 'Discount Amount')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'VCRDD', 48, NULL, 1, 1, NULL, NULL, 'Card Type')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TKNID', 49, NULL, 19, 0, NULL, NULL, 'Payment Token')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TKRQID', 50, NULL, 11, 0, NULL, NULL, 'Token Requestor ID')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TKLVL', 51, NULL, 2, 0, NULL, NULL, 'Token Assurance Level (01 - VCN Mapped to PAN and transaction enriched, 02 - VCN Mapped to PAN)')
/
update din_message_field set field_number = 46 where function_code = 'XD' and field_number = 48
/
update din_message_field set field_number = 47 where function_code = 'XD' and field_number = 49
/
update din_message_field set field_number = 48 where function_code = 'XD' and field_number = 50
/
update din_message_field set field_number = 49 where function_code = 'XD' and field_number = 51
/
update din_message_field set field_number = 48 where function_code = 'XD' and field_number = 46
/
update din_message_field set field_number = 49 where function_code = 'XD' and field_number = 47
/
update din_message_field set field_number = 50 where function_code = 'XD' and field_number = 48
/
update din_message_field set field_number = 51 where function_code = 'XD' and field_number = 49
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TRMTYP', 46, NULL, 1, 0, NULL, NULL, 'POS Terminal Type (M - Mobile POS)')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'AQGEO', 47, NULL, 3, 0, NULL, NULL, 'Acquirer Geographic Area Code')
/
delete din_message_field where function_code = 'XD' and field_number = 48
/
delete din_message_field where function_code = 'XD' and field_number = 49
/
delete din_message_field where function_code = 'XD' and field_number = 50
/
delete din_message_field where function_code = 'XD' and field_number = 51
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'VCRDD', 48, NULL, 1, 1, NULL, NULL, 'Card Type')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TKNID', 49, NULL, 19, 0, NULL, NULL, 'Payment Token')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TKRQID', 50, NULL, 11, 0, NULL, NULL, 'Token Requestor ID')
/
insert into din_message_field (function_code, field_name, field_number, format, field_length, is_mandatory, default_value, emv_tag, description) values ('XD', 'TKLVL', 51, NULL, 2, 0, NULL, NULL, 'Token Assurance Level (01 - VCN Mapped to PAN and transaction enriched, 02 - VCN Mapped to PAN)')
/
