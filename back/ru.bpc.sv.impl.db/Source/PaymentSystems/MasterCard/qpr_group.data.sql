insert into qpr_group (id, group_name, group_desc, id_parent) values (11, 'RETAIL SALES', 'I. RETAIL SALES', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (12, 'ATM CASH ADVANCES', 'II A. ATM CASH ADVANCES', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (13, 'MANUAL CASH ADVANCES', 'II B. MANUAL CASH ADVANCES', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (14, 'CREDITS', 'III. CREDITS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (15, 'Unknown', 'UNKNOWN', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (17, 'ATM', 'IV A. ATM / TELLER ACCEPTANCE', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (18, 'MERCHANT', 'IV B. MERCHANT ACCEPTANCE', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (19, 'RETAIL', 'I. RETAIL SALES (Purchases)', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (20, 'ATM', 'II A. ATM CASH ADVANCES', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (21, 'MANUAL', 'II B. MANUAL CASH ADVANCES', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (22, 'CREDITS', 'III. CREDITS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (23, 'ACCOUNTS', 'IV. ACCOUNTS AND CARDS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (24, 'CHARGES', 'V. FINANCE CHARGES AND FEES', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (25, 'OUTSTANDINGS', 'VI. OUTSTANDINGS AND PAYMENTS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (26, 'ACCOUNTS PAY NOW', 'NUMBER OF ACCOUNTS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (27, 'CARDS PAY NOW', 'NUMBER OF CARDS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (30, 'ISSUING ATM', 'ISSUING BUSINESS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (31, 'Cash Withdrawals', 'A. Cash Withdrawals', 30)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (32, 'ACQUIRING ATM', 'ACQUIRING BUSINESS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (33, 'Cash Withdrawals', 'A. Cash Withdrawals', 32)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (34, 'Acceptance', 'B. Acceptance', 32)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (35, 'ISSUING POS', 'ISSUING BUSINESS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (36, 'Retail Sales', 'A. Retail Sales (Purchases)', 35)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (37, 'ACQUIRING POS', 'ACQUIRING BUSINESS', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (38, 'Retail Sales', 'A. Retail Sales (Purchases)', 37)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (39, 'Acceptance', 'B. Acceptance', 37)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (41, 'Card Feature Details', 'Card Feature Details', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (42, 'Card Feature Details', 'Card Feature Details', null)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (43, 'Delinquent Outstandings', 'Delinquent Outstandings', null)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (100, 'CARDHOLDER_ACTIVITY', 'I. Cardholder Activity', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (101, 'PURCHASES', 'A. Purchases', 100)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (102, 'TOTAL_CASH_ADVANCES', 'B. Total Cash Advances', 100)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (103, 'ATM_CASH_ADVANCES', 'B1. ATM Cash Advances', 102)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (104, 'MANUAL_CASH_ADVANCES', 'B2. Manual Cash Advances', 102)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (105, 'REFUNDS_RETURNS_CREDITS', 'C. Refunds / Returns / Credits', 100)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (106, 'ACCOUNTS_CARDS', 'D. Accounts/Cards', 100)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (108, 'FINANCE_CHARGES_FEES', 'II. Finance Charges and Fees', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (109, 'CHARGED_OFF_LOSSES', 'III. Charged-Off Losses', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (110, 'CREDIT_LOSSES', 'A. Credit Losses (excluding bankruptcy losses)', 109)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (111, 'BANKRUPTCY_LOSSES', 'B. Bankruptcy Losses', 109)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (112, 'FRAUD_LOSSES', 'C. Fraud Losses (including counterfeit losses)', 109)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (113, 'OTHER_LOSSES', 'D. Other Losses', 109)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (114, 'TOTAL_CHARGED_OFF_LOSSES', 'E. Total Charged-Off Losses', 109)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (115, 'CARD_FEATURE_DETAILS', 'IV. Card Feature Details', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (116, 'MAESTRO_PURCHASE_RETAIL_SALES_ACTIVITY', 'I. Maestro Purchase (Retail Sales) Activity', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (117, 'MAESTRO_CASH_DISBURSEMENTS_ATM_ACTIVITY', 'II. Maestro Cash Disbursements (ATM) Activity', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (118, 'ACCOUNTS_AND_CARDS', 'III. Accounts and Cards', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (119, 'MAESTRO_CARDS', 'A. Maestro Cards', 118)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (120, 'MAESTRO_ACCOUNTS', 'B. Maestro Accounts', 118)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (121, 'DETAIL_ACTIVITY_BREAKOUT', 'IV. Detail Activity Breakout', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (122, 'CARD_FEATURE_DETAILS', 'IV. Card Feature Details', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (123, 'RETAIL_SALES_PURCHASES', 'I. Retail Sales (Purchases)', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (124, 'TOTAL_CASH_ADVANCES', 'II. Total Cash Advances', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (125, 'ATM_CASH_ADVANCES', 'IIA. ATM Cash Advances', 124)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (126, 'MANUAL_CASH_ADVANCES', 'IIB. Manual Cash Advances', 124)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (127, 'REFUNDS_RETURNS_CREDITS', 'III. Refunds / Returns / Credits', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (128, 'ACCEPTANCE', 'IV. Acceptance', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (129, 'CASH_DISBURSEMENT_LOCATIONS', 'A. Cash Disbursement Locations', 128)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (130, 'MERCHANTS', 'B. Merchants', 128)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (131, 'MAESTRO_ACQUIRING_PURCHASE_ACTIVITY', 'I. Maestro Acquiring Purchase (Retail Sales) Activity', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (132, 'MAESTRO_ACQ_CASH_DISB_ACTIVITY', 'II. Maestro Acquiring Cash Disbursements (ATM) Activity', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (133, 'MAESTRO_ACCEPTANCE', 'III. Maestro Acceptance', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (134, 'DETAIL_ACQ_ACTIVITY_BREAKOUT', 'IV. Detail Acquiring Activity Breakout', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (135, 'CIRRUS_ACQ_CASH_DISB_ACTIVITY', 'I. Cirrus Acquiring Cash Disbursements (ATM) Activity', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (136, 'CIRRUS_ACCEPTANCE', 'II. Cirrus Acceptance', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent) values (137, 'DETAIL_ACQ_ACTIVITY_BREAKOUT', 'III. Detail Acquiring Activity Breakout', NULL)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (138, 'PURCHASES_LOCAL_USE_ONLY', 'Purchases on Local-Use Only Cards', 101, 3)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (139, 'TOTAL_CASH_ADVANCES_LOCAL_USE_ONLY', 'Total Cash Advances on Local-Use Only Cards', 102, 5)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (140, 'ATM_CASH_ADVANCES_LOCAL_USE_ONLY', 'ATM Cash Advances on Local-Use Only Cards', 103, 7)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (141, 'MANUAL_CASH_ADVANCES_LOCAL_USE_ONLY', 'Manual Cash Advances on Local-Use Only Cards', 104, 9)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (142, 'REFUNDS_RETURNS_CREDITS_LOCAL_USE_ONLY', 'Refunds / Returns / Credits on Local-Use Only Cards', 105, 11)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (143, 'ACCOUNTS_CARDS_LOCAL_USE_ONLY', 'Accounts and Cards Local-Use Only', 106, 13)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (144, 'OUTSTANDINGS', 'II. Outstandings', NULL, 14)
/
insert into qpr_group (id, group_name, group_desc, id_parent, priority) values (145, 'TOTAL_OUTSTANDINGS', 'A. Total Outstandings', 144, 15)
/
update qpr_group set priority = 1 where id = 100
/
update qpr_group set priority = 2 where id = 101
/
update qpr_group set priority = 4 where id = 102
/
update qpr_group set priority = 6 where id = 103
/
update qpr_group set priority = 8 where id = 104
/
update qpr_group set priority = 10 where id = 105
/
update qpr_group set priority = 12 where id = 106
/
update qpr_group set priority = 16 where id = 109
/
update qpr_group set priority = 17 where id = 112
/
update qpr_group set priority = 18 where id = 113
/
update qpr_group set priority = 19 where id = 114
/
update qpr_group set priority = 20 where id = 115
/
update qpr_group set group_desc = 'A. Fraud Losses (including counterfeit losses)' where id = 112
/
update qpr_group set group_desc = 'B. Other Losses' where id = 113
/
update qpr_group set group_desc = 'C. Total Charged-Off Losses' where id = 114
/
update qpr_group set priority = 51 where id = 116
/
update qpr_group set priority = 52 where id = 117
/
update qpr_group set priority = 53 where id = 118
/
update qpr_group set priority = 54 where id = 119
/
update qpr_group set priority = 55 where id = 120
/
update qpr_group set priority = 56 where id = 121
/
update qpr_group set priority = 57 where id = 122
/
update qpr_group set priority = 100 where id = 100
/
update qpr_group set priority = 200 where id = 101
/
update qpr_group set priority = 400 where id = 102
/
update qpr_group set priority = 600 where id = 103
/
update qpr_group set priority = 800 where id = 104
/
update qpr_group set priority = 1000 where id = 105
/
update qpr_group set priority = 1200 where id = 106
/
update qpr_group set priority = 1600 where id = 109
/
update qpr_group set priority = 1700 where id = 112
/
update qpr_group set priority = 1800 where id = 113
/
update qpr_group set priority = 1900 where id = 114
/
update qpr_group set priority = 2000 where id = 115
/
update qpr_group set priority = 5100 where id = 116
/
update qpr_group set priority = 5200 where id = 117
/
update qpr_group set priority = 5300 where id = 118
/
update qpr_group set priority = 5400 where id = 119
/
update qpr_group set priority = 5500 where id = 120
/
update qpr_group set priority = 5600 where id = 121
/
update qpr_group set priority = 5700 where id = 122
/
update qpr_group set priority = 300 where id = 138
/
update qpr_group set priority = 500 where id = 139
/
update qpr_group set priority = 700 where id = 140
/
update qpr_group set priority = 900 where id = 141
/
update qpr_group set priority = 1100 where id = 142
/
update qpr_group set priority = 1300 where id = 143
/
update qpr_group set priority = 1400 where id = 144
/
update qpr_group set priority = 1500 where id = 145
/
-- Mastercard
insert into qpr_group(id, group_name, group_desc, id_parent, priority ) values (223, 'Breakdown of Cash Disbursements', 'Breakdown of Cash Disbursements', 102, 450)
/
update qpr_group t set t.group_name = 'Card Feature Details', t.group_desc = 'III. Card Feature Details' where id = 115
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Transactions', t.mc_rep_col_3_name = 'Volume' where id = 101
/
update qpr_group t set t.mc_rep_col_1_name = 'Open', t.mc_rep_col_2_name = 'Blocked', t.mc_rep_col_3_name = 'Total' where id = 106
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Accounts', t.mc_rep_col_3_name = 'Volume' where id = 112
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Accounts', t.mc_rep_col_3_name = 'Volume' where id = 113
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Accounts', t.mc_rep_col_3_name = 'Volume' where id = 114
/
update qpr_group t set t.mc_rep_col_1_name = 'Cards', t.mc_rep_col_2_name = 'Transactions', t.mc_rep_col_3_name = 'Volume' where id = 115
/
-- Maestro
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Transactions', t.mc_rep_col_3_name = 'Volume' where id = 116
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Transactions', t.mc_rep_col_3_name = 'Volume' where id = 117
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = null, t.mc_rep_col_3_name = 'Total' where id = 119
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Transactions', t.mc_rep_col_3_name = 'Volume' where id = 121
/
update qpr_group t set t.group_desc = 'V. Card Feature Details', t.mc_rep_col_1_name = 'Cards', t.mc_rep_col_2_name = 'Transactions', t.mc_rep_col_3_name = 'Volume' where id = 122
/
-- All Acquiring
update qpr_group set priority = 100 where id = 123
/
update qpr_group set priority = 200 where id = 124
/
update qpr_group set priority = 300 where id = 125
/
update qpr_group set priority = 400 where id = 126
/
update qpr_group set priority = 500 where id = 127
/
update qpr_group set priority = 600 where id = 128
/
update qpr_group set priority = 700 where id = 129
/
update qpr_group set priority = 800 where id = 130
/
update qpr_group set priority = 100 where id = 131
/
update qpr_group set priority = 200 where id = 132
/
update qpr_group set priority = 300 where id = 133
/
update qpr_group set priority = 400 where id = 134
/
update qpr_group set priority = 100 where id = 135
/
update qpr_group set priority = 200 where id = 136
/
update qpr_group set priority = 300 where id = 137
/
-- Acquiring MasterCard
update qpr_group t set t.mc_rep_col_1_name = 'Transactions', t.mc_rep_col_2_name = 'Volume', t.mc_rep_col_3_name = null where id = 123
/
update qpr_group t set t.mc_rep_col_1_name = 'Transactions', t.mc_rep_col_2_name = 'Volume', t.mc_rep_col_3_name = null where id = 124
/
update qpr_group t set t.mc_rep_col_1_name = 'Transactions', t.mc_rep_col_2_name = 'Volume', t.mc_rep_col_3_name = null where id = 127
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Total', t.mc_rep_col_3_name = null where id = 129
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Total', t.mc_rep_col_3_name = null where id = 130
/

-- Acquiring Maestro
update qpr_group t set t.mc_rep_col_1_name = 'Transactions', t.mc_rep_col_2_name = 'Volume', t.mc_rep_col_3_name = null where id = 131
/
update qpr_group t set t.mc_rep_col_1_name = 'Transactions', t.mc_rep_col_2_name = 'Volume', t.mc_rep_col_3_name = null where id = 132
/
update qpr_group t set t.mc_rep_col_1_name = null, t.mc_rep_col_2_name = 'Total', t.mc_rep_col_3_name = null where id = 133
/
update qpr_group t set t.mc_rep_col_1_name = 'Transactions', t.mc_rep_col_2_name = 'Volume', t.mc_rep_col_3_name = null where id = 134
/

