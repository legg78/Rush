delete qpr_group where id = 1
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (1, 'Acquirer volumes', 'For report VISA Acquiring transaction volumes', NULL)
/
delete qpr_group where id = 2
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (2, 'Merchant Category Groups', 'For report VISA Merchant Category Groups', NULL)
/
delete qpr_group where id = 3
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (3, 'Merchant and Member Information', 'For report VISA Merchant and Member Information', NULL)
/
delete qpr_group where id = 4
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (4, 'Schedule F', 'For report VISA Schedule F', NULL)
/
delete qpr_group where id = 5
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (5, 'On Us Transactions', 'For report VISA Monthly Issuing', NULL)
/
delete qpr_group where id = 6
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (6, 'National Incoming', 'For report VISA Monthly Issuing', NULL)
/
delete qpr_group where id = 7
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (7, 'International Incoming', 'For report VISA Monthly Issuing', NULL)
/
delete qpr_group where id = 8
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (8, 'Monthly Issuing', 'Totals for report VISA Monthly Issuin', NULL)
/
delete qpr_group where id = 9
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (9, 'Card Issuance', 'For report VISA Card Issuance', NULL)
/
delete qpr_group where id = 10
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (10, 'Schedule A,E', 'For report VISA Schedule A/B-1 (Co-brand / Affinity Programme data)', NULL)
/
delete qpr_group where id = 200
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (200, 'Merchant acquiring', 'Merchant acquiring', NULL)
/
delete qpr_group where id = 201
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (201, 'On-Us', 'On-Us', 200)
/
delete qpr_group where id = 202
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (202, 'National', 'National', 200)
/
delete qpr_group where id = 203
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (203, 'International', 'International', 200)
/
delete qpr_group where id = 204
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (204, 'Total Transactions', 'Total Transactions', 200)
/
delete qpr_group where id = 205
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (205, 'Merchant Data', 'Merchant Data', NULL)
/
delete qpr_group where id = 206
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (206, 'Merchant Category Groups', 'Merchant Category Groups', NULL)
/
delete qpr_group where id = 207
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (207, 'Cash acquiring', 'Cash acquiring', NULL)
/
delete qpr_group where id = 208
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (208, 'On-Us', 'On-Us', 207)
/
delete qpr_group where id = 209
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (209, 'National', 'National', 207)
/
delete qpr_group where id = 210
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (210, 'International', 'International', 207)
/
delete qpr_group where id = 211
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (211, 'Total Transactions', 'Total Transactions', 207)
/
delete qpr_group where id = 212
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (212, 'ATM and Branches', 'ATM and Branches', 207)
/
delete qpr_group where id = 213
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (213, 'Co-Brand', 'Co-Brand partner', NULL)
/
delete qpr_group where id = 214
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (214, 'VISA Issuing', 'VISA Issuing', NULL)
/
delete qpr_group where id = 215
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (215, 'On-Us', 'On-Us', 214)
/
delete qpr_group where id = 216
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (216, 'National', 'National', 214)
/
delete qpr_group where id = 217
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (217, 'International', 'International', 214)
/
delete qpr_group where id = 218
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (218, 'Total Transactions', 'Total Transactions', 214)
/
delete qpr_group where id = 219
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (219, 'Number of Cards', 'Number of Cards', 214)
/
delete qpr_group where id = 220
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (220, 'Card Issuance', 'Card Issuance', 214)
/
delete qpr_group where id = 221
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (221, 'Charge-Offs', 'Charge-Offs', 214)
/
delete qpr_group where id = 222
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (222, 'Outstandings, Payments and Revolving', 'Outstandings, Payments and Revolving', 214, 8)
/
update qpr_group set priority = 11 where id = 200
/
update qpr_group set priority = 12 where id = 201
/
update qpr_group set priority = 13 where id = 202
/
update qpr_group set priority = 14 where id = 203
/
update qpr_group set priority = 15 where id = 204
/
update qpr_group set priority = 22 where id = 205
/
update qpr_group set priority = 23 where id = 206
/
update qpr_group set priority = 16 where id = 207
/
update qpr_group set priority = 17 where id = 208
/
update qpr_group set priority = 18 where id = 209
/
update qpr_group set priority = 19 where id = 210
/
update qpr_group set priority = 20 where id = 211
/
update qpr_group set priority = 21 where id = 212
/
update qpr_group set priority = 10 where id = 213
/
update qpr_group set priority = 1 where id = 214
/
update qpr_group set priority = 2 where id = 215
/
update qpr_group set priority = 3 where id = 216
/
update qpr_group set priority = 4 where id = 217
/
update qpr_group set priority = 5 where id = 218
/
update qpr_group set priority = 6 where id = 219
/
update qpr_group set priority = 7 where id = 220
/
update qpr_group set priority = 9 where id = 221
/
update qpr_group set priority = 1100 where id = 200
/
update qpr_group set priority = 1200 where id = 201
/
update qpr_group set priority = 1300 where id = 202
/
update qpr_group set priority = 1400 where id = 203
/
update qpr_group set priority = 1500 where id = 204
/
update qpr_group set priority = 2200 where id = 205
/
update qpr_group set priority = 2300 where id = 206
/
update qpr_group set priority = 1600 where id = 207
/
update qpr_group set priority = 1700 where id = 208
/
update qpr_group set priority = 1800 where id = 209
/
update qpr_group set priority = 1900 where id = 210
/
update qpr_group set priority = 2000 where id = 211
/
update qpr_group set priority = 2100 where id = 212
/
update qpr_group set priority = 1000 where id = 213
/
update qpr_group set priority = 100 where id = 214
/
update qpr_group set priority = 200 where id = 215
/
update qpr_group set priority = 300 where id = 216
/
update qpr_group set priority = 400 where id = 217
/
update qpr_group set priority = 500 where id = 218
/
update qpr_group set priority = 600 where id = 219
/
update qpr_group set priority = 700 where id = 220
/
update qpr_group set priority = 900 where id = 221
/
update qpr_group set priority = 800 where id = 222
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (232, 'V PAY Acquiring Data', 'V PAY Acquirer Data', NULL, 2200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (224, 'V PAY Acquired Electronic Commerce Transaction', 'V PAY Acquired Electronic Commerce Transaction Data', NULL, 2300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (225, 'V PAY Member And Merchant Data', 'Member And Merchant Data', NULL, 2400, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (226, 'Contactless', NULL, NULL, 2500, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (227, 'Acquired Electronic Commerce Transactions', 'Acquired Electronic Commerce Transactions Data', NULL, 2900, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (228, 'Acquired International ATM Transactions', NULL, NULL, 3000, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (229, 'Acquirer Data', NULL, NULL, 2600, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (230, 'MOTO (Mail and Telephone Order)', NULL, NULL, 2700, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (231, 'Acquired Recurring Transaction', NULL, NULL, 2800, NULL, NULL, NULL)
/
update qpr_group set group_desc = 'Member and Merchant data' where id = 225
/
update qpr_group set group_desc = 'Acquirer Data' where id = 229
/
update qpr_group set group_desc = 'Acquired International ATM Transactions' where id = 228
/
update qpr_group set group_desc = 'MOTO (Mail and Telephone Order)' where id = 230
/
update qpr_group set group_desc = 'Acquired Recurring Transactions' where id = 231
/
update qpr_group set group_desc = 'Contactless' where id = 226
/
update qpr_group set priority = 2190 where id = 229
/
update qpr_group set priority = 3100 where id = 206
/
update qpr_group set priority = 3050 where id = 226
/
update qpr_group set group_desc = 'Member and Merchant data' where id = 205
/
update qpr_group set group_desc = 'Merchant Category Group Data' where id = 206
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (233, 'Merchant Data', 'Member and Merchant data', NULL, 2200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (234, 'Merchant Category Groups', 'Merchant Category Group Data', NULL, 3100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (235, 'Visa Money Transfer', 'Visa Money Transfer', NULL, 5800, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (236, 'On-Us', 'On-Us', 235, 5900, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (237, 'National', 'National', 235, 6000, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (238, 'International', 'International', 235, 6100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (239, 'Total Transactions', 'Total Transactions', 235, 6200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (240, 'Merchant Data', 'Member and Merchant data', NULL, 3500, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (241, 'Merchant Category Groups', 'Merchant Category Group Data', NULL, 3600, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (242, 'On-Us', 'On-Us', NULL, 3100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (243, 'National', 'National', NULL, 3200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (244, 'International', 'International', NULL, 3300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (245, 'On-Us', 'On-Us', NULL, 100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (246, 'National', 'National', NULL, 200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (247, 'International', 'International', NULL, 300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (248, 'Cards and Accounts', 'Cards and Accounts', NULL, 400, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (249, 'On-Us', 'On-Us', NULL, 100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (250, 'National', 'National', NULL, 200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (251, 'International', 'International', NULL, 300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (252, 'Cards and Accounts', 'Cards and Accounts', NULL, 400, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (253, 'On-Us', 'On-Us', NULL, 100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (254, 'National', 'National', NULL, 200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (255, 'International', 'International', NULL, 300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (256, 'Cards and Accounts', 'Cards and Accounts', NULL, 400, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (257, 'Associate', 'Associate', NULL, 200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (260, 'On-Us', 'On-Us', NULL, 300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (261, 'National', 'National', NULL, 400, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (262, 'International', 'International', NULL, 500, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (263, 'Cards and Accounts', 'Cards and Accounts', NULL, 600, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (259, 'Plus', 'Plus', NULL, 400, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (264, 'Cross Border Data', 'Cross Border Data', NULL, 100, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (265, 'Cross Border Locations', 'Cross Border Locations', NULL, 200, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (266, 'Cross Border Outlets', 'Cross Border Outlets', NULL, 300, NULL, NULL, NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority, mc_rep_col_1_name, mc_rep_col_2_name, mc_rep_col_3_name) values (267, 'Acquirer Data by BAI', 'Acquirer Data by BAI', NULL, 100, NULL, NULL, NULL)
/